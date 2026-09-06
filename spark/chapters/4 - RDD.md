# 4. RDD

**Objective:** Understand Spark's foundational low-level API, why it existed, its properties, and why modern projects prefer DataFrames.

**Why it matters:** Interviewers probe RDD vs DataFrame to check whether you truly understand why the Structured APIs exist. RDDs also matter for unstructured data and custom processing.

**Book chapters to study:** Ch 3 (tour), and the book's Part III (low-level APIs) covering RDDs.

**Interview importance:** `MUST KNOW` (concept), `GOOD TO KNOW` (using RDDs day-to-day).

---

## Concept: RDD (Resilient Distributed Dataset)

### Simple Explanation
Spark's lowest-level data structure: an **immutable, partitioned collection of elements** that can be processed in parallel using functional methods like `map` and `filter`.

### Technical Explanation
An RDD has five core properties (`EXTERNAL KNOWLEDGE`, from the original RDD paper — not in the book verbatim):
1. A list of **partitions** (slices of data).
2. A function for computing splits.
3. A list of dependencies on parent RDDs (**lineage**).
4. A **partitioner** (for key-value RDDs).
5. A list of preferred locations (data locality).

These five enable: parallelism (partitions), fault tolerance (lineage re-computation), and locality (preferred locations). RDDs carry **no schema**, so Spark cannot optimize them with Catalyst/Tungsten the way it optimizes DataFrames.

### Why It Exists
RDDs were Spark's original abstraction that introduced the in-memory, fault-tolerant functional programming model. They remain useful for unstructured data (raw text, binary) and fine-grained control over partitioning, but structured work should use DataFrames.

### Real-World Example
Processing raw server logs that don't fit a tabular schema:
```python
lines = spark.sparkContext.textFile("s3://bucket/logs/*.log")
errors = lines.filter(lambda l: "ERROR" in l).count()
```

### Interview Explanation
> "An RDD is Spark's foundational low-level abstraction: an immutable, fault-tolerant, partitioned collection of elements with no enforced schema. It maintains lineage so any lost partition can be recomputed. Because RDDs lack schema, Spark can't apply Catalyst query optimization to them the way it does for DataFrames. They're useful for unstructured data and low-level control, but DataFrames/SQL are the standard for structured data."

### Common Mistakes
- Using RDDs for structured data (lose Catalyst/Tungsten optimizations).
- Assuming RDDs are faster — usually the reverse.
- Forgetting immutability — RDD transformations return new RDDs.

---

## Concept: RDD Properties & Fault Tolerance

#### Immutable Nature
- RDDs can't be changed once created; `map`/`filter` produce new RDDs. Enables safe parallel computation and simple reasoning.

#### Partitioning
- An RDD is split into partitions; operations on a partition can be done independently/parallel on different nodes.

#### Lineage (DAG of dependencies)
- Every RDD knows its parents, forming a lineage chain. If a partition is lost/recomputed, Spark replays lineage.

#### Fault Tolerance (the "R" in RDD)
- Because lineage records *how* to recompute, Spark recovers from node failures by recomputing lost partitions rather than replicating all data. To reconstruct only the lost partition, Spark needs the original data intact (and cached data helps).

### Real-World Example — fault recovery
One executor crashes during a 1000-partition job. Spark identifies partitions computed there, recomputes only those (by replaying their lineage), and continues — instead of aborting the job.

### Interview Explanation
> "RDDs are fault tolerant through lineage: each RDD remembers how it was derived from its parents. If an executor fails and partitions are lost, Spark recomputes exactly those partitions by replaying lineage from the original source. Because the dataset is immutable and partitioned, this recompute is cheap and targeted. Optionally, replicating cached partitions adds extra safety."

### Common Mistakes
- Thinking RDDs replicate data for fault tolerance (they *recompute*, not replicate).
- Believing fault tolerance is free — recomputation reads the source again.

---

## Transformations vs Actions (RDD)

### Simple Explanation
RDD **transformations** (`map`, `filter`, `flatMap`, `reduceByKey`) return new RDDs lazily; RDD **actions** (`count`, `collect`, `take`, `saveAsTextFile`) trigger execution.

### Technical Explanation
Same lazy model as DataFrames: building transformations is cheap; the first action triggers the job. Narrow transformations (one-to-one partition) vs wide transformations (shuffle — `groupByKey`, `join`, `distinct`, `repartition`).

### Real-World Example
```python
rdd.map(lambda x: x*2).filter(lambda x: x > 10)  # lazy
rdd.count()                                       # action → job
```

### Interview Explanation
> "RDD transformations are lazy and return new RDDs; actions trigger actual computation. Transformations can be narrow (each input partition maps to one output partition, no shuffle) or wide (cause a shuffle, creating stage boundaries). The lazy model lets Spark build a plan and only compute when an action demands results."

---

## Narrow vs Wide (RDD) — recap in RDD words

| | Narrow | Wide |
|--|--------|------|
| Dependencies | One input partition → one output partition | Input partitions contribute to many output partitions |
| Shuffle | No | Yes |
| Pipelined | Yes | No (stage boundary) |
| Examples | `map`, `filter`, `flatMap`, `mapValues` | `groupByKey`, `reduceByKey`, `join`, `distinct`, `repartition` |
| Cost | Cheap | Expensive (network + disk) |

---

## RDD vs DataFrame

| Aspect | RDD | DataFrame |
|--------|-----|-----------|
| Schema | None (untyped elements) | Rich typed schema |
| Optimization | None (no Catalyst/Tungsten) | Catalyst + Tungsten |
| Speed | Slower (no optimization) | Significantly faster |
| API style | Functional (map/filter) | Declarative (SQL-like) |
| Fault tolerance | Lineage recompute | Lineage recompute |
| Use case | Unstructured data, custom control | Structured/semi-structured — the standard |
| Creation | `sc.parallelize`/`sc.textFile` | `spark.read...`/`spark.createDataFrame` |

### Real-World Example
For a daily ETL over Parquet, use DataFrames — Catalyst prunes columns/pushes predicates and Tungsten runs fused code. RDDs would re-read everything with no optimization.

### Interview Explanation
> "The key difference is schema and optimization. DataFrames carry a schema, letting Catalyst optimize (predicate pushdown, column pruning, efficient joins) and Tungsten generate fast code. RDDs are untyped and unoptimized. So DataFrames are much faster and are the standard for structured data; RDDs remain for unstructured data or fine-grained partitioning control."

---

## RDD vs Dataset

| Aspect | RDD | Dataset |
|--------|-----|---------|
| Language | All (Scala/Python/Java/R) | Java/Scala only |
| Type safety | No compile-time schema | Strongly typed `Dataset[T]` |
| Encoders | Java/serialization | Tungsten encoders (efficient) |
| Optimized | No | Yes (Catalyst + encoders) |
| Best for | Unstructured, low-level | Type-safe domain objects (JVM) |

### Interview Explanation
> "RDDs are untyped, available in every language, and unoptimized. Datasets are the type-safe structured API in Java/Scala — a `Dataset[Person]` has compile-time types and uses Tungsten encoders for efficient serialization. DataFrames are `Dataset[Row]`. PySpark users work with DataFrames because Datasets require JVM-level types."

### Common Mistakes
- Claiming PySpark supports `Dataset[T]` (it does not).

---

## Why modern PySpark projects prefer DataFrames/Spark SQL

1. **Performance** — Catalyst optimization + Tungsten codegen are enormous (10–100× vs naive RDD for complex jobs).
2. **Ease of use** — declarative SQL-like API, less boilerplate.
3. **Optimization as the norm** — you get predicate pushdown, column pruning, broadcast joins, AQE automatically.
4. **SQL interoperability** — same logical plan, analysts can write SQL.
5. **Semi-structured support** — JSON, Parquet, nested types handled naturally.

RDDs are still taught/used for: legacy code, unstructured text, custom binary, or when you need fine-grained partition control. But for intern-level Data Engineering, **default to DataFrames**.

### Interview Explanation
> "Modern PySpark prefers DataFrames and Spark SQL because the Structured APIs let Catalyst optimize queries (predicate pushdown, column pruning, efficient joins) and Tungsten execute them fast — huge wins over unoptimized RDD code. They're also declarative and SQL-friendly, so analysts and engineers share one model. RDDs remain only for unstructured data or low-level control."

---

**End of Chapter 4.** Tick "RDD" in the tracker.

---

