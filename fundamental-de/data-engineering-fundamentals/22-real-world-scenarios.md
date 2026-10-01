# 22 — Real-World Scenarios

## Scenario 1: Daily sales analytics
### Problem
A company receives 5 million orders a day.

### Solution
- Source: order DB, payment system, product catalog
- Ingestion: nightly batch plus CDC for recent changes
- Storage: raw object storage + curated warehouse
- Processing: join orders with products and customers
- Data model: fact table for orders and dimension tables for product/customer/date
- Quality: duplicates removed, null checks, row counts
- Orchestration: pipeline DAG with dependency order
- Monitoring: freshness and run status alerts

## Scenario 2: Fraud alerting
### Problem
A bank needs to detect suspicious transactions in real time.

### Solution
- Source: payment events
- Ingestion: Kafka stream
- Processing: rules and live aggregations
- Storage: raw event log and aggregate tables
- Recovery: dead-letter queue and replay support

## Scenario 3: SaaS usage analytics
### Problem
A product company wants to analyze usage by customer and feature.

### Solution
- Source: application events and API exports
- Ingestion: event stream + scheduled API pulls
- Processing: normalize and join event data
- Storage: object storage + warehouse
- Quality: schema validation and deduplication

## Scenario 4: Sensor pipeline
### Problem
A manufacturing company collects sensor data every second.

### Solution
- Ingestion: streaming ingestion
- Processing: time-window summary and anomaly detection
- Storage: raw event log + aggregate time-series tables
- Reliability: checkpointing and late-event management

## Scenario 5: Backfill after logic bug
### Problem
A transformation bug distorted revenue numbers for the last 3 months.

### Solution
- Start with corrected logic
- Re-run historical data through the pipeline
- Validate totals against trusted source data
- Ensure pipeline logic is idempotent and replay-safe
