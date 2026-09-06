# 8. Partitions, Parallelism and Shuffle

**Objective:** Build a very strong mental model of partitions, parallelism, repartition/coalesce, and the shuffle — the concepts at the heart of Spark performance.

**Why it matters:** This is where internship interviews get serious. Understanding partitions and shuffle shows real Spark depth.

**Book chapters to study:** Ch 19 (shuffle internals), Ch 8 (partitioning) and throughout.

**Interview importance:** `MUST KNOW` — make this a strength.

---

## Concept: Partition

### Simple Explanation
A **slice of data** that Spark treats as one unit. Each partition is processed by one task on one core. More partitions = more parallelism (up to core count).

### Technical Explanation
Data is split into partitions. When Spark reads files, it creates partitions (often one or more per file). Each partition is handled independently by a **task** running on a core. Partition count determines parallelism: with `N` partitions and `C` cores, you can run `C` partitions at a time.

### Why It Exists
Partitioning is how Spark splits big work into parallel chunks across the cluster.

### Real-World Example
A 100-partition DataFrame on a 20-core cluster → 20 partitions processed at a time, 5 waves of tasks.

### Interview Explanation
"Partitions are the units of parallelism in Spark. Data is split into partitions, each of which is processed independently by one task on one core. With more partitions you get more parallelism, up to the number of cores. Partition sizing and balance directly drive performance."

### Common Mistakes
- Too few partitions → underuse cores.
- Too many tiny partitions → task scheduling overhead.
- Ignoring unbalanced partition sizes (skew).

### Interview Questions
1. (B) What is a partition?
2. (I) How does partition count relate to parallelism?

---

## Concept: Why Partitions Matter

- **Parallelism:** more partitions → more concurrent tasks (bounded by cores).
- **Locality:** tasks prefer partitions already on their node (less network).
- **Memory:** partitions must fit in executor memory or they spill/OOM.
- **Shuffle cost:** the number and evenness of partitions after a shuffle directly affects performance.

Target: **128–256 MB per partition**, and roughly **2–4 partitions per core**.

---

## Concept: Partition Count / Parallelism

How partitions are set:
- **Input:** file splits / Hadoop blocks (often one partition per HDFS block). Local file → depends on size/splittability.
- **Shuffle:** governed by `spark.sql.shuffle.partitions` (default **200**) — this is the partition count *after* a shuffle (e.g. groupBy/join output).
- **Repartition:** explicit via `repartition()`.

### Code
```python
# Check current partitions
df.rdd.getNumPartitions()

# Set shuffle partitions cluster-wide
spark.conf.set("spark.sql.shuffle.partitions", "200")
```

### Interview Explanation
"Input partitions come from how files are split during read. After a shuffle, partition count is controlled by `spark.sql.shuffle.partitions` (default 200), which is often wrong for your data size — you tune it so each shuffle partition ends up around 128–256MB. The 'right' parallelism also considers total cores: ideally 2–4 partitions per core."

### Common Mistakes
- Leaving default 200 for all datasets (huge or tiny).
- Confusing input partition count with shuffle partition count.

---

## Concept: repartition

### Simple Explanation
Increases (or decreases) the number of partitions, **redistributing data evenly** — but always causes a **full shuffle**.

### Code Example
```python
df.repartition(100)          # exactly 100 partitions (shuffle)
df.repartition("user_id")    # partition by user_id (same key → same partition)
df.repartition(100, "user_id")
```

### When to use
- **Increasing** partitions (more parallelism).
- **Even distribution** required.
- **Partitioning by a column** so subsequent joins/aggregations by that key may avoid shuffle.

### Interview Explanation
"`repartition` redistributes data across a specified number of partitions and always triggers a full shuffle, so every record can move. Use it to increase parallelism or to co-partition by a join key so later operations on that key run more efficiently. It's expensive, so don't overuse it."

### Common Mistakes
- Using `repartition` to *decrease* partitions (use `coalesce` — cheaper).

---

## Concept: coalesce

### Simple Explanation
Decreases the number of partitions **without a full shuffle** — it merges existing partitions, keeping data mostly local.

### Code Example
```python
# Reduce from N to 2 partitions (no shuffle)
df.coalesce(2)

# Typical: filter shrank the data, then reduce partitions
df.filter(...).coalesce(20)
```

### When to use
- **Decreasing** partitions (after filtering lots of data out, or before writing fewer files).

### Key fact
- `coalesce` only **reduces** partitions (cannot increase beyond current).
- It avoids the full shuffle — it just moves data from the partitions being removed into adjacent ones.

### Interview Explanation
"`coalesce` reduces the number of partitions by merging existing ones, and unlike `repartition` it avoids a full shuffle — data in kept partitions stays put, and data from removed partitions is moved to neighbors. That's cheaper. But it can only decrease partition count and may leave partitions unbalanced. Use `coalesce` when data shrank (e.g. after filtering) or writing fewer output files."

### Common Mistakes
- Using `coalesce` to increase partitions (it won't).
- Expecting `coalesce` to keep partitions perfectly balanced.

---

## Concept: repartition vs coalesce (summary)

| | `repartition(n)` | `coalesce(n)` |
|--|------------------|---------------|
| Purpose | Increase or decrease | Decrease only |
| Shuffle | Full shuffle (all data moves) | No full shuffle (merge in place) |
| Evenness | Even partitions | Can be uneven |
| Cost | Expensive | Cheaper |
| Can increase count | Yes | No |
| Use case | More parallelism / partition by key | Reduce after filter / fewer files |

### Interview Explanation
"`repartition` does a full shuffle to re-slice data into exactly `n` (ideally even) partitions — use it to increase parallelism or partition by a key. `coalesce` decreases partition count by merging in place without a full shuffle, so it's cheaper but only reduces and can be uneven. Filter-then-coalesce is a great pattern."

---

## Concept: Shuffle

### Simple Explanation
The **repartitioning of data across executors** triggered by wide transformations (groupBy, join, distinct, orderBy, repartition). Data is written to disk locally, then moved over the network so same-key records land together.

### Technical Explanation
The shuffle has two phases:
- **Shuffle Write:** each task writes the records for various keys into local files/sorted buckets to disk.
- **Shuffle Read:** the next stage's tasks fetch the relevant blocks from other executors over the network (which may also spill to disk).

Because shuffling writes to disk and moves data across the network, it is **the most expensive operation in Spark** and creates **stage boundaries**.

### Why It Exists
Operations like `groupBy`/`join` require records with the same key on the same executor — the shuffle is how Spark relocates them.

### Interview Explanation
"A shuffle is the repartitioning of data across executors, triggered by wide transformations like groupBy, join, distinct, orderBy, and repartition. It writes intermediate data to disk on the source side (shuffle write) and fetches it over the network on the destination side (shuffle read). Because it touches disk and network, it's the dominant cost in most Spark jobs and creates stage boundaries."

### Common Mistakes
- Thinking shuffle is all in-memory (it writes to disk).
- Not counting shuffles when estimating job cost.

### Interview Questions
1. (B) What is a shuffle?
2. (I) What operations cause a shuffle?
3. (I) Why is shuffle expensive?

---

## Concept: Shuffle Read / Shuffle Write (metrics)

- **Shuffle Write:** bytes a task wrote for downstream tasks (proportional to shuffle cost).
- **Shuffle Read:** bytes a task fetched from other executors (proportional to shuffle cost + network).
- Check these in the Spark UI's Stages tab. Big shuffle read/write = likely a join/aggregation/repartition issue.
- **Spill (memory/disk):** when a task's partition doesn't fit in memory, part spills to disk → slower. Reduce by more partitions or more memory.

### Interview Explanation
"In the Spark UI, shuffle write measures what each task wrote for downstream consumers, shuffle read measures what it fetched. Large values highlight expensive shuffles (joins, groupBy, repartition). Spill to disk means a partition exceeded memory — a sign to increase partitions or memory."

---

## Concept: Partition Imbalance & Data Skew

### Simple Explanation
When some partitions hold far more data than others, parallelism suffers — a few tasks carry most of the work.

### Technical Explanation
- **Partition imbalance:** the total partition sizes are unequal (e.g. `coalesce` merging big partitions).
- **Data skew:** imbalance by *key* distribution — e.g. a `user_id` with 10M rows vs most with 10 rows.

### Why it matters
A skewed/imbalanced partition makes its task the bottleneck; the whole job waits for that straggler. This is why you check task-duration distribution in the Spark UI.

### Detection
```python
from pyspark.sql import functions as F
df.withColumn("pid", F.spark_partition_id()) \
  .groupBy("pid").count().orderBy(F.desc("count")).show(20)
# max/avg ratio > ~3 suggests skew
```

### Mitigation
- For **skew**: salting, AQE skew join, split hot keys, broadcast small side.
- For **imbalance after coalesce**: use `repartition` for evenness.

### Interview Explanation
"Partition imbalance means some partitions hold far more data than others, so a few tasks run long while others wait — a straggler problem. Data skew is the key-level cause (some keys dominate). I detect it by comparing partition sizes or task durations in the Spark UI, and fix it with salting, AQE's skew join, or broadcasting the hot side."

### Common Mistakes
- Ignoring the Spark UI task-duration histogram.
- Adding executors to fix imbalance (it's about distribution).

---

## Concept: Identifying Expensive Operations

Signs of an expensive DataFrame operation:
1. **Many/wide shuffles** in the plan (EXCHANGE nodes) — check `df.explain()`.
2. **Large shuffle read/write** in the Spark UI.
3. **Spill to disk** — memory pressure.
4. **Uneven task durations** — skew.
5. **Many stages** — many shuffle boundaries.

### Interview Explanation
"I identify expensive operations by reading the physical plan for Exchange (shuffle) nodes, and by watching the Spark UI: large shuffle read/write, disk spill, long GC, and uneven task durations all flag problems. Then I apply: broadcast joins, earlier filtering/column pruning, partition tuning, AQE, and skew handling."

---

**End of Chapter 8.** Tick "Partitions", "Shuffle" in the tracker.

---

