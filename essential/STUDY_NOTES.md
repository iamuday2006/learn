# Data Engineering Study Notes

These notes summarize the topics in `TODO.md` for internship preparation. For every
technology, remember the interview pattern: **what it is, why it exists, the
problem it solves, where it is used, its limitation, and one example**.

## 1. Storage Fundamentals

**Data storage** is the durable recording of data so it can be retrieved,
processed, shared, and recovered later. Persistent storage is needed because
memory is temporary and business data must survive process or machine failures.

| Type | Meaning | Examples |
|---|---|---|
| Structured | Fixed rows, columns, and types | PostgreSQL tables, CSV |
| Semi-structured | Flexible or nested structure with tags/keys | JSON, XML, Avro |
| Unstructured | No regular tabular structure | Images, audio, documents, logs |

**File storage** is inexpensive and flexible, but the application must manage
formats, consistency, and querying. **Database storage** provides indexes,
constraints, transactions, and query execution, but is usually more expensive
and structured.

**Row-oriented storage** keeps complete records together and is good for OLTP
point lookups and writes. **Column-oriented storage** keeps values from one
column together and is good for analytics because queries often read only a few
columns; compression is also more effective.

## 2. OLTP and OLAP

### OLTP

OLTP (Online Transaction Processing) supports day-to-day business operations:
placing orders, updating account balances, or registering users. It has many
concurrent users, short selective queries, frequent inserts/updates/deletes,
and strong transactional consistency.

**ACID**:

- **Atomicity:** a transaction succeeds completely or has no effect.
- **Consistency:** constraints and business rules remain valid.
- **Isolation:** concurrent transactions do not incorrectly interfere.
- **Durability:** committed data survives failures.

### OLAP

OLAP (Online Analytical Processing) supports reporting, dashboards, trend
analysis, and machine learning. It is read-heavy, scans large historical
datasets, and performs joins and aggregations.

| Concern | OLTP | OLAP |
|---|---|---|
| Goal | Run the business | Analyze the business |
| Data | Current operational state | Historical, integrated data |
| Queries | Short and selective | Long scans and aggregations |
| Writes | Frequent | Batch or controlled loads |
| Schema | Usually normalized | Often dimensional/denormalized |
| Optimization | Fast transactions | Fast analytical scans |
| Examples | PostgreSQL, MySQL | Snowflake, BigQuery, Redshift |

Do not run large reports directly on a production OLTP database: scans compete
with customer transactions, operational schemas are not analytics-friendly,
and long-running queries can affect availability.

## 3. Data Warehouse

A **data warehouse** is a centralized, governed system for integrated,
historical, structured analytical data. Examples include Snowflake, BigQuery,
Redshift, and Synapse.

Typical flow:

```text
OLTP / APIs / Files -> Ingestion -> Staging or Raw -> Warehouse -> BI
```

- **Sources:** operational databases, SaaS APIs, files, and event systems.
- **Ingestion:** extracts or receives data and records load metadata.
- **Staging/raw:** preserves incoming data for validation and replay.
- **Transformation:** cleans, standardizes, joins, and applies business rules.
- **Warehouse:** stores trusted analytical models.
- **BI/data marts:** expose focused datasets to analysts and dashboards.

Classic warehouse characteristics are **subject-oriented** (sales, customers),
**integrated** (consistent names and types), **time-variant** (history is
retained), and **non-volatile** (analytical data is not constantly overwritten
by end-user transactions).

**Full load** replaces or reloads all data and is simple but expensive.
**Incremental load** processes only new or changed data and is faster but
requires reliable change detection, deduplication, and late-data handling.
**CDC (Change Data Capture)** records source inserts, updates, and deletes.
An **upsert** inserts new rows and updates existing rows. SQL `MERGE` is a
common implementation.

```sql
MERGE INTO target t
USING changes s ON t.order_id = s.order_id
WHEN MATCHED THEN UPDATE SET amount = s.amount, updated_at = s.updated_at
WHEN NOT MATCHED THEN INSERT (order_id, amount, updated_at)
VALUES (s.order_id, s.amount, s.updated_at);
```

## 4. Data Lake, Warehouse, and Lakehouse

A **data lake** stores raw structured, semi-structured, and unstructured data
in low-cost object storage such as S3, ADLS, or GCS. Files may be CSV, JSON,
Parquet, logs, or images. It generally uses **schema-on-read**: data is
interpreted when it is consumed.

A lake is flexible and cheap, but a poorly governed lake can become a **data
swamp**: unknown schemas, duplicates, poor quality, unclear ownership, and
slow queries.

| Concern | Data lake | Data warehouse |
|---|---|---|
| Storage | Object storage/files | Managed analytical tables |
| Data | Raw and any format | Curated structured data |
| Schema | Usually on read | Usually on write |
| Cost | Lower storage cost | Higher but optimized query service |
| Users | Engineers, data scientists | Analysts, BI users |
| Strength | Flexibility and retention | Governance and predictable analytics |
| Risk | Quality and discoverability | Less flexible and costly for raw data |

Do not use only a lake when business users need governed, predictable metrics.
Do not use only a warehouse when you need cheap raw retention, unstructured
data, or flexible experimentation.

A **lakehouse** adds warehouse capabilities to open object storage: ACID
transactions, schema enforcement, governance, reliable updates, and SQL
analytics. It supports both BI and ML without copying all data into a
proprietary warehouse. Examples include Databricks with Delta Lake, and systems
using Apache Iceberg or Hudi.

## 5. Delta Lake

A Delta table is primarily **Parquet data files plus a transaction log**:

```text
table/
  part-*.parquet
  _delta_log/
```

Parquet stores the columnar data. `_delta_log` records commits, file additions
and removals, schemas, and table versions. Readers use the log to construct a
consistent snapshot instead of guessing which files belong to a transaction.

Delta provides:

- **ACID transactions:** readers see consistent states and writes commit
  atomically.
- **Updates/deletes/MERGE:** reliable row-level changes on object storage.
- **Schema enforcement:** rejects incompatible incoming data.
- **Schema evolution:** allows approved structural changes such as new columns.
- **Time travel:** reads an earlier table version for audit, debugging, or
  recovery.

`OPTIMIZE` compacts many small files into larger files. **Data skipping** uses
file statistics to avoid reading files that cannot match a filter. **Z-Ordering**
co-locates related values to improve skipping for commonly filtered columns.
`VACUUM` removes obsolete files after a retention period; aggressive cleanup
can break time travel, so retention must be managed carefully.

Delta is more than Parquet: Parquet alone does not provide a transaction log,
atomic multi-file commits, table history, or reliable concurrent updates.

## 6. Medallion Architecture

```text
Sources -> Bronze -> Silver -> Gold -> BI / ML / Applications
```

- **Bronze:** raw or minimally changed data, with ingestion metadata. It
  preserves auditability and enables reprocessing when downstream logic changes.
- **Silver:** typed, cleaned, validated, deduplicated, standardized data;
  joins and reusable business transformations belong here.
- **Gold:** business-ready facts, dimensions, aggregates, KPIs, and data marts.
  It is optimized for consumption.

BI should not normally query Bronze because it contains duplicates, malformed
records, source-specific fields, and unstable semantics.

## 7. Data Modeling

**Data modeling** defines entities, attributes, relationships, keys, and
constraints so data is reliable and useful.

- **Conceptual model:** major business entities and relationships.
- **Logical model:** attributes, keys, relationships, and normalization,
  independent of a specific database.
- **Physical model:** actual tables, data types, partitions, indexes, and
  storage choices.

### OLTP modeling

Use normalized tables to reduce update anomalies:

- **1NF:** atomic values and no repeating groups.
- **2NF:** 1NF plus every non-key attribute depends on the whole key.
- **3NF:** 2NF plus non-key attributes do not depend on other non-key
  attributes.

An e-commerce OLTP design can contain `customers`, `orders`, `order_items`,
`products`, and `payments`. `orders.customer_id` references
`customers.customer_id`; `order_items.order_id` and `product_id` reference
their parent tables. Constraints protect valid relationships.

### Dimensional modeling

Dimensional models are designed for analytics:

- **Fact table:** measurable business events, foreign keys, and measures.
- **Dimension table:** descriptive context such as customer, product, date,
  store, or employee.
- **Measure:** numeric value such as quantity, revenue, or discount.
- **Grain:** exactly what one fact row represents.

Always declare grain before choosing columns. For example:

- `fact_orders`: one row per order.
- `fact_order_items`: one row per product line within an order.

Mixing these grains can double-count revenue. Measures may be:

- **Additive:** can sum across all dimensions, e.g. order amount.
- **Semi-additive:** can sum across some dimensions, not time, e.g. account
  balance.
- **Non-additive:** ratios or percentages that must be recalculated.

### Star and snowflake schemas

```text
dim_customer
      |
dim_product - fact_sales - dim_date
      |
  dim_store
```

A **star schema** has a central fact and denormalized dimensions. It is simple
and fast for BI, at the cost of some redundancy. A **snowflake schema**
normalizes dimensions into additional tables, reducing duplication but adding
joins and complexity. Analytics commonly favors stars for usability and speed.

## 8. Keys and Slowly Changing Dimensions

- **Primary key:** uniquely identifies a row.
- **Foreign key:** references a key in another table.
- **Natural/business key:** meaningful source identifier, such as an email or
  source customer number.
- **Surrogate key:** warehouse-generated identifier, such as `customer_sk =
  1001`.
- **Composite key:** key made from multiple columns.

Surrogate keys are stable when business keys change and allow multiple
historical versions of one business entity.

A **Slowly Changing Dimension (SCD)** tracks changes to descriptive attributes.

- **Type 1:** overwrite the old value. Simple and useful when history is not
  required, but previous values are lost.
- **Type 2:** create a new version and retain history. Typical columns are
  `customer_sk`, `customer_id`, `effective_start_date`,
  `effective_end_date`, and `current_flag`.
- **Type 3:** keep limited history in extra columns, such as `current_city` and
  `previous_city`; it is useful only when a small amount of history is needed.

Type 2 example:

```text
customer_sk | customer_id | city    | start_date | end_date   | current
------------+-------------+---------+------------+------------+--------
101         | C7          | Kolkata | 2025-01-01 | 2026-04-01 | false
102         | C7          | Delhi   | 2026-04-01 | NULL       | true
```

When the city changes, expire the current row and insert a new surrogate-key
row. Facts join to the correct historical surrogate key so past reports use
the address that was valid at the event time.

## 9. File Formats and Partitioning

| Format | Best use | Main trade-off |
|---|---|---|
| CSV | Simple exchange and ingestion | No types, weak schema, large scans |
| JSON | APIs and nested events | Flexible but verbose and slower to scan |
| Parquet | Analytical storage | Columnar and efficient, less convenient to edit manually |
| Avro | Streaming and schema-based messages | Row-oriented; needs schema management |

**Parquet** is columnar, typed, compressed, and supports predicate pushdown:
the engine can read only required columns and files. This is why it is usually
better than CSV for analytics.

**Partitioning** places data in separate directories or table partitions based
on a column, commonly date:

```text
sales/year=2026/month=01/
sales/year=2026/month=02/
```

When a query filters on the partition column, **partition pruning** avoids
unneeded partitions. Good partition columns have low-to-moderate cardinality
and are frequently filtered, such as event date. Avoid high-cardinality
columns such as `customer_id`; they create too many directories.

Too many partitions and frequent tiny writes cause the **small-file problem**,
which increases metadata and scheduling overhead. Too few partitions cause
large scans. Use sensible partitioning and compaction.

## 10. Incremental Processing, Quality, and Reliability

A **watermark** records the latest safely processed source position, commonly
an `updated_at` timestamp, monotonically increasing ID, or CDC offset. A robust
incremental pipeline should:

1. Read a bounded range, often with a small overlap for late arrivals.
2. Deduplicate using a business key and latest update timestamp.
3. Upsert or merge into the target.
4. Advance the watermark only after a successful commit.

Late-arriving data requires an overlap window, event-time processing, or a
reconciliation job. **Idempotency** means running the same input more than once
produces the same final result. Use deterministic keys, batch IDs, MERGE, and
atomic checkpoints to prevent duplicate loads.

Essential quality checks:

- required columns are not null;
- keys are unique where required;
- foreign keys exist in dimensions;
- data types and schemas are valid;
- numeric values are within range, such as `amount >= 0`;
- row counts are within expected bounds;
- data is fresh and arrives before its SLA;
- duplicates and unexpected deletes are detected.

On failure, quarantine bad records, alert the owner, preserve the failed batch,
and stop or isolate downstream publication. Never silently convert invalid data
into success.

## 11. End-to-End Architecture

```text
API / PostgreSQL / Kafka
          |
      Ingestion
          |
   Object Storage (S3)
          |
     Bronze Delta
          |
     Silver Delta
          |
      Gold Delta
       /       \
     BI/SQL     ML
```

API and database extraction may be batch or CDC; Kafka provides event
streaming. Object storage is the durable landing area. Bronze preserves source
fidelity, Silver creates trusted reusable data, and Gold contains dimensional
models and aggregates. Spark or another distributed engine processes large
volumes; Airflow can orchestrate dependencies; dbt can manage SQL
transformations; BI tools consume governed Gold tables.

Technology map:

| Need | Common technology |
|---|---|
| OLTP | PostgreSQL, MySQL |
| Object storage | S3, GCS, ADLS |
| Warehouse | Snowflake, BigQuery, Redshift |
| Lakehouse/table format | Databricks, Delta, Iceberg, Hudi |
| Processing | Spark |
| Orchestration | Airflow |
| Transformations | dbt |
| Streaming | Kafka |
| BI | Power BI, Tableau |

## 12. E-Commerce Modeling Exercise

Suggested Gold model:

- `dim_customer`: customer attributes and Type 2 history.
- `dim_product`: product category, brand, and price attributes.
- `dim_store`: store and location details.
- `dim_date`: calendar attributes such as month, quarter, and fiscal year.
- `fact_order_item`: one row per product in an order; quantity, unit price,
  discount, and net amount.
- `fact_payment`: one row per payment event if payment analysis is needed.

Define keys, grain, and relationships before writing transformations. Keep
source identifiers for traceability, but use surrogate dimension keys for
warehouse joins and historical versions.

## 13. Scenario Playbook

**PostgreSQL with five years of sales:** extract with CDC or an incremental
timestamp, land raw data in object storage, validate and deduplicate in Silver,
load dimensional Gold tables into a warehouse, and expose sales marts to BI.
Avoid heavy reporting queries on PostgreSQL.

**Hourly JSON API:** land the original response in a date/hour path, record
request and batch metadata, parse and validate into Silver, deduplicate by the
API's event ID, retry transient failures, quarantine malformed records, and
make the target idempotent.

**Customer address history:** use SCD Type 2 with a surrogate key and effective
dates. Facts join to the dimension version valid when the event occurred.

**Millions of tiny Delta files:** identify the write pattern, compact files
with `OPTIMIZE`, reduce unnecessary partitions, batch writes, and use data
skipping/Z-Ordering where appropriate.

**Same day loaded twice:** detect by batch ID, source interval, row counts, or
duplicate business keys. Make the load idempotent with a deterministic batch
identifier and MERGE/overwrite of the exact partition.

**Dashboard takes ten minutes:** inspect the query plan, selected columns,
joins and filters, table grain, partition pruning, file sizes, clustering,
data volume, stale statistics, warehouse resources, and whether an aggregate
or data mart is appropriate.

## 14. Short Interview Answers

**What is a data warehouse?** A governed, centralized store of integrated
historical data optimized for analytical queries and BI. It separates reporting
workloads from operational systems and usually exposes curated dimensional
models.

**What is a data lake?** Low-cost object storage for raw data in many formats.
It provides flexibility and long-term retention, but needs cataloging,
governance, quality controls, and a processing layer.

**What is a lakehouse?** A lake architecture with warehouse capabilities such
as ACID transactions, schema management, governance, and SQL analytics on open
storage.

**What is Delta Lake?** A table format that combines Parquet files with a
transaction log to provide reliable updates, ACID commits, schema controls,
versioning, and time travel.

**What is grain?** The exact meaning of one fact row. It must be fixed before
designing the fact table because mixed grain causes incorrect joins and
double-counting.

**What is SCD Type 2?** A historical dimension technique that expires the old
row and inserts a new version with a surrogate key and effective dates.

**What is partitioning?** Organizing data by a frequently filtered,
moderate-cardinality column so queries can prune irrelevant data. It improves
scans only when the partition design matches access patterns.

**What is CDC?** A mechanism that captures inserts, updates, and deletes from a
source so downstream systems can process changes instead of repeatedly
reloading the entire source.

**What is idempotency?** A property where retrying the same input does not
change the final result beyond the first successful application.

**How do you handle bad data?** Validate at ingestion and transformation,
quarantine invalid records with reasons, alert the owner, preserve the input
for replay, and do not publish failed data as trusted data.

## 15. Final Revision Checklist

Before an interview, be able to draw and explain:

```text
Source -> Ingestion -> Raw/Object Storage -> Bronze -> Silver -> Gold
       -> Dimensional Model -> Warehouse/Lakehouse -> BI
```

You should be able to explain why each component exists, identify fact and
dimension grain, compare lake/warehouse/lakehouse, describe Delta's log,
implement a basic incremental MERGE, design SCD Type 2, list quality checks,
and explain how your design changes for batch versus streaming.

