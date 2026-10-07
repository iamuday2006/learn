# 21. Real-World Database Architecture

> Combines replication/sharding/partitioning/HA/caching/pooling into production patterns.

## 1. What is Real-World DB Architecture?

Pragmatic design combining techniques to meet **scalability, availability, performance, consistency** needs. Focus on **simplicity first**, evolve as scale grows.

## 2. Typical Evolution

| Stage | Architecture | Notes |
|---|---|---|
| **Startup/Small** | **Single DB (Vertical)** | Simple, Postgres/MySQL. Focus on schema, indexes |
| **Growth (Read-heavy)** | **Primary + Read Replicas + Cache** | Add replicas + Redis, connection pooling, LB for reads |
| **Scale Writes/Size** | **Partitioning** | Time-based partitioning for large tables (logs/orders) |
| **Massive Scale** | **Sharding + HA + Distributed Cache** | True horizontal scale, eventual consistency where acceptable |
| **Global** | **Multi-region** | Read replicas/active-passive across regions, geo-routing |

## 3. Common Production Patterns

### 3.1 Monolith + Single RDBMS (Simple)
`	ext
App → Single DB (Postgres)
`
Sufficient for many MVPs. Add indexes, pooling.

### 3.2 Primary-Replica with Read Scaling
`	ext
Client → LB(App) → App
                ├─ Write → Primary DB
                └─ Read  → Read Replica(s) (via LB)
Cache: Redis for hot reads
`
**Use**: E-commerce, SaaS read-heavy.

### 3.3 High Availability (HA) with Failover
`	ext
App → Proxy/HAProxy → Primary (active)
                    ↕ (streaming repl + heartbeat)
                  Standby (passive) – auto-promoted on failover
Redis + PgBouncer for pooling
`
**Use**: Critical apps needing minimal downtime.

### 3.4 Partitioned + Replicated (Large Tables)
`	ext
Orders table RANGE partitioned by month (same instance)
+ Streaming replication to standby for HA
+ Read replicas for reporting
`
**Use**: Time-series, billing, logs.

### 3.5 Sharded Architecture (Massive Scale)
`	ext
App → Shard Router (by shard key: user_id)
     ├─ Shard 1 (Primary+Replica)
     ├─ Shard 2 (Primary+Replica)
     └─ Shard N (Primary+Replica)
Global Cache: Redis Cluster
Config Service for routing
`
**Use**: Social, multi-tenant at scale.

## 4. Combining Techniques

| Technique | Purpose | When |
|---|---|---|
| **Connection Pooling (PgBouncer/Hikari)** | Prevent connection exhaustion | Always (high concurrency) |
| **Caching (Redis/Memcached)** | Cut DB load, faster reads | Hot/frequently read data |
| **Read Replicas** | Read scale + reporting isolation | Read >> Write |
| **Partitioning** | Manage large tables, archival | Time-based/bulky tables |
| **Sharding** | Write+data scale across nodes | Dataset too big for one node |
| **Load Balancing** | Distribute traffic | Multiple app/DB nodes |
| **WAL/Streaming Rep** | HA + durability | Need uptime + DR |
| **Backups (PITR)** | Point-in-time recovery | Production critical |

## 5. OLTP + OLAP Separation

Production often separates **operational** vs **analytical**:

`	ext
OLTP DB (Postgres Primary+Replicas) – live transactions
  ↓ (Change Data Capture / ETL/ELT)
Data Lake / Staging
  ↓
Data Warehouse/Lakehouse (Snowflake/BigQuery/Redshift/Databricks)
  ↓
BI Tools (Tableau/Metabase/PowerBI)
`

**Why**: Heavy analytics scans don't impact OLTP. Use **columnar** for OLAP.

## 6. Example: E-commerce Real-World

| Component | Choice | Reason |
|---|---|---|
| **Core OLTP** | PostgreSQL (Primary+2 Replicas) | ACID, relational integrity |
| **Catalog Search** | Elasticsearch | Full-text, filters, faceting |
| **Cart/Sessions** | Redis | Fast, TTL, volatile |
| **Image/Assets** | S3 + CDN | Scalable object storage |
| **Orders** | Partitioned by order_date (Range) | Easy archival, pruning |
| **Analytics** | Snowflake/Redshift (via ETL) | Columnar, aggregates |
| **Queue** | Kafka/SQS | Async emails/inventory updates |
| **Connection Pooling** | PgBouncer | Handle high traffic |

**Scale path**: Start simple → add replicas/cache → partition orders → shard users/orders only if massive.

## 7. Example: Ride-Sharing (Real-Time)

| Component | Choice | Reason |
|---|---|---|
| **Rides/Users/Payments** | PostgreSQL (HA cluster) | Strong consistency (bookings) |
| **Driver Locations** | Redis (Geo + TTL) | Real-time, geospatial queries |
| **Trip Locations (History)** | TimescaleDB (time-series partitioned) | High ingest, time-range |
| **Matching/Dispatch** | Redis + app logic | Low latency |
| **Payments** | OLTP with strict ACID | Financial correctness |
| **Analytics** | ClickHouse/BigQuery | High-speed aggregates |
| **WebSockets** | Redis pub/sub | Real-time updates |

## 8. High Availability Checklist

- [ ] **Redundancy**: Primary + Standby/Replicas
- [ ] **Automatic Failover**: Orchestrator (Patroni) tested
- [ ] **Backups**: Regular + **Point-in-Time Recovery (PITR)**
- [ ] **Monitoring**: Lag, connections, disk, CPU, replication status
- [ ] **Connection Pooling**: Prevent exhaustion
- [ ] **Health Checks**: LB detects unhealthy nodes
- [ ] **Quorum/Fencing**: Avoid split-brain
- [ ] **Geo-DR** (optional): Cross-region standby
- [ ] **Runbook**: Documented failover/recovery

## 9. Simplicity vs Complexity

**Advice**:
- **Premature sharding** is expensive (dev+ops). Avoid.
- **Indexes + queries + cache** solve majority of perf issues.
- **Measure first** (slow queries, bottlenecks) before scaling.
- **Design for failure** (network/partitions happen).
- **Keep consistency requirements explicit** (CP vs AP acceptable per feature).

## Key Takeaways (Interview)

- **Evolutionary**: Vertical → Replicas+Cache → Partitioning → Sharding.
- **Real systems combine** multiple techniques (rarely just one).
- **OLTP vs OLAP separation** critical for analytics at scale.
- **HA needs** replication + failover + monitoring + backups.
- **Cache for hot reads**, **pooling for concurrency**, **partition for large tables**, **shard for horizontal scale**.
- **Simplicity wins** – scale only when data shows need.

## Interview Qs

**Q1. Design a scalable e-commerce DB architecture.**
- Start: Postgres Primary+Replicas, Redis cache, PgBouncer. Partition orders by date. Add Elasticsearch for search. Separate OLAP to DW. Shard later by user_id if massive.

**Q2. How would you make DB highly available?**
- Streaming replication (sync/semi-sync), hot standby, automatic failover (Patroni), PgBouncer/HAProxy, health checks, regular backups+PITR, monitoring replication lag.

**Q3. When to shard vs add read replicas?**
- Replicas: **read scaling** + HA, keep single write source. Shard: **write scaling + data size** beyond single node capacity.

**Q4. Why separate OLTP and OLAP?**
- Heavy analytical queries (scans/aggregates) hurt OLTP latency/concurrency. Separate to **columnar DW** for faster analytics, protect transactional workload.

**Q5. Real-world production stack essentials?**
- HA (replication+failover), caching, connection pooling, load balancing, backups/PITR, monitoring/alerts, partitioning for large tables, security.
