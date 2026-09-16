# 03 — Producers: Acks, Retries, Idempotence, Batching (P0/P1)

> Source: *Kafka: The Definitive Guide* Ch. 3 "Kafka Producers: Writing Messages to Kafka" + Ch. 6 (reliability configuration). The `acks` + idempotence + ISR story is the most-tested producer chain.

---

## 1. Producer internal flow (draw this)

```text
Application
    |  producer.send(record)          ← asynchronous
    v
Serializer            key/value → bytes  (must match consumer's deserializer)
    |
Partitioner           key → partition (hash / sticky / explicit)
    |
Accumulator (RecordAccumulator)
    |  buffers per-partition batches
    |  batch ready when batch.size full OR linger.ms elapsed
    v
Sender thread
    |  compress (optional) → send batch to partition leader
    v
Broker leader  ──replicates──▶ followers
    |
ack from leader (+ in-sync replicas per acks)
    |
producer future/callback completes
```

Key insight to say out loud: **`send()` is asynchronous.** It appends to an in-memory buffer and returns a future; a background sender thread does the network I/O and batching. That's where both throughput and failure behavior come from.

## 2. Serialization

- Producers convert objects → bytes (`StringSerializer`, `AvroSerializer`, ...); consumers must use the **matching deserializer**.
- Wrong serializer/deserializer pair = garbage or exceptions downstream — the classic "schema" interview hook (see `07-ecosystem.md`).
- Prefer a **schema registry + Avro/Protobuf** over raw JSON in production: compact binary, explicit schema, compatibility enforcement.

## 3. Partition selection (recap from 02)

1. Key present → `hash(key) % partitions` — same key ⇒ same partition ⇒ per-key ordering.
2. No key → sticky/round-robin partitioner spreads load evenly.
3. Explicit partition → used as-is.
- **Changing partition count breaks the key→partition mapping** (rehashing) — mention this in any design question about scaling partitions.

## 4. Batching and compression (P1 — performance questions)

| Setting | What it does | Trade-off |
|---|---|---|
| `batch.size` | Max bytes per batch **per partition** | Bigger = better throughput, more latency + memory |
| `linger.ms` | Wait up to N ms to fill a batch before sending | Bigger = bigger batches/throughput, higher latency |
| `buffer.memory` | Total memory for unsent records | Full buffer → `send()` blocks (or times out) — a **backpressure signal** |
| `compression.type` | `none/gzip/snappy/lz4/zstd` | CPU spent to save network+storage; producer-side compression means broker stores compressed, consumer decompresses |

Explain-the-mechanism answer: *"Batching amortizes network round-trips and lets Kafka write big sequential blocks; `linger.ms` trades a few ms of latency for much higher throughput. Compression shrinks the batch before it hits the network and disk — broker stores it compressed, so savings apply to replication and retention too."*

## 5. Acks — durability vs latency (P0)

| Setting | Behavior | Risk | Latency |
|---|---|---|---|
| `acks=0` | Fire-and-forget; producer doesn't wait | Records lost on any failure before broker write | Lowest |
| `acks=1` | **Leader** writes locally, then acks | Leader crashes **before followers replicate** → record lost when new leader elected | Medium |
| `acks=all` | Leader waits until all **ISR** replicas have the record | Safe as long as ISR ≥ `min.insync.replicas`; if ISR shrinks below it, produce fails (by design) | Highest |

### The interview question (TODO.md §10)

> "Why is `acks=all` generally safer than `acks=1`?"

Model answer:

> "With `acks=1`, only the leader has the record when the ack is sent. If the leader dies immediately after — before followers fetch the record — the new leader (elected from ISR) never received it, and the record is lost even though the producer got a success. With `acks=all`, the leader acks only after every in-sync replica has the record, so a leader failure can't lose acked data. `acks=all` is really 'ack to all in-sync replicas', and its strength depends on `min.insync.replicas` — with RF=3 and `min.insync.replicas=2`, you survive one broker failure without losing acked data. If the ISR shrinks below the minimum, the broker rejects writes to protect durability — that's the availability-for-durability trade-off."

Chain to say fluently: **acks=all → ISR → min.insync.replicas → RF=3, min.isr=2 → "one broker can fail without data loss or write outage."**

## 6. Producer retries → duplicates (P0)

Failure mode (TODO.md §11):

```text
Producer ──record──▶ Broker: record accepted, replicated
                 X ack response lost (network blip)
Producer thinks send failed
    |
    v  retries
Broker now has the record TWICE   ← duplicate
```

- Retries are **necessary** for reliability but create duplicates when the ack is lost, not the write.
- Old behavior: `retries=0` to avoid duplicates = fragile (any transient error loses data).

## 7. Idempotent producer (P0)

`enable.idempotence=true` (default in modern clients, requires `acks=all`, `retries>0`, `max.in.flight≤5`):

- Broker assigns the producer a **Producer ID (PID)**; each (PID, partition) stream gets **sequence numbers**.
- Broker keeps the last sequence per (PID, partition): a **retry** of the same batch is recognized and **deduplicated**; out-of-order batches are rejected.
- Result: **exactly-once per partition per producer session** (no duplicates, no reordering on retry).
- Boundaries to state (this is where candidates impress):
  - Scope is **one producer session** — a producer restart gets a new PID → duplicates possible across restarts (unless using transactions).
  - Scope is **per partition** — no cross-partition atomicity (that's transactions).
  - It does **not** deduplicate consumer-side effects downstream.

## 8. `max.in.flight.requests.per.connection`

- How many unacked batches can be in flight per broker connection.
- >1 + retries used to allow reordering after a failed batch; **idempotence guarantees ordering** by rejecting out-of-sequence batches, so with `enable.idempotence=true` you can keep `max.in.flight ≤ 5` and still preserve order.

## 9. Producer configs summary (know what each changes)

```text
acks                          durability vs latency
retries                       transient-error resilience (can duplicate without idempotence)
enable.idempotence            dedupe broker-side retries; per-partition, per-session
batch.size / linger.ms        throughput vs latency
buffer.memory                 producer backpressure behavior
compression.type              network/disk savings vs CPU
max.in.flight.requests...     ordering under retries (safe ≤5 with idempotence)
max.block.ms                  how long send() blocks when buffer full
```

"Do not memorize values without knowing what they change" — always pair a config with its trade-off.

## 10. Failure cases

- **Buffer full** (`buffer.memory` exhausted, slow broker) → `send()` blocks up to `max.block.ms`, then exception → your app must handle backpressure.
- **Non-retriable error** (e.g., message too large, serialization) → fails immediately, does not retry — check callback/future errors.
- **Retriable error exhausted retries** → exception in callback → decide: drop, dead-letter, or block.
- **Leader change mid-batch** → producer refreshes metadata, re-sends to new leader; idempotence prevents duplicates on that retry.
- **Idempotence + `acks=all` + `min.insync.replicas` violation** → produce fails with `NotEnoughReplicasException` — durability protection working as intended.

## 11. Scenario (TODO.md §12) — payment event, lost ack, retry

> Kafka accepted a payment event; the ack was lost; the producer retries.

1. **What can go wrong?** The write actually succeeded; the retry creates a **duplicate** payment event downstream.
2. **Why duplicates?** The producer cannot distinguish "write failed" from "ack lost" — it must retry to avoid data loss, and retries without dedupe duplicate.
3. **How does idempotence help?** Broker tracks (PID, partition, sequence); the retried batch is recognized and stored once. Enables at-least-once **without** retry-induced duplicates.
4. **Still need downstream idempotency** for: producer restarts (new PID), cross-partition atomicity (transactions), and consumer-side reprocessing (at-least-once semantics) — e.g., dedupe by `payment_id` at the sink.

## 12. Interview questions

1. **Explain acks=0/1/all.** — Table in §5 + the leader-failure story for acks=1.
2. **Why does `acks=all` need `min.insync.replicas`?** — If all replicas die but one, `acks=all` + `min.isr=1` would ack on a single (possibly stale) replica; min.isr enforces the durability floor and fails writes when ISR is too small.
3. **What does idempotent producer guarantee?** — No duplicates/no reordering from producer retries, per partition, per producer session.
4. **Why do producers batch?** — Amortize round-trips; bigger sequential disk writes; compression efficiency. Controlled by `batch.size` + `linger.ms`.
5. **How does compression help? Is it free?** — Shrinks network + disk (incl. replicas); costs producer CPU; consumer pays decompression.
6. **What happens if the producer can't reach the broker?** — Metadata refresh fails → retriable errors with backoff until `delivery.timeout.ms` exceeded → callback error.

## 13. Hands-on (lab)

- `lab/weather-pipeline/producer.py` — key by `city` (ordering per city), observe partition assignment.
- Break it: set `acks=1` against a 1-broker lab and kill the broker mid-send (accept that RF=1 lab loses data — that's the point of the demo).
- CLI practice: `kafka-console-producer.sh --property parse.key=true --property key.separator=:`.
