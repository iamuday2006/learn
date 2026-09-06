# 20. Explain Spark From Memory

**Objective:** Be able to explain Spark end-to-end without notes. Practice this out loud until it's fluent.

## The 2-Minute Spark Explanation (internship interview)

> "Apache Spark is a unified, in-memory distributed computing engine for large-scale data processing. It's *distributed* because it splits work across a cluster of machines, and *unified* because one engine handles batch, SQL, streaming, and machine learning with the same APIs.
>
> A Spark application is coordinated by a **driver**, which turns your code into a plan. Catalyst, Spark's optimizer, takes the logical plan, applies rules like predicate pushdown and column pruning, and produces an efficient physical plan — which Tungsten then executes with fast generated code.
>
> Data in Spark is split into **partitions**. When you call an **action** — like `count()` or `collect()` — the driver creates a **job**, which the DAG Scheduler splits into **stages** at each **shuffle** boundary (wide transformations like `groupBy` and `join`), and each stage into **tasks** — one task per partition, run on **executors** across the cluster. Narrow transformations like `filter` and `select` pipeline in memory; wide ones trigger a shuffle that writes to disk and moves data over the network, which is the main cost.
>
> Because transformations are **lazy**, Spark optimizes the whole query before executing. It's **fault tolerant** through lineage — lost partitions are recomputed from the recorded transformations. For performance, I broadcast small tables, filter and prune columns early, tune shuffle partitions, enable AQE, handle data skew, and cache reused frames.
>
> So: Spark reads from a data lake, transforms it in a distributed, optimized, fault-tolerant way, and writes results — that's the core of modern Data Engineering."

## The step-by-step skeleton (practice tracing)

1. **What is Spark?** — unified, distributed, in-memory compute engine.
2. **How does an app start?** — `SparkSession` created; driver connects to cluster via cluster manager; executors allocated.
3. **What does the Driver do?** — builds plan/DAG, schedules jobs/stages/tasks, collects results.
4. **What are Executors?** — worker JVMs that run tasks on partitions, store cache/shuffle.
5. **What happens on a transformation?** — lazy: builds the logical plan/DAG, nothing runs.
6. **What happens on an action?** — triggers a job; DAG materialized and executed.
7. **How is the DAG created?** — built incrementally from transformations; optimized by Catalyst; physical plan as DAG.
8. **How are stages created?** — DAG Scheduler cuts at shuffle boundaries.
9. **How are tasks created?** — one per partition per stage.
10. **How are partitions processed?** — one task per partition, on one core of an executor.
11. **Where does shuffle happen?** — at wide transformations (groupBy, join, distinct, orderBy, repartition).
12. **How do joins execute?** — broadcast (small side) or sort-merge/hash (larger), with shuffle as needed; skew via AQE/salting.
13. **How does Spark optimize?** — Catalyst: pushdown, pruning, constant folding, join reorder, algorithm selection; Tungsten: codegen.
14. **How do I optimize a slow job?** — Spark UI (stage, shuffle, spill, GC, skew) + plan; then broadcast, filter/prune, tune partitions, AQE, cache, small files.

---

**End of Chapter 20.** This is the skill to have memorized — practice until smooth.

---

