# 01 — Kafka Fundamentals (P0)

> Source: *Kafka: The Definitive Guide*, Ch. 1 "Meet Kafka" + Ch. 2 "Installing Kafka" (broker config). Interview depth: internship / entry-level DE.

---

## 1. What is Kafka? (60-second answer)

> "Apache Kafka is a **distributed, partitioned, replicated, append-only commit log** used as a high-throughput, low-latency event streaming platform. Producers write events to **topics**; Kafka stores them durably on disk across **brokers**; consumers read them at their own pace and track their own position (**offset**) — so the same data can be consumed independently by many downstream systems, and events can be **replayed**. It solves the N×M integration problem of point-to-point systems: publish once, fan out to every consumer."

Answer structure (Definition → Why → How → Example → Trade-off → Use case) — see `notes/11-interview-drills.md`.

## 2. Why was Kafka created? (the problem it solves)

At LinkedIn, data flowed between every system via point-to-point connections:

```text
Before (N×M mess)              After (Kafka as the backbone)

 app ── DB                     app ──┐
 app ── metrics                      ├──> KAFKA ──> analytics / search / metrics
 app ── search                 app ──┘
 app ── app                    DB ──CDC──> KAFKA
```

Problems with point-to-point / ad-hoc pipelines (from Ch.1 "How It Starts"):

| Problem | Effect |
|---|---|
| Each pipeline has its own format & delivery semantics | No consistency |
| Pull vs push, retries, error handling re-solved everywhere | Wasted engineering |
| No way to replay history | Lost data on bugs/gaps |
| Load spikes overwhelm direct consumers | No buffering |

**Kafka's answer:** one central, durable, high-throughput log that both producers and consumers integrate against.

## 3. Event streaming: what is an "event"?

- An **event** (a.k.a. message, record): a fact that *happened* — `{"event":"order_placed","order_id":42,"amount":120,"ts":...}`.
- Structure: usually **key** + **value** + **timestamp** (+ optional headers).
- **Key is not just metadata**: it determines the partition → determines ordering for that entity. (Details in `03-notes`.)
- **Message vs event**: a *message* is the transport unit; an *event* carries business meaning. In Kafka they are the same record; terminology differs by context.
- **Batch**: producers group records into a batch for efficiency — a batch is compressed as one unit and adds one network round-trip overhead, not per-record overhead. Larger batches = higher throughput, more latency.

## 4. The five core abstractions

| Abstraction | One-liner | Interview detail |
|---|---|---|
| **Producer** | Writes records to topics | Chooses partition by key / round-robin / sticky |
| **Consumer** | Reads records at its own pace | Tracks its own position; never "removes" data |
| **Topic** | Logical named stream of events | Like a table name, but an append-only log |
| **Partition** | Ordered, append-only log; unit of parallelism | Each record gets a sequential **offset** |
| **Broker** | One Kafka server; stores partitions on disk | A cluster = many brokers; each partition has one **leader** broker |

Book wording (Ch.1): Kafka is a *distributed, partitioned, replicated commit log service*.

## 5. Is Kafka a queue? Is it a database?

**Kafka vs traditional message queue** (RabbitMQ, ActiveMQ, SQS):

| Aspect | Kafka | Traditional queue |
|---|---|---|
| Data model | Distributed, append-only **log**; records stay | Queue: message **removed** after ack |
| Consumption model | **Consumer tracks its own offset**, pulls when ready | Broker pushes/tracks; ack/removal model |
| Replay | Read from any offset again — trivially | Usually not possible |
| Multiple independent consumers | Native: many consumer groups each with own offset | Varies; fan-out often needs extra config/exchanges |
| Parallelism | Partition-based, horizontal | Varies |
| Retention | Configurable (time/size), independent of consumption | Until consumed (typically) |
| Ordering | Guaranteed **within a partition** | Often per-queue (varies) |

Killer differentiator sentence: *"A queue deletes history as it delivers; Kafka keeps history so any consumer can start at any point in time."*

**Kafka vs database:**

- Kafka: event **transport + durable log**; no querying (other than key lookup in compacted topics), no joins/constraints, no random updates.
- DB: system of record, queries, transactions, constraints, secondary indexes.
- Not either/or: the app writes to Postgres (state) **and** publishes to Kafka (events); downstream systems consume independently. Kafka can *hold* data (replayable log), but it is **not a database** — say that clearly; it signals senior thinking.
- Caveat that shows depth: **compacted topics** retain the latest value per key, so they behave like a key-value snapshot — this is how Streams rebuilds state. But "a compacted topic is not a queryable table."

## 6. Why is Kafka fast / horizontally scalable?

Four reasons (be ready to name 2–3):

1. **Sequential disk I/O** — appends to log files; sequential writes are near-memory speed.
2. **Zero-copy / page cache** — Kafka relies on the OS page cache and sends bytes without copying through the app heap.
3. **Partitioned parallelism** — throughput scales by adding partitions and brokers.
4. **Batching + compression** — producers batch; network and disk see big sequential blocks.

Horizontal scalability: add brokers → redistribute partition leaders; add partitions → more consumers in parallel.

## 7. Kafka architecture (draw from memory)

```text
                 ┌────────────── Kafka Cluster ──────────────┐
   Producer ───▶ │  Broker 1        Broker 2        Broker 3 │ ───▶ Consumer Group
   (key,value)   │  topicA-p0 L     topicA-p1 L    topicA-p2 L│      (C1  C2  C3)
                 │  topicA-p1 F     topicA-p2 F    topicA-p0 F│
                 └────────────────────────────────────────────┘
                 L = leader, F = follower replica
```

Terminology to use precisely:

- **Cluster** — set of brokers sharing metadata.
- **Broker** — one server; holds partition replicas; serves produce/fetch requests.
- **Topic** — logical stream; physically = set of partitions.
- **Partition** — ordered append-only log on one broker; the unit of storage, parallelism, and ordering.
- **Replica** — copy of a partition on another broker (leader + followers).
- **Leader** — the replica that serves all reads+writes for a partition; followers only replicate.
- **Follower** — replica that fetches from the leader; becomes leader if the leader dies.
- **Controller** — one broker (or, in KRaft, a controller node) that elects partition leaders when brokers fail.
- **Producer / Consumer / Consumer group** — see dedicated notes.

## 8. Where Kafka is used (real DE use cases)

- **CDC**: Postgres/MySQL → Debezium → Kafka → warehouse (Snowflake/BigQuery). Decouples OLTP from analytics.
- **Event-driven microservices**: orders topic fanned out to payments, inventory, notifications, fraud.
- **Telemetry/clickstream**: high-volume app events → Kafka → stream processing → dashboards/alerts.
- **Buffering bursty producers**: front-end events arrive in spikes; consumers read at a steady rate.
- Companies: LinkedIn (origin), Uber, Netflix, Airbnb, Pinterest — all for event pipelines at scale.

### Scenario (from TODO.md §4)

> E-commerce: 50,000 order events/min; payment, inventory, notification, analytics all need them.

Answer outline:
1. Order service **publishes once** to `orders` (keyed by `order_id`) — 3+ partitions, RF=3.
2. Each downstream system runs its **own consumer group** → independent offsets, independent pace, replay available.
3. Payment can't afford duplicates → idempotent producer + idempotent downstream handling; Notification can tolerate loss → cheap settings.
4. Backpressure: if analytics is slow, its lag grows, but payment is unaffected — no cross-system coupling.
5. New consumer (e.g., fraud) added later with zero change to producers.

## 9. Failure cases to know cold

- **Broker dies** → controller elects new leaders for its partitions from ISR; producers/consumers reconnect to the new leader. Brief produce unavailability (can throw `NotLeaderForPartitionException` until client metadata refreshes).
- **All replicas of a partition die** → partition unavailable (no writes) unless `unclean.leader.election` allows an out-of-sync replica (data-loss risk).
- **Consumer dies** → its partitions get reassigned within the group (rebalance); processing resumes from last committed offset (possible duplicates — see delivery semantics).
- **Producer send fails** → depends on `acks`/retries config; can lose (acks=0/1 edge) or duplicate (retry without idempotence).

## 10. Interview questions (with model answers)

1. **What is Apache Kafka?** — Distributed, partitioned, replicated append-only log; event streaming platform with three capabilities: publish/subscribe, durable storage with retention, stream processing (Kafka Streams/Connect ecosystem).
2. **Why was Kafka created / what problem does it solve?** — Replace brittle N×M point-to-point integrations with one durable, high-throughput, replayable event backbone; decouple producers from consumers in rate and in time.
3. **Kafka vs traditional message queue?** — Log vs queue-and-remove; offsets vs acks; replay vs no; many independent consumer groups vs often single-consumer semantics. (Table above.)
4. **Kafka vs database? Is Kafka a database?** — No — it's an event transport + durable log; DBs hold queryable state. Complementary: DB = system of record, Kafka = event backbone (CDC bridges them).
5. **Is Kafka a streaming platform?** — Yes, in three layers: messaging (topics), storage (partitioned replicated log), processing (Streams, Connect). This is the book's three-capability framing.
6. **Why is Kafka horizontally scalable?** — Partitions distribute across brokers; add brokers/partitions for more throughput; consumers scale per-partition; no central broker that bottlenecks (metadata via controller/KRaft quorum).
7. **Where is Kafka used?** — CDC ingestion, microservice event backbone, clickstream/telemetry, stream-landing into warehouses. Give ONE end-to-end example with component names.

## 11. Hands-on

```bash
# From lab/ — ./k.sh runs the CLI inside the container (see lab/README.md):
docker compose -f lab/docker-compose.yml up -d
lab/k.sh kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic orders --partitions 3 --replication-factor 1
lab/k.sh kafka-console-producer.sh \
  --bootstrap-server localhost:9092 --topic orders --property parse.key=true --property key.separator=:
lab/k.sh kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 --topic orders --from-beginning --group demo
```

Then do `lab/weather-pipeline/producer.py` and `consumer.py`.
