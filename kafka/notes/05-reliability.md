# 05 — Reliability: Replication, ISR, Delivery Semantics (P0)

> Source: *Kafka: The Definitive Guide* Ch. 6 "Reliable Data Delivery" (Replication, Unclean Leader Election, Minimum In-Sync Replicas, Configuring Producers/Consumers for reliability) + Ch. 7 for exactly-once/transactions. This chapter is the "what happens when something fails" core of every interview.

---

## 1. Replication (P0)

Every partition is replicated across N brokers (**replication factor, RF = N**). One replica is the **leader**; the rest are **followers**.

```text
Partition P0 (RF=3)

Broker 1: LEADER   ← all reads + writes
    |  fetch
    +──▶ Broker 2: follower
    |
    +──▶ Broker 3: follower
```

- **Leader** serves ALL produce/fetch requests for the partition. Followers never serve clients (in the base design).
- **Followers** constantly fetch from the leader to stay in sync — replication is pull-based.
- **RF=3** is the production norm: survive 1 broker failure with `min.insync.replicas=2` and still take writes.
- Replication unit = **log segments** copied batch-by-batch (not per record).

### Why replication matters

Brokers are machines; disks die. Without replicas, a broker death = data loss. Replication makes broker failure an **availability event, not a data-loss event** (with correct config).

### Interview questions

1. **What is replication?** — Keeping N copies of each partition across brokers; leader serves, followers fetch.
2. **Why does Kafka need replication?** — Fault tolerance: broker failure must not lose data or permanently stop the pipeline.
3. **Can the follower serve reads?** — In standard Kafka, no; only the leader. (Mention it as a known design trade-off for simplicity/consistency.)
4. **RF=3 with min.insync.replicas=2 — what do you get?** — Survive 1 broker failure with no acked-data loss AND no write outage. If 2 of 3 fail → writes stop (durability protection).

## 2. Leader election & broker failure scenario (P0)

> Broker 1 holds the leader for Partition 0 and dies. What happens? (TODO.md §18)

1. **What happens to the leader?** — It's gone; partition has no active leader temporarily.
2. **What happens to followers?** — They keep fetching (failing) and remain in ISR as long as their fetches were recent.
3. **How is a new leader selected?** — The **controller** (broker/KRaft controller that watches broker failures) picks a new leader **from the ISR** — the replica guaranteed to have everything acked before the failure.
4. **What happens to producers?** — Get `NOT_LEADER_FOR_PARTITION` on the next send → refresh metadata → resend to the new leader. Brief latency spike; idempotence protects against duplicates from those retries.
5. **What happens to consumers?** — Same: refresh metadata, resume fetching from the new leader at their committed offset.

**Unclean leader election** (`unclean.leader.election.enable=false` by default):
- If **no ISR replica** is alive: with unclean election disabled → partition unavailable (correctness over availability). If enabled → an out-of-sync replica becomes leader → **acks acked before the failure are lost**. Know this trade-off by name.

## 3. ISR — In-Sync Replicas (P0)

ISR = the set of replicas **currently fully caught up** with the leader (within `replica.lag.time.max.ms`, default 30s).

```text
Partition P0
Leader
 +-- Replica A   ← ISR (caught up)
 +-- Replica B   ← ISR (caught up)
 +-- Replica C   ← NOT in ISR (lagging > replica.lag.time.max.ms)
```

- "In sync" = the follower has fetched the latest records within the lag window. It does NOT mean real-time-identical to the millisecond.
- A lagging follower is **removed from ISR**; when it catches up, it **rejoins** ISR automatically.
- **`acks=all` means "wait for all *current* ISR members"** — not all RF replicas. This is the subtle part interviewers probe.

### The key interaction (TODO.md §19)

> What if `acks=all` is used and ISR falls below `min.insync.replicas`?

- The broker **rejects produces** with `NotEnoughReplicasException` until ISR recovers.
- This is **intentional**: Kafka chooses durability over availability. Better to stop accepting writes than to write to too few replicas and risk losing acked data.
- Availability–durability trade-off sentence: *"With RF=3, min.insync.replicas=2: one broker can fail with zero impact; two failures stop writes but lose nothing. Lowering min.insync.replicas to 1 buys availability at the cost of potential acked-data loss."*

### Gotcha interviewers love

**`acks=all` with `min.insync.replicas=1` and RF=3** — if two replicas are down/lagging, `acks=all` degrades to "ack from 1 replica" → almost `acks=1` durability. **`acks=all` is only as strong as min.insync.replicas.** Say this sentence.

## 4. Delivery semantics (P0 — the crown jewel topic)

Three paradigms, defined by **when you commit relative to processing**:

### At-most-once
```text
commit offset → process record
```
- Record processed 0 or 1 times — may be **lost** if processing crashes after commit, never duplicated.
- Implementation: commit early (auto-commit high-frequency or commit-on-receive). Use when loss is tolerable (metrics, tick data) and you need speed.

### At-least-once
```text
process record → commit offset
```
- Record processed 1+ times — never lost, but **duplicates** when a crash happens between processing and commit.
- Implementation: manual commit **after** processing (per batch). The default engineering choice because **duplicates are cheaper to handle than loss** — you make downstream effects idempotent.
- Idempotent downstream examples: `INSERT ... ON CONFLICT (id) DO NOTHING`, upsert by event id, dedupe table with processed-ids, idempotent REST (client-generated request id).

### Exactly-once
- **The externally visible effect happens exactly once** — not "code runs once" but "the result is as if once."
- Say the nuanced sentence: *"Kafka does not automatically give you exactly-once everywhere. Kafka provides the building blocks — idempotent producer, transactions, read-committed consumers, and Kafka Streams' transactional state management — and EOS is achievable end-to-end when producer, Kafka, and consumer/app all cooperate."*

The EOS toolbox (P1/P2):
| Tool | Guarantees |
|---|---|
| Idempotent producer | No retry duplicates **per partition, per producer session** |
| Transactions (producer) | Atomic write across **multiple partitions** + atomic offset commit for consume-transform-produce loops |
| `read_committed` consumers | Skip aborted/uncommitted transactional records |
| Kafka Streams | Transactions by default: commit = atomic (output + offsets + state store changelog) |
| Beyond Kafka (external sinks) | Must be idempotent or transactional on their side (e.g., sink connectors with upsert) |

### Crash-timing scenarios — connect the dots

```text
process → crash → no commit        → reprocess (at-least-once)
commit → crash → no process        → skipped   (at-most-once)
process → external write → crash before commit → duplicate external effect
```

That last line is exactly why at-least-once + idempotent sinks is the standard pattern.

## 5. Configuring for reliability (book Ch.6 checklist)

**Broker/Topic:**
- `replication.factor=3`
- `min.insync.replicas=2`
- `unclean.leader.election.enable=false` (never lose acked data to a stale replica)

**Producer:**
- `acks=all`
- `enable.idempotence=true` (implies acks=all, retries>0, in-flight≤5)
- `retries` generous within `delivery.timeout.ms`
- handle send-callback errors (log + dead-letter or block)

**Consumer:**
- `enable.auto.commit=false` + commit after processing (at-least-once) — or design at-most-once deliberately
- handle rebalance callbacks: commit before partitions are revoked
- idempotent processing downstream regardless

## 6. Failure cases recap

- Leader fails pre-replication with `acks=1` → acked record lost.
- ISR shrunk below min.insync.replicas → writes fail (availability hit by design).
- Unclean leader election → data loss from stale leader.
- Crash between external side-effect and commit → duplicate effect even with at-least-once (fix: idempotent sink or transactions).
- Producer restart mid-retry → new PID → duplicates possible (transactions fix this).

## 7. Interview questions

1. **Explain ISR.** — Replicas caught up within replica.lag.time.max.ms; membership is dynamic; acks=all waits on ISR not RF.
2. **What is min.insync.replicas for?** — Durability floor: minimum ISR required to accept writes; protects acks=all from degrading to acks=1.
3. **Broker dies — walk me through recovery.** — Controller detects → elects new leader from ISR → producers/consumers refresh metadata and reconnect → partitions fully available once election completes.
4. **Explain at-least-once vs at-most-once vs exactly-once.** — Commit-vs-process ordering + idempotence; EOS via transactions + read_committed.
5. **Is Kafka exactly-once?** — "Kafka provides EOS building blocks; end-to-end EOS requires the whole chain (producer transactions, broker, consumer read_committed, idempotent sinks)."
6. **How do you make a consumer pipeline idempotent?** — Dedupe keys, upserts, ON CONFLICT, processed-id table, transactional sink.
7. **RF=3, min.insync.replicas=2, one broker down — what breaks?** — Nothing; writes and reads continue. Two down → writes rejected, reads still served by remaining leader if it's alive.
