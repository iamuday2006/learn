# Partitioning vs Sharding Cheat Sheet

| | **Partitioning** | **Sharding** |
|---|---|---|
| Location | Same server/instance | Multiple servers/nodes |
| Scale | Manageability/query pruning | Horizontal scale-out |
| Transparent | Yes (single table) | Often needs shard key routing |
| Types | Range/List/Hash/Composite | Range/Hash/Consistent Hashing/Directory |
| Key | Partition Pruning | Shard Key (high cardinality, even, stable) |
| Cross | Cheaper | Expensive (queries/txns) |
| Failure | Affects all instance | Isolated per shard |
| Use | Large tables, archival, time-series | Massive scale, global distribution |
