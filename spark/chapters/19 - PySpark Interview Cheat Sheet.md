# 19. PySpark Interview Cheat Sheet

**Objective:** Rapid revision tables. Skim these daily before interviews.

---

### Transformation vs Action

| Transformation (lazy) | Action (eager) |
|-----------------------|----------------|
| Returns a new DataFrame | Triggers execution, returns result/writes |
| `select`, `filter`, `withColumn`, `groupBy`, `join` | `count()`, `collect()`, `take()`, `show()`, `write` |
| Nothing computed | Fires a job |

### Narrow vs Wide Transformation

| Narrow | Wide |
|--------|------|
| 1 input partition → 1 output partition | Input contributes to many output partitions |
| No shuffle | Shuffle (stage boundary) |
| Pipelined in-memory | Writes to disk + network |
| `filter`, `map`, `select`, `withColumn`, `coalesce` | `groupBy`, `join`, `distinct`, `orderBy`, `repartition` |

### RDD vs DataFrame

| RDD | DataFrame |
|-----|-----------|
| No schema | Schema typed |
| No Catalyst/Tungsten | Catalyst + Tungsten |
| Functional (`map`/`filter`) | Declarative (SQL-like) |
| Slower | Faster |
| Unstructured/custom control | Standard for structured data |

### DataFrame vs Dataset

| DataFrame | Dataset |
|-----------|---------|
| `Dataset[Row]`, untyped | Typed `Dataset[T]` |
| All languages | Java/Scala only |
| PySpark standard | Type-safe JVM use |

### repartition vs coalesce

| repartition | coalesce |
|-------------|----------|
| Full shuffle | No full shuffle (merge in place) |
| Increase or decrease | Decrease only |
| Even partitions | Can be uneven |
| Expensive | Cheaper |

### cache vs persist

| cache() | persist() |
|---------|-----------|
| Shorthand: `MEMORY_AND_DISK` | Choose a StorageLevel |
| Same thing under the hood | `MEMORY_ONLY`, `MEMORY_AND_DISK`, `DISK_ONLY`, `_SER`, etc. |

### Driver vs Executor

| Driver | Executor |
|--------|----------|
| Orchestrates, builds plan/DAG, schedules | Runs tasks on partitions |
| Hosts SparkContext/SparkSession | Stores cached/shuffle data |
| `collect()` results here | Reports back to driver |

### Job vs Stage vs Task

| Job | Stage | Task |
|-----|-------|------|
| One action | Between shuffle boundaries | One partition on one core |
| Coarse | Medium | Fine |
| Can contain many stages | Contains many tasks | Smallest unit |

### Broadcast Join vs Sort Merge Join

| Broadcast | Sort Merge |
|-----------|------------|
| Small table copied to executors | Both sides shuffled + sorted |
| No shuffle of large | Two shuffles + sort |
| Small dim → large fact | Large → large equi-join |
| Low cost | Higher cost |

### Partition vs File

| Partition | File |
|-----------|------|
| In-memory/disk unit of parallelism | Unit of storage on object store |
| One task per partition | One or more partitions per file |
| Not directly persisted | Persisted on disk/S3 |

### Spark vs MapReduce

| Spark | MapReduce |
|-------|-----------|
| In-memory, fast iterative | Disk between steps |
| Unified SQL/streaming/ML | Batch only |
| Catalyst/Tungsten | No optimizer |
| Higher memory needs | Simpler, memory-light |

### Batch vs Streaming

| Batch | Streaming (Structured) |
|-------|------------------------|
| Finite data, scheduled | Unbounded, continuous |
| `spark.read` + actions | `readStream`/`writeStream` |
| Runs once/on schedule | Triggers/micro-batches |
| No watermark needed | Watermarks + checkpointing |

---

**End of Chapter 19.**

---

