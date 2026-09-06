# 2. Spark Architecture

**Objective:** Understand every component of a running Spark application and exactly what happens — from writing PySpark code to results landing on disk.

**Why it matters:** This is the most-asked deep-dive area in Data Engineering interviews. Every interviewer wants to know you understand Driver, Executor, Job, Stage, Task, Partition, and DAG.

**Book chapters to study:** Ch 2 (architecture), Ch 19/20 of the book's Part IV (Spark internals), and throughout.

**Interview importance:** `MUST KNOW` — arguably the single most important section for Data Engineering interviews.

---

## Concept: Driver

### Simple Explanation
The **conductor** of a Spark application. One process that runs your main program, breaks it into jobs/stages/tasks, and sends tasks to executors.

### Technical Explanation
The **driver process** runs the user's main function (your PySpark script), maintains the `SparkContext`/`SparkSession`, converts user code into a **logical plan → physical plan → DAG**, and schedules **tasks** onto executors via the cluster manager. It also collects results for actions like `collect()`. An unhealthy driver = the whole app fails.

### Why It Exists
Someone must orchestrate: translate user code into an executable plan, schedule work, track progress, and aggregate results. That's the driver.

### Real-World Example
You run `spark-submit etl.py`. The driver process starts, builds a DAG from your transformations, schedules tasks to executors, and at the end `collect()`s or `write`s results.

### Interview Explanation
> "The driver is the central coordinating process of a Spark application. It runs the user's main program and the SparkContext, translates user code into an execution plan, breaks it into jobs, stages, and tasks, and schedules those tasks onto executors through the cluster manager. It's also responsible for returning results for actions like collect. If the driver fails, the whole application dies."

### Common Mistakes
- Running heavy logic on the driver that should run distributed (e.g. `collect()` on huge data → driver OOM).
- Thinking drivers can be stateless — they hold the DAG and often cached metadata.

### Interview Questions
1. (B) What does the driver do?
2. (I) What happens on the driver when you call `collect()`?
3. (I) Why can `collect()` on large data crash the driver?

---

## Concept: Executor

### Simple Explanation
A **worker process** that runs on a cluster node and actually executes tasks (computations) on partitions of your data.

### Technical Explanation
Executors are JVM processes running on **worker nodes**. Each executor:
- Runs **tasks** (the smallest unit of work) sent to it by the driver.
- Stores data in memory (cache) and on disk for shuffle/spill.
- Reports progress/blocks back to the driver.
Executors are launched at app start and killed at app end (unless dynamic allocation changes their count).

### Why It Exists
Computation must happen *where the data is* (locality) and in parallel — executors provide the parallel execution slots.

### Real-World Example
A 10-node cluster with 4 executors each = up to 40 concurrent tasks (one per core). Your 200-partition DataFrame runs across them.

### Interview Explanation
> "Executors are worker processes that run on cluster nodes and perform the actual computation. Each executor provides a set of cores, each of which can run one task at a time. Executors also hold cached and shuffle data for reuse. The driver schedules tasks to executors, and executors feed results back. Having too few executors/cores limits parallelism."

### Common Mistakes
- Confusing executor with worker node — a node can host many executors.
- Not sizing executor memory correctly (OOM on large partitions).

### Interview Questions
1. (B) What is an executor? What does it store?
2. (I) If you have 4 executors with 4 cores each, how many tasks run in parallel?
3. (I) What's in an executor's memory?

---

## Concept: Cluster Manager

### Simple Explanation
The component that **allocates cluster resources** (machines, CPU, memory) to your Spark application. Options: Standalone, YARN, Mesos, Kubernetes.

### Technical Explanation
The cluster manager is a pluggable resource scheduler. When your app starts, the driver asks the cluster manager for executor resources. Standalone is Spark's built-in manager; YARN is Hadoop's; Kubernetes (K8s) is increasingly standard. `EXTERNAL KNOWLEDGE`: Kubernetes support postdates the book but is standard in 2025 interviews.

### Why It Exists
Multiple apps may share a cluster. A cluster manager ensures fair allocation of resources between competing Spark apps (and other frameworks).

### Real-World Example
Two teams submit Spark jobs. YARN/K8s decides how many executors each gets based on their requested `spark.executor.instances` and cluster capacity.

### Interview Explanation
> "The cluster manager is responsible for allocating resources to Spark applications. When a Spark app starts, its driver negotiates with the cluster manager — Standalone, YARN, Mesos, or Kubernetes — to obtain executors. This lets many applications share one cluster fairly. The driver then schedules tasks onto those executors."

### Common Mistakes
- Thinking the cluster manager runs your Spark code — it only allocates resources.
- Assuming local mode has a cluster manager (local mode is single-machine, no manager needed).

### Interview Questions
1. (B) Name the cluster managers Spark supports.
2. (I) How does a Spark app get resources from YARN?
3. (B) What's local mode?

---

## Concept: Worker Node

### Simple Explanation
A **physical/virtual machine** in the cluster where executors execute. It's the computer that does the actual work.

### Technical Explanation
A worker node hosts one or more executors. It runs the cluster-manager agent that launches/kills executors on request. Data locality matters: Spark prefers to schedule a task on an executor that already holds the needed data partition (avoiding network transfer).

### Why It Exists
Parallelism comes from having *many* machines each holding a slice of your data and computing on it locally.

### Real-World Example
In AWS EMR, each worker node is an EC2 instance running executors. Data partitioned across nodes -> tasks run where the data lives.

### Interview Explanation
> "A worker node is a machine in the cluster that hosts executors. To maximize throughput, Spark schedules tasks to executors located on the same node as the relevant data partition — this is data locality, which avoids moving data over the network whenever possible."

### Common Mistakes
- Assuming data is always local (shuffles move data across nodes).
- Ignoring data locality when reasoning about performance.

### Interview Questions
1. (B) What is a worker node?
2. (I) What is data locality and why does it matter?

---

## Concept: Application, Job, Stage, Task, Partition

These are the **granularity levels** of a Spark program. Understanding them is essential — you'll be asked to distinguish them.

### Simple Explanation (all five, together)
- **Application:** your whole Spark program (driver + its executors).
- **Job:** work triggered by **one action** (`count()`, `collect()`, `show()`).
- **Stage:** a set of tasks that can run **together without a shuffle** — stages are separated by shuffle boundaries.
- **Task:** smallest unit of work — processes **one partition** on **one core**.
- **Partition:** a **slice of data** in memory/disk.

### Technical Explanation

| Term | Description | Created by | Granularity |
|------|-------------|------------|-------------|
| Application | Driver + all its executors | `SparkSession` | Coarsest |
| Job | Parallelization of one action | An action call | Coarse |
| Stage | Tasks grouped between shuffles | A shuffle boundary | Medium |
| Task | One partition processed on one core | A stage's partition split | Fine |
| Partition | A logical slice of data | Reading/reshuffling | Data unit |

**A typical flow:** One `job` → split into `stages` (e.g. "map/filter stage", then "shuffle", then "reduce stage") → each stage has as many `tasks` as `partitions` → each task runs on one core.

### Why It Exists
This hierarchy lets Spark parallelize massively (many partitions → many tasks → many cores) while tracking progress and fault tolerance at a manageable granularity.

### Real-World Example

```python
result = df.filter(...).groupBy("key").sum("val")   # 1 stage, then shuffle
result.count()                                       # Action → Job
```

### Interview Explanation (the classic "Job/Stage/Task/Partition" question)
> "A Spark application runs many jobs: each action triggers one job. A job is broken into stages, separated by shuffle boundaries — pipelined operations that need no data movement run together in one stage. Each stage is further split into tasks, where there's one task per partition, and each task runs on a single core of an executor. A partition is a slice of the data. So the hierarchy is: Application → Jobs → Stages → Tasks, with data split into partitions processed one-core-per-partition."

### Common Mistakes
- Saying "stages are separated by every transformation" — only **wide (shuffle)** transformations create stage boundaries.
- Confusing task count with partition count — they're equal (1 task per partition).

### Interview Questions
1. (B) What's the difference between a job and a stage?
2. (I) What creates a stage boundary?
3. (I) How many tasks per partition?
4. (I) What determines the number of stages in a job?

---

## Concept: DAG (Directed Acyclic Graph)

### Simple Explanation
A **picture of your transformations** arranged as a graph of nodes (operations on data), showing dependencies. "Directed" = flows one way; "Acyclic" = no loops.

### Technical Explanation
A DAG is the execution plan Spark builds from your transformations. Nodes are RDD/DataFrame operations; edges are dependencies between them. The **DAG Scheduler** converts the DAG into **stages** of tasks. It's *lazy* — the graph is built as you add transformations, but not executed until an action.

### Why It Exists
By recording the full dependency graph, Spark can: optimize (pipeline narrow operations), schedule efficiently, and **recompute lost partitions** (fault tolerance via lineage).

### Real-World Example
You can see the DAG in the Spark UI's Jobs/Stages tab — a graph of operations with boxes for each stage.

### Interview Explanation
> "A DAG is the graph of transformations Spark builds from your code — nodes are operations, edges are dependencies. It's built lazily as you add transformations and executed when an action runs. The DAG Scheduler uses it to split work into stages and schedule tasks, and the graph doubles as lineage for fault-tolerant recomputation."

### Common Mistakes
- Thinking the DAG is created only at action time — it's built incrementally as transformations accumulate.
- Forgetting the DAG IS the lineage used for fault tolerance.

### Interview Questions
1. (B) What does DAG stand for and what is it?
2. (I) How does the DAG enable fault tolerance?
3. (I) Who uses the DAG?

---

## Concept: DAG Scheduler / Task Scheduler

### Simple Explanation
Two schedulers that convert your action into executable work. The **DAG Scheduler** splits the DAG into stages; the **Task Scheduler** launches tasks on executors.

### Technical Explanation
- **DAG Scheduler:** on each action, builds stages from the DAG (grouping narrow operations; breaking at wide/shuffle ops), tracks which stages are ready, and handles stage failure retries.
- **Task Scheduler:** receives tasks from the DAG Scheduler, launches them onto executors via the cluster manager, and handles task retry on executor failure.

Together they isolate concerns: DAG Scheduler = *what* stages; Task Scheduler = *where/execute* tasks.

### Why It Exists
Separating "plan the stages" from "schedule the tasks" keeps responsibilities clean and makes failure recovery tractable — a failed task can be retried on another executor; a failed stage re-plans.

### Real-World Example
Your job has 2 stages. DAG Scheduler sends stage 1's tasks → Task Scheduler launches them → stage 1 finishes → DAG Scheduler releases stage 2's tasks → Task Scheduler runs them.

### Interview Explanation
> "The DAG Scheduler converts the DAG produced by an action into stages, deciding where shuffle boundaries go and which stages can run. The Task Scheduler then takes the tasks of each stage and schedules them onto executors, handling retries if executors fail. DAG Scheduler decides *what* to run, Task Scheduler decides *where* to run it."

### Common Mistakes
- Thinking they're the same thing or that one of them executes tasks directly.
- Forgetting the driver hosts both.

### Interview Questions
1. (I) What does the DAG Scheduler do?
2. (I) What does the Task Scheduler do?
3. (I) How do the two schedulers interact?

---

## Concept: The Complete Execution Lifecycle

```text
PySpark Code
   ↓
Spark Application
   ↓
Driver
   ↓
Logical Plan
   ↓
Catalyst Optimizer
   ↓
Physical Plan
   ↓
DAG
   ↓
Job
   ↓
Stages
   ↓
Tasks
   ↓
Executors
   ↓
Partitions
   ↓
Output
```

### Explanation of each step
1. **PySpark Code** — You write DataFrames transformations + an action.
2. **Spark Application** — `SparkSession` created; app connects to cluster.
3. **Driver** — Orchestrates everything; builds plans.
4. **Logical Plan** — Unoptimized representation of "what to compute" (your transformations, minus execution details).
5. **Catalyst Optimizer** — Applies rules (predicate pushdown, column pruning, constant folding, join reordering) to produce an **optimized logical plan**.
6. **Physical Plan** — Catalyst chooses specific algorithms (join strategies, how to aggregate, partition counts) producing a bytecode-level plan via Tungsten.
7. **DAG** — The physical plan is represented as a DAG of operations.
8. **Job** — An action materializes the DAG into a job.
9. **Stages** — DAG Scheduler splits the job into stages at shuffle boundaries.
10. **Tasks** — Each stage is split into one task per partition.
11. **Executors** — Task Scheduler sends tasks to executors to run.
12. **Partitions** — Each task processes one partition on one core.
13. **Output** — Results written to storage or returned to driver.

### Real-World Example — lifecycle of `df.filter(...).groupBy("k").sum("v").collect()`:
1. Code defines two transformations + one action (`collect`).
2. Spark builds a logical plan (filter → groupBy+sum → collect).
3. Catalyst optimizes (pushes filter down, prunes columns).
4. Physical plan chosen (hash aggregation, shuffle).
5. A job fires; split into stages at the groupBy shuffle.
6. Executors run tasks; results returned to driver.

### Interview Explanation
> "Spark takes user code, builds a logical plan, then Catalyst optimizes it into a physical plan, expressed as a DAG. An action turns that DAG into a job. The DAG Scheduler splits the job into stages at shuffle boundaries; each stage is split into one task per partition; the Task Scheduler runs those tasks on executors; each task processes one partition on a core. Output goes to storage or back to the driver."

---

## Narrow Transformation

### Simple Explanation
A transformation where **each input partition feeds at most one output partition** — no data movement across the network.

### Technical Explanation
Narrow transformations (`map`, `filter`, `select`, `withColumn`, `coalesce`) keep data in the same partition. Spark **pipelines** them — multiple narrow ops run together in memory in one stage, no shuffle.

### Why It Exists
Pipelining narrow ops avoids expensive disk/network I/O, making them very fast.

### Real-World Example
```python
df.filter(F.col("active") == True).select("id", "name").withColumn("upper", F.upper("name"))
# All pipelined, no shuffle
```

### Interview Explanation
> "A narrow transformation maps each input partition to one output partition, so data stays local and no shuffle is involved. Spark pipelines multiple narrow transformations together in a single stage and in-memory. Examples are filter, map, and select."

### Common Mistakes
- Assuming `withColumn` is wide — it's narrow.
- Not realizing narrow ops are pipelined (hence fast).

---

## Wide Transformation

### Simple Explanation
A transformation where **input partitions contribute to many output partitions** — requiring data to be moved across the network (a **shuffle**).

### Technical Explanation
Wide/`shuffle` transformations (`groupBy`, `join`, `repartition`, `distinct`, `orderBy`) require Spark to reorganize data so that records with the same key land on the same partition. This is the **shuffle**: data is written to local disk (shuffle write), then fetched by other executors (shuffle read), creating a **stage boundary**.

### Why It Exists
Data with the same key (e.g. for a groupBy) may live on different partitions. To group them, Spark must gather them — that's shuffle, the main cost in Spark.

### Real-World Example
```python
df.groupBy("department").count()   # department values scattered across partitions → shuffle
```

### Interview Explanation
> "A wide transformation makes input partitions contribute to multiple output partitions, forcing a shuffle — Spark writes intermediate data to disk and moves it across the network so records with the same key end up together. Wide ops like groupBy, join, repartition, and distinct create stage boundaries and are the primary cost in Spark."

---

## Shuffle Boundary & Stage Creation

### Simple Explanation
A **shuffle** splits your job into stages: everything *before* the shuffle is one stage, everything *after* is the next.

### Technical Explanation
When Spark hits a wide transformation, it inserts a **shuffle boundary**. The DAG Scheduler partitions the job so that stages are separated exactly at these boundaries. Within a stage, narrow ops pipeline; between stages, data is shuffled (written to disk, moved across network, read by next stage).

### Real-World Example
```python
result = df.filter(...)          # Stage 1 (narrow, pipelined)
             .groupBy("k")      # SHUFFLE → Stage 2
             .sum("v")
result.count()
```
Spark runs Stage 1 (filter) on all partitions, shuffles by key, then Stage 2 (sum) on regrouped partitions. Number of stages = shuffle boundaries + 1.

### Interview Explanation
> "A shuffle boundary is created wherever a wide transformation sits. The DAG Scheduler cuts the job into stages at those boundaries: narrow operations before the shuffle run together pipelined in one stage, then data is shuffled, and the next stage continues. More shuffles = more stages = more network I/O = slower jobs."

### Common Mistakes
- Under-counting stages (each shuffle adds a stage).
- Believing a groupBy with a filter creates 3+ stages — usually just 2.

---

**End of Chapter 2.** Tick "Driver", "Executor", "Job", "Stage", "Task", "Partitions" in the tracker.

---

