# 09 — Interview Drills: Template, Rapid-Fire, CLI, Flashcards (P0)

> Your final-phase drill sheet. Pair with `10-checklist.md` and the 7-day sprint in `TODO.md` §44.

---

## 1. The explanation template (use for EVERY conceptual question)

```text
Definition  → what it is, in one precise sentence
Why         → the problem it solves
How         → mechanism, 2-4 steps
Example     → concrete mini-example
Trade-off   → what it costs / when not to use it
Real world  → where you'd see it in a DE pipeline
```

### Worked example — "What is a partition?"

> **Definition:** An ordered, append-only log inside a topic. **Why:** to scale a topic across brokers and enable parallel consumption. **How:** each record appends with a sequential offset; producers route by key-hash; one consumer in a group owns each partition. **Example:** key `customer_id=101` hashes to partition 2 — all their events stay ordered there. **Trade-off:** more partitions = more parallelism but more files, longer elections, and rehashed key mapping if you add partitions. **Real world:** `orders` topic partitioned by `order_id` so payment processing is ordered per order and parallel across orders.

Weak answers name the thing. Strong answers run the template.

## 2. 40 rapid-fire questions — say answers OUT LOUD, <30s each

1. **What is Kafka?** — Distributed, partitioned, replicated append-only log; event streaming platform (publish/subscribe + storage + processing).
2. **What is a broker?** — One Kafka server; stores partition replicas; serves produce/fetch.
3. **What is a topic?** — Logical named stream of records; physically a set of partitions.
4. **What is a partition?** — Ordered append-only log; unit of parallelism and ordering.
5. **What is an offset?** — Sequential position of a record within a partition; how consumers track progress.
6. **What is a consumer group?** — Consumers sharing load over a topic; each partition owned by one member; independent groups each get full stream.
7. **What is replication?** — N copies of each partition across brokers; leader serves, followers fetch.
8. **What is ISR?** — In-Sync Replicas: replicas caught up with the leader within the lag window; `acks=all` waits on these.
9. **What is a leader?** — The replica serving all reads/writes for a partition.
10. **What is a follower?** — Replica fetching from the leader; leader candidate on failure.
11. **What is `acks=all`?** — Leader waits for all in-sync replicas to have the record before acking; durability setting.
12. **What is `min.insync.replicas`?** — Minimum ISR required to accept writes; keeps `acks=all` from degrading to effectively `acks=1`.
13. **Why do producers retry?** — Transient errors/lost acks; without idempotence retries can duplicate.
14. **What is idempotence?** — Producer PID + sequence numbers so broker dedupes retries (per partition, per session).
15. **What is consumer lag?** — Log end offset − committed consumer position; measures how far behind a group is.
16. **Why does rebalancing happen?** — Group membership changes: join/leave/crash, timeouts, partition count changes.
17. **What is at-least-once?** — Process then commit; no loss, possible duplicates; make sinks idempotent.
18. **What is at-most-once?** — Commit then process; no duplicates, possible loss.
19. **What is exactly-once?** — Effects appear once: idempotent producer + transactions + read_committed + Streams transactional commits.
20. **Does Kafka delete messages after consumption?** — No; only retention/compaction removes data.
21. **What is retention?** — Time/size policy for how long records live.
22. **What is compaction?** — Cleanup policy keeping latest value per key; used for changelogs/state.
23. **What is Kafka Connect?** — Framework of source/sink connectors moving data between Kafka and external systems, scalable, offset-managed.
24. **What is a source connector?** — Pulls external data into Kafka (e.g., Debezium CDC).
25. **What is a sink connector?** — Pushes Kafka data to external systems (S3, Snowflake, ES).
26. **What is Kafka Streams?** — Java/Scala library for stateful stream processing with topics as I/O.
27. **KStream vs KTable?** — Event stream vs keyed changelog/latest-state table.
28. **Why use a partition key?** — Route related events to one partition → per-entity ordering.
29. **What happens when a broker dies?** — Controller elects ISR leaders; clients refresh metadata; brief availability blip, no acked-data loss if configured.
30. **What happens when a consumer dies?** — Heartbeats stop → rebalance → partitions reassigned → resume from committed offsets.
31. **Consumers > partitions?** — Extra consumers idle; parallelism capped by partition count.
32. **What causes consumer lag?** — Slow consumers/sinks, too few consumers, skew, rebalances, expensive processing, supply spikes.
33. **How to reduce lag?** — Scale consumers to partitions, speed up processing/sink, fix rebalances, add partitions.
34. **How to preserve ordering?** — Key by entity → one partition → one consumer at a time processes in offset order.
35. **Kafka vs RabbitMQ?** — Replayable log w/ offsets vs ack-and-remove queue; partition parallelism; fan-out via groups.
36. **Kafka vs PostgreSQL?** — Event transport/replay vs queryable state; complementary (CDC bridges).
37. **Kafka vs Redis Streams?** — Redis: lighter, in-memory, limited retention/scale; Kafka: durable disk log, high throughput, rich ecosystem.
38. **Why is Kafka fit for event-driven architecture?** — Durable pub/sub, fan-out to many services, replay, decoupling of rate and time.
39. **What is KRaft?** — Built-in Raft metadata quorum replacing ZooKeeper; simpler ops, faster failover, scales metadata.
40. **Why does Kafka need replication?** — Broker failure must not lose data; RF + ISR make failure an availability event, not data loss.

## 3. CLI commands — know what each does (TODO.md §38)

```bash
# Topics
# In the lab, prefix scripts with ./k.sh (see lab/README.md), e.g.:
#   ./k.sh kafka-topics.sh --bootstrap-server localhost:9092 ...
kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic orders --partitions 3 --replication-factor 1   # create w/ layout
kafka-topics.sh --bootstrap-server localhost:9092 --list          # inventory
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic orders
#   ↑ shows partitions, leaders, replicas, ISR — THE health-check command

# Console producer (keyed)
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic orders \
  --property parse.key=true --property key.separator=:

# Console consumer
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic orders \
  --group demo --from-beginning --property print.key=true --property print.partition=true

# Consumer groups
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group demo
#   ↑ CURRENT-OFFSET, LOG-END-OFFSET, LAG, CONSUMER-ID — THE lag-debugging command
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group demo \
  --reset-offsets --to-earliest --topic orders --execute   # replay demo
```

Interview framing: *"I know `--describe` on topics shows leader/ISR health, and `--describe` on groups shows lag per partition — those are the two commands I'd run first in an incident."*

## 4. Flashcard deck (two-sided drill — cover the right side)

| Prompt | Answer cue |
|---|---|
| Ordering guarantee scope | Within a partition only |
| Globally unique record address | (topic, partition, offset) |
| Consumers > partitions | Extras idle |
| acks=all waits on | Current ISR members |
| min.insync.replicas violated | Writes rejected (NotEnoughReplicas) |
| Retry duplicates fixed by | Idempotent producer (PID + seq) |
| Crash between process & commit | Reprocess → at-least-once |
| Crash between commit & process | Skip → at-most-once |
| Where offsets live | `__consumer_offsets` (compacted) |
| `auto.offset.reset` applies when | No valid committed offset |
| Consumer liveness signals | heartbeats (session.timeout) + poll (max.poll.interval) |
| Constant rebalancing suspect #1 | max.poll.interval.ms vs processing time |
| Topic deletion by reads | Never — retention only |
| Compaction keeps | Latest per key (+tombstone window) |
| Streams state durability | Changelog (compacted topic) |
| #1 broker health metric | Under-replicated partitions |
| #1 consumer health metric | Lag trend |
| Leader election source pool | ISR |
| Unclean leader election | Stale replica takes leadership → data loss |
| EOS building blocks | idempotent producer, transactions, read_committed, Streams commits |

## 5. Mock-interview self-test (Day 7 from TODO.md §44)

1. **60-second Kafka intro** — record yourself, play it back, cut every filler word.
2. **Draw the architecture** — cluster, 3 brokers, one topic with 3 partitions RF=3, two consumer groups. Explain each arrow out loud.
3. **Pick 5 scenarios** from `08-pipelines-scenarios-monitoring.md` §3 — answer in <90s each.
4. **One system design** — the CDC pipeline (§2C): justify every component and its failure mode.
5. **Rapid-fire** — all 40 above; mark any answer >30s or hedged, re-drill those.

## 6. Red flags to avoid (interviewer pet peeves)

- ❌ "Kafka is a queue" without the log/offset contrast.
- ❌ "Kafka guarantees exactly-once" without scoping the building blocks.
- ❌ "Offsets are global" / "messages are deleted after reading".
- ❌ Quoting config values with no trade-off attached.
- ❌ Skipping clarifying questions in scenario/design answers (always ask: what's the ordering need? throughput? freshness SLO? duplicate tolerance?).
- ✅ Instead: run the template (§1), name the trade-off, then give the real-world example.
