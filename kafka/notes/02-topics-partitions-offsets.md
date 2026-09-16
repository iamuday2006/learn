# 02 — Topics, Partitions, Offsets (P0)

> Source: *Kafka: The Definitive Guide* Ch. 1 ("Topics and Partitions", "Producers and Consumers") + Ch. 6 (replication effects on partitions). This is **the** core interview topic — most P0 questions reduce to these three concepts.

---

## 1. Topic

A **topic** is a logical, named stream of records — like a table name, except it is an **append-only log**, not queryable storage.

- Topics are **append-only**: producers add to the end; nothing is modified.
- Kafka does **NOT delete a message when a consumer reads it** (top-3 interview trap). Records stay until a **retention policy** (time/size) or compaction removes them.
- Multiple **consumer groups** can read the same topic independently — each group has its own offsets.
- Creating a topic decisions: **partition count**, **replication factor**, **retention/cleanup policy**. These three are the levers you justify in a design question.

```text
orders  payments  users  click-events  weather-events
```

## 2. Partition — the most important concept

A partition is an **ordered, append-only log** — the unit of storage, parallelism, and ordering in Kafka.

```text
Partition 0 of topic "orders"
offset:  0        1        2        3        4
        order-A  order-B  order-C  order-D  order-E   (append happens at the right end)
```

### Why partitions exist

| Benefit | Mechanism |
|---|---|
| **Parallelism** | One consumer per partition at a time; N partitions = max N active consumers in a group |
| **Scalability** | Partitions spread across brokers; more partitions → more write throughput |
| **Distribution** | Each partition lives on a broker (plus replicas on others) |
| **Ordering boundary** | Ordering is guaranteed *within* a partition only |

### The critical ordering rule (memorize this phrasing)

> **Kafka guarantees ordering only within a partition. There is no global ordering across partitions.**

If a producer writes `order-C` to P0 and `order-B` to P1, a consumer reading both partitions may see C before B. Nothing in Kafka will reorder that for you.

### Partition selection — how does Kafka pick?

When a producer sends a record:

1. **Key present** → `partition = hash(key) % num_partitions` (murmur2 in the Java client). Same key ⇒ same partition (as long as partition count doesn't change) ⇒ ordered per key.
2. **No key** → **round-robin/sticky partitioner**: spreads evenly for load balancing, but **no ordering** for related events.
3. **Explicit partition** in the record → used directly (rare; for special tooling).

### Partition key — ordering by entity

```text
customer_id = 101  →  key = "101"  →  always partition 2
  event1 → offset 0
  event2 → offset 1
  event3 → offset 2     ← consumer reading P2 sees 0,1,2 in order
```

- Use a key whenever **events for one entity must be processed in order** (per-customer, per-order, per-account, per-device).
- **Skew risk**: a hot key (one giant customer) makes one partition huge while others idle → uneven consumer load. Mitigate by salting keys (`key + shard-number`) or designing for per-key ordering only.
- **Changing partition count breaks key→partition mapping** — new keys (and rehashed old keys) route to different partitions; per-key ordering can break during/after the change. This is why you over-provision partitions at creation time.

### Model answer: "What is a partition?" (from TODO.md §39)

> "A partition is an ordered append-only log inside a Kafka topic. Kafka divides a topic into partitions to distribute data across brokers and enable parallel processing. Each record gets an offset within the partition, and ordering is guaranteed within that partition. A partition key keeps related events together. So partitions provide both scalability and the ordering boundary."

### Interview questions

1. **Why does Kafka use partitions?** — Parallelism + scalability + distribution; partitions are the unit of parallel read/write; they also bound ordering.
2. **What determines which partition a record goes to?** — Hash of the key; round-robin/sticky if no key; explicit partition if set.
3. **What happens with no key?** — Even spread, no per-entity ordering.
4. **Is ordering global?** — No. Only within a partition. This kills global ordering by design (trade-off for scale).
5. **Guarantee ordering for one customer?** — Key by `customer_id` so all their events land on one partition; single consumer per partition processes them sequentially.
6. **Can a partition move between brokers?** — Replicas can be reassigned (leader moves via election/reassignment); the *data* (log) is copied to the new broker during reassignment.
7. **More consumers than partitions?** — Extra consumers sit **idle** (no partitions assigned). Parallelism cap = partition count. (Classic P0 question.)

### Partition count: how to choose (very common design question)

More partitions = more parallelism & throughput, BUT:

- more open file handles & replication traffic,
- more leader elections on broker failure (longer recovery),
- larger end-to-end commit latency for `acks=all` (more replicas to wait on),
- **cannot decrease** without recreating the topic; increasing breaks key→partition mapping.

Rule of thumb for interviews: *target per-partition throughput you can consume; partition for expected peak + headroom, not for today's average.* Don't quote magic numbers; show the trade-off.

## 3. Offsets

An **offset** is the sequential ID of a record **within one partition** — the record's position in that log.

```text
Partition 0:   0→A  1→B  2→C  3→D  4→E
Partition 1:   0→F  1→G  2→H
```

Key facts:

- **Offset is scoped to a partition** — `(topic, partition, offset)` is the globally unique address of a record. Two partitions can both contain offset 100. (Top trap question: "Is an offset globally unique?" — NO.)
- Offsets are immutable once written; they are long (up to 64-bit).
- Consumers track their **position** per partition; they **commit** that position so a restart resumes from there.

### Committed offset vs current position

- **Current position**: the next record the consumer will fetch (in-memory, per poll).
- **Committed offset**: last position saved to Kafka's internal `__consumer_offsets` topic, per (group, topic, partition).
- On restart, the consumer resumes from the **committed** offset. If nothing was committed → `auto.offset.reset` decides.

### `auto.offset.reset` (know all three values)

| Value | When no committed offset exists | Use case |
|---|---|---|
| `earliest` | Start from the beginning of the log | Analytics/backfills that must see history |
| `latest` | Start from the end; only new records | Real-time alerting; skip old backlog |
| `none` | Throw exception to the consumer (you handle it) | Want to fail fast and decide manually |

Trap: `auto.offset.reset` only applies when there is **no valid committed offset** — e.g., brand-new group, or committed offset was evicted (offsets.retention). If an offset exists but points to data already deleted by retention, behavior also falls back to the reset policy.

### Interview questions

1. **What is an offset?** — Sequential, immutable position of a record within a partition; how consumers track progress.
2. **Is an offset globally unique?** — No; unique per partition. Global address = (topic, partition, offset).
3. **Can two partitions have offset 100?** — Yes, absolutely.
4. **What happens after a consumer crashes?** — New consumer in the group resumes from the **committed** offset for each partition → may reprocess uncommitted work (duplicates → at-least-once).
5. **How does a consumer resume processing?** — Look up committed offset for its partitions; if none/invalid, apply `auto.offset.reset`.
6. **Who stores committed offsets?** — Kafka itself, in the internal compacted topic `__consumer_offsets` (replicated like any topic).

## 4. Putting it together — mental model

```text
Topic "orders" (4 partitions, RF=3)

P0: [0:A][1:B][2:C]...     leader on broker1, followers on broker2,3
P1: [0:D][1:E][2:F]...     leader on broker2
P2: [0:G][1:H]...          leader on broker3
P3: [0:I][1:J]...          leader on broker1

Producer: key=order_id → hash → P0..P3
Consumer group: C1←P0,P1   C2←P2,P3   (parallelism ≤ 4)
```

- Topic = logical name; partitions = physical parallel logs; offsets = positions within each.
- Add partitions → add parallelism, but see the key-mapping caveat above.

## 5. Failure cases

- **Partition count increased** → new records keyed with existing keys may route to new partitions → per-key ordering breaks; consumers must rebalance to cover new partitions.
- **Hot key / skewed partition** → one partition & its consumer lag while others idle.
- **Replica failure** → if leader dies, an ISR follower takes over (see `05-reliability.md`); partition temporarily unavailable for writes (usually sub-second to seconds).
- **Retention deletes data behind a slow consumer** → consumer's committed offset points to deleted segment → reset per `auto.offset.reset` (data gap or reprocessing decision).

## 6. Hands-on (lab)

```bash
# From repo root — ./k.sh runs the CLI inside the lab container (see lab/README.md)
lab/k.sh kafka-topics.sh --bootstrap-server localhost:9092 --create --topic orders \
  --partitions 4 --replication-factor 1
# inspect partition layout
lab/k.sh kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic orders
# send keyed records, watch them land on consistent partitions
lab/k.sh kafka-console-producer.sh --bootstrap-server localhost:9092 --topic orders \
  --property parse.key=true --property key.separator=:
# read per-partition with offsets shown
lab/k.sh kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic orders \
  --from-beginning --property print.partition=true --property print.offset=true
```

Try: send 5 records with the same key, then describe partitions — note all landed on one partition.
