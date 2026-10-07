# CAP Theorem Cheat Sheet

**C** Consistency (strong/linearizable), **A** Availability (always responds), **P** Partition Tolerance (survives network split)

**In partition**: must choose **CP** or **AP** (P unavoidable)

- **CP**: consistent, may be unavailable (MongoDB majority, HBase, ZK)
- **AP**: available, eventually consistent (Cassandra, CouchDB, DynamoDB)
- **CA**: only single-node (no real P)

**Nuance**: "pick any two" misleading – focus C vs A under P. Many **tunable**.
