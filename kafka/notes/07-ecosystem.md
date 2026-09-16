# 07 — Ecosystem: Connect, Streams, Schema, Security, KRaft (P1)

> Source: *Kafka: The Definitive Guide* Ch. 8 (Cross-Cluster/MirrorMaker), Ch. 9 (Administration/security basics), Ch. 11 (Kafka Streams), plus Schema Registry practice. For internship interviews: **architecture + use cases beat API trivia.**

---

## 1. Kafka Connect (P1)

Framework for **reliably moving data between Kafka and external systems** with pre-built, reusable connectors — no custom consumer/producer code for every integration.

```text
PostgreSQL ──▶ [Source Connector] ──▶ Kafka ──▶ [Sink Connector] ──▶ Snowflake / ES / S3
```

### Architecture terms (know precisely)

| Term | What it is |
|---|---|
| **Worker** | A Connect server process (JVM). Runs in **standalone** (single worker, config in files — dev only) or **distributed** mode (cluster of workers). |
| **Connector** | The *config/definition* of a job: "ingest the `orders` table" — decides how to split the work into tasks. |
| **Task** | The *unit of work* that actually moves data. A connector can have N tasks running across workers. |
| **Converters** | JSON/Avro/Protobuf serialization for connector data. |
| **Transforms (SMT)** | Single-message transforms: rename fields, filter, route — lightweight, not full stream processing. |
| **Offsets & source records** | Connect stores its own source offsets in Kafka topics → **resume on failure** out of the box. |

### How Connect scales & fails

- **Distributed mode**: workers form a group (like a consumer group). Connectors+tasks rebalance across workers when workers join/leave → horizontal scale + HA.
- Tasks store progress in Kafka topics → a dead worker's tasks resume elsewhere **from last committed offsets**.
- `tasks.max` per connector; partitions are a natural task boundary for many connectors.

### Why not write a custom Python consumer per destination? (TODO.md §26 Q3)

Model answer: *"Connect gives you pre-built, tested, fault-tolerant pipelines with offset management, scaling, and config-driven deployment for free. Hand-rolled consumers re-solve retries, offsets, schema handling, and monitoring for every system — and they break in production. Connect centralizes all of that; you just pick connectors and configure them."*

### Interview questions

1. **What is Kafka Connect?** — Framework/tooling for scalable, reliable, config-driven data import/export between Kafka and external systems.
2. **Source vs sink connector?** — Source pulls external data INTO Kafka (Debezium for DB CDC, files, APIs); sink pushes Kafka data OUT (S3, Elasticsearch, Snowflake, JDBC).
3. **What's a worker vs connector vs task?** — Worker = server process; connector = job definition that plans work; task = the actual data-moving unit distributed across workers.
4. **How does Connect scale / handle failure?** — Distributed workers rebalance tasks like a consumer group; progress persisted in Kafka topics → resume from offsets.
5. **Name a real CDC source connector.** — Debezium (Postgres/MySQL/Mongo → Kafka via WAL/oplog, minimal source-DB impact).

## 2. Kafka Streams (P1 basics)

A **Java/Scala library** (not a broker, not a cluster) for building stream-processing apps where **input and output are Kafka topics**.

```text
Kafka topic ──▶ [Streams app: filter → map → aggregate → join → window] ──▶ Kafka topic
```

### Core concepts

| Concept | Meaning |
|---|---|
| **KStream** | An unbounded, **record stream** — every record is an event (insert). `KStream` of clicks = every click. |
| **KTable** | A **changelog of keyed updates** — table semantics; latest value per key wins (backed by compacted changelog topic). KTable of users = current user state. |
| **Stateless ops** | filter, map, flatMap, keyBy — no storage needed. |
| **Stateful ops** | aggregations, joins, windowing — need **state stores**. |
| **State store** | Local (RocksDB/in-memory) store per instance, backed by a **compacted changelog topic** → state survives restarts (rebuild from changelog) and scales with partitions. |
| **Windowing** | Tumbling / hopping / sliding / session windows for time-bounded aggregates (e.g., "orders per 5 min"). |
| **Processing time vs event time** | Event-time (timestamp in the record) is what you almost always want; watermarks/grace periods handle late data. |

### KStream vs KTable — the classic question

> Clicks = KStream (each event matters). Users table = KTable (latest state per user key matters). Joining a KStream of orders with a KTable of users enriches each order event with the user's current profile.

### Architecture points that impress

- Streams apps are **elastic**: instances coordinate via a consumer group; partitions of the input determine parallelism (tasks).
- **Failover**: an instance dies → its partitions+tasks move to others; state rebuilt from changelog topics.
- Streams has **exactly-once processing** built in (transactional commit of offsets + outputs + state changelog atomically).
- Alternatives to name-drop: Flink/Spark Structured Streaming for heavier orchestration; Streams when you want a lightweight library with no separate cluster.

### Interview questions

1. **What is Kafka Streams?** — Client library for stateful stream processing with Kafka topics as I/O; scales like consumer groups; state in local stores backed by changelogs.
2. **KStream vs KTable?** — Event stream vs keyed changelog/table.
3. **Stateless vs stateful?** — No storage vs state stores (aggregations/joins/windows).
4. **How does Streams survive failures?** — Changelog topics + task reassignment → rebuild state, resume at offsets.
5. **Windowing example.** — "Count purchases per city per 5-minute tumbling window; late events within grace period still count."

## 3. Schema management (P1)

Kafka moves **bytes** — producers serialize, consumers deserialize. Without shared schemas, one side changing breaks the other silently.

```text
Producer ──serialize(schema v2)──▶ Kafka (bytes) ──deserialize(schema)──▶ Consumer
              \                        |                       /
               \____ both register/fetch schemas from Schema Registry _/
```

### Formats compared

| Format | Type | Schema | Size | Best for |
|---|---|---|---|---|
| JSON | text | optional/loose | large | quick prototyping, non-critical feeds |
| Avro | binary | explicit, registry | compact | Kafka data at rest, ecosystem default |
| Protobuf | binary | explicit, registry | compact | polyglot services, gRPC shops |

### Schema evolution & compatibility (the interview core)

- Schemas evolve (add field, make field optional). **Compatibility modes** in Schema Registry control what changes are accepted:
  - **Backward** (default): new schema can read **old** data — e.g., adding a field with a default, deleting an optional field.
  - **Forward**: old schema can read **new** data.
  - **Full**: both directions.
- **The scenario (TODO.md §28): "producer adds a new field — what happens?"**
  - With JSON, no registry: consumers may ignore it (fine) or break (typo/type drift) — silently inconsistent.
  - With Avro + registry, backward-compatible change (new optional/defaulted field): old consumers read old projection, new consumers see the field — **no coordinated deployment needed**.
  - Incompatible change (renaming a required field): registry **rejects** the new schema at produce-registration time → you find out before your pipeline breaks.

Model sentence: *"The registry turns 'hope both sides agree' into a governed contract with enforced compatibility — producers and consumers evolve independently."*

## 4. Security basics (P2-lite; know the vocabulary)

```text
Who are you?        → Authentication  (SASL: PLAIN/SCRAM/GSSAPI-Kerberos/OAUTHBEARER; mTLS)
What may you do?    → Authorization   (ACLs: principal + operation + resource; e.g., consumer group read)
Is the wire safe?   → Encryption      (TLS in transit; at rest via disk encryption)
Audit/ops           → quotas, audit logs, securing ZooKeeper/KRaft, broker admin ops
```

One-liner per concept is enough for internship level; name `SSL/TLS + SASL + ACLs` as the trio. Don't claim deep config experience unless you have it.

## 5. KRaft — modern Kafka architecture (P1 high level)

- **KRaft** (Kafka Raft) = Kafka's built-in **Raft-based metadata quorum** replacing ZooKeeper (ZK mode removed in Kafka 4.0).
- Controllers run as a **quorum** (usually 3 or 5) storing metadata in an internal **metadata log** (a Kafka-style log — "Kafka's metadata as a topic").
- **Why move away from ZooKeeper? (the interview question, TODO.md §30)**
  - **One system to run, secure, monitor** — no second distributed system + no ZK↔Kafka split-brain class of failures.
  - **Faster controller failover** — the metadata log makes failover deterministic vs ZK's ephemeral-watch dance.
  - **Scalability** — metadata as a replicated log supports far more partitions than ZK's in-memory/watch limits.
  - Cleaner **security model** and simpler configuration.
- Mental model: brokers + controllers are all "Kafka nodes" now; cluster metadata is just another replicated log. The lab in `lab/` runs KRaft mode — zero ZooKeeper.

## 6. Multi-cluster & MirrorMaker (P2 — one paragraph)

- Reasons for multiple clusters: DR (active-standby), geo-proximity (active-active), isolation, compliance.
- **MirrorMaker 2** replicates topics+offsets between clusters (Kafka Connect under the hood); names get prefixed (`source.topic`) to avoid loops.
- Know "hub-and-spoke vs active-active vs active-standby" by name; expect only high-level questions at internship level.

## 7. Failure cases / gotchas

- **No registry + schema drift** → deserialization failures downstream at 2am; fix: enforce compatibility early.
- **Connect sink writes duplicates after retry** → sinks must be idempotent (upsert) — same delivery-semantics rule as consumers.
- **Streams state store too big / hot key** → RocksDB pressure, changelog bloat → reconsider keys/windows.
- **Forgetting `read_committed`** with transactional producers → consumers see duplicates of aborted writes.
- **Running ZK-mode Kafka in interviews** (2026) → dates your knowledge; know KRaft basics.

## 8. Hands-on pointers

- Lab runs **KRaft** (`lab/docker-compose.yml`) — inspect: `kafka-metadata-quorum.sh describe --status`.
- Schema Registry demo (optional extension): add `confluentinc/cp-schema-registry` container; register an Avro schema; try an incompatible one and watch it rejected.
- Connect demo (optional): add a `FileStreamSourceConnector` in standalone mode copying a file into a topic — the "hello world" of Connect.
