# 10 — Final Readiness Checklist (P0 → Interview Ready)

> Check items off only when you can answer **out loud, without notes**. Pair each section with its notes file and the 7-day sprint (TODO.md §44).

## 1. Kafka Fundamentals — `01-fundamentals.md`

- [ ] I can explain Kafka in 60 seconds (log, topics, offsets, replay, fan-out).
- [ ] I can draw the architecture: producers → topic/partitions on brokers → consumer groups.
- [ ] I understand brokers, topics, partitions, offsets — and their failure behavior.
- [ ] I can contrast Kafka vs queue vs database in 3 sentences each.
- [ ] I can explain why Kafka is fast (sequential I/O, page cache, batching, partitioning).

## 2. Topics / Partitions / Offsets — `02-topics-partitions-offsets.md`

- [ ] I know ordering is per-partition only, and why.
- [ ] I can explain key → hash → partition and the rehash caveat when partition count changes.
- [ ] I know consumers > partitions → idle consumers.
- [ ] I know offsets are per-partition and where committed offsets live.
- [ ] I can explain `auto.offset.reset` values and when they apply.
- [ ] I can reason about choosing partition count (trade-offs, not magic numbers).

## 3. Producers — `03-producers.md`

- [ ] I can walk the producer flow: serialize → partition → batch → compress → send.
- [ ] I can explain `acks=0/1/all` with the leader-failure data-loss story.
- [ ] I can connect `acks=all` → ISR → `min.insync.replicas` → RF=3/min.isr=2.
- [ ] I can explain why retries duplicate and how idempotence (PID+sequence) fixes it.
- [ ] I know idempotence scope: per partition, per producer session.
- [ ] I can discuss batching (`batch.size`, `linger.ms`) and compression trade-offs.

## 4. Consumers & Groups — `04-consumers.md`

- [ ] I can walk the poll loop and the two liveness mechanisms (heartbeats, poll interval).
- [ ] I can explain consumer groups, ownership rules, and fan-out across groups.
- [ ] I can explain rebalancing triggers + eager vs cooperative strategies.
- [ ] I can diagnose the "constant rebalancing" bug (max.poll.interval vs processing time).
- [ ] I can explain auto vs manual commits and the commitAsync+commitSync pattern.
- [ ] I can define lag, list its causes, and walk the investigation ladder.
- [ ] I can handle both crash-timing scenarios (commit-before-process, process-before-commit).

## 5. Reliability & Delivery Semantics — `05-reliability.md`

- [ ] I can explain replication, leader/follower, and leader election from ISR.
- [ ] I can explain the broker-failure scenario end-to-end (controller → election → clients).
- [ ] I can explain ISR dynamics and the availability-vs-durability trade-off.
- [ ] I can state `unclean.leader.election.enable=false` consequences.
- [ ] I can define at-most-once / at-least-once / exactly-once via commit-vs-process ordering.
- [ ] I can say the exactly-once sentence: building blocks + cooperation, not automatic magic.
- [ ] I can make a pipeline idempotent (upserts, dedupe keys, transactional sinks).

## 6. Storage — `06-storage-retention-compaction.md`

- [ ] I can explain log segments and why they enable cheap deletion/compaction.
- [ ] I can contrast retention by time vs size (and the per-partition size gotcha).
- [ ] I can explain retention vs compaction and pick use cases for each.
- [ ] I know tombstone semantics on compacted topics.
- [ ] I can explain page cache + sequential I/O + zero-copy (why Kafka is fast).

## 7. Ecosystem — `07-ecosystem.md`

- [ ] I can explain Connect: workers, connectors, tasks, source vs sink, distributed mode.
- [ ] I can argue Connect vs hand-rolled consumers.
- [ ] I can explain Streams basics: KStream vs KTable, state stores + changelogs, windows.
- [ ] I can explain schema evolution + compatibility modes and the "new field" scenario.
- [ ] I can explain why Kafka moved to KRaft (one system, faster failover, metadata scalability).
- [ ] I know the security vocabulary: SASL (authn), ACLs (authz), TLS (encryption).

## 8. Data Engineering Design & Ops — `08-pipelines-scenarios-monitoring.md`

- [ ] I can whiteboard the reference architecture and justify every arrow.
- [ ] I can design the order pipeline (key, partitions, RF, groups, retries, idempotency).
- [ ] I can design the CDC pipeline and explain duplicates + schema-change handling.
- [ ] I can run the 10-step troubleshooting ladder without prompting.
- [ ] I know the two highest-signal metrics: lag trend, under-replicated partitions.
- [ ] I can rehearse all 8 scenario-bank answers in <90s each.

## 9. Hands-On — `../lab/`

- [ ] I've stood up the KRaft Kafka container (`docker compose up -d`).
- [ ] I've created topics, produced keyed records, consumed with a group via CLI.
- [ ] I've run the weather producer/consumer and observed partition assignment.
- [ ] I've killed the consumer mid-stream and watched at-least-once reprocessing.
- [ ] I've checked lag with `kafka-consumer-groups.sh --describe`.
- [ ] (Stretch) I've demoed compaction and a rebalance storm.

## 10. The Final Bar (TODO.md §46)

- [ ] "What problem does Kafka solve, how does its architecture solve it, what happens when something fails, and how would I use it in a real DE pipeline?" — 4 minutes, confident, with an example.
- [ ] I've completed the Day-7 mock (rapid-fire 40 + 5 scenarios + 1 design) — `09-interview-drills.md` §5.
