# 11. Spark Performance Optimization

**Objective:** Learn how to make Spark jobs fast, and how to debug a slow job. This is the highest-value practical chapter.

**Why it matters:** "How do you optimize a slow Spark job?" is the single most common advanced interview question.

**Book chapters to study:** Part IV (Chapters 19–20 on performance/internals). `EXTERNAL KNOWLEDGE` for AQE specifics (Spark 3.0+).

**Interview importance:** `MUST KNOW`

---

## Concept: Avoiding Unnecessary Shuffles

Shuffles are the biggest cost. Reduce them by:
- **Filtering early** — remove rows before groupBy/join.
- **Column pruning** — select only needed columns before shuffle.
- **Broadcast joins** — avoid shuffling a small table.
- **Avoiding multiple shuffles** — combine operations.
- **Co-partitioning** join keys so later joins skip a shuffle.

### Code Example
```python
# BAD: shuffle before filter
df.groupBy("cat").sum("v").filter(F.col("total") > 1000)

# GOOD: filter first, then aggregate
df.filter(F.col("v") > 0).groupBy("cat").sum("v")
```

### Interview Explanation
"Shuffles are the dominant cost, so I minimize them: filter and prune columns before any shuffle, use broadcast joins for small tables, and avoid chaining needless wide operations. Fewer shuffles = fewer stage boundaries = less network I/O."

---

## Concept: Partition Sizing

- **Target:** ~128–256 MB per partition.
- **Tune `spark.sql.shuffle.partitions`** so each shuffle partition lands in that range.
- **2–4 partitions per core** for parallelism.
- After filtering lots of data, **coalesce** to avoid tiny partitions.

### Code Example
```python
# For ~100GB of data and 200 shuffle partitions → 500MB each (too big)
spark.conf.set("spark.sql.shuffle.partitions", "800")  # ~128MB each
```

### Interview Explanation
"Partitions should be right-sized — around 128–256MB each, roughly 2–4 per core. I set `spark.sql.shuffle.partitions` so shuffle output lands in that range and coalesce after filters that shrink data. Too few partitions → big ones that spill; too many → scheduling overhead."

---

## Concept: Broadcast Joins (recap) — see Chapter 7

Small dimension tables should be broadcast (< ~10MB default, up to ~200MB tuned). Using `broadcast()` hint or raising `autoBroadcastJoinThreshold`.

---

## Concept: Predicate Pushdown

Catalyst pushes `filter` conditions down to the data source so Spark reads **fewer rows**. For Parquet (columnar), it also pushes column filters so fewer columns are scanned.

### Code Example
```python
# Filter is pushed into the Parquet read
df = spark.read.parquet("s3://bucket/") \
    .filter(F.col("date") == "2024-01-01")
# Check: explain shows PushedFilters
```
You can't always choose where the filter is in code — Catalyst moves it, but only when the condition is on the data being read (not computed columns).

### Interview Explanation
"Predicate pushdown lets Catalyst push filter conditions into the data source, so Spark only reads the rows (and, for columnar formats, the columns) it needs. I verify it via `PushedFilters` in the physical plan. Writing filters near the read helps."

---

## Concept: Column Pruning

Catalyst drops columns that aren't used downstream, reducing data read and shuffle size. `select` only what you need.

### Code Example
```python
# GOOD: only needed columns selected before aggregation/shuffle
df.select("key", "value").groupBy("key").sum("value")

# BAD: aggregating a 50-column df without pruning
df.groupBy("key").sum("value")   # shuffle carries all columns unless pruned
```

### Interview Explanation
"Column pruning makes Catalyst read and shuffle only the columns actually used, shrinking I/O and shuffle size. Selecting only needed columns before a wide operation gives the optimizer the most room to prune."

---

## Concept: Caching — see Chapter 9

Cache reused/expensive DataFrames; unpersist when done.

---

## Concept: Repartition vs Coalesce — see Chapter 8

`repartition` = full shuffle (increase/even). `coalesce` = cheaper (decrease). Filter-then-coalesce is a common pattern.

---

## Concept: Data Skew — see Chapter 8

Detect via Spark UI (uneven task durations). Fix: AQE skew join, salting, or split+broadcast hot keys.

---

## Concept: The Small Files Problem

### Simple Explanation
When data is written into too many tiny files, Spark reads/writes them inefficiently — high overhead per file, poor parallelism granularity.

### Why It Matters
Thousands of tiny files (a few KB each) cause massive task overhead, slow listing, and poor columnar-read efficiency — very common after `coalesce(1)` misuse, streaming writes, or too many partitions.

### Mitigation
- **Write fewer, larger files:** target ~128MB+ per output file; use `repartition`/`coalesce` at write time.
- **Compaction jobs:** periodically rewrite/merge small files into larger ones.
- `maxRecordsPerFile` and `coalesce`/`repartition` before write.

### Code Example
```python
# Compact many small files into few large ones
spark.read.parquet("s3://bucket/many_small/") \
    .repartition(50) \
    .write.mode("overwrite").parquet("s3://bucket/compacted/")
```

### Interview Explanation
"The small files problem occurs when data is split across far too many tiny files. Each file adds read/listing/task overhead, and columnar formats like Parquet are inefficient on small files. I fix it by writing reasonably sized files (repartition/coalesce before write, target ~128MB+) and running compaction jobs to merge small files."

### Common Mistakes
- Writing with too many partitions producing thousands of small Parquet files.
- Using `coalesce(1)` and losing all parallelism.

---

## Concept: File Formats & Compression

- **Parquet** is the standard (columnar, predicate pushdown, column pruning, good compression) — see Chapter 12.
- **Compression:** Snappy (fast, default), Gzip (better ratio, slower), LZ4 (fast).
- **Serialization:** Kryo is faster/more compact than Java for RDD/serialized data (`spark.serializer`).

### Interview Explanation
"I prefer Parquet for the columnar benefits (predicate pushdown, column pruning, efficient compression), with Snappy compression for speed. For serialization, Kryo is more compact and faster than Java serialization when caching or shuffling serialized data."

---

## Concept: Adaptive Query Execution (AQE) — Spark 3.x

`EXTERNAL KNOWLEDGE` — AQE is Spark 3.0+, added after this book. But it's pivotal for interviews and real work, so learn it.

### What AQE does at runtime (after gathering shuffle stats)
1. **Dynamically coalesces shuffle partitions** — merges small output partitions to the target size.
2. **Dynamically switches join strategies** — e.g. switches a sort-merge to broadcast if a table turns out small.
3. **Dynamically optimizes skew joins** — splits skewed partitions.

### Enable
```python
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.skewedPartitionFactor", "5")
spark.conf.set("spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes", "256MB")
```

### Interview Explanation
"AQE (Spark 3.0+) optimizes the query *at runtime* based on actual shuffle statistics: it coalesces too-small shuffle partitions, switches large joins to broadcast when a side is actually small, and splits skewed join partitions. It's a big reason to enable it and it reduces manual tuning."

### Common Mistakes
- Forgetting AQE exists in Spark 3+ and manually fighting skew/partition issues AQE would handle.

---

## Concept: Catalyst Optimizer — see Chapter 3

The planner that does predicate pushdown, column pruning, constant folding, join reordering. Understand it as the *why* behind many best practices.

---

## Concept: Efficient Transformations

- **Use built-in functions** over Python UDFs (10–100× faster).
- **Avoid `collect()`** on large data (use `take`/write).
- **Sequence narrow ops** so they pipeline in one stage.
- **Cache** reused frames.
- **Broadcast** small tables.

---

## "Spark Job Optimization Checklist"

Use this when a job is slow:

1. **Look at the Spark UI first** (don't guess).
   - Which **stage** is slowest? Which **job**?
   - **Shuffle read/write** sizes — big = find the wide op.
   - **Spill (memory/disk)** — memory pressure.
   - **GC time** — memory issues.
   - **Task duration distribution** — skew? (max ≫ median).

2. **Identify the culprit operator.**
   - Check the **physical plan** (`explain(True)`): where are the `Exchange` (shuffle) nodes? Is there a `SortMergeJoin` that could be broadcast?

3. **Reduce data early.**
   - **Filter** before joins/aggregations.
   - **Select/prune columns** before shuffles.
   - Confirm **predicate pushdown** (PushedFilters).

4. **Fix the shuffle.**
   - **Broadcast** small dimension tables.
   - Tune **`spark.sql.shuffle.partitions`** (divide data size by target 128MB).
   - Enable **AQE**.

5. **Fix skew.**
   - Detect hot keys; use **salting** or **AQE skew join**.

6. **Fix partitioning.**
   - `coalesce` after filtering/at write; `repartition` only to increase/even out or to co-partition join keys.

7. **Cache only reused data; unpersist when done.**
   - Check Storage tab "Fraction Cached" = 100%.

8. **Handle small files.**
   - Write ~128MB+ files; run compaction.

9. **Check resources/config.**
   - Executors/cores/memory sized correctly; `spark.executor.memoryOverhead` adequate; dynamic allocation.

10. **Avoid anti-patterns.**
    - No `collect()` on big data.
    - No Python UDFs where built-ins exist.
    - No unnecessary `distinct`/`orderBy`/`repartition`.

### Interview Explanation (model answer to "how do you debug a slow job?")
> "I start in the Spark UI: I find the slowest stage, check shuffle read/write sizes, disk spill, GC time, and whether task durations are skewed. Then I look at the physical plan to locate the expensive operators — especially Exchange nodes and join strategies. Depending on what I find, I reduce data early (filter and prune columns before shuffles), broadcast small tables, tune shuffle partitions, enable AQE, fix skew with salting, coalesce/repartition appropriately, cache reused frames, and clean up small files. I re-run and re-check the UI to confirm the fix helped."

---

**End of Chapter 11.** Tick "Performance optimization", "AQE" in the tracker.

---

