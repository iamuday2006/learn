# 16 — Modern Data Stack

The modern data stack is a set of tools that work together for ingestion, storage, transformation, and analytics.

## Typical components
- Object storage
- Warehouse
- Lakehouse
- dbt
- Spark
- Kafka
- Airflow
- Databricks
- Snowflake
- Data catalogs

## Example architecture
```text
Application
    ↓
Kafka / API / Database
    ↓
Ingestion
    ↓
Object Storage
    ↓
Spark / dbt
    ↓
Data Lake / Lakehouse
    ↓
Warehouse
    ↓
BI / Analytics / ML
```

## How they fit together
- source systems produce data
- ingestion loads data into storage
- processing cleans and transforms it
- warehouse or lakehouse serves analytics
- BI and ML consume the final output

## Must Know
- Storage -> processing -> warehouse/lakehouse -> BI
- Role of Kafka, Spark, Airflow, dbt, warehouse, and catalog

## Good to Know
- Databricks and Snowflake patterns
- Lakehouse trends

## Advanced
- Data contracts
- Data product design

## Interview Questions
1. How do object storage and warehouse complement each other?
2. Why is dbt commonly used in modern stacks?
3. What role does Kafka play?
4. Why is orchestration required even with a warehouse?
5. What problem does the lakehouse solve?
