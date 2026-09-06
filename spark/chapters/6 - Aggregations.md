# 6. Aggregations

**Objective:** Master grouping and aggregation, and understand the *execution* implications — especially why `groupBy` causes a shuffle.

**Why it matters:** Aggregations are everywhere in ETL and analytics, and the shuffle-reasoning behind them is a top interview topic.

**Book chapters to study:** Ch 4/5 (structured operations), Ch 12 (aggregations).

**Interview importance:** `MUST KNOW`

---

## Concept: groupBy

### Simple Explanation
Groups rows by one or more columns, then applies aggregate functions per group, returning one row per group.

### Code Example
```python
from pyspark.sql import functions as F

df.groupBy("department").count()
df.groupBy("department", "region").agg(F.sum("sales"))
```

### Execution Implication — why it can cause a shuffle
```python
df.groupBy("department").count()
```
Data for the same `department` may be spread across many partitions. To compute each department's count, Spark must bring all rows with the same department together — that requires a **shuffle** (a wide transformation / stage boundary). Spark writes intermediate data to disk and moves it across the network so grouping keys land on the same executor.

### Interview Explanation
> "`groupBy` groups rows by one or more keys and applies an aggregate per group. Because rows with the same key may live on different partitions across the cluster, Spark performs a shuffle to bring same-key rows together — a wide transformation that creates a stage boundary and moves data over the network. That's why `groupBy` can be expensive, and why tuning shuffle partitions matters."

### Common Mistakes
- Underestimating the cost of grouping many keys (huge shuffle).
- Forgetting that fewer keys reduces shuffle but can skew.

### Interview Questions
1. (B) What does `groupBy` do?
2. (I) Why does `groupBy` cause a shuffle?
3. (I) What's inside `spark.sql.shuffle.partitions` after a groupBy (default 200)?

---

## Concept: agg

### Simple Explanation
`agg` lets you compute **multiple** aggregations in one call, typically combined with `groupBy`.

### Code Example
```python
from pyspark.sql import functions as F

stats = df.groupBy("department").agg(
    F.count("*").alias("count"),
    F.sum("sales").alias("total_sales"),
    F.avg("sales").alias("avg_sales"),
    F.min("sales").alias("min_sales"),
    F.max("sales").alias("max_sales"),
    F.countDistinct("user_id").alias("unique_users"),
    F.stddev("sales").alias("std_sales")
)
```

### Interview Explanation
"`agg` computes several aggregates over grouped data in one `groupBy`, letting you produce count, sum, avg, min, max, etc. together with a single shuffle."

---

## Concept: Aggregation Functions (count, sum, avg, min, max)

### Code Example
```python
df.agg(F.count("*"), F.sum("amount"), F.avg("amount"),
       F.min("amount"), F.max("amount"))
```
- `count(*)` counts all rows; `count(col)` counts non-null; `countDistinct(col)` counts unique non-null.
- `sum/avg/min/max` ignore nulls.

### Interview Explanation
"Aggregate functions operate per group (or whole frame with `agg`): `count`, `sum`, `avg`, `min`, `max`, `countDistinct`. They generally ignore nulls. `approx_count_distinct` is a much cheaper approximate alternative to `countDistinct`."

---

## Concept: countDistinct & approx_count_distinct

### Simple Explanation
`countDistinct` gives exact distinct counts (expensive — needs shuffle); `approx_count_distinct` estimates with a HyperLogLog sketch (fast, slight error).

### Code Example
```python
from pyspark.sql import functions as F

df.agg(F.countDistinct("user_id"))          # exact, expensive
df.agg(F.approx_count_distinct("user_id", rsd=0.05))  # fast estimate
```

### Interview Explanation
"`countDistinct` computes exact distinct counts but is expensive because it shuffles all distinct values. `approx_count_distinct` uses a probabilistic sketch (HyperLogLog-like) and is dramatically faster with a tunable relative error — great for large-cardinality counts in analytics."

### Common Mistakes
- Using `countDistinct` on huge, high-cardinality columns when approximation is acceptable.

---

## Concept: rollup & cube

### Simple Explanation
Multi-dimensional aggregations: `rollup` computes subtotals for a hierarchy; `cube` computes subtotals for all combinations.

### Code Example
```python
from pyspark.sql import functions as F

# rollup: (dept, region), (dept), ()  — hierarchical subtotals
df.rollup("department", "region").agg(F.sum("sales")).show()

# cube: all combinations — (dept,region),(dept),(region),()
df.cube("department", "region").agg(F.sum("sales")).show()
```
Rows with `null` in grouping columns indicate subtotal/grand-total rows.

### Interview Explanation
"`rollup` produces hierarchical subtotals (each level + grand total). `cube` produces all combinations of the grouping columns. Both are SQL `GROUPING SETS`-style and useful for reporting but expand output and still shuffle."

### Common Mistakes
- Confusing rollup (hierarchical) with cube (all combinations).
- Mis-interpreting `null` grouping values as missing data (they're subtotal markers).

---

**End of Chapter 6.** Tick "Aggregations" in the tracker.

---

