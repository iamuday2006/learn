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


