# 03 — Data Ingestion

## ETL vs ELT
### ETL
Extract, Transform, Load.
- transform before loading
- used in legacy and controlled pipelines

### ELT
Extract, Load, Transform.
- load raw data first
- transform later in warehouse or lakehouse
- common in modern cloud systems

## Batch ingestion
Data arrives periodically and is processed in groups.

## Streaming ingestion
Data flows continuously and is processed as it arrives.

## Full load vs incremental load
### Full load
- reload everything each run
- simple but expensive at scale

### Incremental load
- load only new or updated records
- efficient and common in production

## CDC
Change Data Capture identifies new, updated, and deleted rows from source systems.

### Why important
It keeps downstream data fresh without full reloads.

## Event-driven ingestion
A pipeline starts when a specific event occurs, often via Kafka or a queue.

## Micro-batching
Very small interval-based batches, often seconds or minutes.

## Idempotency
Running the same job twice should not duplicate or corrupt results.

### Example
Importing the same file twice should not create duplicate rows.

## Deduplication
Remove repeated records based on a key or business rule.

## Retries
Retry transient failures such as timeouts or network errors.

## Checkpointing
Save progress so a job can resume without reprocessing everything.

## Watermarks
Estimate how late events may arrive.

## Late-arriving data
A record shows up after the expected window has closed.

## Schema changes
New columns or renamed fields can break downstream processing.

## Backfills
Reprocess historical data to fix incorrect output or repopulate a table.

## Replay
Read the same raw data again from a previous point in time.

## Must Know
- ETL vs ELT
- Incremental load and CDC
- Idempotency, retries, checkpointing
- Late data and backfills

## Good to Know
- Micro-batching
- Event-driven ingestion
- Watermarks and replay

## Advanced
- Exactly-once semantics
- Schema evolution management

## Interview Questions
1. Why choose ELT over ETL in a modern data platform?
2. What is CDC and when is it useful?
3. What does idempotency mean in a pipeline?
4. Why do streaming systems need checkpoints and watermarks?
5. What happens when late-arriving data appears after a window is closed?
6. How do you handle backfills safely?
