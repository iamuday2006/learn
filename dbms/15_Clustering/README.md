# 15. Clustering

> Covers: 10:07:49 – Clustering. HA, Active-Passive/Active-Active, distinctions from Replication/Partitioning/Sharding.

## 1. What is Database Clustering?

**Database Clustering** = Grouping **multiple database servers (nodes)** together to act as a **single, highly available (HA) system**. Provides **fault tolerance, load balancing, automatic failover**.

**Goal**: Minimize downtime, ensure continuity if one node fails.

## 2. Why Clustering?

- **High Availability (HA)**: Near-zero downtime (automatic failover)
- **Redundancy**: Eliminate single point of failure
- **Load Distribution**: Spread queries across nodes (active-active)
- **Scalability**: Add nodes to handle more load
- **Improved Reliability**: Survive hardware/software failures

## 3. Clustering vs Replication (Clear Distinction)

| Aspect | **Clustering** | **Replication** |
|---|---|---|
| **Purpose** | **High Availability + Load Balancing** as unified system | **Data redundancy + Read Scaling** via copies |
| **Architecture** | Tightly coupled nodes (shared or coordinated state) | Loosely coupled: Primary → Replicas |
| **Write Access** | Often **all nodes** (active-active) or **one active** (active-passive) | Usually **single primary** only |
| **Data Storage** | Can be **shared storage** (SAN) or **replicated storage** | Data **copied** from primary to replicas |
| **Failover** | **Automatic, seamless** (cluster manager handles) | Manual or automated promotion |
| **Transparency** | Apps see **single logical DB endpoint** | Often apps choose read/write routing |
| **Coordination** | Needs **clusterware/heartbeat** (consensus, quorum) | Simpler log/WAL streaming |
| **Examples** | MySQL NDB Cluster, Oracle RAC, Galera Cluster, Pacemaker+Postgres | Streaming Replication, Master–Slave |

**Key**: Replication **copies data**. Clustering makes **nodes work together** as one HA unit.

## 4. Active-Passive vs Active-Active

### 4.1 Active-Passive Clustering (Failover Cluster)

`	ext
                ┌─► Passive Node (Standby, idle until failover)
Load Balancer → Active Node (Handles all reads+writes)
                └─ (Heartbeat between nodes)
`

- **Only one node active** at a time
- **Standby** monitors, takes over on failure
- **Shared storage** common (SAN) or replicated data
- **Pros**: Simple, avoids write conflicts
- **Cons**: Standby underutilized, failover causes brief interruption
- **Use**: HA with minimal complexity
- **Examples**: Pacemaker/Corosync + DRBD/shared storage setups

### 4.2 Active-Active Clustering

`	ext
Load Balancer → Node1 (Read+Write)
                ↕ (sync/coordination)
              Node2 (Read+Write)
`

- **All nodes active** simultaneously
- **Load balanced** reads+writes
- **Needs** **synchronous replication + conflict resolution**
- **Pros**: Better utilization, higher throughput, no idle node
- **Cons**: Complex (split-brain, write conflicts), needs strong sync
- **Use**: High scale HA needing both read+write distribution
- **Examples**: Galera Cluster (MySQL), some distributed NewSQL

## 5. Shared Storage vs Replicated Storage

| Approach | Description | Pros | Cons |
|---|---|---|---|
| **Shared Storage** | All nodes access same disk (SAN/NAS/FC) | Data consistent, simple | **Single point of failure** for storage (needs RAID/HA storage) |
| **Replicated Storage** | Each node has own disk; data replicated (block-level or DB-level) | No shared disk SPOF, geo-distributed possible | Needs sync (latency), more disk space |

## 6. Cluster Components (Conceptual)

| Component | Role |
|---|---|
| **Cluster Manager/Orchestrator** | Monitors nodes, coordinates failover, quorum |
| **Heartbeat/Interconnect** | Health checks between nodes (low-latency) |
| **Load Balancer** | Routes traffic to active node(s) |
| **Shared/Replicated Storage** | Data persistence layer |
| **Quorum/Voting** | Prevents split-brain (majority must agree) |
| **Fencing** | Isolate failed node (STONITH – Shoot The Other Node In The Head) |

## 7. MySQL/ Postgres Clustering Examples (Conceptual)

| Solution | Type | Notes |
|---|---|---|
| **Galera Cluster (MySQL/MariaDB)** | **Active-Active** | Synchronous multi-master, InnoDB only, auto-conflict handling |
| **MySQL Group Replication** | Active-Active/Multi-primary | Plugin-based, Paxos-like consensus |
| **Percona XtraDB Cluster** | Active-Active | Galera-based |
| **Pacemaker + Corosync + Streaming Rep** | **Active-Passive** | Common Postgres HA (resource agent promotes standby) |
| **Patroni** | Orchestrator (HA) | Uses etcd/consul + streaming repl, leader election (RAFT-like) |
| **Oracle RAC** | Active-Active (shared storage) | Enterprise, cache fusion, shared disk |
| **Citus (Postgres)** | Distributed sharding+HA | Horizontal scaling + replication |

## 8. Clustering vs Partitioning vs Sharding

Distinguish clearly:

| Aspect | **Clustering** | **Partitioning** | **Sharding** |
|---|---|---|---|
| **Goal** | **HA + Availability + Load Balancing** | **Manage large tables by splitting logically within same DB/server** | **Horizontal scale by splitting across multiple DB instances/nodes** |
| **Scope** | Multiple servers/nodes working together | Single database instance | Multiple independent DB nodes (shards) |
| **Data Split** | Usually **full copy** (replicated) or shared | Split by **rows** into logical partitions (range/list/hash) | Split by **shard key** across different servers |
| **Writes** | Active-passive or active-active | All to same instance (routed to partition) | Routed to **specific shard** by key |
| **Query Impact** | Failover/load distribution | **Partition pruning** improves query (scan subset) | May need **cross-shard** queries/joins (complex) |
| **Examples** | Galera, Pacemaker | PostgreSQL PARTITION BY RANGE, MySQL partitioning | Instagram, Pinterest style sharding, Citus |

**See**: 16_Partitioning, 17_Sharding for deeper.

## 9. Pros/Cons of Clustering

### Pros
- **High Availability**: Minimal downtime
- **Automatic Failover**: Faster recovery
- **Load Balancing** (active-active)
- **Scalability** for reads+writes (active-active)
- **Single endpoint** abstraction (active-passive often)

### Cons
- **Complexity**: Setup, monitoring, tuning
- **Cost**: More hardware, network, licensing
- **Network Dependency**: Interconnect critical (latency)
- **Write Conflicts** (active-active)
- **Split-Brain Risk**: Needs quorum/fencing
- **Shared Storage SPOF** if not HA'd

## Key Takeaways (Interview)

- **Clustering = multiple nodes act as one HA system** (not just copies).
- **Active-Passive**: one active, standby idle – simple HA. **Active-Active**: all active – higher utilization + complexity.
- **Replication copies data; Clustering coordinates nodes for availability/load**.
- **Partitioning** is logical split in same DB. **Sharding** is horizontal split across different DB servers.
- **Galera = Active-Active synchronous**. **Pacemaker+Streaming Rep = Active-Passive** common for Postgres HA.

## Interview Qs

**Q1. Database Clustering vs Replication – difference?**
- Clustering: nodes coordinate to form single HA system (shared/replicated state, often failover). Replication: primary→replicas copies for redundancy/read scaling.

**Q2. Active-Passive vs Active-Active clustering?**
- Active-Passive: one handles all, standby takes over on failover (simple). Active-Active: all handle traffic (load balanced) but needs sync + conflict resolution.

**Q3. What is split-brain in clustering? How to avoid?**
- Both nodes think primary/active after network partition → divergence. Avoid via **quorum**, **voting**, **fencing (STONITH)**, or **majority consensus**.

**Q4. Clustering vs Sharding – difference?**
- Clustering = HA/failover (availability/redundancy). Sharding = horizontal data split across nodes for **scale** (data partitioning by key).

**Q5. When choose clustering?**
- Need **high availability** with minimal downtime (e-commerce, banking critical systems) where single DB is SPOF.
