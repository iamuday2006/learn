# Advanced Questions (30)

1. How does MVCC prevent dirty/non-repeatable/phantom in Postgres? (conceptual)
2. Explain ARIES crash recovery (analysis/redo/undo) at high level
3. How does query optimizer use statistics/cardinality?
4. Indexed Nested Loop vs Hash/ Merge trade-offs deeply
5. Write-heavy vs read-heavy index strategy
6. Phantom reads: RR in MySQL InnoDB vs PostgreSQL
7. Serializable Snapshot Isolation (SSI) in Postgres – conceptual
8. 2PC vs Saga – failure modes, blocking
9. Consistent Hashing + Virtual Nodes details
10. Rebalancing/resharding online with minimal downtime
11. Leader election & Quorum (Raft intuition)
12. Split-brain detection/prevention (fencing, quorum)
13. Read-Your-Writes, Monotonic Reads (session consistency)
14. PACELC vs CAP
15. NewSQL (Spanner/CockroachDB) – ACID+horizontal scale
16. CDC (Debezium/WAL) + exactly-once
17. Lakehouse ACID + Time Travel (Delta/Iceberg)
18. Snowflake vs BigQuery architecture differences (storage/compute separation)
19. Dist Key/Sort Key (Redshift) vs Clustering (Snowflake) performance
20. Columnar compression + encoding for OLAP
21. HTAP trade-offs
22. B+Tree structure (leaf links, range scans) conceptually
23. Bitmap scans vs B-Tree in Postgres
24. Covering + Partial + Expression indexes use cases
25. Lock escalation, row vs page vs table
26. Optimistic vs Pessimistic concurrency control
27. Distributed query planning/cross-shard fan-out
28. Geo-replication: strong vs eventual, read replicas across regions
29. Data modeling trade-offs: normalized (OLTP) vs denorm (OLAP) + materialized views
30. Cost/perf trade-offs: sync vs async replication + semi-sync
