# 3. Spark Execution Model

**Objective:** Understand *how* Spark turns your code into an efficient execution, and be able to reason about "what will Spark actually do when this code runs?"

**Why it matters:** Lazy evaluation, Catalyst, and Tungsten are the difference between "Spark groups data" and "Spark optimizes and executes a plan." Internship interviews love to test whether you know transformations are lazy.

**Book chapters to study:** Ch 2 (intro to DAG/plan), Ch 4, Ch 7 (logical/physical plans), Ch 19 (Catalyst/Tungsten in Part IV).

**Interview importance:** `MUST KNOW`

---

## Concept: Lazy Evaluation

### Simple Explanation
Spark **doesn't run anything** when you define transformations. It just records *what to do*. Execution happens only when you call an **action** that needs a result.

### Technical Explanation
Transformations are **lazy**: calling `filter`, `select`, `groupBy` only builds up the logical plan (a DAG). No computation touches the data until an **action** (`count()`, `show()`, `collect()`, `write`) forces execution. This lets Catalyst see the *whole* query and optimize across all transformations at once.

### Why It Exists
If Spark ran each transformation immediately, it would re-read/recompute data per step. Laziness lets Spark **optimize the entire pipeline as one unit** (e.g. push a later filter down to the source) and avoid unnecessary work.

### Real-World Example
```python
df = spark.read.csv("huge.csv", header=True)   # nothing read yet
df2 = df.filter(F.col("amount") > 100)          # nothing
df3 = df2.groupBy("region").sum("amount")       # nothing
df3.show()                                       # NOW Spark reads + computes
```

### Interview Explanation
> "Spark uses lazy evaluation: transformations only build up an execution plan (a DAG) and don't touch data until an action is called. This is crucial because it lets Catalyst optimize the entire query at once — pushing filters down to the source, pruning columns, and avoiding recomputation. It's a core reason Spark is efficient."

### Common Mistakes
- Expecting a transformation to print/execute results immediately.
- Not realizing reading a DataFrame is also lazy until an action.

### Interview Questions
1. (B) What is lazy evaluation in Spark?
2. (I) How does lazy evaluation enable query optimization?
3. (I) Which methods are lazy: transformations or actions?

---

## Concept: Transformation

### Simple Explanation
An operation that **defines** how to produce a new DataFrame from an existing one — but doesn't compute anything yet.

### Technical Explanation
A transformation takes a DataFrame and returns a new immutable DataFrame describing a new logical plan node. Examples: `select`, `filter`, `withColumn`, `groupBy`, `join`. Transformations are lazy. They may be **narrow** (no shuffle) or **wide** (shuffle).

### Why It Exists
Transformations are the declarative "recipe" — you describe what you want; Spark figures out how.

### Real-World Example
```python
clean = raw.filter(F.col("is_valid") == True).dropDuplicates(["id"])
```

### Interview Explanation
> "A transformation is a lazy operation on a DataFrame that returns a new DataFrame describing additional work to do — like filter, select, or join. It doesn't execute until an action. Narrow transformations avoid shuffles; wide ones cause them."

### Common Mistakes
- Thinking transformations modify the original DataFrame (they return a new one; DataFrames are immutable).

---

## Concept: Action

### Simple Explanation
An operation that **triggers actual execution** and returns a result (or writes data).

### Technical Explanation
An action forces Spark to compute the DAG: `count()`, `collect()`, `take()`, `show()`, `first()`, `write` (yes, writing is an action), `foreach`, etc. Each action fires a **job**. Importantly, different actions may share cached middle results but otherwise recompute from scratch unless you cache.

### Why It Exists
Without a trigger, nothing happens. Actions are when Spark materializes the plan.

### Real-World Example
```python
df.count()                 # action
df.collect()               # action
df.write.parquet("out/")   # action
```

### Interview Explanation
> "An action is what triggers Spark to actually execute the lazy DAG. Examples are count, collect, show, take, and write operations. Each action corresponds to a Spark job. Without an action, transformations never touch the data."

### Common Mistakes
- Treating `write` as a transformation (it's an action).
- Not realizing two actions recompute the same transformations unless cached.

### Interview Questions
1. (B) Name common actions.
2. (I) What happens if you call two actions on the same transformed DataFrame without caching?

---

## Concept: Lineage

### Simple Explanation
The **complete history** of transformations that produced a DataFrame (or RDD). Spark remembers every step.

### Technical Explanation
Each DataFrame/RDD carries its **lineage** — the chain of parent RDDs and transformations. Because DataFrames are immutable, Spark can recreate any partition by replaying lineage from source. This is how **fault tolerance** works: if an executor/partition is lost, Spark recomputes just that partition from lineage instead of re-running the whole job.

### Why It Exists
Fault tolerance without duplicating every byte: instead of replicating data, Spark records the instructions to reproduce it.

### Real-World Example
A node dies mid-job. Spark inspects lineage, finds which partitions came from that node, recomputes only those, and continues.

### Interview Explanation
> "Lineage is the recorded history of transformations that produced a dataset. Because Spark datasets are immutable, any lost partition can be recomputed by replaying lineage from the source. This gives Spark fault tolerance without the cost of full data replication — only the missing partitions are recomputed."

### Common Mistakes
- Thinking lineage repetition is free — recomputation has a cost (which is why you cache reused data).
- Confusing lineage with caching (they're complementary, not the same).

---

## Concept: Logical Plan

### Simple Explanation
An **abstract, unoptimized** description of "what to compute" — the raw steps you wrote, before performance tuning.

### Technical Explanation
When you apply transformations, Spark builds a **logical plan** — a tree of logical operations (Scan, Project, Filter, Aggregate, Join) with no execution details (no shuffle decisions, no partition counts). `df.explain()` (without `extended`) shows the optimized logical plan.

### Why It Exists
A clean logical model lets Catalyst apply optimizer rules independent of execution concerns.

### Interview Explanation
> "A logical plan is Spark's operator-tree representation of your query — what to compute with no execution details. Catalyst first builds an unresolved logical plan, resolves columns/types, then optimizes it to an optimized logical plan by applying rules like predicate pushdown and column pruning. `df.explain()` shows it."

---

## Concept: Optimized Logical Plan

### Simple Explanation
The logical plan **after Catalyst applies optimization rules** — same "what," but smarter.

### Technical Explanation
Catalyst's optimizer applies rule- and cost-based optimizations to the logical plan:
- **Predicate pushdown** — move filters closer to the data source (read less).
- **Column pruning** — drop unused columns early.
- **Constant folding** — compute `1 + 1` once, not per row.
- **Join reordering** — order joins to minimize intermediate size.
The result is the **optimized logical plan**.

### Why It Exists
To make the query as cheap as possible before deciding *how* to execute.

### Real-World Example
```python
df.select("a", "b").filter(...)  # Catalyst prunes unselected columns at the source
```

### Interview Explanation
> "The optimized logical plan is produced when Catalyst applies transformations like predicate pushdown, column pruning, and constant folding to the raw logical plan. It reduces how much data must be read and processed. This is why Spark is fast even when your transformation order isn't perfect."

### Common Mistakes
- Assuming Catalyst always gets it right — it's good but not magic; see performance chapter.

---

## Concept: Physical Plan

### Simple Explanation
The **concrete execution strategy** — *how* Spark will actually run the query (algorithms, shuffle details).

### Technical Explanation
Catalyst converts the optimized logical plan into a **physical plan**, choosing specific execution strategies: join algorithm (broadcast vs sort-merge vs hash), aggregation method, partition counts, shuffle configurations. `df.explain(True)` shows logical + optimized logical + physical plans.

### Why It Exists
The physical plan is the link between "what" and the actual tasks Spark schedules on executors.

### Interview Explanation
> "The physical plan is Catalyst's concrete execution strategy — choosing actual algorithms like broadcast vs sort-merge join, how to aggregate, and shuffle partitioning. `df.explain(True)` reveals both the logical and physical plans. The physical plan is what becomes the DAG of tasks."

---

## Concept: Catalyst

### Simple Explanation
Spark's **query optimizer** — a rule-based system that turns your DataFrame/SQL code into an efficient physical plan.

### Technical Explanation
Catalyst is a tree-transformation framework. It:
1. Builds an unresolved logical plan.
2. Analyzes/resolves it (types, columns) → logical plan.
3. Applies optimization rules → optimized logical plan.
4. Selects physical operators (cost/rule-based) → physical plan.
5. Generates Java/Scala code via Tungsten (whole-stage code generation) → runs on executors.

### Why It Exists
To automatically optimize user queries so performance doesn't depend on writing "perfect" code, and so SQL and DataFrame APIs produce identical plans.

### Interview Explanation
> "Catalyst is Spark's optimizer. It takes a query, builds a logical plan, resolves it, applies optimization rules like predicate pushdown and column pruning, and then chooses a physical plan with specific algorithms. It's why SQL and DataFrames compile to identical, highly optimized plans and why the same query can be tuned automatically."

### Common Mistakes
- Confusing Catalyst (optimizer/planning) with Tungsten (execution/codegen) — together they optimize and run.

---

## Concept: Tungsten

### Simple Explanation
Spark's **execution engine** — makes actual computation fast using direct memory access and code generation.

### Technical Explanation
Tungsten optimizes execution by:
- **Off-heap memory / binary in-memory data** — columnar binary format avoiding JVM object overhead and GC pressure.
- **Cache-aware computation and code generation** — Java codegen for tight loops.
- **Whole-stage code generation** — fuse the whole stage into a single Java function, eliminating virtual calls and intermediate data.

### Why It Exists
JVM object overhead and garbage collection were huge bottlenecks. Tungsten stores data efficiently and generates compact code.

### Real-World Example
A `filter + select + withColumn` stage compiles into one fused loop over binary columns — no per-row object creation.

### Interview Explanation
> "Tungsten is Spark's execution backend. It stores data in a compact binary format in off-heap memory, generates optimized Java code for the whole stage, and uses whole-stage code generation to fuse operations — cutting JVM overhead and GC pressure dramatically. Catalyst plans the query; Tungsten executes it fast."

### Common Mistakes
- Treating Catalyst and Tungsten as interchangeable (planner vs executor).

---

## Concept: Whole-Stage Code Generation

### Simple Explanation
Turning an entire Spark stage into **one fused piece of generated Java code**, avoiding overhead between operations.

### Technical Explanation
Whole-stage code generation lets the compiler fuse the operators of a stage into a single function so data flows between them via local variables instead of through intermediate objects/memory. It's a Tungsten optimization visible as `WholeStageCodegen` in the physical plan. Note: it's effectively disabled when Python UDFs are involved (they break the fused JVM loop).

### Why It Exists
Removes per-record overhead (virtual calls, serialization, intermediate buffers) — major speedup.

### Interview Explanation
> "Whole-stage code generation, part of Tungsten, fuses all operators in a stage into one generated Java function. Data moves between them in registers/local variables instead of through memory, eliminating huge overhead. It shows up as WholeStageCodegen in plans and is why Catalyst-optimized DataFrame code runs far faster than naive per-row execution."

### Common Mistakes
- Not realizing Python UDFs can break whole-stage codegen (performance hit).

---

## Concept: Query Optimization (putting it together)

### Simple Explanation
Spark automatically tries to make your query as cheap as possible, then executes it as tight fused code.

### Technical Explanation
```text
Transformation
      ↓
Logical Plan
      ↓
Catalyst
      ↓
Physical Plan
      ↓
Execution
```
Catalyst optimizes (pushdown, pruning, constant folding, join reorder, and selections of algorithms), Tungsten executes (binary storage, codegen, whole-stage fusion). Together they deliver the performance edge of Structured APIs over raw RDD code.

### Real-World Example — reasoning about this code:
```python
df = spark.read.parquet("s3://bucket/data/") \
    .filter(F.col("date") == "2024-01-01") \
    .select("user_id", "amount") \
    .groupBy("user_id") \
    .agg(F.sum("amount"))
df.show()
```
"What Spark actually does": Catalyst pushes the `date` filter into the Parquet read (predicate + column pruning) so only date=2024-01-01 rows and only the needed columns are read; then groupBy→sum triggers a shuffle; Tungsten fuses and executes. Understanding this lets you explain *why* it's fast and where the shuffle is.

### Interview Explanation
> "Optimization in Spark is a pipeline: Catalyst builds and optimizes the logical plan (predicate pushdown, column pruning, constant folding, join reordering), then selects a physical plan with specific algorithms. Tungsten then executes it with binary in-memory storage and whole-stage code generation. So Spark reads the minimum data, processes it in tight fused loops, and only shuffles where truly necessary."

---

## Teach me to reason: "What will Spark actually do when this code runs?"

Use this mental model for any DataFrame code:

1. **Is the operation a transformation or action?** — If it's all transformations, nothing runs until an action.
2. **What's the slot pipeline?** — Which ops are narrow (pipelined in a stage) vs wide (shuffle, stage boundary)?
3. **Count the shuffles** — each `groupBy/join/distinct/orderBy/repartition` = likely a shuffle = stage boundary + network I/O.
4. **What will Catalyst fix for me?** — filters pushed down, columns pruned, joins reordered/broadcast.
5. **What won't Catalyst fix?** — data skew, too many tiny partitions, cache-not-reused, Python UDFs.

---

**End of Chapter 3.** Tick "Transformations", "Actions", "Lazy evaluation", "DAG", "Catalyst" in the tracker.

---

