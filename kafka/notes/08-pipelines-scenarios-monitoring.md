# 08 — Data Engineering Pipelines, Scenarios, Troubleshooting, Monitoring (P0/P1)

> Sources: *Kafka: The Definitive Guide* Ch. 1/8/11 (ecosystem + architecture), Ch. 10 (Monitoring). This file is your **system-design + production-ops** layer — where DE interviews are won.

---

## 1. The reference DE architecture (be able to draw + justify every arrow)

```text
                 Applications / OLTP DB (PostgreSQL)
                      |
                      v  (Debezium CDC / app events)
                  Kafka  ← the event backbone
                      |
        +-------------+--------------+
        |                            |
        v                            v
 Stream Processing             Kafka Connect sinks
 (PySpark / Flink / Streams)        |
        |                    +------+------+------+
        v                    v      v             v
    Storage (S3/HDFS)   Snowflake   Elasticsearch  PostgreSQL
        |                    |
        +---------+----------+
                  v
              Analytics / BI
```

Why Kafka sits in the middle — say each of these:

- **Decoupling**: producers don't know consumers; add a new consumer (fraud, ML) with zero producer change.
- **Buffering**: bursty producers vs steady consumers; Kafka absorbs spikes.
- **Replay**: a bug in the warehouse loader? Reset offsets and reload from the log (within retention) — no request to source systems.
- **Multiple materializations**: same events → real-time dashboards, batch warehouse, search index.
- **Backpressure isolation**: one slow consumer's lag does not slow others.

### The canonical stack (TODO.md §33)

```text
PostgreSQL → Debezium CDC → Kafka → PySpark/Databricks → Snowflake
                                  └→ Elasticsearch
                                  └→ Notifications
```

**Why each component exists:**

| Component | Why it's there |
|---|---|
| Debezium (CDC) | Streams row changes from the DB WAL without hammering the DB with queries; low-latency, ordered per row-key |
| Kafka | Durable buffer + fan-out + replay |
| Spark/Flink/Databricks | Heavy transforms, joins, aggregations at scale |
| Snowflake/warehouse | Queryable analytics, BI |
| Elasticsearch | Search/ops dashboards |
| Notifications consumer | Real-time alerting straight off the log |

## 2. Five pipeline designs to be able to whiteboard (TODO.md §42)

### A. Order event pipeline

```text
Order Service → Kafka topic `orders` → payment / inventory / notification / analytics
```

Decisions to state explicitly:
- **Partition key**: `order_id` — all events of one order ordered; orders independent → parallel.
  - (If the question is per-customer ordering: key `customer_id` instead.)
- **Partitions**: size for peak+headroom (can't decrease later; increasing breaks key mapping). Say "12 partitions for headroom" style reasoning, not magic numbers.
- **Replication**: RF=3, `min.insync.replicas=2`, producer `acks=all` + idempotence.
- **Consumer groups**: one per downstream system (payment group, analytics group...).
- **Ordering**: per order_id only; no global ordering — explain why that's acceptable.
- **Retries**: producer retries + idempotence; consumer side: retry topic / DLQ (`orders.retry`, `orders.dlq`).
- **Duplicates**: idempotent sinks (upsert by order_id + version).

### B. Real-time analytics

```text
apps → Kafka → stream processing → warehouse → dashboard
```

Discuss: latency budget (seconds ok?), throughput, fault tolerance (replay + EOS in Streams), schema governance, monitoring (lag, freshness).

### C. CDC pipeline

```text
PostgreSQL → Debezium → Kafka → Spark → Snowflake
```

- **Why CDC?** Move changes, not full dumps; near-real-time; low impact on source.
- **Why Kafka?** Buffer, replay, fan-out to multiple sinks.
- **Why Spark/warehouse?** Heavy transforms + SQL analytics at rest.
- **Duplicates**: CDC has "at-least-once-ish" semantics on failover → **idempotent merge/upsert by primary key** into the warehouse; snapshot+stream consistency (Debezium snapshot then stream).
- **Schema changes**: Debezium emits schema change events / registry compatibility governs evolution; warehouse loader maps types explicitly.
- Delete handling: CDC tombstones → propagate deletes (not just upserts).

### D. Kafka → PostgreSQL (reverse sink)

- JDBC sink connector, upsert mode, batched writes; watch sink lag and DB write latency (sink DB is the usual bottleneck).

### E. Kafka → S3/data lake

- S3 sink connector: file rotation by time/size, partitioned Hive-style layout; consumers of the lake do batch compaction later.

## 3. Scenario bank (TODO.md §34 — rehearse out loud)

### Scenario 1 — Duplicate payment events downstream

Check in order: producer retries without idempotence → enable idempotence; consumer commit-after-process crash window → make sink idempotent (dedupe by payment_id); replay after fix → expected; producer restart duplicates → transactions if needed; downstream retries → idempotent API (request ids).
**Answer shape:** locate *where* duplication enters (producer retry / consumer reprocess / replay), fix root cause, and make the sink idempotent regardless — defense in depth.

### Scenario 2 — Consumer lag grows continuously

Investigation order (TODO.md §35 framework): producer rate → broker health → partition distribution → consumer count vs partitions → processing time → downstream latency → errors/retries → rebalance frequency. Change one thing, measure. Common fixes: scale consumers to partition count; batch downstream writes; fix slow sink; add partitions (with key-mapping caveat).

### Scenario 3 — Ordering requirements

Ask clarifying questions first (interviewers love this): *what entity needs ordering, and is global ordering really required?* Then: key by that entity; accept parallelism across entities; document the partition-count-change caveat. Only if true global ordering is unavoidable: single partition (throughput ceiling!) — say the trade-off.

### Scenario 4 — Consumer crashes after processing before commit

→ at-least-once: record reprocessed on restart. Answer: explain commit-vs-process ordering, then "make processing idempotent," and mention transactions/`read_committed` as the Kafka-internal upgrade path.

### Scenario 5 — Leader broker fails

Controller detects → elects new leader **from ISR** → clients refresh metadata → producers/consumers resume. Mention `unclean.leader.election.enable=false` and what happens if ISR is empty (availability vs durability choice).

### Scenario 6 — 4 partitions, 8 consumers in one group

4 active, 4 idle. Parallelism capped by partitions. Scale-up path: add partitions (key mapping!) or another group (fan-out, not load-sharing).

### Scenario 7 — Millions of events per minute

Walk capacity design: partition count from target throughput & consumer speed; broker count from disk/network; RF=3; producer batching+compression (`linger.ms`, `lz4/zstd`); consumer parallelism = partitions; monitor lag; retention by need (time vs compact); ensure downstream (warehouse loaders) can absorb the rate — Kafka is rarely the bottleneck; sinks are.

### Scenario 8 — One slow consumer / batch takes 10 min

`max.poll.interval.ms` exceeded → kicked from group → rebalance storm. Fix: lower `max.poll.records`, raise `max.poll.interval.ms`, move heavy work off the poll thread with bounded hand-off, cooperative-sticky assignor. (See `04-consumers.md` §3.)

## 4. Troubleshooting framework (TODO.md §35 — memorize the ladder)

```text
1. Define the symptom precisely (which topic/group, since when, correlated with what deploy?)
2. Producer rate — did supply change?
3. Broker health — CPU/disk/network, request latency, errors
4. Partition distribution — skew? hot partitions?
5. Consumer lag — which partitions, trend
6. Consumer errors — exceptions, retry loops, poison pills
7. Processing latency — app-level timing, GC
8. Downstream system — DB/warehouse/API health
9. Rebalances — frequency, cause (poll interval? crashes?)
10. Change ONE thing and measure
```

Interview phrase: *"I'd resist tuning configs blindly — I'd walk the data path from producer to sink, find where the throughput actually drops, and change one variable at a time."*

## 5. Monitoring concepts (TODO.md §36)

| Layer | Metrics that matter |
|---|---|
| **Producer** | send throughput, error rate, retry rate, request latency, batch size/queue (buffer.memory pressure) |
| **Broker** | CPU, disk usage+I/O, network, request latency, **under-replicated partitions** (the #1 health metric), active controller count |
| **Consumer** | **lag** (per partition + trend), processing latency, poll interval headroom, rebalance count, commit errors |
| **Cluster** | partition count vs limit, ISR shrink events, leader election rate, broker availability |

- **Under-replicated partitions > 0** = replication falling behind — a broker is unhealthy/slow. Often THE early warning.
- Tools: Prometheus + kafka-exporter + Grafana, Burrow (lag), Confluent Control Center, cloud vendor dashboards.
- Alert on **lag trend/freshness SLO** ("max event age in warehouse < 5 min"), not raw lag alone.

## 6. Interview questions

1. **Design a pipeline: app → Kafka → warehouse.** — Draw it, justify Kafka (buffer/replay/fan-out), pick keys/partitions/RF, discuss duplicates+ordering+monitoring. Rehearse 5 minutes.
2. **Why Kafka before the warehouse, why not write directly?** — Coupling, burst absorption, replayability, multiple consumers, schema contract.
3. **How do you handle duplicate data end-to-end?** — Idempotent producer + idempotent sinks (upsert/merge by key) + optional dedupe windows; replay-aware design.
4. **How do you handle schema changes?** — Registry + compatibility modes; additive changes with defaults; consumer-driven contracts.
5. **What do you monitor first when something feels off?** — Consumer lag trend + under-replicated partitions — the two highest-signal metrics.

## 7. Hands-on (ties to lab)

- Run `lab/weather-pipeline/` and use `lab/README.md` lag/chaos experiments.
- Practice scenario rehearsal: for each scenario in §3, say the answer out loud in <90 seconds.
