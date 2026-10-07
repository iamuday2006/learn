# Concurrency Cheat Sheet

**Anomalies**: Lost Update (W–W), Dirty Read (R uncommitted), NRR (row changes), Phantom (range inserts/deletes)

**Isolation**: RU: dirty yes. RC: no dirty. RR: no dirty/NRR. Serializable: no all.

**Locks**: S (read, shared), X (write, exclusive). Row/table granularity. 2PL.

**Deadlock**: circular wait → detect+victim rollback.

**MVCC**: versioned snapshots, readers≠block writers, PG uses snapshots + VACUUM.
