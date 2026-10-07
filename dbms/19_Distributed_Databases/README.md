# 19. Distributed Databases

> Covers: 11:18:22 – Master-Slave Architecture (tie-in). Nodes, partitions, replication, consensus (conceptual), consistency/availability/fault tolerance (interview-level).

## 1. What is a Distributed Database?

**Distributed Database (DDB)** = Collection of **logically related data** spread across **multiple interconnected nodes** (computers/sites), managed by a **distributed DBMS (DDBMS)**. Appears to users as **single unified database**.

**Types**:
- **Homogeneous**: Same DBMS, schema, data model across all nodes
- **Heterogeneous (Federated)**: Different DBMS/platforms, integrated via middleware

## 2. Why Distributed Databases?

- **Scalability (Horizontal)**: Add nodes as demand grows
- **High Availability & Fault Tolerance**: Survive node/network failures
- **Geographic Distribution**: Data closer to users (lower latency)
- **Load Balancing**: Distribute queries/workload
- **Data Locality**: Keep data near where it's used
- **Modular Growth**: Incremental expansion

## 3. Key Concepts

| Concept | Explanation |
|---|---|
| **Node** | Individual server/machine in distributed system storing subset of data |
| **Data Fragmentation (Partitioning/Sharding)** | Split data into fragments across nodes (horizontal/vertical) |
| **Replication** | Copy fragments to multiple nodes (HA, read scaling) |
| **Allocation** | Decide which fragments on which nodes (with/without replication) |
| **Transparency** | Hide distribution details from users/apps (location, replication, fragmentation) |
| **Network Partition** | Nodes can't communicate – drives CAP trade-offs |

## 4. Distributed Architectures

### 4.1 Client–Server (Basic)
Clients connect to distributed DB via network. Simple.

### 4.2 Peer-to-Peer (P2P)
All nodes equal, can serve reads/writes (decentralized). e.g. Cassandra ring.

### 4.3 Master–Slave / Leader–Follower
Single leader accepts writes, followers read (common for replication). See 14_Replication.

### 4.4 Multi-Master (Active-Active)
Multiple nodes accept writes, need conflict resolution.

## 5. Fragmentation (Data Distribution)

| Type | How | Example |
|---|---|---|
| **Horizontal Fragmentation (Sharding)** | Split **rows** by condition (range/hash) | Customers by region/country |
| **Vertical Fragmentation** | Split **columns** (keep PK on all) | Put frequently accessed cols on node A, others B |
| **Hybrid** | Combine horizontal + vertical | Common in complex cases |

## 6. Replication + Fragmentation Combinations

| Strategy | Description |
|---|---|
| **Fully Replicated** | Every node has **entire** DB (high availability, expensive storage/write sync) |
| **Partially Replicated** | Fragments replicated on subset of nodes (balance) |
| **Non-Replicated (Partitioned)** | Each fragment on **exactly one** node (max space efficiency, less HA) |

## 7. Consistency in Distributed Systems

| Model | Description | Notes |
|---|---|---|
| **Strong Consistency** | All reads see latest write (Linearizability) | CP systems often aim for this |
| **Weak Consistency** | No guarantee latest seen immediately | Rare |
| **Eventual Consistency** | If no new writes, all replicas converge eventually | AP systems (Cassandra, DynamoDB default) |
| **Causal Consistency** | Related operations seen in order | Middle-ground |
| **Read-Your-Writes** | User sees their own writes | Session guarantee |

**Trade-off**: Stronger consistency → higher latency, less availability during partitions.

## 8. Consensus (Conceptual, Interview-Level)

**Consensus** = Group of nodes agree on **single value/decision** despite failures.

**Why**: Critical for **leader election, distributed locks, commit decisions**.

**Key Properties (Paxos/Raft intuition)**:
- **Agreement**: All correct nodes agree on same value
- **Validity**: Agreed value was proposed
- **Termination**: Decision made eventually
- **Fault Tolerance**: Tolerates node failures (majority quorum)

**Algorithms (names only, conceptual)**: **Raft** (understandable, leader-based), **Paxos** (classic). **Zookeeper/etcd** use Raft-like consensus.

**Quorum**: Need **majority (N/2+1)** of nodes to commit to avoid split-brain.

## 9. Distributed Transactions

As in sharding (17): **2PC (Two-Phase Commit)** for strong atomicity, **Saga** for eventual consistency + resilience.

- **2PC**: Coordinator ensures all nodes PREPARE then COMMIT. Blocking risk if coordinator fails.
- **Saga**: Sequence of local txns with compensating actions. More scalable, eventual.

## 10. Fault Tolerance & Availability

| Concept | Meaning |
|---|---|
| **Fault Tolerance** | System continues despite **node/link failures** |
| **High Availability (HA)** | Minimal downtime, automatic failover |
| **Redundancy** | Replicas eliminate SPOF |
| **Quorum** | Majority voting prevents split-brain |
| **Fencing** | Isolate failed node |
| **Heartbeat** | Detect node failures |

**MTBF/MTTR** concepts less common; focus on replication+failover+consensus.

## 11. Distributed DB Design Considerations

- **Fragmentation Strategy**: Horizontal/Vertical? By access pattern?
- **Replication Level**: How many copies? Sync vs Async?
- **Placement**: Geo-distribution vs latency trade-off
- **Query Routing**: How to direct to right node(s)?
- **Consistency Requirements**: Strong vs eventual per use case?
- **Failure Handling**: Partition tolerance strategy (CP/AP)
- **Scalability Plan**: Add nodes without downtime
- **Security/Network**: Encryption, auth between nodes

## 12. Examples of Distributed Databases

| DB | Type | Notes |
|---|---|---|
| **Cassandra** | Peer-to-peer, AP-leaning | Consistent hashing, tunable consistency, no single point |
| **CockroachDB** | NewSQL, CP-leaning (strong) | Raft consensus, SQL, horizontal scale, ACID |
| **Google Spanner** | NewSQL, globally distributed | TrueTime + Paxos, strong consistency globally |
| **TiDB** | NewSQL | HTAP, Raft, MySQL compatible |
| **MongoDB Sharded** | Sharded distributed | Config servers + routers, replica sets per shard |
| **Amazon Aurora Global** | Distributed relational | Cross-region replication, low lag |

## Key Takeaways (Interview)

- **Distributed DB = logically single, physically spread** across nodes.
- **Fragmentation + Replication** core strategies.
- **CAP governs C vs A during partitions**.
- **Consensus (Raft/Paxos)** ensures agreement in distributed (leader election/quorum).
- **Strong consistency** = correctness but less available/latency. **Eventual** = available/scalable.
- **NewSQL** aims for **ACID + horizontal scale + strong consistency**.
- **Transparency** hides complexity from apps.

## Interview Qs

**Q1. What is a Distributed Database? Advantages?**
- Data on multiple nodes, unified view. Advantages: scale-out, HA, fault tolerance, geo-locality, load balancing.

**Q2. Fragmentation vs Replication in distributed DB?**
- Fragmentation: split data across nodes (horizontal/vertical). Replication: copy data to multiple nodes (redundancy/read scale).

**Q3. Strong vs Eventual Consistency?**
- Strong: all see latest (linearizable). Eventual: converge over time if no writes (AP systems). Trade-off latency/availability.

**Q4. What is Consensus in distributed systems? Why needed?**
- Nodes agree on value despite failures. Needed for leader election, locks, distributed commits (prevent split-brain). Raft/Paxos use quorum.

**Q5. 2PC vs Saga for distributed transactions?**
- 2PC: prepare→commit, ensures atomicity, blocking/coordinator failure risk. Saga: local txns + compensating, eventual consistency, resilient, better scale.

**Q6. Homogeneous vs Heterogeneous distributed DB?**
- Homogeneous: same DBMS/schema on all nodes. Heterogeneous: different DBMS integrated (federated/middleware).
