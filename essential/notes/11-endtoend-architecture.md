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


