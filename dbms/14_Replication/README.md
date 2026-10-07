# 14. Replication

> Covers: 10:07:49 – Clustering / Replication, 11:18:22 – Master-Slave Architecture. Sync/Async, Leader-Follower, Read Replicas, Failover, Replication Lag, Read/Write paths.

## 1. What is Replication?

**Replication** = Copying data from one database server (**Primary/Master/Leader**) to one or more other servers (**Replica/Secondary/Follower/Standby**) to improve **availability, scalability, fault tolerance**.

**Goal**: Keep replicas in sync (eventually or synchronously) so reads can go to replicas, writes to primary.

## 2. Why Replicate?

- **High Availability (HA)**: If primary fails, promote replica (failover)
- **Read Scalability**: Distribute read traffic (reports, analytics)
- **Fault Tolerance/Disaster Recovery**: Data redundancy across nodes
- **Lower Latency**: Serve reads from geo-nearby replicas
- **Load Balancing**: Separate read/write workloads
- **Backup Offloading**: Take backups from replica (less impact)

## 3. Replication Topologies

### 3.1 Master–Slave (Legacy) / Leader–Follower (Modern)
`	ext
                ┌─► Replica 1 (Read)
Application → Primary (Read+Write)
                └─► Replica 2 (Read)
`

- **Writes** go to **Primary (Leader)**
- **Reads** go to any **Replica (Follower)**
- Unidirectional: changes flow **primary → replicas**
- Most common (async or semi-sync)

### 3.2 Multi-Master (Active–Active) – Replication Variant
Multiple nodes accept writes, changes replicated bidirectionally. Complex (conflict resolution). Less common for pure "replication", closer to clustering.

### 3.3 Chain Replication / Others (conceptual)
Less frequent in interviews.

## 4. Synchronous vs Asynchronous Replication

| Aspect | **Synchronous Replication** | **Asynchronous Replication** |
|---|---|---|
| **When** | COMMIT waits until **all/specified** replicas confirm write | COMMIT returns immediately; changes sent to replicas later |
| **Durability** | **Stronger**: data on primary + confirmed replicas | Weaker: data may be lost if primary crashes before replica receives |
| **Consistency** | **Stronger** (read from replica sees committed data) | **Eventual Consistency** (replica may lag) |
| **Latency (Write)** | **Higher** (network RTT to replicas) | **Lower** (fast commits) |
| **Availability** | Lower if replica slow/unreachable (can block writes) | **Higher** (primary continues even if replicas down) |
| **Use Case** | Critical (finance, payments) – zero data loss priority | Most general (read scaling, HA) – performance priority |
| **Risk** | Write blocking on network/replica issues | **Replication Lag** → stale reads |
| **Examples** | PostgreSQL synchronous standby, some HA setups | Default async in many setups |

**Semi-Synchronous**: Wait for **at least one** replica to acknowledge (balance).

## 5. Read Replicas

**Read Replica** = Replica dedicated to serving **read-only** queries. Offloads primary.

**When to use**:
- **Read-heavy** apps (reports, dashboards, search)
- **Geographic distribution** (serve nearby reads)
- **Analytics** without impacting OLTP
- **Backup** without locking primary

**Read/Write Path**:
- **Write**: pp → primary (propagated via WAL/log shipping or streaming)
- **Read**: pp → any healthy replica (load balanced)

**Consideration**: **Stale reads** possible with async replication (lag). Don’t read from replica for data just written unless strong consistency needed.

## 6. Replication Lag

**Replication Lag** = Delay between write on primary and that write appearing on replica.

**Causes**:
- Network latency (geo)
- High write volume on primary
- Slow disk I/O on replica
- Long-running queries on replica blocking replay
- Large transactions

**Effects**: User reads stale data (e.g. "post created" not visible yet).

**Mitigations**:
- Read from **primary** for **read-after-write** consistency
- Use **read-replica routing** by session/user context
- Monitor lag (seconds behind master)
- Synchronous/semi-sync for critical paths
- Tune replica (faster disk, no heavy analytics blocking)

## 7. Failover & Promotion

**Failover** = Automatically (or manually) switch to replica when primary becomes unavailable.

**Steps (conceptual)**:
1. **Detect failure** (health check, heartbeat timeout)
2. **Choose best replica** (least lag, most up-to-date)
3. **Promote replica to Primary (Leader)**
4. **Reconfigure**: redirect writes to new primary, update clients
5. **Catch-up**: old primary may rejoin as replica later (after recovery)

**Split-Brain**: Risk if both think they’re primary (network partition) → data divergence. Need **quorum/consensus** (e.g. Raft/Paxos) or fencing.

**Automatic failover** tools: Patroni (Postgres), Orchestrator (MySQL), etc. Implementation-dependent.

## 8. Replication Methods (How Changes Propagate)

| Method | How | Notes |
|---|---|---|
| **Statement-based (SBR)** | Send exact SQL statements | Small logs but non-deterministic functions (NOW(), RAND()) can cause divergence |
| **Row-based (RBR)** | Send changed rows (before/after values) | More accurate, larger but safer. Common (Postgres logical, MySQL binlog ROW) |
| **WAL-based (Physical)** | Ship raw WAL bytes (block changes) | Very efficient, byte-for-byte, lower-level. Postgres streaming replication uses physical/logical variants |
| **Logical Replication** | Replicate changes by table/rows with schema flexibility | Can replicate subset, cross-version (Postgres logical) |
| **Log Shipping** | Periodically ship WAL files to replica, apply later | Simpler, higher lag (file-based)

**PostgreSQL Streaming Replication**: Uses **WAL streaming** (physical) by default for HA; logical also available.

## 9. Replication vs Clustering (Distinction)

| Aspect | **Replication** | **Clustering** |
|---|---|---|
| **Purpose** | Data **copy** for HA + read scaling | **Shared access / High Availability** as a **single coherent system** |
| **Writes** | Usually to **single primary** (except multi-master) | Often **shared storage** or **active-active** with coordination |
| **Topology** | Primary → Replicas (unidirectional mostly) | Nodes form a **cluster** (tightly coupled) |
| **Failover** | Promote replica | Automatic failover (node takes over) |
| **Data Sync** | Log/WAL shipping/streaming | Shared disk or synchronous replication + cluster manager |
| **Examples** | Postgres streaming repl, MySQL async repl | Pacemaker+Corosync, Oracle RAC (shared storage), Galera Cluster |

**Note**: Terms sometimes mixed. **Replication = data copies. Clustering = group working together for HA/load.** (See 15_Clustering)

## 10. Practical Example (PostgreSQL Mental Model)

`	ext
Primary (pg_primary)
  ├─ streams WAL → Replica1 (hot standby, read-only)
  └─ streams WAL → Replica2 (hot standby, read-only)
`

- hot_standby = on allows read-only queries on replicas
- Async by default; can enable **synchronous_commit** for sync
- Uses **pg_wal/** shipping/streaming

## Key Takeaways (Interview)

- **Replication** = copies for HA + read scaling. Writes → Primary, Reads → Replicas.
- **Sync** = safer (no data loss) but slower writes. **Async** = faster writes but **replication lag + stale reads**.
- **Read-after-write**: route to primary or wait for replica sync if consistency critical.
- **Failover** needs careful handling (split-brain avoidance).
- **WAL-based streaming** common in modern RDBMS (efficient).
- **Replication ≠ Clustering** – different goals/topologies.

## Interview Qs

**Q1. What is Database Replication? Why use it?**
- Copying data to replicas for HA, read scalability, DR, lower latency, load separation.

**Q2. Synchronous vs Asynchronous Replication?**
- Sync: COMMIT waits for replica ack → strong durability/consistency, higher latency. Async: immediate COMMIT → lower latency, eventual consistency, risk of lag/loss on failover.

**Q3. Replication Lag – causes & mitigation?**
- Network, high volume, slow replica I/O, blocking replay. Mitigate: read from primary for read-after-write, semi-sync, monitor lag, tune.

**Q4. Read Replicas – when useful? Trade-offs?**
- Read-heavy (reports/analytics), geo. Trade-off: stale reads with async, extra infra/cost.

**Q5. Failover in replication – challenges?**
- Detect failure, promote replica, redirect. Challenges: split-brain, data divergence, catching up old primary. Need careful orchestration.

**Q6. Replication vs Clustering – difference?**
- Replication = data copies (often primary→replicas). Clustering = nodes form coherent HA system (shared or coordinated). Different topologies/purposes.
