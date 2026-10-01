# 21 — Interview Knowledge

## Definition questions
- What is ETL?
- What is a data warehouse?
- What is a data lake?
- What is an event?
- What is idempotency?

## Why questions
- Why is Parquet preferred for analytics?
- Why do we need orchestration?
- Why is lineage important?
- Why use CDC instead of full reloads?
- Why do we partition by date?

## Scenario questions
- How would you design a pipeline for 5 million orders a day?
- What would you do if a Kafka pipeline started lagging?
- How do you recover from a failed warehouse load?
- How would you handle late-arriving data from a mobile app?
- How do you keep a production pipeline idempotent?

## Troubleshooting questions
- A dashboard is wrong. Where do you investigate first?
- Why is a Spark job slow?
- Why are duplicate records appearing in a table?
- Why is data freshness dropping?
- Why is a warehouse not updating as expected?

## System design questions
- Design a system to process 100 million transactions daily.
- Design ingestion for API + database + Kafka sources.
- Design a near-real-time analytics pipeline.
- Design a reliable batch pipeline with backfills.
- Design a secure data platform for regulated data.

## Must Know
- ETL vs ELT
- Warehouse vs lake
- Kafka concepts
- Spark DAG and shuffle
- Data quality checks

## Good to Know
- CDC and SCD
- Cloud service categories
- Partitioning trade-offs

## Advanced
- Exactly-once semantics
- Hybrid streaming-batch design
