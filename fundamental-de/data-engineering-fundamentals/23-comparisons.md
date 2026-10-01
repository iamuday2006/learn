# 23 — Comparisons

## ETL vs ELT
- ETL transforms before load
- ELT loads raw data first and transforms later
- ELT is common in modern cloud platforms

## Batch vs Streaming
- Batch uses scheduled intervals
- Streaming processes events continuously
- Batch is simpler; streaming is lower-latency

## OLTP vs OLAP
- OLTP supports transactions
- OLAP supports analytical queries
- OLTP is operational; OLAP is reporting-focused

## Data Lake vs Data Warehouse
- Lake is low-cost and flexible
- Warehouse is curated and query-optimized
- Use lake for raw storage, warehouse for trusted reporting

## Data Lake vs Lakehouse
- Lakehouse combines lake flexibility with warehouse structure
- Better governance and performance than raw lake storage

## Row vs Column Storage
- Row storage is good for transactions
- Column storage is good for analytics

## CSV vs Parquet
- CSV is simple and readable
- Parquet is compressed, columnar, and efficient for analytics

## Full Load vs Incremental Load
- Full load reloads all data
- Incremental handles only new or changed data
- Incremental is more efficient in production

## Batch vs Micro-batch
- Batch is larger and slower
- Micro-batch is smaller and more frequent
- It is a middle ground between batch and real-time

## Kafka vs Traditional Queues
- Kafka supports high-throughput event streams and replay
- Traditional queues are often simpler but less suited to large streaming analytics

## Airflow vs Spark
- Airflow orchestrates workflows
- Spark processes data at scale
- Orchestration and processing are different jobs

## dbt vs Spark
- dbt transforms data in warehouse/lakehouse layers
- Spark performs distributed computation

## Warehouse vs Lakehouse
- Warehouse is optimized for SQL analytics
- Lakehouse combines the raw flexibility of a lake with warehouse semantics

## Normalization vs Denormalization
- Normalization reduces redundancy
- Denormalization improves read performance for analytics

## Interview takeaway
The real test is not memorizing labels but explaining trade-offs clearly.
