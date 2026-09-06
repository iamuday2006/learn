# 13. Structured Streaming

**Objective:** Learn internship-level streaming concepts — not too deep, but enough to answer fundamentals and build simple streaming pipelines.

**Why it matters:** Streaming is a core Data Engineering skill and a frequent interview topic, even for interns.

**Book chapters to study:** Ch 4/21 (streaming in the book). `EXTERNAL KNOWLEDGE` for some modern specifics.

**Interview importance:** `GOOD TO KNOW` / partial `MUST KNOW` for the core concepts (see labels below).

---

## Concept: Streaming DataFrame

### Simple Explanation
A DataFrame that grows with incoming data — you apply the *same* transformations as batch, but the input is an **unbounded stream**.

### Technical Explanation
A Streaming DataFrame is created with `spark.readStream` instead of `spark.read`. It represents an **unbounded table**; each trigger processes newly arrived data in **micro-batches**. Definition is lazy; `writeStream...start()` begins the continuous query.

### Code Example
```python
stream = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "clicks") \
    .load()
```

### Interview Explanation
> "Structured Streaming treats a stream as an unbounded DataFrame. You read with `readStream`, apply the same transformations you'd use in batch, and write with `writeStream`. Spark processes data in micro-batches triggered at intervals. The key idea is batch and streaming share the same engine and API."

**Internship must know** ✓

---

## Concept: Input Sources

### Simple Explanation
Where streaming data comes from.

### Sources
- **Kafka** — the dominant streaming source (`format("kafka")`).
- **File source** — read new files dropped into a directory.
- **Socket** — for testing.
- **Rate source** — generates test data at a rate.

### Code Example
```python
# File source — new files loaded as they arrive
df = spark.readStream \
    .schema(schema) \
    .option("path", "s3://bucket/incoming/") \
    .format("json") \
    .load()
```

### Interview Explanation
"Common input sources are Kafka (the go-to message bus), file sources that pick up new files landing in a directory, and rate/socket sources for testing. Kafka gives low-latency, high-throughput, replayable streams."

**Internship must know** ✓

---

## Concept: Output Sinks

### Simple Explanation
Where streaming results are written.

### Sinks
- **Kafka** — write results to a topic.
- **File sink** — write to Parquet/JSON/CSV on storage.
- **Console** — print to console (testing).
- **Memory** — hold results in memory (testing/dashboards).
- **foreach/foreachBatch** — custom processing per batch.

### Code Example
```python
query = result.writeStream \
    .format("parquet") \
    .option("path", "s3://bucket/out/") \
    .option("checkpointLocation", "s3://bucket/checkpoints/ct/") \
    .trigger(processingTime="1 minute") \
    .start()
```

### Interview Explanation
"Sinks are where results go: Kafka for re-publishing, file sinks (Parquet/JSON) for landing data, console/memory for testing, and foreachBatch for custom logic like database upserts or Delta merges. The checkpoint location is mandatory for fault tolerance."

**Internship must know** ✓

---

## Concept: Trigger

### Simple Explanation
Controls *when* each micro-batch runs.

### Options
```python
# Default: process as fast as possible
.trigger(processingTime="0 seconds")
# Fixed interval
.trigger(processingTime="1 minute")
# Once: process all available once, then stop
.trigger(once=True)
# Available now (Spark 3.3+)
.trigger(availableNow=True)
```

### Interview Explanation
"Triggers decide micro-batch cadence: 'processing time' runs a batch at a fixed interval or as fast as possible; 'once' processes what's available and stops (nice for batch-style catch-up). Continuous processing is an experimental ultra-low-latency mode."

**Internship must know** ✓

---

## Concept: Checkpointing & Fault Tolerance

### Simple Explanation
Spark stores the streaming query's **offsets, state, and committed batches** in a checkpoint directory so it can resume exactly after a crash.

### Technical Explanation
The checkpoint location (required) records: (1) read offsets — how far each input source was consumed, (2) operator state for stateful ops, (3) which batches committed. On restart, Spark resumes from the checkpoint → **exactly-once** processing (with the right sinks) even in the face of failures.

### Code Example
```python
.option("checkpointLocation", "s3://bucket/checkpoints/my_query/")
```

### Interview Explanation
"Checkpointing is what makes Structured Streaming fault-tolerant: the checkpoint directory stores consumed offsets, operator state, and committed batches. If the query crashes, Spark restarts from the last checkpoint and resumes exactly where it left off, giving end-to-end exactly-once guarantees when combined with idempotent sinks. It's mandatory, never optional."

**Internship must know** ✓

---

## Concept: Event Time vs Processing Time

### Simple Explanation
Two clocks:
- **Processing time:** when Spark processes the record (Spark's clock).
- **Event time:** when the event *actually happened* (embedded in the data).

### Why it matters
Analytics should usually use **event time**, because events can arrive late/out of order. Watermarks handle that lag.

### Interview Explanation
"Processing time is when Spark processes a record; event time is the timestamp in the data itself. For correct analytics we use event time, because real events can arrive late or out of order. Watermarks bound how late we're willing to accept data."

**Internship must know** ✓

---

## Concept: Watermark

### Simple Explanation
A threshold (e.g. "10 minutes") that tells Spark how long to wait for late-arriving events before finalizing a window and cleaning up state.

### Technical Explanation
`withWatermark("event_time", "10 minutes")` sets the watermark: Spark will include events whose event time is within the window of the max seen event time minus the watermark. Once the watermark passes a window's end (plus the delay), the window's results are finalized and its state dropped — bounding memory and preventing late data from changing finalized results.

### Code Example — windowed aggregation with watermark
```python
from pyspark.sql import functions as F

result = df \
    .withWatermark("event_time", "10 minutes") \
    .groupBy(F.window("event_time", "5 minutes"), "user_id") \
    .agg(F.count("*").alias("cnt"), F.sum("amount").alias("total"))
```

### Interview Explanation
"A watermark tells Spark how late data may be: it keeps state for a window until the max event time seen minus the watermark passes the window. After that, the window is finalized and state is cleaned up. Watermarks are essential to bound memory in stateful streaming and to handle out-of-order events correctly."

**Internship must know** ✓

---

## Concept: Windows (tumbling, sliding, session)

### Simple Explanation
Group events into time windows for aggregation.

### Types
- **Tumbling:** fixed, non-overlapping windows.
- **Sliding:** overlapping windows (with a slide interval).
- **Session:** windows separated by idle gaps.

### Code Example
```python
# Tumbling 5-min window
.groupBy(F.window("event_time", "5 minutes"))

# Sliding 10-min window every 2 min
.groupBy(F.window("event_time", "10 minutes", "2 minutes"))
```

### Interview Explanation
"Window functions group events by time: tumbling windows are fixed and non-overlapping; sliding windows overlap; session windows group activity separated by idle gaps. They're the standard way to do time-based aggregations over streams, always paired with a watermark."

**Internship must know** ✓

---

## Concept: Stateful Operations

### Simple Explanation
Operations that keep state *across* batches (e.g. running aggregates, deduplication), as opposed to stateless per-batch operations.

### Examples
- **Aggregations** (`groupBy...agg`) — running state per key.
- **Deduplication** (`dropDuplicates`) — remembers seen keys.
- **Stream-stream joins** — keeps buffered past events on both sides.

State grows over time → must be paired with a **watermark** to clean up old state (bounded memory), otherwise state grows unbounded.

### Code Example — dedup
```python
deduped = df.withWatermark("event_time", "10 minutes") \
    .dropDuplicates(["event_id"])
```

### Interview Explanation
"Stateful operations keep state across micro-batches — running aggregations, deduplication of seen keys, and stream-stream joins. Because state can grow forever, you must pair them with a watermark so Spark can drop state older than the watermark and keep memory bounded."

**Internship must know** ✓, partly `ADVANCED`

---

## Concept: Output Modes

### Simple Explanation
How results are written each trigger.

### Modes
- **Append:** only *new* rows added since the last trigger (default). Use for stateless queries or windowed aggregations with watermark.
- **Update:** only rows that *changed* since last trigger (for aggregations).
- **Complete:** the *entire* result table each trigger (expensive).

### Interview Explanation
"Output modes control what each trigger emits: append writes only new rows; update writes only updated rows from aggregations; complete rewrites the whole result table each time, which is expensive. Choosing correctly (append for ETL, update/complete for aggregations) matters for correctness and cost."

**Internship must know** ✓

---

## Concept: Exactly-Once Concepts

### Simple Explanation
The guarantee that each event is processed **exactly once**, even after failures.

### Technical Explanation
Structured Streaming achieves exactly-once through **checkpointing** (stored offsets + committed batches) plus **idempotent sinks** (Kafka, Delta Lake, or transactional DBs that tolerate re-writing the same data). The engine replays from the checkpoint, and the sink ensures no duplicates.

### Interview Explanation
"Exactly-once means each input event is processed exactly once despite failures. Structured Streaming gets this by checkpointing offsets and committed batches, then resuming from the checkpoint after a crash, combined with an idempotent sink that won't duplicate on re-write. Certain sinks (like append-only file/Delta/Kafka) support it; the mode must be compatible."

**Internship must know** ✓, partly `ADVANCED`

---

## Concept: Kafka Integration

### Simple Explanation
Read from and write to Kafka — the standard streaming backbone.

### Code Example (read)
```python
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType, TimestampType, DoubleType

schema = StructType([
    StructField("user_id", StringType()),
    StructField("event_time", TimestampType()),
    StructField("amount", DoubleType()),
])

events = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "user-events") \
    .option("startingOffsets", "latest") \
    .load() \
    .select(
        from_json(col("value").cast("string"), schema).alias("data")
    ).select("data.*")
```

### Code Example (write)
```python
query = events \
    .selectExpr("user_id AS key", "to_json(struct(*)) AS value") \
    .writeStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("topic", "enriched-events") \
    .option("checkpointLocation", "s3://checkpoints/kafka/") \
    .start()
```

### Interview Explanation
"Kafka is the standard streaming backbone. Spark reads Kafka topics as a streaming source — parsing the byte `value` with `from_json` against a schema — and writes results back to Kafka as `key`/`value`. Spark provides exactly-once with Kafka through checkpointing."

**Internship must know** ✓

---

## Advanced vs Internship label summary

**Internship Must Know:** Streaming DataFrame, sources/sinks, triggers, checkpointing/fault tolerance, event vs processing time, watermarks, windows, output modes, Kafka basics.

**Advanced (know conceptually):** stateful custom operations (`flatMapGroupsWithState`), stream-stream joins, continuous processing, exactly-once internals, RocksDB state store.

---

**End of Chapter 13.** Tick "Structured Streaming" in the tracker.

---

