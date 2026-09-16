# 04 — Consumers: Poll Loop, Consumer Groups, Commits, Rebalancing, Lag (P0)

> Source: *Kafka: The Definitive Guide* Ch. 4 "Kafka Consumers: Reading Data from Kafka". Consumer groups + rebalancing + commits are the most common P0 deep-dive questions.

---

## 1. Consumer flow

```text
Kafka
  |
  v
Consumer loop:
  poll()            ← fetch batches from assigned partitions
  |  deserialize    ← must match producer's serializer
  |  process        ← your business logic
  |  commit offset  ← when? = delivery semantics decision
  └── loop (poll again)
```

- Consumers **pull**. `poll()` returns records from all assigned partitions, up to `max.poll.records`.
- Kafka never pushes to a consumer; a dead consumer's partitions simply stop being read.
- Consumers **never delete** data — reading has no effect on the log; other groups read independently.

## 2. Consumer groups (P0, top topic)

Rules:

- A **consumer group** shares the consumption of a topic: **each partition is assigned to at most one consumer within a group at a time**.
- Different **groups** each get their own full copy of the stream with independent offsets.

```text
                 orders (4 partitions)
                    |
        +-----------+-------------+
        |                         |
        v                         v
Analytics Group            Notification Group
  C1 ← P0,P1                 C1 ← P0,P1,P2,P3
  C2 ← P2,P3
```

Why groups exist: they give you **queue semantics** (work splitting within a group) AND **pub/sub semantics** (fan-out across groups) in one system.

### Capacity math (memorize the pattern)

- Partitions = 4, group has 3 consumers → consumers own {2,2} or {2,1,1} partitions. Parallelism limited by 4.
- Partitions = 4, group has **8** consumers → 4 active, **4 idle**. (TODO.md §34 Scenario 6.)
- **Key principle: max active parallelism per group = number of partitions.** To scale past it → add partitions (mind the key-mapping break) or add another group.

### Interview questions

1. **What is a consumer group?** — A set of consumers sharing a group.id that collectively consumes a topic, each partition owned by exactly one member; independent groups each get the full stream.
2. **Why use groups?** — Scale consumption horizontally (split partitions) while allowing independent downstream systems (separate groups).
3. **Can two consumers in one group read the same partition simultaneously?** — No (excluding advanced transactional read_committed edge semantics — just say "no, by assignment rules").
4. **Consumers > partitions?** — Extra consumers idle.
5. **Partitions > consumers?** — Some consumers own multiple partitions (uneven load possible).
6. **A consumer dies?** — Group detects (heartbeat/session timeout), rebalance reassigns its partitions, processing resumes from committed offsets.
7. **Multiple groups, same topic?** — Yes — fully independent; classic fan-out pattern.

## 3. Rebalancing (P0)

Rebalance = redistribution of partition ownership within a group.

Triggers:
- consumer **joins** (deployment scale-out, new instance)
- consumer **leaves/crashes** (OOM, killed pod, network partition)
- subscribed **topic partition count changes**
- session/poll timeouts exceeded

Flow:

```text
Consumer failure
      |
      v
Group Coordinator (broker) detects missing heartbeats
      |
      v
Rebalance: consumers revoke partitions, join group, get new assignment
      |
      v
Consumers resume from committed offsets
```

### Mechanics worth naming

- **Group Coordinator**: broker responsible for a group's membership + the `__consumer_offsets` partition for it.
- **Group Leader**: one consumer member that runs the assignment strategy on the coordinator's behalf.
- **Heartbeats** (`heartbeat.interval.ms`) sent to the coordinator within `session.timeout.ms` — proves liveness.
- **Poll-based liveness**: a consumer must call `poll()` within `max.poll.interval.ms` or is considered dead and kicked out — **the classic "my app rebalances constantly" bug**.

### The scenario (TODO.md §15)

> A consumer takes 10 minutes to process one batch; the group keeps rebalancing.

What to investigate/configure:

1. `max.poll.interval.ms` — processing must finish within it; 10 min batch + default 5 min → kicked out → rebalance → repeat. Fix: **reduce batch work** (lower `max.poll.records`) or raise the interval.
2. `max.poll.records` — shrink batch size so each poll's processing fits comfortably.
3. `session.timeout.ms` / `heartbeat.interval.ms` — heartbeats must continue during processing (they're sent by a background thread, but extreme pauses/GC stop them too).
4. App behavior: move slow work off the poll thread (hand off to worker pool with backpressure), avoid blocking I/O inside poll loop without bounds.
5. **Cooperative (incremental) rebalancing** (`partition.assignment.strategy=CooperativeStickyAssignor`) — only moves the partitions that must move, others keep processing → much shorter stop-the-world pauses vs eager (Range/RoundRobin) strategies.

### Rebalance pain points to mention

- **Stop-the-world (eager)**: everyone revokes everything, even if unnecessary.
- **Processing progress lost**: offsets may not be committed for in-flight records → reprocessing after rebalance (duplicates).
- Frequent rebalances = lag spikes + duplicate processing. Detect via logs/metrics (consumer group metrics, `kafka-consumer-groups.sh --describe` churn).

## 4. Offset commits (P0)

Two approaches:

**Auto commit** (`enable.auto.commit=true`, every `auto.commit.interval.ms` during poll):
- Pro: simple, no code.
- Con: commit timing is decoupled from processing → duplicates (processed-but-crashed-before-commit) AND loss (committed-but-not-processed) can both occur depending on timing. Also: auto-commit happens at poll() time for records fetched previously — a crash mid-processing still leaves them "committed" on next poll.

**Manual commit** (recommended for interviews):
- `commitSync()` — blocks, retries internally, guarantees commit attempt; lower throughput.
- `commitAsync()` — non-blocking; no retry on failure (a later successful commit supersedes) — used in the steady loop for throughput.
- Pattern from the book: **commitAsync in the loop + commitSync on shutdown/rebalance callbacks** — best of both.

```text
At-least-once:      process → commit       (crash before commit → reprocess)
At-most-once:       commit → process       (crash after commit → skip)
```

### The two crash scenarios (TODO.md §16) — know both cold

**A. Commit happened, processing crashed:**
```text
record received → offset committed → processing crashes
→ restart resumes AFTER the record → record never processed  (loss → at-most-once)
```

**B. Processing succeeded, commit crashed:**
```text
record received → processing succeeds → crash before commit
→ restart resumes BEFORE the record → record reprocessed  (duplicate → at-least-once)
```

Explain: which one you choose = delivery semantics decision (see `05-reliability.md`), and B (at-least-once + idempotent downstream) is the default engineering choice.

### Commit granularity

- Commit per record (slow, safest), per batch, or periodic — and commit **only after the partition's records are processed**; committing the "latest" offset in a multi-partition poll before processing risks loss.
- Rebalance listener: `onPartitionsRevoked` → commit what's done; `onPartitionsAssigned` → optional seek adjustments.

## 5. Important consumer settings (know what they change)

```text
group.id                  membership + offset namespace
auto.offset.reset         earliest | latest | none (only when NO valid committed offset)
enable.auto.commit        auto vs manual commit
auto.commit.interval.ms   auto-commit frequency
max.poll.records          max records per poll (batch work sizing)
max.poll.interval.ms      deadline between polls before being kicked (liveness #2)
session.timeout.ms        heartbeat timeout (liveness #1)
heartbeat.interval.ms     usually ~1/3 of session.timeout
fetch.min.bytes/max...    fetch batching vs latency
partition.assignment.strategy  Range / RoundRobin / Sticky / CooperativeSticky
```

## 6. Consumer lag (P0 — real DE favorite)

```text
Lag (per partition) = log end offset (latest) − consumer committed position
```

- Lag ≈ how far behind the group is. Mild lag = buffering; **continuously growing lag = consumers can't keep up** = data freshness dying.

### Causes (TODO.md §23)

slow consumer, too few consumers, slow downstream DB, expensive processing, network bottleneck, broker issue, oversized batches, constant rebalancing, skewed partitions (one hot partition starves).

### The scenario (TODO.md §23 / §34 Scenario 2)

> Lag jumped from 100 to 1,000,000. How do you investigate?

Walk the pipeline in order — never jump to tuning:

1. **Producer rate changed?** (marketing campaign, new publisher, burst) → is lag from supply, not consumer?
2. **Kafka throughput OK?** broker CPU/disk/network, request latency.
3. **Consumer count vs partitions** — did a consumer die (rebalance churn)? Are some idle?
4. **Consumer processing time** — per-record latency spike? GC? thread starvation?
5. **Downstream system** — DB writes timing out? connection pool exhausted?
6. **Errors/retries** — poison pills, retry storms, exception loops.
7. **Partition skew** — one hot key → one partition/consumer drowning.
8. Then change **one** variable (scale consumers to partition count, fix the slow sink, add partitions) and measure.

Monitoring: Burrow, kafka-exporter + Prometheus/Grafana, Confluent Control Center; alert on **trend** (lag derivative), not just absolute value.

### Reducing lag (be ready)

- Scale consumers up to partition count; then consider adding partitions.
- Make processing faster (batch DB writes, async I/O).
- Fix/repair the slow downstream.
- Confirm no frequent rebalances (they pause consumption).
- Last resort for burst tolerance: bigger retention + accept freshness SLO hit, catch up later (Kafka's replay makes this survivable).

## 7. Scaling consumers (TODO.md §24)

```text
Topic = 8 partitions, group = 3 consumers → e.g., 3/3/2 splits
Topic = 8 partitions, group = 10 consumers → 8 active, 2 idle
```

- **Max active parallelism per group = partition count.**
- More throughput → more partitions (with rehashing caveat) or more groups (but each group processes everything — that's fan-out, not load sharing).

## 8. Failure cases

- **Frequent rebalances** → check `max.poll.interval.ms` vs processing time first (this is the #1 real-world consumer bug).
- **Committed offset evicted** (group inactive longer than `offsets.retention.minutes`) → `auto.offset.reset` applies → unexpected reprocess or skip.
- **Slow consumer + retention** → committed offset points to deleted data → data gap (or intentional skip).
- **Skewed partitions** → average lag fine, one partition's lag exploding.

## 9. Interview questions

1. **Walk me through the poll loop.** — poll → deserialize → process → (commit) → repeat; explain max.poll.* liveness.
2. **What happens when a consumer crashes?** — heartbeats stop → session timeout → coordinator triggers rebalance → partitions reassigned → resume from committed offsets (possible reprocessing).
3. **Auto vs manual commits?** — trade-offs; manual gives you control over delivery semantics; pattern commitAsync + commitSync-on-shutdown.
4. **What is consumer lag and how do you fix growing lag?** — definition + investigation pipeline + single-change-fix-measure loop.
5. **How does a consumer know where to start?** — committed offset lookup → else `auto.offset.reset`.
6. **What's a group coordinator?** — broker-side membership manager for a group; handles join/heartbeat/rebalance protocol.
7. **Eager vs cooperative rebalancing?** — stop-the-world vs incremental partition moves.

## 10. Hands-on (lab)

- `lab/weather-pipeline/consumer.py` — manual `commitSync` after processing each batch.
- Simulate crash: Ctrl-C after processing some records, restart — observe reprocessing from last commit (at-least-once).
- Watch the group: `lab/k.sh kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group weather-analytics` (see lab/README.md).
- Break rebalancing: set `max.poll.interval.ms` tiny in the consumer and add a slow `time.sleep` — watch rebalance churn.
