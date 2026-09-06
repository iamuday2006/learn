# 10. Spark SQL

**Objective:** Use SQL against DataFrames, understand temp vs global views, and read/interpret query plans to see how SQL and DataFrames share one engine.

**Why it matters:** Data Engineers write a lot of Spark SQL, and being able to read `EXPLAIN` output is a strong interview skill.

**Book chapters to study:** Ch 3–4 (SQL), Ch 7 (plans/EXPLAIN), Ch 10 (Spark SQL).

**Interview importance:** `MUST KNOW`

---

## Concept: Temporary Views

### Simple Explanation
Register a DataFrame as a **named, queryable table** scoped to the current SparkSession, then run SQL on it.

### Code Example
```python
df.createOrReplaceTempView("sales")

result = spark.sql("""
    SELECT product, SUM(amount) AS total
    FROM sales
    GROUP BY product
    ORDER BY total DESC
""")
result.show()
```
- `createOrReplaceTempView` creates/overwrites a session-scoped view.
- View disappears when the session ends (or `dropTempView`).

### Interview Explanation
"A temp view registers a DataFrame as a named table in the current SparkSession so you can query it with `spark.sql`. It's session-scoped and vanishes when the session ends. `createOrReplaceTempView` overwrites any existing view of the same name."

### Common Mistakes
- Forgetting the view only lives for the session.
- Not calling `createOrReplaceTempView` before `spark.sql`.

---

## Concept: Global Temporary Views

### Simple Explanation
Views **shared across sessions** in the same application — accessible within the `global_temp` database.

### Code Example
```python
df.createOrReplaceGlobalTempView("sales")
spark.sql("SELECT * FROM global_temp.sales")
```

### Interview Explanation
"Global temp views are shared across multiple SparkSessions within the same application and live until the application ends. You must qualify them with the `global_temp` database (e.g. `global_temp.sales`). Temp views are session-scoped; global views are app-scoped."

### Common Mistakes
- Forgetting to prefix with `global_temp.`.

---

## Concept: SQL / DataFrame Interoperability

### Simple Explanation
DataFrames ↔ SQL are **two syntaxes for the same engine**. Both compile through Catalyst to the *same* optimized physical plan.

### Code Example
```python
# DataFrame API
df1 = spark.read.parquet("...").filter("amount > 100").groupBy("cat").sum("amount")

# Equivalent SQL
df.createOrReplaceTempView("t")
df2 = spark.sql("SELECT cat, SUM(amount) FROM t WHERE amount > 100 GROUP BY cat")
```
Both produce identical plans → identical performance.

### Interview Explanation
"SQL and the DataFrame API are interchangeable: a DataFrame can become a temp view queried with SQL, and any `spark.sql` result is itself a DataFrame. Because both compile through Catalyst to the same physical plan, there's no performance difference — it's purely stylistic."

### Common Mistakes
- Assuming SQL is faster/slower than DataFrames (it isn't).

---

## Concept: Catalyst Optimization & Query Plans / EXPLAIN

### Simple Explanation
`df.explain()` shows the **optimized logical plan**; `df.explain(True)`/`extended` shows all plans (unresolved → logical → optimized → physical).

### Code Example
```python
df.filter("amount > 100").groupBy("cat").sum("amount").explain(True)
```

### What to look for in the plan
- **Logical plan:** the operator tree (Scan, Filter, Aggregate) — what's computed.
- **Optimized logical plan:** after Catalyst rules (predicate pushdown, column pruning).
- **Physical plan:** actual operators — look for:
  - `PushedFilters` (predicate pushed to source)
  - `BroadcastHashJoin` vs `SortMergeJoin`
  - `Exchange` (shuffle)
  - `WholeStageCodegen` (Tungsten fused execution)

### Interview Explanation
"`df.explain(True)` prints the full plan chain. I use it to verify optimization actually happened — e.g. that filters were pushed down (PushedFilters), that a small table got a `BroadcastHashJoin` instead of a shuffling `SortMergeJoin`, and where the `Exchange`/shuffle stages sit. Reading plans is how I diagnose slow jobs."

### Common Mistakes
- Only looking at execution time, never the plan.
- Confusing logical and physical plans.

---

## Concept: Physical plan operators cheat-sheet

| Operator in plan | Meaning |
|------------------|---------|
| `Scan parquet` / `FileScan` | Reading data; check `PushedFilters`, `PushedPredicates` |
| `Filter` | Row filtering |
| `Project` | Selecting columns (pruning) |
| `HashAggregate` | Aggregation |
| `Exchange` | **Shuffle** (network I/O) |
| `Sort` | Sorting |
| `BroadcastHashJoin` | Broadcast join (no shuffle of large side) |
| `SortMergeJoin` | Shuffled + sorted join (large-large) |
| `WholeStageCodegen` | Tungsten fused execution (good) |

---

**End of Chapter 10.** Tick "Spark SQL" in the tracker.

---

