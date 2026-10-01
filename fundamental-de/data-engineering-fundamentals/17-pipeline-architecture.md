# 17 — Data Pipeline Architecture

Production pipelines usually follow a layered structure.

```text
Source
  ↓
Ingestion
  ↓
Raw Storage
  ↓
Processing
  ↓
Quality Checks
  ↓
Curated Data
  ↓
Warehouse / Serving
  ↓
Analytics
```

## Why each layer exists
- Source: where the data originates
- Ingestion: collect and move data
- Raw Storage: durable landing area
- Processing: clean and transform data
- Quality Checks: validate correctness
- Curated Data: trusted datasets
- Serving: query layer for BI and apps
- Analytics: reporting and downstream use cases

## What can fail
- source outages
- malformed files
- schema drift
- failed transformations
- quality issues

## Recovery patterns
- retries
- checkpointing
- replay
- backfills
- alerts and runbooks

## Monitoring
Measure job success, row counts, latency, quality, and freshness.

## Must Know
- Pipeline layer structure
- Recovery and monitoring patterns
- Raw vs curated separation

## Good to Know
- Data contracts between stages
- Observability in pipeline architecture

## Advanced
- Event-driven architecture
- Multi-region pipelines

## Interview Questions
1. Why separate raw and curated data?
2. What happens when ingestion fails in a daily pipeline?
3. How would you monitor data freshness?
4. What is the difference between a failed job and a bad result?
5. How do you design a pipeline that can recover from a bad transformation?
