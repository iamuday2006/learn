# 20. Scaling Databases

> Covers: 20_Scaling_Databases. Vertical vs Horizontal, Read replicas, Caching, Partitioning, Sharding, Load balancing, Connection pooling. When to choose.

## 1. Why Scale?

As data/traffic grows: need to handle **more reads/writes, larger dataset, lower latency, higher availability** without degrading performance.

## 2. Vertical vs Horizontal Scaling

| Aspect | **Vertical Scaling (Scale-Up)** | **Horizontal Scaling (Scale-Out)** |
|---|---|---|
| **Approach** | Add more power to **same server** (CPU, RAM, Disk, SSD) | Add **more servers/nodes** to cluster |
| **Cost** | Expensive beyond point (diminishing returns) | Cheaper commodity hardware, grows linearly |
| **Limit** | **Hardware limit** (max CPU/RAM/disk) | **Theoretically unlimited** (add nodes) |
| **Complexity** | **Simple** (no major app changes) | **Complex** (sharding, routing, distributed txns) |
| **Downtime** | Often needs restart/upgrade | Can be **zero-downtime** with careful design |
| **Availability** | **Single point of failure** | Better HA (redundancy across nodes) |
| **Examples** | Upgrade EC2 to larger instance | Add read replicas, shards, cluster nodes |
| **Best For** | Small–medium, quick fix, low complexity | Large-scale, high growth, global distribution |

**Rule**: Start **vertical**, move to **horizontal** as scale demands.

## 3. Scaling Techniques

### 3.1 Read Replicas (Read Scaling)
Offload reads to replicas (async). See 14_Replication.

- **Use**: Read-heavy (reports, dashboards)
- **Pros**: Easy, uses existing replication
- **Cons**: Stale reads with async

### 3.2 Connection Pooling
Reuse DB connections (expensive to create). Reduce connection overhead/exhaustion.

- **Why**: Opening TCP+auth per request is costly; pool maintains reusable connections
- **App-side**: HikariCP (Java), pgBouncer (Postgres), Sequelize pool
- **Benefits**: Lower latency, higher throughput, avoids "too many connections"
- **Tuning**: pool size, idle timeout, max lifetime

**Architecture**: App → Connection Pool → DB

### 3.3 Caching (Reduce DB Load)
Store frequently accessed data in **fast memory**.

| Cache Type | Location | Notes |
|---|---|---|
| **Application Cache** | In-app memory (local) | Fast, but per instance (not shared) |
| **Distributed Cache** | Redis/Memcached (shared) | Scalable, shared across app nodes |
| **CDN Cache** | Edge | Static assets |
| **Query Result Cache** | DB-level | Some DBs support (less common) |

**Patterns**:
- **Cache-Aside (Lazy)**: Check cache → miss → load from DB → set cache
- **Write-Through**: Write to cache+DB together
- **Write-Behind (Async)**: Write to cache, flush to DB later (eventual)
- **Read-Through**: Cache transparently loads on miss

**Use**: Hot reads (user profiles, product catalogs), sessions. **Avoid caching** highly dynamic/transactional critical data without invalidation.

**Cache Invalidation** = hard problem (TTL, explicit invalidation).

### 3.4 Partitioning (Manageability/Query Perf)
Logical split within same instance. See 16_Partitioning.

- **Use**: Large tables, time-series, archival, prune queries

### 3.5 Sharding (Horizontal Data Scale)
Split across multiple nodes by shard key. See 17_Sharding.

- **Use**: Massive dataset/throughput, need true scale-out

### 3.6 Load Balancing
Distribute traffic across multiple DB nodes/app nodes.

- **For Reads**: Load balance across read replicas
- **For Writes**: Usually go to single primary (unless active-active)
- **Tools**: HAProxy, ProxySQL, PgBouncer (routing), AWS RDS Proxy
- **Strategies**: Round-robin, least connections, weighted

## 4. Scaling by Workload Type

| Workload | Bottleneck | Solution |
|---|---|---|
| **Read-Heavy** (feeds, reports) | Too many SELECTs on primary | **Read Replicas + Caching (Redis)** + Load Balancer |
| **Write-Heavy** (logs, IoT, events) | High insert rate | **Sharding**, **Batch writes**, **Queue (Kafka)**, consider **Wide-column/TSDB** |
| **Mixed CRUD** (e-commerce) | Balance | **Primary + Read Replicas + Cache + Connection Pooling**; shard later if needed |
| **Large Dataset (Billions)** | Storage/scan time | **Sharding + Partitioning + Archival** |
| **Global Low-Latency** | Geo distance | **Read Replicas in regions**, **CDN + Cache**, **Multi-region** (careful with consistency) |

## 5. Connection Pooling Deep Dive

**Problem**: Creating DB connection = TCP handshake + auth + setup (~ms). High concurrency → exhaust DB connections (max_connections).

**Solution**: Pool maintains **pre-created reusable** connections.

**Key Params**:
- **Minimum/Maximum Pool Size**: Too small → wait; too large → DB overloaded
- **Connection Timeout**: Fail fast if can't get
- **Idle Timeout**: Close unused
- **Max Lifetime**: Rotate to avoid stale

**Example (Postgres)**: Use **PgBouncer** (connection pooler in transaction/session mode) in front of DB to handle thousands of client connections with few DB connections.

## 6. Scaling Decision Tree (Pragmatic)

`	ext
1. Is it read-heavy?
   → Yes: Add **Read Replicas + Caching** first

2. Is DB CPU/Memory maxed but reads OK?
   → Try **Vertical Scaling** (quick)

3. Still hitting limits (writes/size)?
   → Consider **Partitioning** (same instance)

4. Need true horizontal scale across nodes?
   → Consider **Sharding** (complex, last resort)

5. Always: Add **Connection Pooling** early
6. Always: Use **Caching** for hot, non-transactional data
`

**Golden Rule**: **Don't shard until you have to**. Optimize first (indexes, queries, cache, replicas, partitioning).

## 7. Scaling Patterns in Production

| Pattern | When | Notes |
|---|---|---|
| **Primary-Replica + LB** | Most apps | Simple, read scale + HA |
| **CQRS (Command Query Responsibility Segregation)** | Read/write models differ | Separate read/write DBs; complex sync (eventual) |
| **Event-Driven + Queue** | Write spikes (bursts) | Buffer writes via Kafka/RabbitMQ, process async |
| **Materialized Views** | Expensive aggregations | Precompute for reporting |
| **Read-Only DB for Analytics** | Separate OLAP | Avoid mixing heavy reports with OLTP |
| **Multi-Region Active-Passive** | DR + geo reads | Careful with failover/consistency |

## Key Takeaways (Interview)

- **Vertical** = simpler but limited. **Horizontal** = scalable but complex.
- **Read scaling**: Replicas + Cache easiest wins.
- **Write scaling**: Sharding is main path (hard).
- **Connection pooling** prevents exhaustion, improves throughput.
- **Caching** reduces DB load massively but needs invalidation.
- **Partitioning** helps manageability/query perf in same instance.
- **Shard only when necessary** – high complexity + cross-shard trade-offs.

## Interview Qs

**Q1. Vertical vs Horizontal Scaling – differences?**
- Vertical: bigger server (scale-up), simple, limited. Horizontal: more nodes (scale-out), complex, highly scalable, HA-friendly.

**Q2. How to scale read-heavy application?**
- Add **read replicas**, use **distributed cache (Redis)**, **load balancer** for reads, **CDN** for static. Also optimize queries/indexes.

**Q3. Connection Pooling – why and how?**
- Avoids creating new connections per request (costly). Reuses pool → lower latency, prevents max connections hit. Use app pooler (Hikari) or proxy (PgBouncer).

**Q4. Caching strategies & invalidation?**
- Cache-Aside common: check cache, miss→DB→set. Invalidation hard: use **TTL**, explicit key deletion on update, or write-through. Stale data risk.

**Q5. When to choose sharding over partitioning?**
- Shard when **need horizontal scale across multiple servers** (dataset too large for one instance, high write throughput). Partition when staying on **same instance** for manageability/pruning.

**Q6. How to handle write spikes?**
- Use **async queues** (Kafka/SQS), **batching**, backpressure. Also consider **sharding** long-term.

**Q7. CQRS – when useful?**
- When read/write patterns differ drastically (complex domain, many reads, few writes or vice versa). Allows optimizing each side; introduces eventual consistency.
