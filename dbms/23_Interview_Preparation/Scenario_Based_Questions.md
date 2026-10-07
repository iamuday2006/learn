# Scenario-Based Questions (20)

1. 100M users, reads 10x writes – scale DB. (replicas+cache+shard if needed)
2. Query suddenly slow – investigate (EXPLAIN, stats, missing index, locks, I/O)
3. 500 connections, only 100 active – connection pool/exhaustion?
4. Payment fails after debit – guarantee correctness (ACID, txn, rollback, idempotency)
5. Hot shard (celebrity) – mitigation (better key, virtual shards, hash)
6. Replication lag causing stale reads – read-after-write strategy
7. Avoid overselling inventory – transactions + row locks, check constraints
8. Design feed (fan-out write vs read, hybrid)
9. Ride-sharing double driver assignment – atomic update/row lock
10. Choose SQL vs NoSQL for fintech app – CP/ACID
11. Archival: 10TB old orders – partitioning (drop partition) vs delete
12. Cross-shard join unavoidable? – denorm, scatter-gather, CQRS
13. Network partition: choose CP or AP? Banking vs social feed
14. High write IoT logs – wide-column/TSDB, partitioning by time
15. Need geo-low latency reads – regional read replicas
16. Deadlocks frequent – lock ordering, shorter txns, avoid long-held locks
17. Index slowing writes heavily – partial/composite, remove unused, cover
18. Global app, strong consistency needed – NewSQL/spanner or CP careful
19. ETL heavy affects OLTP – separate OLAP, read replicas, CDC offload
20. Exactly-once in distributed pipeline – idempotency + dedup + ACID/merges
