# 13. Database Types

> Covers: 09:33:20 – Types of Database. Includes relational, document, KV, wide-column, graph, time-series, in-memory, OLTP, OLAP, distributed. Comparison tables.

## 1. Overview

Databases classified by **data model, storage, purpose, workload**. Many systems combine types (polyglot). Key: match type to workload (OLTP vs OLAP, real-time vs analytics).

## 2. By Data Model

| Type | Model | Schema | Strength | Weakness | Examples |
|---|---|---|---|---|---|
| **Relational (RDBMS)** | Tables (rows/cols), FKs | Fixed/Strong | ACID, integrity, SQL, joins | Vertical scaling, rigid for unstructured | PostgreSQL, MySQL, SQL Server |
| **Document** | JSON/BSON documents (nested) | Flexible | Semi-structured, agile, embedding | Limited cross-doc joins | MongoDB, CouchDB |
| **Key-Value (KV)** | key→value | Very flexible | Ultra-fast, simple, O(1) | No querying by value, minimal indexing | Redis, DynamoDB, Memcached |
| **Wide-Column (Column-Family)** | Column families, sparse rows | Flexible per row | High write, distributed, scalable | Limited ad-hoc queries (need careful design) | Cassandra, HBase, ScyllaDB |
| **Graph** | Nodes/Edges/Properties | Flexible | Relationship traversal, complex graph queries | Not ideal for tabular aggregates | Neo4j, ArangoDB, Neptune |
| **Time-Series (TSDB)** | Time-stamped series | Semi-flexible | Fast time-range, compression, rollups | Less for general OLTP/joins | TimescaleDB, InfluxDB, Prometheus |
| **Object/Other** | Objects/BLOBs | Varies | Specific use cases | Less general-purpose SQL | ObjectDB |

## 3. In-Memory vs Disk-Based

| Type | Storage | Speed | Durability | Use Cases |
|---|---|---|---|---|
| **Disk-Based** | HDD/SSD | Slower (I/O) | High (WAL, checkpoints) | General-purpose, large datasets |
| **In-Memory (IMDB)** | RAM | **Very fast** (μs) | Configurable (persistence/logging) | Caching, session, real-time, leaderboard, gaming |
| **Hybrid** | RAM + Disk | Fast + durable | Yes | Redis (AOF/RDB), SAP HANA |

**Examples**: Redis (primarily in-memory + persistence), Memcached (pure in-memory), VoltDB.

## 4. OLTP vs OLAP (Crucial for Data Engineering)

**OLTP = Online Transaction Processing**. **OLAP = Online Analytical Processing**.

| Aspect | **OLTP** | **OLAP** |
|---|---|---|
| **Purpose** | Handle **day-to-day transactions** (operational) | Support **analysis, reporting, decision-making** (analytical) |
| **Workload** | Short, simple CRUD (INSERT/UPDATE/DELETE/SELECT by key) | Complex queries, aggregations, scans over large data |
| **Users** | Front-end apps, customers, clerks (many concurrent) | Analysts, BI tools, Data/BA users (fewer, heavier) |
| **Data Volume** | Current, operational data (MB–TB, smaller slices) | Historical, consolidated (GB–PB) |
| **Schema** | **Normalized** (3NF) for integrity, minimal redundancy | **Denormalized** (Star/Snowflake) for read speed |
| **Reads/Writes** | **Write-heavy + read-by-key** (balanced, high concurrency) | **Read-heavy** (large scans/aggregates) |
| **Query Type** | Point lookups, small range, exact | Ad-hoc, multi-table aggregations, rollups |
| **Performance Focus** | **Low latency, high TPS (transactions/sec)** | **High throughput for large scans, fast aggregations** |
| **ACID** | **Strict ACID** (critical correctness) | Often relaxed or eventual; focus on query speed |
| **Data Freshness** | **Real-time/current** | Near real-time or batch (updated via ETL/ELT) |
| **Storage Layout** | Row-oriented (row-wise) | **Column-oriented** (column-wise) common |
| **Examples** | PostgreSQL, MySQL, SQL Server (OLTP), Oracle | Snowflake, BigQuery, Redshift, ClickHouse, Azure Synapse, Databricks (analytics) |

### Row-Oriented vs Column-Oriented

| Aspect | **Row-Oriented** (OLTP) | **Column-Oriented** (OLAP) |
|---|---|---|
| **Storage** | Stores entire row together | Stores each column separately |
| **Best For** | Fetch **entire row** (SELECT * with few rows) | Fetch **few columns + aggregates** over many rows |
| **I/O** | Reads whole row even if few cols needed | Reads only needed columns → less I/O |
| **Compression** | Less effective per column | High (similar values in column compress well) |
| **Writes** | Fast for single-row inserts/updates | Slower for point updates (row split across columns) |
| **Use** | OLTP | OLAP/Columnar DW |

## 5. Distributed Databases

**Distributed Database** = Data spread across **multiple nodes/machines** (geographically or locally), appearing as **single logical DB**.

**Goals**: **Scalability, Availability, Fault Tolerance, Performance (locality)**.

| Type | Description | Examples |
|---|---|---|
| **Homogeneous** | Same DBMS on all nodes | PostgreSQL cluster, MySQL Group Replication |
| **Heterogeneous (Federated)** | Different DBMS, integrated (middleware) | Data virtualization, some legacy federations |

**Key Concepts**: Replication, Partitioning, Sharding, CAP (see 18), Consistency models.

## 6. Other Specialized Types

| Type | Purpose | Notes |
|---|---|---|
| **NewSQL** | Combines **ACID + SQL + horizontal scaling** | CockroachDB, Google Spanner, TiDB |
| **Multi-Model** | Supports multiple models in one DB | ArangoDB (doc+graph+KV) |
| **Search Engines** | Full-text, fuzzy, relevance search | Elasticsearch, OpenSearch (not pure OLTP) |
| **Vector DB** | Embeddings for AI/LLM (similarity search) | Pinecone, Qdrant, Weaviate, pgvector (Postgres extension) |

## 7. Quick Decision Matrix

| Use Case | Recommended | Rationale |
|---|---|---|
| **Core App (users/orders/payments)** | **Relational (Postgres/MySQL)** | ACID, integrity, relationships |
| **Catalog with flexible attrs** | **Document (MongoDB)** | JSON, schema-flex, embedding |
| **Cache/Sessions/Leaderboards** | **Key-Value (Redis)** | Ultra-fast in-memory |
| **Massive time-stamped logs/metrics** | **Wide-Column/TSDB (Cassandra/TimescaleDB)** | Write-heavy, time-range queries |
| **Social graph/recs/fraud** | **Graph (Neo4j)** | Relationship traversal |
| **BI/Dashboards/Analytics** | **OLAP DW (Snowflake/BigQuery/Redshift)** | Columnar, aggregations, scale |
| **Real-time analytics on operational** | **HTAP/NewSQL or Materialized Views** | Blend OLTP+OLAP (e.g. Citus, Timescale, ClickHouse) |

## Key Takeaways (Interview)

- **OLTP** = operational (transactions), **normalized**, row-oriented, ACID, low-latency.
- **OLAP** = analytical (reports), **denormalized/columnar**, read-heavy, aggregates over history.
- **Choose by model**: Relational for correctness/joins; Document for flexible JSON; KV for speed; Wide-column for scale; Graph for relationships; TSDB for time-series.
- **Row vs Column**: Row better for full-row fetch (OLTP), Column better for few-col aggregates (OLAP).
- **In-memory** for real-time/caching; disk-based for durability at scale.
- **NewSQL bridges** ACID + horizontal scale.

## Interview Qs

**Q1. OLTP vs OLAP – key differences?**
- OLTP: transactional, normalized, row-oriented, ACID, current data, many small writes/reads. OLAP: analytical, denormalized/columnar, read-heavy, historical, large aggregations.

**Q2. When to use Document DB vs Relational?**
- Relational: strong relationships, multi-row ACID, constraints. Document: flexible schema, nested data, agile dev, less complex cross-entity joins.

**Q3. Row-oriented vs Column-oriented storage?**
- Row: entire row together (OLTP, full-record access). Column: columns separate (OLAP, aggregate few cols over many rows) – better I/O + compression.

**Q4. Graph DB use cases?**
- Social networks, recommendation engines, fraud rings, knowledge graphs, shortest path, dependency analysis.

**Q5. Time-Series DB vs regular RDBMS?**
- TSDB optimized for time-range, high ingest, compression, downsampling/retention. RDBMS general-purpose but can use TimescaleDB/Postgres for TS.
