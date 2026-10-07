# 12. SQL vs NoSQL

> Covers: 08:26:58 – NoSQL vs SQL DB. Types, trade-offs, when to choose (avoid oversimplified "structured vs unstructured").

## 1. SQL (Relational Databases)

**SQL Databases** are based on **Relational Model** (tables, rows, columns, relations via FKs). Use **Structured Query Language (SQL)**.

**Key Characteristics**:
- **Structured schema** (fixed columns, strong typing)
- **ACID compliant** (strong consistency, transactions)
- **Supports JOINs** across relations
- **Normalization** to reduce redundancy
- **Vertical scaling** common; horizontal (sharding/replication) possible but more complex
- **Examples**: PostgreSQL, MySQL, MariaDB, SQL Server, Oracle, SQLite

**Best for**: Structured, relational data with complex relationships, strong consistency needs (finance, banking, inventory).

## 2. NoSQL (Not Only SQL)

**NoSQL** = non-relational databases designed for **flexible schemas, high scalability, distributed systems**. Trade **strong consistency** for **availability/partition tolerance** or flexible modeling.

**Key Characteristics**:
- **Schema-less / Flexible schema** (dynamic documents/columns)
- **Distributed-first** (horizontal scaling easy)
- **High availability, high throughput**
- **BASE properties** often (Basically Available, Soft state, Eventually Consistent) vs ACID
- **No complex JOINs in same way** (denormalized, embedded)
- **Varied data models** (document, key-value, column-family, graph)

**BASE** (conceptual): Favor availability over immediate consistency (eventual consistency common).

## 3. SQL vs NoSQL Comparison

| Aspect | SQL (Relational) | NoSQL (Non-Relational) |
|---|---|---|
| **Data Model** | Relational (Tables/Rows/Columns) | Document, Key-Value, Wide-Column, Graph |
| **Schema** | Fixed, predefined (schema-on-write) | Flexible, dynamic (schema-on-read) |
| **Query Language** | SQL (standard) | Varies (MQL, CQL, Gremlin, API-based) |
| **Scalability** | Vertical (scale-up) dominant, Horizontal harder (sharding complex) | **Horizontal (scale-out)** easy, distributed by design |
| **Transactions** | Strong **ACID** (multi-row, complex) | Often **ACID at doc/record level**, multi-entity distributed txns limited (eventual/causal in some) |
| **Consistency** | Strong Consistency (default) | Tunable: Strong → Eventual Consistency (CAP trade-off) |
| **Joins** | Supported (powerful, relational) | Limited/None; prefer **denormalization/embedding** |
| **Performance** | Great for structured, complex relational queries | Great for high volume, simple, denormalized, distributed reads/writes |
| **Data Relationships** | Normalized, enforced via FKs | Often embedded/denormalized (avoid cross-entity joins) |
| **Examples** | PostgreSQL, MySQL, SQL Server | MongoDB, Redis, Cassandra, DynamoDB, Neo4j |
| **Best For** | Transactional (OLTP), complex queries, data integrity critical | Big data, real-time, unstructured/semi-structured, high scale, rapid iteration |

> **Important**: Not "SQL=structured, NoSQL=unstructured". NoSQL handles **semi-structured** (JSON) well; both can store varied forms. Difference is **model + scaling + consistency trade-offs**.

## 4. NoSQL Data Models

### 4.1 Key-Value Store
- Simplest: **key → value** (blob/string/json)
- Ultra-fast O(1) lookup by key
- No complex queries, no joins
- **Examples**: **Redis**, DynamoDB, Memcached
- **Use**: Caching, session storage, rate limiting, feature flags, leaderboards

### 4.2 Document Store
- Stores **documents** (JSON/BSON). Self-contained, nested.
- Flexible schema, can embed related data
- Query by fields inside documents
- **Examples**: **MongoDB**, CouchDB, Firestore
- **Use**: Product catalogs, user profiles, CMS, logs, content-heavy apps

### 4.3 Wide-Column Store (Column-Family)
- Tables split by **columns** (not rows). Optimized for high write, large datasets, distributed.
- Sparse, columnar-like for wide tables
- Tunable consistency (eventual/strong)
- **Examples**: **Apache Cassandra**, HBase, ScyllaDB
- **Use**: Time-series, IoT, telemetry, logs, write-heavy distributed (billions of rows)

### 4.4 Graph Database
- Stores **nodes + edges + properties** (relationships first-class)
- Optimized for **traversing relationships** (shortest path, social graphs)
- Cypher/Gremlin queries
- **Examples**: **Neo4j**, ArangoDB, Amazon Neptune
- **Use**: Social networks, fraud detection, recommendations, knowledge graphs, dependency graphs

## 5. When to Use SQL vs NoSQL

| Scenario | Choose | Why |
|---|---|---|
| **ACID transactions critical** (payments, banking, inventory) | **SQL** | Strong consistency, multi-row atomicity |
| **Complex queries, many JOINs, reporting** | **SQL** | Relational model + SQL powerful |
| **Fixed, well-defined schema** | **SQL** | Enforces structure/integrity |
| **Need to enforce FKs/constraints** | **SQL** | Built-in referential integrity |
| **Rapid schema changes, agile iteration** | **NoSQL** | Schema-less/flexible |
| **Massive scale (billions), distributed globally** | **NoSQL** | Horizontal scaling by design (sharding easy) |
| **High write throughput (logs, telemetry, IoT)** | **NoSQL (Wide-column)** | Optimized for writes, distributed |
| **Unstructured/semi-structured (JSON)** | **NoSQL (Document)** | Native JSON, nesting/embedding |
| **Relationship-heavy graph traversal** | **NoSQL (Graph)** | Edges first-class |
| **Real-time low-latency (caching/sessions)** | **NoSQL (KV)** | O(1), in-memory (Redis) |
| **Hybrid needs** | **Polyglot** | Use both (e.g. PostgreSQL + Redis + MongoDB) |

## 6. ACID vs BASE

| Aspect | ACID (SQL) | BASE (NoSQL, typical) |
|---|---|---|
| **A** | Atomic (all-or-nothing) | **B** Basically Available (available in partitions) |
| **C** | Consistent (valid state always) | **S** Soft State (state may change over time) |
| **I** | Isolated (no interference) | **E** Eventually Consistent (converges later) |
| **D** | Durable (committed survives) | Focus on availability/partition tolerance |

**Note**: Many NoSQL DBs now offer **strong consistency/configurable ACID** (MongoDB multi-doc ACID, DynamoDB txns) — lines blur.

## 7. CAP Theorem Context (Preview 18)

CAP: **Consistency, Availability, Partition Tolerance** – can’t have all 3 in distributed partition. NoSQL often chooses **AP** (availability+partition), SQL RDBMS traditionally **CP** in distributed (or CA single-node). See 18_CAP_Theorem.

## Key Takeaways (Interview)

- **SQL = ACID + structured + relational + joins**. Great for correctness/transactions.
- **NoSQL = flexible + distributed + scalable + tunable consistency**. Great for scale/high throughput.
- **Trade-off**: Consistency vs Availability + Scalability (CAP/BASE).
- **Don't say "unstructured"** — say **flexible schema/semi-structured + distributed-first**.
- **Choose by use case**, not hype. Many systems are **polyglot** (mix SQL + NoSQL).
- **Embedding vs Normalization**: NoSQL denormalizes/embeds (avoid joins), SQL normalizes.

## Interview Qs

**Q1. SQL vs NoSQL – key differences?**
- SQL: relational, fixed schema, ACID, joins, vertical scale. NoSQL: non-relational, flexible schema, BASE/eventual (often), horizontal scale, denormalized.

**Q2. When would you choose NoSQL over SQL?**
- Need massive horizontal scale, high write throughput, flexible schema (rapid changes), semi-structured JSON, or specific models (graphs/time-series). Not when strong multi-row ACID critical.

**Q3. Explain 4 types of NoSQL with examples/use cases.**
- KV (Redis): cache/sessions. Document (MongoDB): JSON docs/CMS. Wide-column (Cassandra): time-series/write-heavy. Graph (Neo4j): relationships/social.

**Q4. ACID vs BASE?**
- ACID strong correctness. BASE prefers availability, eventual consistency (distributed systems trade-off).

**Q5. Can NoSQL support ACID transactions?**
- Yes, many modern (MongoDB multi-doc ACID, DynamoDB transactions). Scope varies (single doc vs distributed). Traditional NoSQL relaxed.
