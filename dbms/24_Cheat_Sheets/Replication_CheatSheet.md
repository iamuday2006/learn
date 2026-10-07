# Replication Cheat Sheet

**Primary→Replicas** for HA+read scaling. Writes primary, reads replicas.

**Sync**: COMMIT waits for ack → strong, higher latency, less available on replica issues.
**Async**: fast COMMIT → eventual, **replication lag/stale reads**.

**Read-after-write**: read from primary or wait for sync if critical.

**Failover**: promote replica; watch **split-brain** (quorum/fencing).

**Replication ≠ Clustering** (copies vs coordinated nodes).
