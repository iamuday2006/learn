# 14. PySpark in Real Data Engineering

**Objective:** Understand where Spark fits into a modern data pipeline and how tools like Airflow, Docker, AWS, and Kafka surround it.

**Why it matters:** Interviews (and internships) care about *architecture*, not just Spark in isolation. Knowing where Spark sits shows engineering thinking.

**Interview importance:** `GOOD TO KNOW` — not asked in depth for interns, but knowing the lay of the land is a plus.

---

## The Big Picture

```text
Source
  ↓
Ingestion
  ↓
Object Storage
  ↓
PySpark
  ↓
Transformation
  ↓
Data Quality
  ↓
Data Lake / Warehouse
  ↓
BI / Analytics
```

| Stage | Typical tools | Spark's role |
|-------|---------------|--------------|
| Source | Apps, DBs, files, Kafka events | Consumes from these |
| Ingestion | Kafka, Airflow CDC, spark read | Spark can ingest (stream/batch) |
| Object Storage | S3, ADLS, GCS, HDFS | Where Spark reads/writes the data lake |
| Transformation | **PySpark** | Cleaning, joins, aggregations, enrichment |
| Data Quality | Great Expectations, custom Spark checks | Spark computes quality checks |
| Data Lake / Warehouse | S3+Parquet/Delta, Snowflake, BigQuery | Spark writes the lake |
| BI / Analytics | Looker, Tableau, dashboards | Consumes the warehouse |

### Key insight
**Spark is a compute engine, not a storage system.** It reads from and writes to external storage. Its job is fast distributed *transformation* — it does not store data long-term.

---

## Where Tools Around Spark Fit

### Airflow
- **Role:** Workflow orchestration / scheduling.
- **How it fits:** Airflow *triggers* Spark jobs on a schedule/dependency, watches them succeed/fail, and retries. You submit `spark-submit` (or a Databricks/EMR operator) from an Airflow DAG. Airflow does *not* process data — Spark does.

```python
# (conceptual Airflow task) — EXTERNAL KNOWLEDGE
submit_spark = BashOperator(
    task_id="run_etl",
    bash_command="spark-submit --master yarn /app/etl.py",
    dag=dag,
)
```

### Docker
- **Role:** Containerization.
- **How it fits:** Packages the Spark app (and even local Spark cluster for dev/testing) into reproducible containers, making environments consistent across dev/CI/prod.

### AWS / Azure / GCP
- **Role:** Cloud infrastructure.
- **How it fits:** Object storage (S3/ADLS/GCS) = the data lake; managed Spark services (EMR/Azure Synapse/Databricks) run your PySpark without you managing a cluster. IAM/auth security.

### Databricks
- **Role:** Managed Spark platform (notebooks + clusters + Delta Lake + SQL + jobs).
- **How it fits:** Runs the same PySpark you've learned, but on a hosted service with Delta Lake (ACID over Parquet), auto-scaling, and a UI.

### Snowflake
- **Role:** Cloud data warehouse.
- **How it fits:** Usually the *destination* of Spark-transformed data. You might write from Spark to S3/Parquet, then load into Snowflake, or use Spark Connector to write directly. (Separate query engine, not Spark.)

### Kafka
- **Role:** Distributed message bus / streaming backbone.
- **How it fits:** Source of streaming events into Structured Streaming, or sink of streaming results. Reliable, replayable, high-throughput.

### dbt
- **Role:** SQL-based transformation framework (transform-in-warehouse).
- **How it fits:** Where you prefer SQL transformations inside the warehouse, dbt replaces the "transformation" step Spark might otherwise do. Spark's SQL can do similar; dbt emphasizes versioned, tested SQL. `EXTERNAL KNOWLEDGE`.

---

## Example Architecture with Spark at the Center

```text
Mobile/Web apps ──> Kafka ──> [Structured Streaming] ──> S3 (raw, parquet)
                                                          ↓
DBs/APIs ──> [Airflow schedules] ──> spark-submit: PySpark batch ETL
                                                          ↓
                                            Data Quality checks (Spark)
                                                          ↓
                                              S3/Delta Lake (curated)
                                                          ↓
                                     Snowflake / BI / dashboards
```

### Interview Explanation
> "Spark is the distributed compute engine in the middle of the pipeline. Sources stream into Kafka and are landed in object storage; Airflow schedules Spark jobs that read that raw data, clean and transform it with PySpark, run data-quality checks, and write curated Parquet/Delta back to the data lake; then the warehouse (Snowflake) and BI tools consume it. Spark itself doesn't store data — it reads/writes the lake and does the heavy transformation."

---

**End of Chapter 14.**

---

