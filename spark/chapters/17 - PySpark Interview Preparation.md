# 17. PySpark Interview Preparation

**Objective:** A big bank of interview questions in escalating difficulty, plus scenario questions. Use the answer framework in Chapter 18 to structure answers.

**Interview importance:** `MUST KNOW`

---

## Round 1 — Basic (30+ questions)

1. What is Apache Spark?
2. What is PySpark?
3. What is a DataFrame in Spark?
4. What is an RDD?
5. What is lazy evaluation?
6. What is a transformation?
7. What is an action?
8. What is a SparkSession?
9. What is a SparkContext?
10. What is a partition?
11. What is a schema?
12. Why use Spark over pandas?
13. What is `spark.read` used for?
14. What is `select` vs `selectExpr`?
15. What is `withColumn` vs `withColumnRenamed`?
16. Difference between `filter` and `where`?
17. What is `groupBy` and why does it shuffle?
18. What is an inner vs left join?
19. What is `coalesce` function vs `coalesce` method? (first-non-null vs partition reduction)
20. What is `cache()`?
21. What is `collect()` and why is it dangerous?
22. What is `show()`?
23. Difference between `distinct` and `dropDuplicates`?
24. How do you handle nulls in PySpark?
25. What is `limit` vs `take`?
26. How do you add a column in PySpark?
27. How do you rename a column?
28. How do you remove a column?
29. How do you write a DataFrame to Parquet?
30. What is `explain()` for?
31. What is a temporary view?
32. How do you run SQL in Spark?

---

## Round 2 — Intermediate (30+ questions)

1. What is a DAG and how is it created?
2. What is a stage? What creates a stage boundary?
3. What is a task? What is its relation to partitions?
4. What is the Driver? What is an Executor?
5. What is the difference between Job, Stage, and Task?
6. What is a cluster manager? Name types.
7. What is the Spark execution lifecycle?
8. What is Catalyst optimizer?
9. What is Tungsten?
10. What is whole-stage code generation?
11. What is predicate pushdown?
12. What is column pruning?
13. What is a shuffle? Why is it expensive?
14. What is shuffle write vs shuffle read?
15. What is a narrow vs wide transformation? Give examples.
16. What is a broadcast join? When to use it?
17. What is sort-merge join? When does Spark pick it?
18. What is data skew and how do you handle it?
19. What is `repartition` vs `coalesce`?
20. What is `spark.sql.shuffle.partitions`?
21. What is caching and when does it help/hurt?
22. What is a StorageLevel? Name a few.
23. What is AQE and what does it do?
24. What is Spark SQL and how does it relate to DataFrames?
25. What is a global temp view vs temp view?
26. Why is Parquet preferred for analytics?
27. What is partitioning a table vs partitioning data?
28. How do you inspect the execution plan?
29. What is spark-partition-id?
30. What happens when you call two actions without caching?
31. How does Spark achieve fault tolerance?
32. What is lineage?

---

## Round 3 — Advanced Internship Questions (30+)

1. Walk me through what happens when Spark runs `df.groupBy("k").count()` end-to-end.
2. Your Spark job is slow. How do you debug it? (see checklist in Ch 11)
3. One partition is much larger than others. What's happening and how do you fix it?
4. A join causes a huge shuffle. How do you optimize it?
5. When do you use a broadcast join vs sort-merge?
6. How do you identify data skew in the Spark UI?
7. How does AQE help and when wouldn't it?
8. What does `explain(True)` show and how do you read it?
9. How do you tune the number of shuffle partitions?
10. What causes small files and how do you fix it?
11. How do you choose partition size (128–256MB rule)?
12. How does Catalyst push down predicates for Parquet?
13. What is the difference between partition pruning and predicate pushdown?
14. How does Spark decide between broadcast and sort-merge join?
15. What is shuffle spill and its causes?
16. How does `cache()` interact with the executor memory model?
17. What's the trade-off between `MEMORY_ONLY` and `MEMORY_ONLY_SER`?
18. How would you make a 40-minute job take 10 minutes?
19. How do you co-partition data to avoid join shuffles?
20. What are straggler tasks and how do you fix them?
21. How does lineage enable fault tolerance, and when does recomputation hurt?
22. What is the small-file problem in streaming writes?
23. How do you ensure determinism/reproducibility in a Spark ETL?
24. What config do you set for a memory-heavy job vs I/O-heavy job?
25. How do Python UDFs affect Spark's optimization and performance?
26. What is the relationship between Spark, the data lake, and the warehouse?
27. How would you design a daily incremental ETL with Spark?
28. Compare window-function-based aggregation vs groupBy aggregation cost.
29. When would you choose RDDs over DataFrames?
30. What is the cost of `distinct()` vs `dropDuplicates()`?
31. How do you monitor Spark jobs (which UI tabs)?
32. Explain how a global sort differs from a per-partition sort.

---

## Scenario-Based Questions (20+)

1. **"Your Spark job takes 40 minutes. How would you debug it?"**
   → Start in Spark UI: slowest stage, shuffle read/write, spill, GC, task duration distribution; read plan; then filter/prune, broadcast, tune partitions, AQE, skew, cache, small files.

2. **"One partition is much larger than the others. What could be happening?"**
   → Data skew (hot key) or coalesce imbalance. Detect, then salt/AQE or repartition.

3. **"A join keeps producing a huge shuffle. How would you optimize it?"**
   → Check sizes: broadcast the small side; prune columns/filters before join; tune shuffle partitions; enable AQE; fix skew; consider bucketing/co-partitioning.

4. **"When would you use a broadcast join?"**
   → One side is small (< ~10MB default, ~200MB tuned), e.g. a dimension table; to avoid shuffling the large table.

5. **"Why is coalesce different from repartition?"**
   → coalesce reduces partitions without a full shuffle (merges in place, cheaper, can be uneven); repartition does a full shuffle to any count, more even.

6. **"A nightly ETL fails at 2 a.m. on a bad record. What do you do?"**
   → Inspect logs; isolate failure; use `isNotNull`/robust parsing; consider `mode("PERMISSIVE")` or filtering bad rows + quality checks; make it idempotent and retryable.

7. **"You need to join a 1 GB table with a 10 MB table hourly. Approach?"**
   → Broadcast the 10 MB table every run (small, fits memory); avoid shuffle.

8. **"A user asks why the same query is slow on 1 TB but fast on 1 GB. What changes?"**
   → Data scale triggers shuffles, skew, memory pressure, small/large partition issues that don't appear at small scale. Tune partitions, cache, AQE; test at scale.

9. **"How do you deduplicate a large events table cheaply?"**
   → `dropDuplicates(["key"])` (one shuffle), avoid Python UDFs; if only need first, use window row_number; consider approximate approaches.

10. **"Your groupBy runs out of memory. What's wrong?"**
    → Too much data per key / too few shuffle partitions / spill. Increase shuffle partitions, distribute keys, fix skew, more memory.

11. **"How do you handle time-window aggregation errors from out-of-order events (batch)?"**
    → In streaming use event time + watermark; in batch sort by event time before windowing.

12. **"Your Parquet output has 10,000 tiny files. Why and how to fix?"**
    → Too many output partitions (or streaming small batches). Coalesce/repartition before write to get ~128MB files; run compaction.

13. **"A column has 30% nulls in a quality report. What do you investigate?"**
    → Whether nulls are expected (optional fields) vs data loss; check upstream, join side-effects, cast failures; decide fill/drop/reject.

14. **"You must process files that are mostly (80%) filtered out. How to optimize?"**
    → Predicate pushdown/filter at read (columnar), partition pruning, prune columns, coalesce after filter.

15. **"A streaming query's state keeps growing. What do you do?"**
    → Ensure a watermark is defined; use appropriate state cleanup; monitor state size; maybe RocksDB state store.

16. **"You cached a DataFrame but the UI shows Fraction Cached < 100%. What now?"**
    → Executor memory is insufficient; reduce data, use `MEMORY_AND_DISK`, or increase memory.

17. **"Your join is correct but very slow; the key has a NULL-heavy skew."**
    → NULL keys concentrate on one partition. Filter/handle NULLs, salt them, or broadcast the small side.

18. **"Write a query to rank employees by salary within each department and keep top 3."**
    → Window `row_number() over (partitionBy dept orderBy salary desc)`, filter rn<=3.

19. **"What does it mean for a Spark job to be 'lazy', and why is that good?"**
    → Transformations don't run until an action; lets Catalyst optimize the whole plan; avoid recomputation.

20. **"How would you move from pandas to Spark for a pipeline?"**
    → Replace collect/loops with distributed operations, explicit schemas, avoid UDFs, use DataFrame functions, test at scale on real partitions.

21. **"Explain how you'd build a daily sales report from raw event logs."**
    → Ingest → clean → filter/prune → join dims (broadcast) → aggregate → quality check → write partitioned Parquet → schedule with Airflow.

---

**End of Chapter 17 (Interview Prep).**

---

