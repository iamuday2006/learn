# 22. DBMS for Data Engineering

> Covers OLTP→ETL/ELT→Lake→DWH/Lakehouse→Analytics, Postgres/MySQL, Snowflake/BigQuery/Redshift, Databricks/Delta Lake, why DEs need DBMS even with Spark/Databricks.

## 1. Why Data Engineers Need DBMS Knowledge

Even with Spark/Databricks/Cloud, DEs must understand:
- **Data modeling** (3NF vs Star/Snowflake, normalization/denormalization)
- **Transactions/ACID** (data correctness, consistency)
- **Indexes, query processing, joins** (performance, cost)
- **Partitioning/Sharding** (scalability, pruning)
- **OLTP vs OLAP** (source vs warehouse behavior)
- **Consistency, CDC, upserts** (MERGE/UPSERT, idempotency)
- **Replication, HA** (reliability, ingestion sources)

DBMS fundamentals are essential for **pipelines, modeling, performance, correctness**.

## 2. OLTP vs OLAP (DE Context)

| Aspect | **OLTP (Operational)** | **OLAP (Analytical)** |
|---|---|---|
| **Purpose** | Application transactions (source of truth) | Analytics, BI, reporting, ML features |
| **Systems** | PostgreSQL, MySQL, SQL Server | Snowflake, BigQuery, Redshift, Databricks |
| **Data Shape** | Normalized (3NF) | Denormalized (Star/Snowflake, Dim–Fact) |
| **Storage** | Row-oriented | Column-oriented |
| **Freshness** | Real-time/current | Batch/near-real-time |
| **Users** | Apps, Backend | Analysts, DS, DE, BI |
| **Queries** | Point lookups, small | Large scans, aggregations |
| **Volume** | Transactional | Historical (massive) |

## 3. Data Architecture Flow

`	ext
OLTP (Sources)
  ↓
Extraction (CDC/Batch)
  ↓
Raw Data (Data Lake – S3/ADLS/GCS)
  ↓
Staging / Bronze
  ↓
Transformation (ETL/ELT)
  ↓
Clean/Curated (Silver)
  ↓
Dimensional/Fact (Gold) → Data Warehouse / Lakehouse
  ↓
Analytics/BI/ML (Databricks, Snowflake, PowerBI)
`

### ETL vs ELT

| Aspect | **ETL** (Extract–Transform–Load) | **ELT** (Extract–Load–Transform) |
|---|---|---|
| **Order** | Transform **before** loading to DW | Load **raw** first, transform **in** DW/lakehouse |
| **Compute** | External (ETL tool) | DW/Lakehouse compute (Snowflake/DB/Databricks) |
| **Flexibility** | Less on raw, curated only | Keep raw + transform on-demand |
| **Cost/Scale** | Fixed ETL infra | Leverage elastic cloud compute |
| **Modern** | Legacy batch | **Preferred** (cloud DW/lakehouse, ELT) |
| **Examples** | Informatica, Talend (older) | dbt + Snowflake/BigQuery/Databricks |

## 4. Data Lake, Data Warehouse, Lakehouse

| Concept | Storage | Schema | Purpose | Examples |
|---|---|---|---|---|
| **Data Lake** | Raw files (Parquet/JSON/CSV/ORC) | **Schema-on-Read** | Store **all** raw data (structured+semi+unstructured) | S3, ADLS, GCS, MinIO |
| **Data Warehouse (DWH)** | Structured tables (curated) | **Schema-on-Write** | Clean, modeled, optimized for **SQL analytics** | **Snowflake, BigQuery, Redshift, Synapse** |
| **Data Lakehouse** | Files + ACID transaction layer | Schema-on-Read+Write | Combine **Lake (cheap, flexible)** + **Warehouse (ACID, SQL, governance)** | **Databricks (Delta Lake), Delta/Apache Iceberg, Apache Hudi** |

**Lakehouse** solves: Lakes lack ACID/transactions/governance; Warehouses expensive for raw/large unstructured.

### Delta Lake (Databricks)
- **ACID transactions** on data lake files (Parquet)
- **Time Travel** (versioning)
- **UPSERT/MERGE**, **schema evolution**
- **Optimizations** (Z-Order, compaction, V-Order)
- **Bronze/Silver/Gold** Medallion Architecture

## 5. Cloud Data Warehouse Platforms

| Platform | Architecture | Columnar | Notes |
|---|---|---|---|
| **Snowflake** | Multi-cluster shared data (separates storage/compute) | Yes (columnar compressed) | Auto-scaling, zero-copy cloning, time travel, very elastic, SQL-first |
| **Google BigQuery** | Serverless, decoupled storage/compute (Dremel) | Columnar (Capacitor) | Pay-per-query (slot-based options), ML built-in, external tables |
| **Amazon Redshift** | Massively Parallel Processing (MPP), RA3/Spectrum | Columnar | Spectrum (query S3), sort/dist keys matter for perf, workload management |
| **Azure Synapse** | MPP + Spark integration | Columnar | Unified analytics |

**Key (DE)**: Understand **partitioning/pruning, clustering keys (Snowflake/Redshift), distribution, columnar, cost vs performance**.

## 6. OLTP Sources (Relational)

| DB | Role | Notes |
|---|---|---|
| **PostgreSQL** | Primary OLTP source | ACID, strong modeling, common. CDC via Debezium/Logical Rep, WAL-based ingestion |
| **MySQL** | OLTP source | Common, binlog-based CDC (Debezium) |
| **Others** | SaaS/ERP | APIs, CDC, Fivetran/Airbyte/Stitch |

**Ingestion**: **Batch** (full/load) vs **Incremental/CDC** (Change Data Capture) for near-real-time (Debezium + Kafka).

## 7. Lakehouse & Processing

| Tool | Role | Notes |
|---|---|---|
| **Databricks** | Spark-based processing + Delta Lake + SQL | Medallion (Bronze/Silver/Gold), Unity Catalog, Photon, workflows |
| **Apache Spark** | Distributed compute (batch/stream) | Core engine; Databricks managed |
| **Delta/Apache Iceberg/Hudi** | Table formats (ACID + versioning) | Lakehouse open table formats |
| **dbt** | SQL transformation (ELT) | Modular, versioned, tests, docs (critical DE tool) |

**Medallion Architecture**:
- **Bronze**: Raw ingested (immutable, as-is)
- **Silver**: Cleansed, deduped, conformed (normalized/clean)
- **Gold**: Business-level, curated (facts/dims, denormalized for analytics)

## 8. Data Modeling (DE)

| Model | Normalized/Denorm | Use |
|---|---|---|
| **3NF (Relational)** | Normalized | OLTP (sources) |
| **Star Schema** | Denormalized | OLAP/DW – fact + dimension (simple, fast) |
| **Snowflake Schema** | Partly normalized dims | OLAP – less redundancy, more joins |

**Dimensional Modeling (Kimball)** dominates DW (facts/measures, dims/attributes).

## 9. Why DE Needs DBMS (Even with Spark/Databricks)

| Concept | Why It Matters in DE |
|---|---|
| **ACID** | Guarantees correctness in MERGE/UPSERT, CDC, incremental loads (Delta Lake brings ACID to files) |
| **Normalization/Denorm** | Model sources (3NF) vs marts (star) correctly |
| **Indexes** | Understand read perf; DWs use clustering/sorting instead |
| **Query Optimization** | Cost-based, join strategies, pruning – applies to SQL engines (Snowflake/Databricks SQL) |
| **Partitioning/Clustering** | Partition pruning in DW/lake (date partition) + clustering keys (Snowflake) ≈ DB partitioning/indexing |
| **Transactions** | Idempotent pipelines, exactly-once semantics |
| **Consistency/Isolation** | CDC ordering, late-arriving data, deduplication |
| **Joins/Keys** | Surrogate/business keys, SCD (Slowly Changing Dimensions) |
| **Storage I/O** | Columnar vs row, file sizes (Parquet), compression – DB storage knowledge transfers |

**Key point**: Spark is distributed compute on files; DWs are DB engines (columnar, MPP). DBMS fundamentals explain **why** they perform/behave this way.

## 10. Modern Data Stack (Common)

| Layer | Tools |
|---|---|
| **Ingestion** | Fivetran, Airbyte, Meltano, Debezium (CDC), Kafka |
| **Storage** | S3/ADLS/GCS (Lake), Snowflake/BigQuery (DWH) |
| **Transform** | **dbt** (SQL ELT), Spark/Databricks |
| **Orchestration** | Airflow, Prefect, Dagster |
| **Observability/Quality** | Great Expectations, Soda, Monte Carlo |
| **BI** | Metabase, PowerBI, Tableau, Looker |
| **Catalog/Governance** | Unity Catalog, DataHub, Amundsen |

## 11. Practical DE Workflow Example

`	ext
1. OLTP (Postgres) → CDC via Debezium → Kafka → Bronze (Raw Parquet/S3)
2. Databricks (Spark) cleans → Silver (Delta Lake, deduped, typed)
3. dbt transforms Silver → Gold (facts/dims, star schema) in Snowflake
4. PowerBI reads Gold for dashboards
5. ACID + Time Travel via Delta; Pruning via partition by date
`

## Key Takeaways (Interview)

- **OLTP** (normalized, row) feeds pipelines → **ELT** loads raw to Lake/DWH → transform to **curated (Star/Snowflake, columnar)** for analytics.
- **Lakehouse = Lake + ACID + Warehouse SQL** (Delta/Iceberg/Hudi).
- **Snowflake/BigQuery = cloud DW (columnar, MPP/serverless, elastic)**. Redshift MPP.
- **DBMS concepts (ACID, normalization/denorm, partitioning, joins, optimization)** directly apply to DE (modeling + performance + correctness).
- **dbt + ELT + cloud DW/lakehouse** is modern pattern.
- **CDC + incremental + idempotency** critical for reliability.

## Interview Qs (DE-Focused)

**Q1. OLTP vs OLAP from DE perspective?**
- OLTP = source (normalized, row, transactions). OLAP = target (denormalized, columnar, aggregates). DE moves/ models between them.

**Q2. ETL vs ELT – difference & modern preference?**
- ETL transforms before load (external). ELT loads raw, transforms in DW (scalable, keeps raw). Modern prefers **ELT** with cloud DW/lakehouse.

**Q3. Data Lake vs Warehouse vs Lakehouse?**
- Lake: raw, schema-on-read, cheap. Warehouse: curated, schema-on-write, SQL/ACID. Lakehouse: Lake+ACID+SQL (Delta/Iceberg) – best of both.

**Q4. Why need DBMS knowledge as Data Engineer?**
- Modeling (3NF vs Star), ACID/correctness, joins/optimization, partitioning/pruning, CDC/merges, performance tuning – transfers to SQL engines/Spark.

**Q5. Medallion Architecture (Bronze/Silver/Gold)?**
- Bronze: raw ingested. Silver: cleaned/conformed. Gold: business-level curated (facts/dims) for BI/ML.

**Q6. Columnar vs Row storage – when used?**
- Row (OLTP): full-row access. Columnar (OLAP/DW): few columns + aggregates → less I/O, better compression.

**Q7. Snowflake vs Redshift vs BigQuery?**
- Snowflake: multi-cluster shared data, elastic. BigQuery: serverless Dremel, pay-per-query. Redshift: MPP, sort/dist keys, Spectrum for S3.
