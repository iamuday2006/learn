# 06 — Storage: Log Segments, Retention, Compaction, Page Cache (P1)

> Source: *Kafka: The Definitive Guide* Ch. 2 (broker config, log retention) + Ch. 6 (replication at segment level) + Ch. 10-11 (operational view of logs). Storage questions separate candidates who've actually run Kafka from those who only read definitions.

---

## 1. Log segments — how a partition is physically stored

A partition is **not one infinite file**. It is a sequence of **segment files** on disk:

```text
Partition "orders-0" directory on a broker:
  00000000000000000000.log        ← segment containing offsets 0..1233
  00000000000000000000.index
  00000000000000000000.timeindex
  00000000000000001234.log        ← active segment, offsets 1234..now
  00000000000000001234.index
```

- Segment name = **first offset** in that segment.
- Exactly **one active segment** per partition — the one being appended to.
- Roll to a new segment when: `segment.bytes` reached, `segment.ms` age reached, or log rolled by compaction.
- `.index` = offset → file position map (sparse index); `.timeindex` = timestamp → offset map.

### Why segments exist (the interview answer)

- **Retention/deletion**: delete whole old segments — no per-record surgery, just drop files. Cheap and fast.
- **Compaction**: rewrite compacted segments in bulk.
- **Efficient seeks**: sparse index jumps near the target offset, then sequential scan.
- **Log recovery**: segments make crash recovery checks manageable.

## 2. Retention (P0)

**Kafka does not delete records because a consumer read them.** Deletion is purely a function of retention/cleanup policy. This is the top-3 trap question.

Two main policies (a topic uses `cleanup.policy=delete` or `compact` or `delete,compact`):

### Retention by time — `retention.ms` (default 7 days) / `retention.minutes` / `retention.hours`

- Segments whose **newest record** is older than the limit are eligible for deletion.
- Precision is at the **segment level**: a segment is deleted only when all its records qualify; the active segment is never deleted. So actual data age can exceed `retention.ms` by up to one segment's time span (`segment.ms` bounds this).

### Retention by size — `retention.bytes` (per partition; -1 = unlimited)

- Oldest segments deleted until the partition fits under the limit.
- **Gotcha to mention:** `retention.bytes` is **per partition**, not per topic — total topic size = retention.bytes × partitions.

### What consumers experience with retention

- Consumer offline longer than retention → its committed offset may point to **deleted data** → on restart it resumes at the earliest remaining data (per `auto.offset.reset`) → a **data gap** (not an error).
- Slow consumer + aggressive retention = silent data loss. Monitor lag AND retention headroom.
- Consumers can **re-read** anything still retained — replay is just "reset offsets and go."

### Interview questions

1. **Does Kafka delete a message after consumption?** — No. Deletion is only by retention policy/compaction, never by reads.
2. **What is retention?** — Configurable time/size policy controlling how long records live in the log, independent of consumption.
3. **Can consumers reread old data?** — Yes, within retention: reset offsets (or use a new group with `auto.offset.reset=earliest`).
4. **Consumer offline for a week with 3-day retention?** — Its offsets may point to deleted segments → resumes at earliest available → data gap; design with lag alerts and retention ≥ max expected downtime.
5. **Time vs size retention?** — Time = predict data age; size = predict disk usage. Size is per partition.

## 3. Log compaction (P1)

`cleanup.policy=compact` — **different from delete-retention**: instead of dropping old segments by age, Kafka **retains at least the latest value for each key** and removes older values for the same key.

```text
Before compaction                 After compaction
key=A value=1                     key=A value=4   ← latest per key kept
key=B value=2                     key=B value=2
key=A value=3                     key=C value=5
key=A value=4
key=C value=5
```

- Compaction is per **key** — topics must have keyed records.
- **Tombstones**: a record with `value=null` marks a key deleted; after `delete.retention.ms` (default 24h) the tombstone itself is removed. Deleting the tombstone immediately would break state-rebuilding on other replicas/consumers.
- The **active segment is never compacted** — only sealed segments.
- Kafka guarantees: every consumer still sees every key's latest value *in offset order*, and compacted topics usually keep recent history + all latest values (not "only latest record overall").

### Retention vs compaction — the comparison they ask for

| | Retention (delete) | Compaction |
|---|---|---|
| Unit | Whole segments by age/size | Latest value per key |
| Data shape | Full time-series history | "Latest snapshot" + bounded recent history |
| Requires keys | No | Yes |
| Typical use | Events/streams: clicks, orders, metrics | Changelog/state: entity status, table-like feed |
| Consumer recovers by | Replaying history | Reading latest state per key |

### Use cases (TODO.md §22)

- `customer_id → latest customer state` (change-feed for cache rebuild)
- Kafka Streams **changelog topics** for state stores (that's why they're compacted)
- Database CDC after-images per entity key
- Configuration/state distribution (latest config per key)

### Not suitable

- Append-only event streams without keys; data where history matters (audit logs — use time retention).

## 4. Page cache & why Kafka is fast (P1)

Kafka doesn't manage its own disk cache; it leans on the **OS page cache**:

1. Writes are **sequential appends** to the active segment → sequential disk I/O ≈ RAM speed for disks.
2. Recent writes live in the page cache; **followers and consumers read mostly from cache**, not disk.
3. **Zero-copy** sendfile path: broker serves consumers bytes straight from page cache to network socket without copying through the JVM heap.
4. Consequence: give the broker RAM instead of fancy storage; avoid JVM heap sizes that squeeze the page cache (broker heap is usually small, e.g. 5–6 GB even on big machines).

One-liner: *"Kafka treats disk as an append-only sequential log and lets the OS page cache absorb reads — that's why throughput is near network saturation and consumers can read historical data without hurting producers."*

## 5. Tiered storage (P2 — mention, don't dive)

- Newer Kafka feature: hot data local on broker disks, **older segments offloaded to cheap object storage** (S3/GCS/HDFS).
- Benefits: decouple retention cost from broker disk, scale retention massively, faster broker recovery/rebalance (less data to copy).
- Costs: slower reads of cold data, added operational complexity. Interview use: name it as the modern answer to "how do you keep 12 months of data."

## 6. Failure cases

- **Disk full from unbounded topic** (`retention.bytes=-1` + producer surge) → broker failure cascade; set retention + disk alerts.
- **Over-aggressive retention** → consumers offline too long lose data (gap on resume).
- **Compacted topic with null keys** → compaction can't work correctly (records with null key are invalid for compacted topics).
- **Tombstone mismanagement** (deleted immediately / never produced) → state rebuild divergence.
- **Many small segments** (tiny `segment.ms`) → file-handle pressure, slower deletes/compaction.

## 7. Interview questions

1. **What is a log segment and why do segments exist?** — Physical rolling files; enable whole-file deletion, bulk compaction, sparse indexing, cheap seeks.
2. **Retention vs compaction?** — Table in §3.
3. **When would you use compaction?** — Latest-state-per-key needs: changelogs, CDC state, cache rebuild, Streams state stores.
4. **Is compaction the same as deleting all old records?** — No — keeps latest per key (plus tombstone semantics and bounded recent history).
5. **Why is Kafka fast at reads AND writes?** — Sequential appends + page cache + zero-copy + batching/compression.
6. **Where do consumers store offsets?** — Internal compacted topic `__consumer_offsets` (nice segue: it's compacted because we only need latest offset per (group,partition)).

## 8. Hands-on (lab)

```bash
# From repo root — ./k.sh runs the CLI inside the lab container (see lab/README.md)
# create a compacted topic
lab/k.sh kafka-topics.sh --bootstrap-server localhost:9092 --create --topic user-state \
  --config cleanup.policy=compact --config segment.ms=100 --config min.cleanable.dirty.ratio=0.01

# write multiple values per key via console producer (parse.key=true), then read:
lab/k.sh kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic user-state \
  --from-beginning --property print.key=true
```

Experiment: set tiny `segment.ms`/`min.cleanable.dirty.ratio` on a test topic, write multiple updates for the same key, wait, and observe compaction removing older values.
