# 17. Sharding

> Covers: 10:24:07 – Partitioning and Sharding. Shard key, Hash/Range, Consistent Hashing, Hot shards, Cross-shard queries/txns, Partitioning vs Sharding.

## 1. What is Sharding?

**Sharding** (Horizontal Partitioning across nodes) is splitting a large dataset into smaller, independent chunks (**shards**) and distributing them across **multiple database servers/instances**.

**Goal**: **Horizontal Scalability** – handle more data/traffic by adding more nodes (scale-out), not just bigger server (scale-up).

**Each shard** = subset of rows + its own schema/data, runs on separate server.

## 2. Why Shard?

- **Horizontal Scaling**: Add nodes as data grows (linear-ish)
- **High Throughput**: Write/read distributed
- **Reduced Load Per Node**: Smaller dataset/index per shard
- **Improved Availability**: Failure of one shard doesn't bring down all (if isolated)
- **Geo-Distribution**: Place shards near users (lower latency)
- **Handles Massive Scale** (billions of rows)

## 3. Sharding vs Partitioning (Very Clear)

| Aspect | **Sharding** | **Partitioning** |
|---|---|---|
| **Distribution** | Across **different servers/machines/instances** | Within **same database server/instance** |
| **Type of Scaling** | **Horizontal (Scale-Out)** – add nodes | **Vertical/Logical (Manageability)** – not node-level scale |
| **Transparency** | Often **not fully transparent** – app needs **shard key** routing | Usually **transparent** – single table view |
| **Failure Isolation** | Shard failure affects only that subset | Whole instance failure affects all |
| **Cross-Shard** | Expensive (joins, txns) | Cheaper (same instance) |
| **Complexity** | **High** (routing, rebalancing, resharding, cross-shard) | **Moderate** |
| **Use Case** | Massive scale (millions→billions, global) | Large table in single DB (archival, pruning) |

## 4. Shard Key (Most Critical)

**Shard Key** (Partition Key) determines **which shard** a row goes to.

**Properties of good shard key**:
- **High cardinality** (many distinct values) → even distribution
- **Even distribution** → avoid hot shards
- **Stable** – rarely changes (changing key = expensive migration)
- **Frequently used in queries** – enables **targeted** routing (avoid fan-out)
- **Monotonic? Avoid** (e.g. auto-increment ID, timestamps) → can create hot shards

**Examples**: user_id, 	enant_id, customer_id, order_id (if well distributed).

**Bad**: country (low cardinality), status (few values), monotonically increasing.

## 5. Sharding Strategies

### 5.1 Range-Based Sharding
Divide shard key range across shards.

- **How**: user_id 1–1M → Shard A, 1M–2M → Shard B
- **Pros**: Easy to implement, range queries possible on same shard
- **Cons**: **Hot shards** if range grows unevenly (monotonic), rebalancing hard
- **Good for**: Time-based or naturally ranged keys

### 5.2 Hash-Based Sharding
Compute hash(shard_key) mod N → assign shard.

- **Pros**: **Uniform distribution** (if good hash), avoids hot spots
- **Cons**: **No range queries** across shards, adding shards breaks mapping (mod changes) → need remapping
- **Good for**: Even spread, point lookups by key

### 5.3 Consistent Hashing
Map both keys & shards to **hash ring**. Minimizes rebalancing when adding/removing shards.

- **Pros**: **Minimal data movement** on re-shard, scales smoothly
- **Cons**: More complex, can have **virtual nodes** imbalance if not tuned
- **Widely used**: DynamoDB, Cassandra (token ring), distributed caches

### 5.4 Directory-Based Sharding (Lookup Table)
Maintain **lookup service** mapping shard key → shard location.

- **Pros**: Very flexible (can rebalance easily)
- **Cons**: **Single point of failure** for lookup unless replicated, extra hop
- **Use**: Complex cases needing dynamic mapping

## 6. Hot Shards

**Hot Shard** = Shard receiving **disproportionately more traffic/requests** than others (imbalance).

**Causes**:
- **Poor shard key** (low cardinality, monotonic)
- **Popular entities** (celebrity users/posts)
- **Geo/skewed access**

**Effects**: Bottlenecks, increased latency, node overload.

**Mitigations**:
- Choose better **high-cardinality, evenly distributed** shard key
- **Virtual shards** (more logical shards than physical nodes)
- **Re-sharding/rebalancing**
- **Consistent hashing**
- **Hash-based** over range for uniformity
- **Read replicas** per shard to offload reads

## 7. Cross-Shard Queries & Transactions

### Cross-Shard Queries
Queries needing data from **multiple shards** (e.g. JOIN across shards).

**Challenges**:
- **No single-node JOIN** – must fetch from shards + merge in app
- **Network overhead** (latency, fan-out)
- **Complex sorting/pagination**
- **Inconsistent views** if async

**Mitigations**:
- **Denormalize** (embed related data in shard) to avoid joins
- **Avoid cross-shard** by good key design (co-locate related data)
- **Scatter-gather** pattern (parallel fetch) – expensive
- **Materialized views** / aggregated tables

### Cross-Shard Transactions
**Distributed Transactions** across shards (2PC, Saga pattern).

**Challenges**:
- **ACID hard** across nodes (CAP theorem)
- **Latency + failure modes** (partial commits)
- **Coordination overhead**

**Approaches**:
- **2PC (Two-Phase Commit)**: Prepare → Commit. Ensures atomicity but **blocking, slow**.
- **Saga Pattern**: Break into **local transactions** + **compensating actions** on failure. **Eventual consistency**, more resilient but complex.
- **Avoid cross-shard txns** if possible (design to keep entity in one shard)

**Reality**: Many large-scale systems choose **eventual consistency + Saga** over strict ACID across shards.

## 8. Resharding (Rebalancing)

**Resharding** = Moving data between shards when adding/removing nodes or to fix imbalance.

**Challenges**:
- **Downtime risk** (if offline)
- **Data movement cost**
- **Routing updates** (clients/routers)
- **Consistency during migration**

**Strategies**:
- **Consistent Hashing** → minimal movement
- **Virtual Nodes** → smoother splits
- **Double-write + cutover** (online migration)
- **Range splitting** → gradual

## 9. Sharding in Practice (Examples)

| System | Approach | Notes |
|---|---|---|
| **Instagram** | User-based sharding (by user_id) | Posts/comments co-located by user context |
| **Pinterest** | Sharding + object storage | Pins distributed by pin/user ID |
| **Cassandra** | Consistent Hashing (token ring) | No single master, distributed |
| **MongoDB Sharded Cluster** | Range/Hash + config servers + routers (mongos) | Production sharding |

## 10. Pros & Cons

### Pros
- **True horizontal scale** (handle massive growth)
- **Improved performance** (smaller datasets per node)
- **Better availability/fault isolation**
- **Geographic distribution** possible

### Cons
- **High complexity** (architecture + ops)
- **Cross-shard queries/txns hard**
- **Rebalancing/resharding painful**
- **Routing logic required**
- **Operational overhead** (backups, monitoring per shard)
- **Data consistency trade-offs**

## Key Takeaways (Interview)

- **Sharding = horizontal split across multiple servers** → true scale-out.
- **Shard key is everything** – drives distribution, routing, query efficiency.
- **Hash-based** = uniform, no range. **Range-based** = range queries but hot-spot risk.
- **Consistent Hashing** minimizes rebalancing.
- **Avoid cross-shard** by co-locating related data. If unavoidable, use **Saga** over 2PC when eventual consistency acceptable.
- **Partitioning ≠ Sharding**: same server vs multiple servers.

## Interview Qs

**Q1. What is Sharding? Why needed?**
- Horizontal partitioning across multiple nodes. Needed for massive scale, high throughput, fault isolation beyond vertical scaling.

**Q2. Partitioning vs Sharding – explain clearly.**
- Partitioning: same DB instance, logical split (manageability/pruning). Sharding: multiple instances, horizontal scale, app routes by shard key.

**Q3. Range-based vs Hash-based sharding?**
- Range: easy, supports range queries, risk of hot shards. Hash: uniform distribution, no range queries, mod breaks on add/remove (fix with consistent hashing).

**Q4. What is a good shard key?**
- High cardinality, even distribution, stable, frequently used in queries (enables targeted routing). Avoid monotonic/low-cardinality.

**Q5. Hot shard – what, causes, fix?**
- Uneven traffic on shard. Causes: bad key, popular entities. Fix: better key, virtual shards, consistent hashing, read replicas, rebalancing.

**Q6. Cross-shard transactions – how to handle?**
- Avoid if possible (co-locate). Else use **2PC** (strong atomicity, blocking) or **Saga** (local txns + compensating, eventual consistency, resilient).

**Q7. Consistent Hashing advantage?**
- Minimizes data movement when adding/removing shards (stable mapping) vs naive mod hash.
