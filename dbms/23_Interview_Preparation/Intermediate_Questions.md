# Intermediate Questions (50)

Include key ones with template elements.

1. B-Tree vs Hash Index – B-Tree equality+range, Hash equality only.
2. Composite Index & Leftmost Prefix – column order critical.
3. Covering Index – index-only, avoids table lookup.
4. Partial Index – subset condition, smaller.
5. When NOT to index – small tables, write-heavy, low selectivity.
6. Deadlock – circular wait, detection+victim rollback.
7. Lost Update/Dirty/NRR/Phantom – differences clearly.
8. Isolation Levels (RU/RC/RR/SERIALIZABLE) – anomalies prevented.
9. MVCC – versioned snapshots, readers don’t block writers.
10. Locks (S/X, Row/Table) – compatibility.
11. WAL – write-ahead log, redo/undo, durability.
12. Undo vs Redo – uncommitted revert vs committed replay.
13. Checkpoints – speed recovery.
14. Crash Recovery (concept) – analysis/redo/undo.
15. Query Processing Lifecycle – parse→optimize→execute.
16. Cost-Based Optimization – stats, cost.
17. NLJ vs Hash vs Merge Join – when.
18. EXPLAIN/EXPLAIN ANALYZE – plan/debug.
19. Predicate Pushdown – filter early.
20. Heap vs Clustered – storage order.
21. Seq I/O vs Random I/O – perf impact.
22. Buffer Pool – cache hits reduce I/O.
23. Normalization vs Denormalization – when to denorm (OLAP/read-heavy).
24. BCNF vs 3NF – determinant must be super key.
25. Transitive Dependency – A→B→C example.
26. ER→Relational M:N mapping – bridge table.
27. Weak Entity mapping – FK+composite PK.
28. SQL vs NoSQL – ACID vs BASE, scaling, schema.
29. 4 NoSQL Types – KV/Doc/Wide-col/Graph + examples.
30. OLTP vs OLAP – normalized vs denorm, row vs column.
31. Replication Sync vs Async – durability vs latency, lag.
32. Read Replicas – stale reads, read-after-write.
33. Failover/Split-brain – quorum/fencing.
34. Replication vs Clustering – copies vs coordination.
35. Partitioning vs Sharding – same server vs multiple.
36. Range/List/Hash Partitioning – use cases.
37. Partition Pruning – key benefit.
38. Shard Key – good properties, avoid monotonic.
39. Consistent Hashing – minimal rebalancing.
40. Hot Shard – causes/mitigations.
41. Cross-shard queries/txns – Saga vs 2PC.
42. CAP Theorem – C/A/P, CP vs AP, nuance.
43. Distributed DB – fragmentation+replication.
44. Vertical vs Horizontal Scaling – trade-offs.
45. Connection Pooling – exhaustion prevention.
46. Caching + Invalidation – hard problem.
47. Connection Pool vs Cache – different concerns.
48. Row vs Columnar Storage – OLTP vs OLAP.
49. Data Lake/Warehouse/Lakehouse – differences.
50. ETL vs ELT – modern preference.
