# Kafka Interview Notes — Internship / Entry-Level Data Engineering

Interview-focused notes distilled from **Kafka: The Definitive Guide** (Narkhede, Shapira, Palino), organized by the priority system in `../TODO.md`.

## Reading order

| # | File | Priority | Topics |
|---|---|---|---|
| 01 | [fundamentals](01-fundamentals.md) | **P0** | What/why Kafka, event streaming, vs queue/DB, architecture, speed |
| 02 | [topics-partitions-offsets](02-topics-partitions-offsets.md) | **P0** | Topics, partitions, keys, ordering, offsets, `auto.offset.reset` |
| 03 | [producers](03-producers.md) | **P0** | Producer flow, `acks`, retries, idempotence, batching, compression |
| 04 | [consumers](04-consumers.md) | **P0** | Poll loop, consumer groups, rebalancing, commits, lag, scaling |
| 05 | [reliability](05-reliability.md) | **P0** | Replication, leader election, ISR, `min.insync.replicas`, delivery semantics |
| 06 | [storage-retention-compaction](06-storage-retention-compaction.md) | P1 | Log segments, retention, compaction, page cache, tiered storage |
| 07 | [ecosystem](07-ecosystem.md) | P1 | Connect, Streams, schemas/registry, security, KRaft |
| 08 | [pipelines-scenarios-monitoring](08-pipelines-scenarios-monitoring.md) | **P0/P1** | Reference architecture, 5 designs, scenario bank, troubleshooting, monitoring |
| 09 | [interview-drills](09-interview-drills.md) | drill | Explanation template, 40 rapid-fire, CLI cheat sheet, flashcards |
| 10 | [checklist](10-checklist.md) | final | Readiness checklist mapped to TODO.md §45 |

## How to use

1. **Learn phase** — read 01–05 (P0 core), one file per sitting; answer the Q&A sections *out loud* before moving on.
2. **Broaden phase** — 06–07 (P1), then 08 for the design/ops layer.
3. **Drill phase** — 09 daily in the last 3 days before interviews; run the Day-7 mock from TODO.md §44.
4. **Verify** — tick off `10-checklist.md`; anything unchecked sends you back to the matching file + the lab.

## Hands-on

The [`../lab/`](../lab/) directory has a Dockerized KRaft Kafka + the real-time weather pipeline (producer/consumer in Python) with failure experiments that make the concepts above physical. Run it while reading 02–05.
