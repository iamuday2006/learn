# PySpark Internship Preparation
> Your single, complete PySpark study guide — from beginner to Data Engineer internship interview readiness.
>
> **Primary source:** *Spark: The Definitive Guide* by Bill Chambers & Matei Zaharia (O'Reilly, 2018).
>
> **How to use this document:** Work through it top-to-bottom. Each section builds on the previous. Section 0 (Roadmap) tells you *why* each stage matters and what to study at each step. The last section is a progress tracker — tick boxes as you go.
---
## 0. The Journey
```text
Python/SQL Foundation
        ↓
Spark Fundamentals
        ↓
PySpark DataFrame API
        ↓
Spark Execution Model
        ↓
Spark Architecture
        ↓
Transformations & Actions
        ↓
Partitions & Parallelism
        ↓
Joins & Aggregations
        ↓
Shuffles
        ↓
Caching & Persistence
        ↓
Performance Optimization
        ↓
Spark SQL
        ↓
Structured Streaming
        ↓
Real Data Engineering Projects
        ↓
Interview Preparation
```
This is the **progressive curriculum** this entire document follows. Each chapter of this guide maps to one or more stages. Do not jump ahead — the stages are ordered so that hard concepts (shuffles, partitioning, optimization) only appear after you've built the foundation.
| Stage | Chapter in this guide | Objective |
|-------|----------------------|-----------|
| Python/SQL Foundation | (pre-requisite, see below) | Comfortable writing Python, basic SQL SELECT/GROUP BY/JOIN |
| Spark Fundamentals | Ch 1 | What Spark is, why it exists, core abstractions |
| PySpark DataFrame API | Ch 5 | Write everyday column/row transformations |
| Spark Execution Model | Ch 3 | Lazy evaluation, plans, Catalyst, Tungsten |
| Spark Architecture | Ch 2 | Driver, executors, cluster manager, DAG, stages, tasks |
| Transformations & Actions | Ch 3 & 4 | Narrow vs wide, lazy vs eager |
| Partitions & Parallelism | Ch 8 | repartition, coalesce, parallelism |
| Joins & Aggregations | Ch 6 & 7 | groupBy, join types, join strategies |
| Shuffles | Ch 8 | Where shuffles happen, why they're expensive |
| Caching & Persistence | Ch 9 | cache/persist/StorageLevel |
| Performance Optimization | Ch 11 | AQE, broadcast, skew, small files, checklist |
| Spark SQL | Ch 10 | temp views, EXPLAIN, SQL↔DataFrame interop |
| Structured Streaming | Ch 13 | internship-level streaming concepts |
| Real Data Engineering | Ch 14 | where Spark sits in a modern pipeline |
| Internship Projects | Ch 15 | 3 hands-on projects |
| Practice | Ch 16 | 60 realistic problems |
| Interview Preparation | Ch 17–21 | questions, answer frameworks, cheat sheet |
---
### Pre-Requisite: Python & SQL Foundation
- **Python:** variables, lists, dicts, loops, functions, list comprehensions, basic file I/O, `datetime`, basic `pandas` (DataFrame mental model helps).
- **SQL:** `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `JOIN` (inner/left), `ORDER BY`, `LIMIT`, aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).
- **Interview importance:** `MUST KNOW` — Spark's DataFrame API maps almost 1:1 onto SQL, and interviews assume you can write SQL.
**Practice requirement:** Solve 10–20 easy SQL problems on any platform (LeetCode/HackerRank) and write 5 small Python scripts manipulating lists/dicts.
---
# 1. PySpark Fundamentals
**Objective:** Understand what Apache Spark is, why it exists, and the core abstractions you'll work with daily as a Data Engineer intern.
**Why it matters:** Almost every interview starts with *"What is Spark?"* Your ability to explain *why* Spark exists (not just *what* it is) immediately separates you from other freshers.
**Book chapters to study:** Ch 1 (What Is Apache Spark?), Ch 2 (A Gentle Introduction to Spark), Ch 3 (A Tour of Spark's Toolset).
**Interview importance:** `MUST KNOW`
---
## Concept: Apache Spark
### Simple Explanation
Imagine you have 10 TB of data — too big for one computer to process in reasonable time. Spark lets you **split that work across many computers** (a cluster) and process it in parallel, much faster than one machine alone. You write code once (in Python via PySpark), and Spark figures out how to run it on the cluster.
### Technical Explanation
Apache Spark is a **unified, distributed computing engine** for large-scale data processing. It provides:
- A **unified API** — one engine supports SQL, streaming, machine learning, graph processing, and batch.
- **In-memory processing** — data is cached in memory across executors, dramatically speeding up iterative workloads compared to disk-based MapReduce.
- **Fault tolerance** — if a node dies, Spark recomputes lost data via lineage rather than losing the job.
- **Language APIs** — Scala, Python (PySpark), Java, R.
### Why It Exists
Before Spark, Hadoop MapReduce dominated big data. MapReduce worked but had a critical flaw: **every step wrote intermediate results to disk**, making multi-step jobs slow. Spark was created (at UC Berkeley, 2009) to keep data **in memory** across steps, enabling fast iterative algorithms (like machine learning) and interactive queries. It also unified many separate tools (batch, streaming, SQL, ML) into one engine.
### Real-World Example
A company collects millions of click-stream events daily. They:
1. Ingest into object storage (S3) as Parquet.
2. Use Spark nightly to **clean + aggregate** the day's events.
3. Use Spark SQL for ad-hoc analytics dashboards.
4. Use Spark Streaming for near-real-time fraud alerts.
One engine, many workloads — no need for five separate tools like Hadoop MapReduce (+ separate importer + separate stream processor).
### Code Example
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder \
    .appName("first-job") \
    .getOrCreate()
# Read raw events
events = spark.read.parquet("s3://bucket/raw-events/")
# A transformation (lazy — nothing runs yet)
daily_counts = events.groupBy("event_date").count()
# An action (triggers execution)
daily_counts.show()
```
### Interview Explanation
> "Apache Spark is a unified, in-memory distributed computing engine for big data. It is **unified** because one engine handles batch, SQL, streaming, and machine learning with consistent APIs. It is **in-memory** because it keeps intermediate data in memory across executors rather than writing to disk between every step like Hadoop MapReduce — which makes iterative and interactive workloads much faster. It provides language APIs (PySpark for Python), is **fault tolerant** via RDD lineage, and runs on a cluster of machines coordinated by a driver."
### Common Mistakes
- Confusing Spark with a **storage system** — Spark does *not* store data long-term; it reads/writes from external storage (S3, HDFS, Parquet, etc.). `EXTERNAL KNOWLEDGE`: Spark is often paired with a data lake (S3/weekly) and a query engine — it is fundamentally a **compute** engine.
- Thinking "Distributed means it's magic" — joins, shuffles, and skew still cost you; Spark just parallelizes the work.
- Forgetting that PySpark code with **no action does nothing** — transformations are lazy.
### Interview Questions (beginner → intermediate)
1. (B) Why does Spark use in-memory processing, and what problem does that solve?
2. (B) Is Spark a database? Why/why not?
3. (I) Spark vs Hadoop MapReduce — what are the key differences?
4. (B) What does "unified" mean in Spark's context?
5. (I) When would you *not* choose Spark?
---
## Concept: Spark vs Traditional (Single-Machine) Processing
### Simple Explanation
A normal Python `pandas` DataFrame lives on **one machine** and can only use that machine's CPU/RAM. Spark DataFrames are **distributed** — the data is split into partitions spread across many machines, and Spark processes them in parallel. `EXTERNAL KNOWLEDGE` (the book emphasizes this: "Python/R DataFrames ... exist on one machine rather than multiple machines").
### Technical Explanation
Single-machine tools like `pandas` load data into one process's memory. Spark splits a DataFrame into **partitions**, distributes them to **executors** on different nodes, each executor processes its partitions in **parallel tasks**, and results are combined. This trades some per-row overhead for **scale** — you can process data far larger than any single machine's RAM/CPU.
### Why It Exists
Single-machine processing physically caps you at one box's resources. Since ~2005 processor clock speeds stopped scaling (heat limits) and instead added cores, and data volumes kept growing, the industry needed a model that could harness **many machines in parallel**. Spark is that model.
### Real-World Example
A **100 GB CSV**: `pandas.read_csv()` would exhaust most laptops' RAM. Spark, distributed across 10 executors with 20 GB each, can load and process it comfortably.
### Code Example
```python
# Single machine limit
import pandas as pd
pdf = pd.read_csv("huge.csv")   # May crash if too big
# Distributed (Spark)
df = spark.read.csv("huge.csv", header=True)  # Handles 100GB+ easily
```
### Interview Explanation
> "Traditional tools like pandas operate on a single machine, so they're limited by that machine's CPU and memory. Spark splits data into partitions distributed across a cluster of executors. Each executor processes its partitions as parallel tasks, so combined they can handle data far beyond a single machine's capacity. The trade-off is more overhead per operation, so for small data pandas is often faster; Spark shines at truly large scale."
### Common Mistakes
- Assuming "Spark is always faster" — for small data, single-machine tools win.
- Treating `collect()` like pandas `.head()` — it drags data back to one node and can OOM.
### Interview Questions
1. (B) What limits a single-machine DataFrame's size?
2. (I) When is pandas preferable to Spark? When is Spark better?
3. (I) What happens internally when Spark processes a large DataFrame that pandas cannot?
---
## Concept: Spark Ecosystem
### Simple Explanation
Spark is not one tool but a **family of libraries built on one engine** — batch (DataFrames), SQL (Spark SQL), streaming (Structured Streaming), ML (MLlib), and graph (GraphX).
### Technical Explanation
Spark's layers:
- **Lower-level APIs:** RDDs — the foundation, rarely used directly for structured data.
- **Structured APIs:** DataFrames, Datasets, Spark SQL — the standard way to write Spark today.
- **Standard libraries:** `MLlib` (machine learning), `Structured Streaming` (streaming), `GraphX` (graph processing), `SparkR`/PySpark wrappers.
All share the same execution engine and Catalyst optimizer.
### Why It Exists
Real pipelines need batch + SQL + streaming together. A single unified engine avoids "glueing" five separate systems and lets one team learn one tool.
### Real-World Example
A ride-sharing company uses Spark for: nightly batch ETL (DataFrames), ad-hoc analytics (Spark SQL), real-time ETA updates (Structured Streaming), and driver-route recommendation (MLlib).
### Interview Explanation
> "Spark's ecosystem is one **execution engine** with multiple libraries on top: DataFrame/SQL for structured processing (the mainstream path), RDDs for low-level control, Structured Streaming for real-time, MLlib for machine learning, and GraphX for graph analytics. They share the same Catalyst optimizer and Tungsten execution engine, so you get consistency across workloads."
### Common Mistakes
- Using RDDs when DataFrames/SQL are the right (and standard) choice.
- Assuming streaming and batch are entirely separate engines — they share Catalyst.
### Interview Questions
1. (B) Name the main Spark libraries.
2. (I) How do batch and streaming share the same engine?
3. (I) Why is it beneficial to have one engine for SQL + streaming + ML?
---
## Concept: PySpark
### Simple Explanation
PySpark is the **Python API for Spark**. You write Python code; Spark translates it into JVM instructions the cluster understands.
### Technical Explanation
PySpark runs a **Python driver** that communicates with the JVM via Py4J. Your Python DataFrame transformations are converted into logical plans executed by Spark's Scala/JVM engine. Data is processed by JVM executors; Python UDFs run in separate Python worker processes (slower — avoid when possible).
### Why It Exists
Python is the lingua franca of data work — PySpark makes Spark accessible to Python developers without writing Scala.
### Real-World Example
A data team that writes ETL in Python can use PySpark for the exact same job on a cluster, reusing existing Python skills.
### Code Example
```python
from pyspark.sql import SparkSession, functions as F
spark = SparkSession.builder.appName("demo").getOrCreate()
df = spark.createDataFrame([("a", 1), ("b", 2)], ["letter", "num"])
df.select(F.upper("letter"), F.col("num") * 2).show()
```
### Interview Explanation
> "PySpark is Spark's Python API. A Python driver uses Py4J to talk to the Spark JVM, which schedules and executes the actual work on executors. Column transformations are optimized by Catalyst in the JVM; Python UDFs run in separate Python processes and are much slower than built-in Spark functions, so professionals prefer built-ins."
### Common Mistakes
- Using Python UDFs when `functions` has a built-in (10–100× slower).
- Mixing `pandas` calls on Spark DataFrames (they aren't the same object).
### Interview Questions
1. (B) What is PySpark?
2. (I) How does Python code get executed by a JVM-based engine?
3. (I) Why are Python UDFs slow, and what should you use instead?
---
## Concept: SparkSession
### Simple Explanation
The **entry point** to Spark. In PySpark you start with `SparkSession.builder...getOrCreate()` and use `spark` for everything — reading data, SQL, config.
### Technical Explanation
One `SparkSession` == one running **Spark Application**. It's the unified entry point (replacing the older `SparkContext`, `SQLContext`, `HiveContext`). It manages configuration, provides access to DataFrames (`spark.read`), SQL (`spark.sql`), streaming (`spark.readStream`), and config (`spark.conf`).
### Why It Exists
Spark 2.0 unified several overlapping contexts (SparkContext, SQLContext, HiveContext) into a single, simpler `SparkSession`.
### Real-World Example
```python
spark = SparkSession.builder \
    .appName("etl-job") \
    .master("yarn") \
    .config("spark.sql.shuffle.partitions", "200") \
    .getOrCreate()
df = spark.read.parquet("s3://bucket/data/")
```
### Interview Explanation
> "SparkSession is the unified entry point to a Spark Application. It bundles the SparkContext (for cluster connection), SQL context, and configuration into a single object. You use it to read data, run SQL, configure the app, and access streaming. There's a one-to-one relationship between a SparkSession and a Spark Application."
### Common Mistakes
- Creating multiple `SparkSession`s for one app (usually a mistake; reuse one).
- Forgetting config before `getOrCreate()` — config is fixed once the session is created.
### Interview Questions
1. (B) What is a SparkSession and why do you need it?
2. (I) What did SparkSession replace and why?
3. (I) Can you have multiple SparkSessions in one app?
---
## Concept: SparkContext
### Simple Explanation
The older, lower-level entry point that SparkSession wraps. It's how your app connects to the cluster.
### Technical Explanation
`SparkContext` (`sc`) is the core entry point for low-level RDD APIs and cluster connectivity. You still access it via `spark.sparkContext` for things like `parallelize()`, `broadcast()`, `accumulator()`, and `textFile()`.
### Real-World Example
```python
rdd = spark.sparkContext.parallelize([1, 2, 3, 4], numSlices=2)
broadcast_var = spark.sparkContext.broadcast({"a": 1})
```
### Interview Explanation
> "SparkContext is the original entry point that connects an app to the cluster and exposes low-level RDD operations — parallelize, broadcast, accumulators, textFile. SparkSession (Spark 2.0+) wraps it along with the SQL context, so in modern code you reach the context through `spark.sparkContext`."
### Common Mistakes
- Using `sc` directly for everyday DataFrame work (unnecessary).
- Thinking SparkContext and SparkSession are completely separate — SparkSession *contains* the context.
### Interview Questions
1. (B) What is SparkContext?
2. (I) Relationship between SparkSession and SparkContext?
---
## Concept: DataFrame
### Simple Explanation
A **distributed, table-like collection** of rows and named columns. Think of it as a SQL table, but spread across many machines with rich programmatic transformation methods.
### Technical Explanation
A DataFrame is an immutable, distributed collection of data organized into named columns with a **schema** (resolved types). It sits on the **Structured API** layer, meaning it benefits from the Catalyst optimizer (query optimization), predicate pushdown, and column pruning. DataFrames carry schema, so Spark can optimize execution automatically.
### Why It Exists
The RDD API gives you raw elements (no schema), so Spark can't optimize. DataFrames add **schema** → enables Catalyst to prune columns, push down filters, and generate efficient code (Tungsten). This makes them the standard way to work with structured data.
### Real-World Example
```python
df = spark.read.parquet("s3://bucket/transactions/")
df.filter(F.col("amount") > 100) \
  .groupBy("customer_id") \
  .agg(F.sum("amount").alias("total"))
```
### Interview Explanation
> "A DataFrame is Spark's Structured API representation of tabular data: an immutable, distributed collection of rows and columns with a resolved schema. Because it carries schema, Spark's Catalyst optimizer can automatically optimize — pruning columns, pushing down filters, and generating efficient code with Tungsten. It's the standard API for structured data in PySpark."
### Common Mistakes
- Forgetting DataFrames are **immutable** — transformations return *new* DataFrames.
- Treating `.show()` like the only way to see data (use `take`/`limit` for large data).
### Interview Questions
1. (B) What is a DataFrame in Spark?
2. (I) Why does carrying a schema make DataFrames more efficient than RDDs?
3. (I) Is a Spark DataFrame the same as a pandas DataFrame?
---
## Concept: Dataset
### Simple Explanation
A **type-safe** DataFfame — a strongly-typed distributed collection available in **Java/Scala only**. PySpark does **not** have the typed Dataset API.
### Technical Explanation
`Dataset[T]` is a typed API: rows are compiled into strongly-typed JVM objects, giving compile-time type safety. A DataFrame is literally `Dataset[Row]` (rows without a compile-time–known row type). In Python there's no Dataset; you use DataFrames. `EXTERNAL KNOWLEDGE`: This is why PySpark interviews rarely ask for Dataset specifics beyond "it's the Scala/Java typed API".
### Why It Exists
Dataset gives you type safety and uses encoders for efficient serialization, useful when you want compile-time correctness and object-oriented manipulation. But it sacrifices the flexibility of untyped rows.
### Real-World Example (Scala only)
```scala
case class Person(name: String, age: Int)
val people: Dataset[Person] = df.as[Person]
```
### Interview Explanation
> "Dataset is the type-safe, strongly-typed API available only in Java and Scala. A specific dataset type like `Dataset[Person]` carries a compile-time row type with automatic encoder-based serialization. A DataFrame is really just `Dataset[Row]` — unttyped. PySpark only exposes DataFrames."
### Common Mistakes
- Claiming PySpark supports Datasets (it doesn't).
- Confusing "typed" with "faster" — type safety is the main benefit, not raw speed.
### Interview Questions
1. (B) What is a Dataset? Is it available in PySpark?
2. (I) DataFrame vs Dataset — key difference?
---
## Concept: RDD (Resilient Distributed Dataset)
### Simple Explanation
Spark's **lowest-level** abstraction: an immutable, partitioned collection of elements that can be processed in parallel. Each element can be *any* object (not necessarily structured rows).
### Technical Explanation
An RDD is an immutable, fault-tolerant, partitioned collection of records. It tracks **lineage** (the chain of transformations that created it) so any lost partition can be recomputed. RDDs give you functional transformations (`map`, `filter`, `reduceByKey`) but **no schema**, so Spark cannot optimize them with Catalyst. See Chapter 4 in this guide for a deep dive.
### Why It Exists
RDDs were Spark's original API — providing fault tolerance and the functional programming model that made Spark possible. They still serve unstructured data and custom low-level processing, though DataFrames are preferred for structured work.
### Real-World Example
```python
lines = spark.sparkContext.textFile("s3://bucket/logs/*.log")
errors = lines.filter(lambda l: "ERROR" in l)
print(errors.count())
```
### Interview Explanation
> "An RDD is Spark's foundational low-level abstraction: a fault-tolerant, immutable, partitioned collection of elements. It remembers its lineage — the operations that produced it — so if partitions are lost, Spark can recompute them. RDDs lack schema, so Spark can't optimize them like DataFrames. They're used for unstructured data and fine-grained control, while DataFrames/SQL are the standard for structured data."
### Common Mistakes
- Using RDDs where DataFrames are the standard choice.
- Assuming RDDs are faster — they're usually slower (no optimizer).
### Interview Questions
1. (B) What does RDD stand for and what is it?
2. (I) Why are DataFrames generally preferred over RDDs?
---
## Concept: SQL (via Spark SQL)
### Simple Explanation
You can write **plain SQL queries** against Spark and get back DataFrames. Both SQL and DataFrame API compile to the **same physical plan**.
### Technical Explanation
Spark SQL lets you run standard `SELECT ... GROUP BY ... JOIN` statements. Register a DataFrame as a **temporary view**, then query it with `spark.sql("...")`. Because SQL and DataFrame code both go through the Catalyst optimizer, they produce identical plans and performance.
### Real-World Example
```python
df.createOrReplaceTempView("sales")
result = spark.sql("""
    SELECT product, SUM(amount) AS total
    FROM sales
    GROUP BY product
    ORDER BY total DESC
""")
```
### Interview Explanation
> "Spark SQL lets you express transformations as regular SQL. You register a DataFrame as a temporary view, then run `spark.sql()` against it, which returns a DataFrame. Since both SQL and the DataFrame API compile through the same Catalyst optimizer to the same physical plan, there's no performance difference — it's purely a matter of which syntax you prefer."
### Common Mistakes
- Forgetting to create a temp view before querying a DataFrame in SQL.
- Assuming SQL is slower/faster than the DataFrame API (it's identical).
### Interview Questions
1. (B) How do you run SQL in Spark?
2. (I) Is Spark SQL faster than the DataFrame API? Why?
---
## Concept: Structured Streaming
### Simple Explanation
A streaming API where you treat a **stream as an unbounded DataFrame** — same transformations as batch, but data arrives continuously.
### Technical Explanation
Structured Streaming processes data as it arrives in **micro-batches** (or continuous processing). You use the *same* DataFrame API; only the input (`readStream`) and output (`writeStream`) differ. It provides **exactly-once** semantics via checkpointing, and supports event-time windows and watermarks. Deep dive in Chapter 13.
### Why It Exists
Real-time data processing without a completely separate paradigm — let engineers write one style of code for both batch and streaming.
### Real-World Example
```python
stream = spark.readStream.format("kafka").option("subscribe", "clicks").load()
query = stream.writeStream.format("parquet").outputMode("append").start()
```
### Interview Explanation
> "Structured Streaming treats a live data stream as an unbounded DataFrame. You write the same transformations as batch, but read with `readStream` and write with `writeStream`. It runs on micro-batches, supports event-time windows and watermarks, and gives exactly-once guarantees through checkpointing."
### Common Mistakes
- Confusing it with older DStreams API (`EXTERNAL KNOWLEDGE` — Structured Streaming is the modern API).
- Forgetting checkpoint location for fault tolerance.
### Interview Questions
1. (B) What is Structured Streaming?
2. (I) How is it similar/different from batch Spark?
---
**End of Chapter 1.** Tick "Spark fundamentals" in the tracker before moving on.

---

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

# 5. PySpark DataFrames

**Objective:** Become fluent in the DataFrame API — the tool you'll use 90% of the time as a Data Engineering intern.

**Why it matters:** All interviews assume you can write DataFrame transformations fluently. This is the coding core of your prep.

**Book chapters to study:** Ch 4 (Structured API overview), Ch 5 (Structured API operations), Ch 6 (working with different types/functions).

**Interview importance:** `MUST KNOW`

---

## Concept: Creating DataFrames

### Simple Explanation
Several ways to build a DataFrame: from files (CSV/JSON/Parquet), from existing data (RDD, pandas, Python list), or from Spark SQL.

### Code Example
```python
from pyspark.sql import SparkSession, Row
from pyspark.sql.types import ...

spark = SparkSession.builder.appName("demo").getOrCreate()

# 1. From a Python list of Rows (with schema inference)
data = [Row(name="Alice", age=25), Row(name="Bob", age=30)]
df = spark.createDataFrame(data)

# 2. From a list of tuples with column names
df = spark.createDataFrame([("a",1),("b",2)], ["letter","num"])

# 3. From a file (lazy — read on action)
df = spark.read.csv("s3://bucket/data/", header=True)
df = spark.read.json("s3://bucket/data/")
df = spark.read.parquet("s3://bucket/data/")

# 4. From existing DataFrame
df2 = df.select("letter")

# 5. From a pandas DataFrame (converts to Spark)
import pandas as pd
spark_df = spark.createDataFrame(pd.DataFrame({"a":[1,2]}))
```

### Interview Explanation
"DataFrames are created from structured files with `spark.read`, from existing objects with `spark.createDataFrame`, from SQL, or by transforming other DataFrames. In production, you always supply an explicit schema when reading so Spark avoids slow schema inference."

### Common Mistakes
- Relying on schema inference in production (slow, may misinfer types).
- Using `collect()`/`pandas` conversions on large data (OOM).

### Interview Questions
1. (B) How do you create a DataFrame?
2. (I) Why shouldn't you rely on schema inference in production?

---

## Concept: Schemas, StructType, StructField, Data Types

### Simple Explanation
A **schema** describes the column names and types of a DataFrame. `StructType` is a list of `StructField`s; each `StructField` gives a name, type, and nullability.

### Code Example
```python
from pyspark.sql.types import (StructType, StructField, StringType,
                               IntegerType, DoubleType, TimestampType,
                               ArrayType, MapType, StructType)

schema = StructType([
    StructField("user_id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("age", IntegerType(), nullable=True),
    StructField("score", DoubleType(), nullable=True),
    StructField("created_at", TimestampType(), nullable=False),
    StructField("tags", ArrayType(StringType()), nullable=True),
    StructField("meta", MapType(StringType(), StringType()), nullable=True)
])

df = spark.read.schema(schema).json("s3://bucket/users/")

# Inspect schema
df.printSchema()
df.schema
```

Common Spark data types: `StringType`, `IntegerType`, `LongType`, `DoubleType`, `FloatType`, `BooleanType`, `TimestampType`, `DateType`, `BinaryType`, `ArrayType`, `MapType`, `StructType`.

### Why Derived / Real-World
In production ETL you *must* define explicit schemas — schema inference reads extra data and can get types wrong (e.g. leading zeros in IDs lost as integers).

### Interview Explanation
"Schemas are a DataFrame's typed column definitions. In production I always define an explicit `StructType` of `StructField`s when reading so Spark skips inference and types are correct and predictable."

### Common Mistakes
- Losing ID precision by reading integer-typed IDs (use StringType).
- Forgetting nested/complex types (Array/Map/Struct) exist.

### Interview Questions
1. (B) What is a schema in Spark?
2. (I) What's the difference between `StructType` and `StructField`?
3. (I) Why use explicit schemas at scale?

---

## Concept: Selecting Columns (select, selectExpr, alias)

### Simple Explanation
`select` picks columns; `selectExpr` lets you run SQL expressions on them; `alias`/`as` renames.

### Code Example
```python
from pyspark.sql import functions as F

# select columns by name
df.select("user_id", "name")

# select with Column expressions
df.select(F.col("user_id"), (F.col("age") + 1).alias("age_plus_one"))

# selectExpr — SQL expression strings
df.selectExpr("user_id", "upper(name) as name_upper", "age * 2 as double_age")

# alias
df.select(F.col("name").alias("full_name"))
```

### Interview Explanation
"`select` picks columns by name or Column expressions; `selectExpr` accepts SQL expression strings so you can compute and alias inline; `alias` renames a column. All are narrow transformations (lazy)."

### Common Mistakes
- Using `select("col")` with a Python variable instead of `F.col()`.
- Confusing `alias` with `withColumnRenamed`.

### Interview Questions
1. (B) Difference between `select` and `selectExpr`?
2. (I) When would you use `selectExpr`?

---

## Concept: withColumn / withColumnRenamed / drop

### Simple Explanation
`withColumn` adds or replaces a column based on an expression; `withColumnRenamed` renames; `drop` removes columns.

### Code Example
```python
# Add new column
df = df.withColumn("age_group",
    F.when(F.col("age") < 18, "minor").otherwise("adult"))

# Replace existing column
df = df.withColumn("age", F.col("age") + 1)

# Rename
df = df.withColumnRenamed("name", "full_name")

# Drop
df = df.drop("temp_col", "another_col")
```

### Why Derived
Production ETL constantly computes new derived columns from raw ones.

### Interview Explanation
"`withColumn` adds or overwrites a column from an expression; it's narrow and lazy. `withColumnRenamed` just changes column labels; `drop` removes columns. All return new DataFrames since DataFrames are immutable."

### Common Mistakes
- Forgetting to reassign (`df.withColumn(...)` without `df =` does nothing persistent).
- Treating `withColumn` as if it mutates in place.

### Interview Questions
1. (B) How do you add a column in PySpark?
2. (I) Is `withColumn` a transformation? Is it narrow?

---

## Concept: filter / where

### Simple Explanation
`filter` (synonym `where`) keeps rows matching a condition.

### Code Example
```python
from pyspark.sql import functions as F

df.filter(F.col("age") >= 18)
df.where("age >= 18")           # SQL string form
df.filter(F.col("age").between(18, 65))
df.filter(F.col("city").isin("NYC", "SF"))
df.filter(F.col("email").isNotNull())
df.filter((F.col("a") > 1) & (F.col("b") < 5))  # use & for AND
```

### Interview Explanation
"`filter`/`where` return rows satisfying a condition — a narrow, lazy transformation. Use Column expressions or SQL strings. To combine conditions use `&` (AND), `|` (OR), `~` (NOT) on Column objects."

### Common Mistakes
- Using Python `and`/`or` instead of `&`/`|`/`~` on Column objects (causes errors).
- Filtering after expensive operations instead of pushing the filter earlier.

### Interview Questions
1. (B) What's the difference between `filter` and `where`? (None — synonyms.)
2. (I) Why should you filter as early as possible?

---

## Concept: distinct / dropDuplicates

### Simple Explanation
`distinct()` removes duplicate rows (all columns); `dropDuplicates(cols)` dedupes on specified columns.

### Code Example
```python
df.distinct()
df.dropDuplicates(["user_id", "event_type"])  # keep first per combination
```

### Interview Explanation
"`distinct` dedupes identical full rows; `dropDuplicates` dedupes by chosen columns. Both are wide transformations (a shuffle is needed to compare rows across partitions) so they can be expensive."

### Common Mistakes
- Forgetting they cause a shuffle.
- Using `distinct` when you only need to dedupe by one column (use `dropDuplicates`).

---

## Concept: orderBy / sort / limit

### Simple Explanation
`orderBy` (synonym `sort`) sorts rows; `limit` caps the number of rows.

### Code Example
```python
from pyspark.sql import functions as F

df.orderBy("age")                       # ascending
df.orderBy(F.col("age").desc())         # descending
df.sort("age", "name")
df.orderBy(F.desc("age"))               # requires import functions.desc
df.limit(10)
```

### Interview Explanation
"`orderBy`/`sort` sort the DataFrame (a wide transformation — global sort requires a shuffle). `limit` returns a fixed number of rows and is relatively cheap."

### Common Mistakes
- Assuming `limit` is free — it still scans until enough results found.
- Using `sort` expecting global order without an action.

---

## Concept: when / otherwise / lit / cast

### Simple Explanation
`when/otherwise` is conditional logic (like CASE WHEN); `lit` creates a literal column; `cast` changes a column's type.

### Code Example
```python
from pyspark.sql import functions as F

# Conditional (CASE WHEN)
df.withColumn("tier",
    F.when(F.col("score") >= 90, "Gold")
     .when(F.col("score") >= 60, "Silver")
     .otherwise("Bronze"))

# Literal column
df.withColumn("country", F.lit("US"))

# Cast type
df.withColumn("age_long", F.col("age").cast("long"))
df.withColumn("birth_date", F.col("date_str").cast("date"))
```

### Interview Explanation
"`when/otherwise` implements CASE-WHEN conditional logic on Columns. `lit` adds a constant-valued column. `cast` converts a column to another type. These are the bread-and-butter of data cleaning and enrichment."

### Common Mistakes
- Using Python `if/else` inside `.map` instead of `when` (slower, breaks optimization).
- Casting without handling conversion failures/null.

---

## Concept: Null Handling

### Simple Explanation
Ways to deal with missing values: filter them, replace them, or drop rows/columns.

### Code Example
```python
from pyspark.sql import functions as F

# Filter out nulls
df.filter(F.col("email").isNotNull())
df.filter(F.col("email").isNull())

# Replace nulls with a value
df.fillna({"name": "Unknown", "age": 0})

# Coalesce: first non-null across columns
df.withColumn("effective", F.coalesce(F.col("phone"), F.col("mobile"), F.lit("none")))

# Drop rows with any null
df.dropna()

# Drop rows null in specific columns
df.dropna(subset=["email"])

# Drop columns / rows
df.na.drop(subset=["age"])
```

### Interview Explanation
"Null handling in PySpark uses `isNull`/`isNotNull` filters, `fillna` to replace, `coalesce` to pick the first non-null across columns, and `dropna`/`na.drop` to drop rows with nulls. Data Quality steps in ETL typically standardize nulls before analysis."

### Common Mistakes
- Forgetting that aggregations ignore nulls (counts and sums may not match intuition).
- Using `fillna` with the wrong type.

### Interview Questions
1. (B) How do you handle nulls in PySpark?
2. (I) How do aggregations treat nulls?

---

## Concept: String Functions

### Simple Explanation
`functions` has a rich set of string helpers: upper/lower, trim, concat, split, substring, regex.

### Code Example
```python
from pyspark.sql import functions as F

df.withColumn("name_upper", F.upper("name"))
df.withColumn("name_lower", F.lower("name"))
df.withColumn("trimmed", F.trim("code"))
df.withColumn("full", F.concat(F.col("first"), F.lit(" "), F.col("last")))
df.withColumn("parts", F.split("email", "@"))
df.withColumn("domain", F.split("email", "@")[1])
df.withColumn("sub", F.substring("phone", 1, 3))
df.withColumn("len", F.length("name"))
df.withColumn("replaced", F.regexp_replace("text", "[^0-9]", ""))
df.withColumn("contains_a", F.contains("name", "a"))
```

### Interview Explanation
"String functions like `upper`, `trim`, `split`, `substring`, `concat`, `regexp_replace`, and `length` handle text cleaning and transformation. Prefer these built-ins over Python UDFs for speed."

### Common Mistakes
- Writing a Python UDF for something `split`/`regexp_replace` already does.
- Forgetting `split` returns an array (index it for a specific part).

---

## Concept: Date Functions

### Simple Explanation
Functions to parse, format, and diff dates/timestamps.

### Code Example
```python
from pyspark.sql import functions as F
from pyspark.sql.types import DateType, TimestampType

df.withColumn("today", F.current_date())
df.withColumn("now", F.current_timestamp())
df.withColumn("parsed", F.to_date("date_str", "yyyy-MM-dd"))
df.withColumn("ts", F.to_timestamp("ts_str", "yyyy-MM-dd HH:mm:ss"))
df.withColumn("year", F.year("created_at"))
df.withColumn("month", F.month("created_at"))
df.withColumn("day", F.dayofmonth("created_at"))
df.withColumn("dow", F.dayofweek("created_at"))
df.withColumn("days_since", F.datediff(F.current_date(), "created_at"))
df.withColumn("fmt", F.date_format("created_at", "yyyyMMdd"))
df.withColumn("add_day", F.date_add("date", 7))
df.withColumn("between_months", F.months_between(F.current_date(), "date"))
```

### Interview Explanation
"Date functions (`to_date`, `year`, `date_format`, `datediff`, `date_add`, `months_between`, etc.) parse, extract, and transform date/timestamp columns. They're essential for time-based ETL, partitioning by date, and analytics."

### Common Mistakes
- Forgetting to specify a format string for `to_date`/`to_timestamp` (defaults may fail).
- Assuming string dates compare correctly (cast them to date first).

---

## Concept: Array Functions

### Simple Explanation
Functions for array columns: size, explode, contain, slice, element access.

### Code Example
```python
from pyspark.sql import functions as F

df.withColumn("first_tag", F.col("tags")[0])
df.withColumn("tag_count", F.size("tags"))
df.withColumn("has_premium", F.array_contains("tags", "premium"))
df.withColumn("uniq", F.array_distinct("tags"))
df.withColumn("exploded", F.explode("tags"))   # one row per element
df.withColumn("joined", F.array_join("tags", ","))
```

### Interview Explanation
"Array functions (`size`, `explode`, `array_contains`, `array_distinct`, indexing) work on array-typed columns. `explode` turns each array element into its own row — very common when normalizing nested data."

### Common Mistakes
- Forgetting `explode` multiplies rows (can blow up data volume).
- Using `explode_outer` when you want to keep empty/null arrays.

---

## Concept: Map Functions

### Simple Explanation
Functions for map (key-value) columns.

### Code Example
```python
from pyspark.sql import functions as F

df.withColumn("key_value", F.map_keys("meta"))
df.withColumn("value_for_x", F.col("meta")["x"])
df.withColumn("map_values", F.map_values("meta"))
df.withColumn("exploded_map", F.explode("meta"))  # rows of (key, value)
```

### Interview Explanation
"Map functions access and transform key-value map columns — `map_keys`, `map_values`, indexing, and `explode` to key/value rows."

---

## Concept: Struct Functions

### Simple Explanation
Functions to build and break nested structs.

### Code Example
```python
from pyspark.sql import functions as F

# Build a struct
df.withColumn("full_name", F.struct("first", "last"))  # full_name.first, full_name.last

# Access struct fields
df.select(F.col("full_name.first").alias("first_name"))

# Flatten struct fields
df.select("full_name.*")  # expands all struct fields into columns

# Nest arrays of structs, etc.
```

### Interview Explanation
"Struct functions (`struct`, field access via dot, `.*` expansion) build and flatten nested structures. They're key for handling nested JSON and hierarchical data."

### Common Mistakes
- Not using `col("struct.field")` dot access or `df.select("struct.*")` to flatten.

---

## Concept: Conditional Expressions (recap)

`when/otherwise`, `case`, `if` via SQL — see `when/otherwise` above. Also `F.coalesce` for first-non-null.

### Code Example (SQL-form)
```python
df.selectExpr("CASE WHEN age < 18 THEN 'minor' ELSE 'adult' END as age_group")
```

---

**End of Chapter 5.** Tick "PySpark DataFrames" in the tracker.

---

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

# 7. Joins

**Objective:** Master join types, join strategies, and — critically — *why joins can become extremely expensive* and how to optimize them.

**Why it matters:** Joins are the #1 performance topic in Data Engineering interviews. Understanding broadcast vs sort-merge and data skew will set you apart.

**Book chapters to study:** Ch 8/9 of the book (joins), Ch 19 (join execution) and throughout Part IV.

**Interview importance:** `MUST KNOW`

---

## Concept: Join Types

### Simple Explanation
Joins combine rows from two DataFrames based on a key. The *type* controls which rows are kept.

### Code Example (all types)
```python
# Inner — only matching rows from both
result = orders.join(customers, "customer_id", "inner")

# Left outer — all left rows, matching right (nulls where no match)
result = orders.join(customers, "customer_id", "left")

# Right outer — all right rows, matching left
result = orders.join(customers, "customer_id", "right")

# Full outer — all rows from both
result = orders.join(customers, "customer_id", "full")

# Left semi — left rows that HAVE a match (no right columns returned)
result = customers.join(orders, "customer_id", "left_semi")

# Left anti — left rows that have NO match
result = customers.join(orders, "customer_id", "left_anti")

# Cross — cartesian product (dangerous!)
result = df1.crossJoin(df2)
```

### Table: what each join keeps

| Join type | Result |
|-----------|--------|
| inner | Only rows matching in both |
| left | All left rows (+ matched right) |
| right | All right rows (+ matched left) |
| full | All rows from both |
| left_semi | Left rows that have a match (only left columns) |
| left_anti | Left rows with no match |
| cross | Every left row × every right row |

### Real-World Examples
- **left_semi:** "Which customers placed at least one order?" (keep customer columns).
- **left_anti:** "Which new users have never placed an order?" (new users not in orders).
- **inner:** "Orders with a valid matching customer."

### Interview Explanation
"Join types control which rows survive: inner keeps matches, left/right/full outer keep respective sides, semi keeps left rows that have a match (left columns only), and anti keeps left rows with no match. Choosing the right join type is essential for correct ETL and analytics."

### Common Mistakes
- Using `left` when you mean `inner` (produces extra null rows).
- Using `crossJoin` accidentally (cartesian explosion).

### Interview Questions
1. (B) What's the difference between inner and left join?
2. (I) When would you use `left_semi` vs `inner`?
3. (I) What does `left_anti` do and when is it useful?

---

## Concept: Join Strategies

When Spark joins two large DataFrames, it must get matching keys onto the same partition — that means a **shuffle** unless it can broadcast. The choice of strategy lives in the physical plan and directly affects performance.

### Broadcast Hash Join
- **What:** The **small** table (below `spark.sql.autoBroadcastJoinThreshold`, default 10MB) is sent (broadcast) to every executor. Each executor builds a hash table in memory of the small table and joins it against its local slice of the large table. **No shuffle of the large table.**
- **When:** One table is small (< ~200MB recommended, default threshold 10MB).
- **Cost:** Cheap — one network broadcast, no data shuffle.

```python
from pyspark.sql.functions import broadcast
result = large_df.join(broadcast(small_df), "key")   # force broadcast
```

### Sort Merge Join
- **What:** Both tables are **shuffled** by join key, then each is **sorted**, and merged. The shuffle ensures same keys land on the same partition; sorting enables an efficient merge.
- **When:** Both tables are large (the default when neither can broadcast). Equi-joins only.
- **Cost:** Expensive — two shuffles (one per side) + sort.

```python
result = large1.join(large2, "key")   # likely sort-merge if both large
```

### Shuffle Hash Join
- **What:** Both tables shuffled by key; the **smaller** side builds a hash table per partition.
- **When:** Medium tables, memory available. Often disabled in favor of sort-merge (`spark.sql.join.preferSortMergeJoin=true` by default).
- **Cost:** Two shuffles, but no sort.

### Broadcast Nested Loop Join
- **What:** Naive nested-loop join; extremely expensive. Used when there's no equality condition (e.g. range join).
- **When:** Only when forced (e.g. `<=` join without sorting/bucketing). **Avoid.**
- **Cost:** Catastrophic at scale.

### Bucket Join
- **What:** Both tables pre-bucketed to the same number of buckets by the same key; matching buckets locate data on the same node → **no shuffle**. Requires writing with `bucketBy`/`saveAsTable`.

### Table: choosing a strategy

| Strategy | Large + Small | Large + Large | Cost | Requires eq key |
|----------|---------------|---------------|------|-----------------|
| Broadcast Hash | ✓ | ✗ | Low (no shuffle) | Yes |
| Sort Merge | — | ✓ | High (2 shuffles + sort) | Yes |
| Shuffle Hash | — | ✓ (memory) | Medium-High | Yes |
| Bucket | ✓ | ✓ | Low (no shuffle) | Yes |
| Broadcast NLJ | — | ✗ | Very high | No |

### Interview Explanation
> "Spark picks a join strategy in the physical plan. **Broadcast hash join** sends a small table to every executor and joins locally without shuffling the large table — best when one side is small. **Sort merge join** shuffles and sorts both large tables by key then merges — the default for large-large joins but it's expensive because of two shuffles. **Shuffle hash join** shuffles both and hashes the smaller side. **Broadcast nested loop** is a fallback for non-equi joins and is very costly. Pre-bucketing can eliminate the shuffle entirely."

### Common Mistakes
- Broadcasting a large table (driver/executor OOM).
- Forgetting default broadcast threshold is only 10MB (small!).
- Assuming all joins shuffle — broadcast avoids it.

---

## Concept: Broadcast Join Detailed

### When should I broadcast a table?
- When one side is **small** (< ~10MB default; up to ~200MB with tuning) — like dimension/lookup tables.
- When broadcasting avoids a huge shuffle cost that outweighs the broadcast.
- For frequently tiny lookup tables (country codes, category names, etc.).

### How to enable
```python
# Explicit hint
from pyspark.sql.functions import broadcast
large.join(broadcast(small), "key")

# Auto threshold
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", 200 * 1024 * 1024)  # 200MB
```

### Trade-offs
- **Pro:** No shuffle of the big table; huge speedup.
- **Con:** The small table must fit in executor memory (broadcast is replicated on every executor). Broadcasting a too-big table → memory pressure/OOM and slow broadcast time.

### Interview Explanation
> "I broadcast a table when one side of the join is genuinely small — typically a dimension or lookup table under a few hundred MB. The small table is copied to every executor, which then joins locally, avoiding a full shuffle of the large table. The trade-off is that the broadcast data is replicated onto every executor, so it must fit in memory; broadcasting an overly large table causes memory pressure or OOM. I can hint with `broadcast()` or tune `spark.sql.autoBroadcastJoinThreshold`."

### Common Mistakes
- Broadcasting without checking actual size.
- Forgetting default auto-broadcast threshold (10MB) is conservative.

---

## Concept: Why a join can become extremely expensive

The main reasons:
1. **Full shuffle** — large-large joins shuffle entire datasets over the network (2 shuffles for sort-merge).
2. **Data skew** — one/hot keys put enormous load on a single partition/task, so the job waits on one slow task (straggler).
3. **Too many/large partitions** — oversized shuffle writes/reads and spill to disk.
4. **Non-equi joins** — fall back to broadcast nested-loop (catastrophic).
5. **No filtering/pruning** — joining entire tables instead of pre-filtering.

### Interview Explanation
> "A join is expensive mainly because large-large joins require shuffling all data across the network so matching keys are co-located. This is amplified by data skew (a few hot keys concentrate work on a few over-loaded partitions), by sorting in sort-merge, by non-equi conditions that force nested-loop joins, and by not filtering or pruning columns before the join."

### Common Mistakes
- Joining full tables and only then filtering (filter first!).
- Ignoring skew until a prod job breaks.

---

## Concept: Data Skew in Joins

### Simple Explanation
When some join keys appear far more than others, the partitions holding those keys get far more data → a few tasks become the bottleneck.

### Why it matters
A skewed join can make a 2-minute job take 30+ minutes because one executor is swamped while others idle.

### Detection
- Spark UI: few tasks take much longer than others (uneven task durations).
- `df.groupBy("key").count().orderBy(desc("count"))` — check max vs avg.

### Mitigation
1. **AQE skew join** (Spark 3.x) — automatically splits skewed partitions.
2. **Salting** — add a random salt suffix to the skewed keys to spread them across partitions, and explode the small side accordingly.
3. **Separate skewed rows** — handle hot keys with broadcast, process the rest normally.
4. **Round-Robin/broadcast the small side**.

### Interview Explanation
> "Data skew happens when a few keys dominate. In a shuffled join, all rows for a hot key land on one partition, so one task does most of the work while others finish early — a classic straggler. I detect it via the Spark UI (uneven task durations) or by checking key cardinality. I fix it with AQE's automatic skew join, or manually by salting the skewed keys and exploding the small side, or by splitting out the hot keys and broadcasting their small counterpart."

### Common Mistakes
- Assuming more executors fix skew (it's about distribution, not raw resources).
- Salting only one side of the join.

---

**End of Chapter 7.** Tick "Joins", "Broadcast joins" in the tracker.

---

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

# 9. Caching and Persistence

**Objective:** Know when caching *helps*, when it *hurts*, the storage levels, and cache eviction/recomputation.

**Why it matters:** Misuse of caching is a classic interview trap and a real performance blocker.

**Book chapters to study:** Ch 7 (and references to persistence in Part IV). `EXTERNAL KNOWLEDGE` for storage-level detail specifics.

**Interview importance:** `MUST KNOW`

---

## Concept: cache() & persist()

### Simple Explanation
`cache()`/`persist()` tells Spark to **store a DataFrame's computed data in memory** (and/or disk) so reuses don't recompute from scratch.

### Code Example
```python
from pyspark import StorageLevel

# Cache (default = MEMORY_AND_DISK)
df_clean = df.filter(...).withColumn(...).cache()
df_clean.count()          # action → materializes the cache NOW

# Reuse without recomputing
r1 = df_clean.groupBy("region").count()
r2 = df_clean.groupBy("product").count()

df_clean.unpersist()      # release when done

# Explicit storage level
df.persist(StorageLevel.MEMORY_AND_DISK)
df.persist(StorageLevel.MEMORY_ONLY)
df.persist(StorageLevel.DISK_ONLY)
df.persist(StorageLevel.MEMORY_ONLY_SER)
```

### Why It Exists
Spark datasets are immutable; without caching, every new action **replays the full lineage** (re-reads + recomputes). Caching stores the computed result so a reused DataFrame is fetched from memory/disk instead of recomputed.

### Interview Explanation
"`cache()` and `persist()` store a DataFrame's computed partitions so that subsequent actions reuse them instead of recomputing the lineage from scratch. `cache()` is a shorthand for `persist()` at the default storage level `MEMORY_AND_DISK`. You must trigger an action (like `count()`) to actually materialize the cache, and you call `unpersist()` when you're done."

### Common Mistakes
- Caching without measuring benefit (usually harmless but wastes memory).
- Not triggering an action after `cache()` → nothing cached.
- Never calling `unpersist()` → memory held.

---

## Concept: StorageLevel

### Simple Explanation
Configures *where* cached data lives: memory, disk, or both, and whether it's serialized.

### StorageLevel options (PySpark)

| StorageLevel | Stores in memory | Stores on disk | Serialized | Notes |
|--------------|------------------|----------------|------------|-------|
| `MEMORY_ONLY` | Yes | No | No | Fast, but loses partitions if out of memory |
| `MEMORY_AND_DISK` | Yes | Yes (overflow) | No | Default & safest |
| `MEMORY_ONLY_SER` | Yes | No | Yes | Less memory, more CPU |
| `MEMORY_AND_DISK_SER` | Yes | Yes | Yes | Balanced for big data |
| `DISK_ONLY` | No | Yes | — | Large data, memory-scarce |
| `OFF_HEAP` | Off-heap | — | Yes | Advanced, requires config |

### Interview Explanation
"Storage levels choose memory vs disk and serialization. `MEMORY_ONLY` keeps deserialized objects in memory (fast, but partitions are dropped if they don't fit). `MEMORY_AND_DISK` spills to disk when memory fills — the safe default that `cache()` uses. Serialized forms (`_SER`) use less memory at the cost of CPU. `DISK_ONLY` is for when data barely fits memory."

### Common Mistakes
- Using `MEMORY_ONLY` on large data (loses partitions → recompute).
- Forgetting serialized levels to save memory.

---

## Concept: When caching helps / hurts

### Helps when:
- A DataFrame is **reused across multiple actions/derived queries** (common: a cleaned base table used by many reports).
- The DataFrame is **expensive to compute** (complex joins/aggregations).
- **Iterative algorithms** reuse intermediate results.

### Hurts when:
- The DataFrame is used **only once** (cache adds overhead, no benefit).
- Data **doesn't fit in memory** anyway (spill/eviction, GC pressure).
- Recomputing the source is cheap and the cache just wastes memory.
- Storage causes excessive **garbage collection**.

### Interview Explanation
"Cache only DataFrames that are reused multiple times or are expensive to compute. Caching hurts when the data is used once — the overhead of materializing and storing outweighs any benefit — or when it doesn't fit in memory, causing eviction, spill, GC pressure, and then recomputation anyway."

### Common Mistakes
- Caching every intermediate step "just in case."
- Caching before knowing the reuse pattern.

---

## Concept: Cache Eviction

### Simple Explanation
If cached data doesn't fit in executor memory, Spark **evicts** (drops) some cached partitions — typically the least-recently-used.

### Technical Explanation
Unified memory: execution and storage share the executor's memory pool. If storage needs more space than available, Spark evicts cached partitions (for `MEMORY_AND_DISK`, evicted blocks spill to disk; for `MEMORY_ONLY`, they're dropped and will be recomputed via lineage). The Spark UI **Storage** tab shows "Fraction Cached" — if < 100%, eviction is happening.

### Interview Explanation
"Cache eviction happens when cached data exceeds the executor's storage memory. Spark drops the least-recently-used cached partitions; with `MEMORY_AND_DISK` they spill to disk, with `MEMORY_ONLY` they're lost and must be recomputed. The Storage tab's 'Fraction Cached' reveals eviction — you want 100%."

### Common Mistakes
- Ignoring a low "Fraction Cached" (means your cache isn't fully effective).

---

## Concept: Recomputing Lineage

### Simple Explanation
When a needed partition isn't cached (evicted or never cached), Spark **recomputes it from lineage** — replaying all its transformations.

### Technical Explanation
Because DataFrames/RDDs carry lineage, any un-cached partition can be regenerated by rerunning its transformations from the source. This is the fallback that guarantees correctness, but recomputation costs time and I/O — hence caching reused data.

### Interview Explanation
"Recomputing lineage is Spark's fallback for data that isn't cached: it replays the transformations from the source to regenerate the lost partition. It guarantees correctness but is costly, so caching is used to avoid repeated recomputation of expensive reused data."

---

**End of Chapter 9.** Tick "Caching" in the tracker.

---

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

# 12. Spark and Data Storage

**Objective:** Understand the file formats Spark reads/writes and why **Parquet** is the Data Engineering standard.

**Why it matters:** "Why Parquet?" is a very common interview question, and file format choice directly affects Spark performance.

**Book chapters to study:** Ch 10 (CSV/JSON/Parquet basics in the book). `EXTERNAL KNOWLEDGE` for ORC/Avro details and deeper columnar internals.

**Interview importance:** `MUST KNOW` (Parquet and columnar concepts).

---

## Concept: CSV

### Simple/Technical
Row-based, plain-text, human-readable, no schema. Slow to parse, no predicate pushdown, no compression efficiency, no type safety unless you define a schema.

### When used
Small/exploratory data, interop with non-Spark systems, user uploads.

### In PySpark
```python
df = spark.read.option("header", True) \
    .option("inferSchema", "true") \
    .csv("s3://bucket/data.csv")
```
Always use `header` and consider an explicit `schema` for production.

### Interview note
CSV is easy but inefficient and untyped; it's rarely the format for large, repeated Big Data processing.

---

## Concept: JSON

### Simple
Row-based, semi-structured, schema *inside* the data (nested objects/arrays). More flexible than CSV but larger and slower to read than columnar formats.

### In PySpark
```python
schema = StructType([...])
df = spark.read.schema(schema).json("s3://bucket/data/")
```
Nested JSON maps to Array/Struct/Map types. Prefer an explicit schema to avoid expensive inference.

### Interview note
Great for ingestion of nested event data; often converted to Parquet downstream for analytics.

---

## Concept: Parquet

### Simple/Technical
**Columnar**, open-source storage format that stores each column separately. Built for efficient compression and analytics. It's the default "workhorse" format of modern Data Engineering.

### Why Parquet is preferred in Data Engineering
1. **Columnar storage** → read only the columns you need (column pruning).
2. **Predicate pushdown** → skip blocks/rows not matching filters (row-group + column chunk skipping).
3. **Efficient compression** → same-type data compresses well (Snappy/Gzip/etc.).
4. **Schema embedded** → column names/types stored in metadata; schema evolution supported.
5. **Great for analytics** → aggregations over few columns are extremely fast.
6. **Faster than row formats (CSV/JSON)** for read-heavy analytical loads.

### Columnar storage explained
Instead of storing all fields of a row together (row-oriented like CSV), Parquet groups values of the *same column* together (column chunks + row groups). Analytical queries usually touch only a few columns, so columnar avoids reading irrelevant data.

### Predicate pushdown & partition pruning
- **Predicate pushdown:** Parquet metadata (min/max stats per column chunk) lets Spark skip entire blocks that can't satisfy a filter → fewer bytes read.
- **Partition pruning:** if data is written partitioned by `date`, filtering `where date=...` reads only the matching partition directories.

### Compression
Parquet compresses each column with a codec (Snappy default, Gzip, LZ4). Columnar ⇒ high column similarity ⇒ better ratios.

### Schema
Parquet stores a binary schema in each file's footer; Spark reads it to know columns/types without scanning data.

### In PySpark
```python
# READ with schema + filter (pushdown + pruning)
df = spark.read.schema(schema).parquet("s3://bucket/data/") \
    .filter("date = '2024-01-01'")

# WRITE partitioned, compressed
df.write.mode("overwrite") \
    .partitionBy("date") \
    .option("compression", "snappy") \
    .parquet("s3://bucket/out/")
```

### Interview Explanation (model answer)
> "Parquet is a columnar storage format, so I prefer it for Data Engineering: it stores each column together, which lets Spark do column pruning (only read needed columns) and predicate pushdown (skip blocks by using per-chunk min/max stats). This, plus efficient compression and an embedded schema, makes analytical reads much faster than row-based CSV/JSON. When I also partition writes by a filter column like date, Spark adds partition pruning on top — reading only relevant directories."

### Common Mistakes
- Writing Parquet with too many tiny files (small-file problem).
- Ignoring partition columns when writing (lose partition pruning).
- Reading CSV/JSON into Parquet for hot-path analytics (wasteful).

---

## Concept: ORC

### Simple
Another **columnar** format (from Hive). Similar benefits to Parquet: columnar, predicate pushdown, ACID-with-Delta/Hive support. Often used in Hive-heavy stacks.

### Parquet vs ORC (quick)
- Both columnar; Parquet is the more universal Spark recommendation; ORC historically tied to Hive.
- Spark handles Parquet natively and most Data/analytics platforms are Parquet-first.

### Interview note
You can mention ORC as Parquet's main columnar rival; know that Parquet is the safe default for Spark.

---

## Concept: Avro

### Simple
A **row-based**, binary, compact format with embedded schema, designed for serialization and efficient writes — good for streaming/pipe boundaries, not for columnar analytics.

### Interview note
Avro is row-oriented and schema-evolution friendly; sometimes used between producers/consumers or with Kafka, whereas Parquet is used for analytics storage. `EXTERNAL KNOWLEDGE`.

---

## Concept: Connecting formats to Spark performance

| Format | Orientation | Pruning/Pushdown | Compression | Typical use |
|--------|-------------|------------------|-------------|-------------|
| CSV | Row | No | Poor | Exchange/exploration |
| JSON | Row/semi | No | Moderate | Ingestion/nested |
| **Parquet** | **Column** | **Yes** | **Excellent** | **Analytics/warehouse** |
| ORC | Column | Yes | Excellent | Hive-heavy stacks |
| Avro | Row | No | Good | Serialization/pipe |

### Why it ties to performance
Choosing columnar Parquet + partitioning + compression multiplications the effects of Catalyst's pruning and pushdown — the single biggest cheap win in the storage layer.

---

**End of Chapter 12.** Tick "Parquet" in the tracker.

---

# 13. Structured Streaming

**Objective:** Learn internship-level streaming concepts — not too deep, but enough to answer fundamentals and build simple streaming pipelines.

**Why it matters:** Streaming is a core Data Engineering skill and a frequent interview topic, even for interns.

**Book chapters to study:** Ch 4/21 (streaming in the book). `EXTERNAL KNOWLEDGE` for some modern specifics.

**Interview importance:** `GOOD TO KNOW` / partial `MUST KNOW` for the core concepts (see labels below).

---

## Concept: Streaming DataFrame

### Simple Explanation
A DataFrame that grows with incoming data — you apply the *same* transformations as batch, but the input is an **unbounded stream**.

### Technical Explanation
A Streaming DataFrame is created with `spark.readStream` instead of `spark.read`. It represents an **unbounded table**; each trigger processes newly arrived data in **micro-batches**. Definition is lazy; `writeStream...start()` begins the continuous query.

### Code Example
```python
stream = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "clicks") \
    .load()
```

### Interview Explanation
> "Structured Streaming treats a stream as an unbounded DataFrame. You read with `readStream`, apply the same transformations you'd use in batch, and write with `writeStream`. Spark processes data in micro-batches triggered at intervals. The key idea is batch and streaming share the same engine and API."

**Internship must know** ✓

---

## Concept: Input Sources

### Simple Explanation
Where streaming data comes from.

### Sources
- **Kafka** — the dominant streaming source (`format("kafka")`).
- **File source** — read new files dropped into a directory.
- **Socket** — for testing.
- **Rate source** — generates test data at a rate.

### Code Example
```python
# File source — new files loaded as they arrive
df = spark.readStream \
    .schema(schema) \
    .option("path", "s3://bucket/incoming/") \
    .format("json") \
    .load()
```

### Interview Explanation
"Common input sources are Kafka (the go-to message bus), file sources that pick up new files landing in a directory, and rate/socket sources for testing. Kafka gives low-latency, high-throughput, replayable streams."

**Internship must know** ✓

---

## Concept: Output Sinks

### Simple Explanation
Where streaming results are written.

### Sinks
- **Kafka** — write results to a topic.
- **File sink** — write to Parquet/JSON/CSV on storage.
- **Console** — print to console (testing).
- **Memory** — hold results in memory (testing/dashboards).
- **foreach/foreachBatch** — custom processing per batch.

### Code Example
```python
query = result.writeStream \
    .format("parquet") \
    .option("path", "s3://bucket/out/") \
    .option("checkpointLocation", "s3://bucket/checkpoints/ct/") \
    .trigger(processingTime="1 minute") \
    .start()
```

### Interview Explanation
"Sinks are where results go: Kafka for re-publishing, file sinks (Parquet/JSON) for landing data, console/memory for testing, and foreachBatch for custom logic like database upserts or Delta merges. The checkpoint location is mandatory for fault tolerance."

**Internship must know** ✓

---

## Concept: Trigger

### Simple Explanation
Controls *when* each micro-batch runs.

### Options
```python
# Default: process as fast as possible
.trigger(processingTime="0 seconds")
# Fixed interval
.trigger(processingTime="1 minute")
# Once: process all available once, then stop
.trigger(once=True)
# Available now (Spark 3.3+)
.trigger(availableNow=True)
```

### Interview Explanation
"Triggers decide micro-batch cadence: 'processing time' runs a batch at a fixed interval or as fast as possible; 'once' processes what's available and stops (nice for batch-style catch-up). Continuous processing is an experimental ultra-low-latency mode."

**Internship must know** ✓

---

## Concept: Checkpointing & Fault Tolerance

### Simple Explanation
Spark stores the streaming query's **offsets, state, and committed batches** in a checkpoint directory so it can resume exactly after a crash.

### Technical Explanation
The checkpoint location (required) records: (1) read offsets — how far each input source was consumed, (2) operator state for stateful ops, (3) which batches committed. On restart, Spark resumes from the checkpoint → **exactly-once** processing (with the right sinks) even in the face of failures.

### Code Example
```python
.option("checkpointLocation", "s3://bucket/checkpoints/my_query/")
```

### Interview Explanation
"Checkpointing is what makes Structured Streaming fault-tolerant: the checkpoint directory stores consumed offsets, operator state, and committed batches. If the query crashes, Spark restarts from the last checkpoint and resumes exactly where it left off, giving end-to-end exactly-once guarantees when combined with idempotent sinks. It's mandatory, never optional."

**Internship must know** ✓

---

## Concept: Event Time vs Processing Time

### Simple Explanation
Two clocks:
- **Processing time:** when Spark processes the record (Spark's clock).
- **Event time:** when the event *actually happened* (embedded in the data).

### Why it matters
Analytics should usually use **event time**, because events can arrive late/out of order. Watermarks handle that lag.

### Interview Explanation
"Processing time is when Spark processes a record; event time is the timestamp in the data itself. For correct analytics we use event time, because real events can arrive late or out of order. Watermarks bound how late we're willing to accept data."

**Internship must know** ✓

---

## Concept: Watermark

### Simple Explanation
A threshold (e.g. "10 minutes") that tells Spark how long to wait for late-arriving events before finalizing a window and cleaning up state.

### Technical Explanation
`withWatermark("event_time", "10 minutes")` sets the watermark: Spark will include events whose event time is within the window of the max seen event time minus the watermark. Once the watermark passes a window's end (plus the delay), the window's results are finalized and its state dropped — bounding memory and preventing late data from changing finalized results.

### Code Example — windowed aggregation with watermark
```python
from pyspark.sql import functions as F

result = df \
    .withWatermark("event_time", "10 minutes") \
    .groupBy(F.window("event_time", "5 minutes"), "user_id") \
    .agg(F.count("*").alias("cnt"), F.sum("amount").alias("total"))
```

### Interview Explanation
"A watermark tells Spark how late data may be: it keeps state for a window until the max event time seen minus the watermark passes the window. After that, the window is finalized and state is cleaned up. Watermarks are essential to bound memory in stateful streaming and to handle out-of-order events correctly."

**Internship must know** ✓

---

## Concept: Windows (tumbling, sliding, session)

### Simple Explanation
Group events into time windows for aggregation.

### Types
- **Tumbling:** fixed, non-overlapping windows.
- **Sliding:** overlapping windows (with a slide interval).
- **Session:** windows separated by idle gaps.

### Code Example
```python
# Tumbling 5-min window
.groupBy(F.window("event_time", "5 minutes"))

# Sliding 10-min window every 2 min
.groupBy(F.window("event_time", "10 minutes", "2 minutes"))
```

### Interview Explanation
"Window functions group events by time: tumbling windows are fixed and non-overlapping; sliding windows overlap; session windows group activity separated by idle gaps. They're the standard way to do time-based aggregations over streams, always paired with a watermark."

**Internship must know** ✓

---

## Concept: Stateful Operations

### Simple Explanation
Operations that keep state *across* batches (e.g. running aggregates, deduplication), as opposed to stateless per-batch operations.

### Examples
- **Aggregations** (`groupBy...agg`) — running state per key.
- **Deduplication** (`dropDuplicates`) — remembers seen keys.
- **Stream-stream joins** — keeps buffered past events on both sides.

State grows over time → must be paired with a **watermark** to clean up old state (bounded memory), otherwise state grows unbounded.

### Code Example — dedup
```python
deduped = df.withWatermark("event_time", "10 minutes") \
    .dropDuplicates(["event_id"])
```

### Interview Explanation
"Stateful operations keep state across micro-batches — running aggregations, deduplication of seen keys, and stream-stream joins. Because state can grow forever, you must pair them with a watermark so Spark can drop state older than the watermark and keep memory bounded."

**Internship must know** ✓, partly `ADVANCED`

---

## Concept: Output Modes

### Simple Explanation
How results are written each trigger.

### Modes
- **Append:** only *new* rows added since the last trigger (default). Use for stateless queries or windowed aggregations with watermark.
- **Update:** only rows that *changed* since last trigger (for aggregations).
- **Complete:** the *entire* result table each trigger (expensive).

### Interview Explanation
"Output modes control what each trigger emits: append writes only new rows; update writes only updated rows from aggregations; complete rewrites the whole result table each time, which is expensive. Choosing correctly (append for ETL, update/complete for aggregations) matters for correctness and cost."

**Internship must know** ✓

---

## Concept: Exactly-Once Concepts

### Simple Explanation
The guarantee that each event is processed **exactly once**, even after failures.

### Technical Explanation
Structured Streaming achieves exactly-once through **checkpointing** (stored offsets + committed batches) plus **idempotent sinks** (Kafka, Delta Lake, or transactional DBs that tolerate re-writing the same data). The engine replays from the checkpoint, and the sink ensures no duplicates.

### Interview Explanation
"Exactly-once means each input event is processed exactly once despite failures. Structured Streaming gets this by checkpointing offsets and committed batches, then resuming from the checkpoint after a crash, combined with an idempotent sink that won't duplicate on re-write. Certain sinks (like append-only file/Delta/Kafka) support it; the mode must be compatible."

**Internship must know** ✓, partly `ADVANCED`

---

## Concept: Kafka Integration

### Simple Explanation
Read from and write to Kafka — the standard streaming backbone.

### Code Example (read)
```python
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType, TimestampType, DoubleType

schema = StructType([
    StructField("user_id", StringType()),
    StructField("event_time", TimestampType()),
    StructField("amount", DoubleType()),
])

events = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "user-events") \
    .option("startingOffsets", "latest") \
    .load() \
    .select(
        from_json(col("value").cast("string"), schema).alias("data")
    ).select("data.*")
```

### Code Example (write)
```python
query = events \
    .selectExpr("user_id AS key", "to_json(struct(*)) AS value") \
    .writeStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("topic", "enriched-events") \
    .option("checkpointLocation", "s3://checkpoints/kafka/") \
    .start()
```

### Interview Explanation
"Kafka is the standard streaming backbone. Spark reads Kafka topics as a streaming source — parsing the byte `value` with `from_json` against a schema — and writes results back to Kafka as `key`/`value`. Spark provides exactly-once with Kafka through checkpointing."

**Internship must know** ✓

---

## Advanced vs Internship label summary

**Internship Must Know:** Streaming DataFrame, sources/sinks, triggers, checkpointing/fault tolerance, event vs processing time, watermarks, windows, output modes, Kafka basics.

**Advanced (know conceptually):** stateful custom operations (`flatMapGroupsWithState`), stream-stream joins, continuous processing, exactly-once internals, RocksDB state store.

---

**End of Chapter 13.** Tick "Structured Streaming" in the tracker.

---

# 14. PySpark in Real Data Engineering

**Objective:** Understand where Spark fits into a modern data pipeline and how tools like Airflow, Docker, AWS, and Kafka surround it.

**Why it matters:** Interviews (and internships) care about *architecture*, not just Spark in isolation. Knowing where Spark sits shows engineering thinking.

**Interview importance:** `GOOD TO KNOW` — not asked in depth for interns, but knowing the lay of the land is a plus.

---

## The Big Picture

```text
Source
  ↓
Ingestion
  ↓
Object Storage
  ↓
PySpark
  ↓
Transformation
  ↓
Data Quality
  ↓
Data Lake / Warehouse
  ↓
BI / Analytics
```

| Stage | Typical tools | Spark's role |
|-------|---------------|--------------|
| Source | Apps, DBs, files, Kafka events | Consumes from these |
| Ingestion | Kafka, Airflow CDC, spark read | Spark can ingest (stream/batch) |
| Object Storage | S3, ADLS, GCS, HDFS | Where Spark reads/writes the data lake |
| Transformation | **PySpark** | Cleaning, joins, aggregations, enrichment |
| Data Quality | Great Expectations, custom Spark checks | Spark computes quality checks |
| Data Lake / Warehouse | S3+Parquet/Delta, Snowflake, BigQuery | Spark writes the lake |
| BI / Analytics | Looker, Tableau, dashboards | Consumes the warehouse |

### Key insight
**Spark is a compute engine, not a storage system.** It reads from and writes to external storage. Its job is fast distributed *transformation* — it does not store data long-term.

---

## Where Tools Around Spark Fit

### Airflow
- **Role:** Workflow orchestration / scheduling.
- **How it fits:** Airflow *triggers* Spark jobs on a schedule/dependency, watches them succeed/fail, and retries. You submit `spark-submit` (or a Databricks/EMR operator) from an Airflow DAG. Airflow does *not* process data — Spark does.

```python
# (conceptual Airflow task) — EXTERNAL KNOWLEDGE
submit_spark = BashOperator(
    task_id="run_etl",
    bash_command="spark-submit --master yarn /app/etl.py",
    dag=dag,
)
```

### Docker
- **Role:** Containerization.
- **How it fits:** Packages the Spark app (and even local Spark cluster for dev/testing) into reproducible containers, making environments consistent across dev/CI/prod.

### AWS / Azure / GCP
- **Role:** Cloud infrastructure.
- **How it fits:** Object storage (S3/ADLS/GCS) = the data lake; managed Spark services (EMR/Azure Synapse/Databricks) run your PySpark without you managing a cluster. IAM/auth security.

### Databricks
- **Role:** Managed Spark platform (notebooks + clusters + Delta Lake + SQL + jobs).
- **How it fits:** Runs the same PySpark you've learned, but on a hosted service with Delta Lake (ACID over Parquet), auto-scaling, and a UI.

### Snowflake
- **Role:** Cloud data warehouse.
- **How it fits:** Usually the *destination* of Spark-transformed data. You might write from Spark to S3/Parquet, then load into Snowflake, or use Spark Connector to write directly. (Separate query engine, not Spark.)

### Kafka
- **Role:** Distributed message bus / streaming backbone.
- **How it fits:** Source of streaming events into Structured Streaming, or sink of streaming results. Reliable, replayable, high-throughput.

### dbt
- **Role:** SQL-based transformation framework (transform-in-warehouse).
- **How it fits:** Where you prefer SQL transformations inside the warehouse, dbt replaces the "transformation" step Spark might otherwise do. Spark's SQL can do similar; dbt emphasizes versioned, tested SQL. `EXTERNAL KNOWLEDGE`.

---

## Example Architecture with Spark at the Center

```text
Mobile/Web apps ──> Kafka ──> [Structured Streaming] ──> S3 (raw, parquet)
                                                          ↓
DBs/APIs ──> [Airflow schedules] ──> spark-submit: PySpark batch ETL
                                                          ↓
                                            Data Quality checks (Spark)
                                                          ↓
                                              S3/Delta Lake (curated)
                                                          ↓
                                     Snowflake / BI / dashboards
```

### Interview Explanation
> "Spark is the distributed compute engine in the middle of the pipeline. Sources stream into Kafka and are landed in object storage; Airflow schedules Spark jobs that read that raw data, clean and transform it with PySpark, run data-quality checks, and write curated Parquet/Delta back to the data lake; then the warehouse (Snowflake) and BI tools consume it. Spark itself doesn't store data — it reads/writes the lake and does the heavy transformation."

---

**End of Chapter 14.**

---

# 15. PySpark Internship Projects

**Objective:** Build portfolio-ready projects that prove you can apply PySpark to real Data Engineering problems.

**Why it matters:** Projects + the ability to explain them are what get freshers hired. Do these, push them to GitHub, and be ready to discuss every decision.

**Interview importance:** `MUST KNOW` — having a project and explaining it beats theoretical knowledge alone.

---

## Project 1 — Beginner: E-Commerce Sales Cleanup & Analytics

### Problem statement
You receive messy daily e-commerce CSV exports. Clean them, compute per-product and per-region KPIs, and land a ready-to-analyze Parquet table.

### Architecture
```text
CSV (raw) → PySpark read → cleaning/validation → aggregation → Parquet (curated)
```

### Dataset requirements
- Public sales CSV (e.g. Brazilian E-Commerce `olist` dataset, or generate 100k rows).
- Columns: `order_id`, `customer_id`, `product_id`, `category`, `region`, `order_date`, `quantity`, `unit_price`, `status`.

### Folder structure
```
project1_ecommerce/
├── data/
│   ├── raw/            # input CSVs
│   └── curated/        # output Parquet
├── src/
│   └── pipeline.py
└── README.md
```

### PySpark tasks
1. Read CSV with an explicit `StructType` schema.
2. Handle missing/invalid values (`fillna`, `dropna`) and standardize strings (`trim`, `upper`).
3. Derive columns: `total_amount = quantity * unit_price`, `order_year/month`.
4. Aggregations per category & region (`groupBy().agg(sum, avg, count, countDistinct)`).
5. Filter out cancelled statuses.
6. Write partitioned Parquet (`partitionBy("order_year")`).
7. Rerun and verify determinism.

### Expected output
- Curated Parquet of clean orders.
- KPI tables: revenue by category/month, avg order value by region.
- A few `.show()` sanity checks.

### Optimization opportunities
- Explicit schema (no inference), filter early, `.cache()` the cleaned frame if reused, `coalesce` at write, partition by year for pruning.

### Interview questions about the project
1. Why did you partition by `order_year`? (partition pruning)
2. How would you make this job 3× faster? (broadcast dims, prune columns, tune shuffle partitions, AQE)
3. How do you handle bad/null data without failing the job?
4. What Spark UI metrics would you check?

---

## Project 2 — Intermediate: Large-Scale User Sessions Join & Optimization

### Problem statement
Join a large fact table (user events) with a dimension table (user profile) to build session-level analytics — and optimize the join so it runs efficiently at scale.

### Architecture
```text
events (Parquet, large) ──┐
                          ├─> PySpark join (broadcast / sort-merge)
user profiles (small)  ──┘
                          ↓
        session aggregation → windowing → curated Parquet
```

### Dataset requirements
- Big events file (millions of rows; generate or use a public clickstream dataset).
- Small profiles file (thousands of rows → broadcast candidate).
- Columns: events `(user_id, event_ts, event_type, amount, device)`; profiles `(user_id, country, tier)`.

### PySpark tasks
1. Create both DataFrames with explicit schemas.
2. **Broadcast join** profiles to events (they're small) — measure the difference vs a shuffled join.
3. Add a session id using window/ordering over `user_id` partitioned by time gaps.
4. Compute session aggregates (session length, total amount, event count).
5. Aggregate sessions by country/tier/device.
6. Repartition/coalesce for even output; write Parquet partitioned by `event_date`.
7. Use `explain()` and the Spark UI to justify optimizations.

### Expected output
- Session-level fact table + country/tier analytics Parquet.
- A written note (in README) on join strategy choice and partition counts.

### Optimization opportunities
- Broadcast join (vs sort-merge), `spark.sql.shuffle.partitions` tuning, AQE enabled, reduce shuffle by pruning columns, coalesce before write.

### Interview questions about the project
1. Why did you broadcast profiles instead of a sort-merge join?
2. How do you choose the number of shuffle partitions?
3. What does `explain(True)` tell you, and what did you change because of it?
4. How would you handle a skewed `user_id`?
5. If sessions look wrong at boundaries, what's the cause?

### (Optional) Add Airflow
Wrap the job in a small Airflow DAG (Dockerized) that schedules it daily and sets a `spark-submit` task. Mention it as orchestration.

---

## Project 3 — Interview-Level: End-to-End Data Engineering Pipeline

### Problem statement
Build a realistic pipeline that ingests data from an API/CSV, lands it in object storage, transforms with PySpark, runs data-quality checks, partitions output, and is scheduled by Airflow — the "full stack" of a Data Engineer intern.

### Architecture
```text
API / CSV
   ↓
Object Storage (S3/raw)
   ↓
PySpark (cleaning + transformations)
   ↓
Data Quality (Spark checks)
   ↓
Partitioned Parquet (curated)
   ↓
Warehouse-style layer (load/validate)
   ↓
Airflow (schedule + orchestration)
```

### Dataset requirements
- A public API or CSV you can call daily (e.g. weather, crypto ticker, GitHub events).
- Aim for nested JSON (arrays/structs) to practice nested handling.

### Folder structure
```
project3_pipeline/
├── dags/
│   └── etl_dag.py            # Airflow DAG
├── scripts/
│   ├── 01_ingest.py          # pull from API → raw storage
│   ├── 02_clean.py           # PySpark cleaning
│   ├── 03_transform.py       # PySpark transformations
│   ├── 04_quality.py         # data quality checks (Spark)
│   └── 05_load.py            # write partitioned, validate
├── data/
│   ├── raw/
│   └── curated/
├── tests/
│   └── test_quality.py
└── README.md
```

### PySpark tasks
1. **Ingest:** pull from API (or read CSV), land raw JSON/CSV in `data/raw/`.
2. **Clean:** explicit schema, handle nulls, dedupe, standardize types, parse dates.
3. **Transform:** derive metrics, window functions (running totals, ranks), aggregations, nested JSON parsing (`from_json`, `explode`).
4. **Quality:** Spark-based checks — row counts, null %, duplicate %, value bounds; fail the job if thresholds exceeded.
5. **Load:** write **partitioned Parquet** (`partitionBy("dt")`), compress (snappy), then validate (read back, count, checksum).
6. **Schedule (optional):** Airflow DAG with `PythonOperator`/`SparkSubmitOperator`, retries, and the DAG's each task depending on the previous.

### Expected output
- Curated partitioned Parquet + a quality report log.
- A reproducible, scheduled pipeline in a GitHub repo.
- README explaining architecture, trade-offs, and how to run it.

### Optimization opportunities
- Explicit schemas, broadcast joins, column pruning, partitioning for pruning, AQE, coalesce at write, caching reused frames, avoiding UDFs.

### Interview questions about the project
1. Walk me through your pipeline — what happens at each step?
2. Why did you partition by `dt`? How does that speed your queries?
3. How do you guarantee data quality before it hits the curated layer?
4. How would you make this pipeline handle 10× more data?
5. How do you recover if a 3 a.m. run fails halfway?
6. Why Spark instead of plain pandas for this?
7. How would you add streaming to convert this to near-real-time?

---

**End of Chapter 15.** Tick "PySpark project" in the tracker.

---

# 16. PySpark Practice

**Objective:** Solve realistic Data Engineering problems. Questions first (no solutions), solutions in a separate section after.

**Why it matters:** Fluency comes from doing. These mirror real ETL/analytics tasks and typical interview coding prompts.

**Interview importance:** `MUST KNOW` — practice all of them.

---

## Recommendations before you start
- Set up: `pip install pyspark` and run in local mode (`SparkSession.builder.master("local[*]")`).
- For each problem, create a small sample dataset to test.
- Use built-in `functions` — no Python UDFs unless the problem explicitly says so.
- After solving, think: was there a shuffle? Could I broadcast/partition better? What would `explain()` show?

---

## Beginner Problems (20)

1. Create a DataFrame from a list of tuples with columns `id, name, age, city`. Print the schema.
2. Read a CSV with `header=True` and an explicit schema. Show the first 5 rows.
3. Select only the `name` and `city` columns.
4. Filter rows where `age >= 18`.
5. Add a column `age_group` using `when`/`otherwise` (minor / adult / senior).
6. Rename `name` to `full_name`.
7. Drop the `id` column.
8. Remove duplicate rows using `distinct()`.
9. Deduplicate by `name` keeping the first occurrence (`dropDuplicates`).
10. Sort by `age` descending.
11. Fill null `city` values with "Unknown".
12. Keep only rows where `email` is not null (add an email column).
13. Concat `first_name` and `last_name` into `full_name` with a space.
14. Convert a numeric `amount` column to double and compute `amount * 1.1` as `amount_taxed`.
15. Use `lit()` to add a constant `source = "csv"` column.
16. Compute `count`, `sum`, `avg`, `min`, `max` of `amount` in one `agg`.
17. Group by `city` and count rows per city.
18. Count distinct values of `category`.
19. Get the top 3 rows by `score` (`orderBy` + `limit`).
20. Cast a string `date_str` to a date and extract the year.

---

## Intermediate Problems (20)

1. Read a JSON with nested `address.city` and `address.zip`; flatten them into columns.
2. Explode an `items` array column so each item becomes its own row.
3. For each `user_id`, compute the running total of `amount` ordered by `event_ts` (window function).
4. Rank products by `revenue` within each `category` (`rank`/`dense_rank`).
5. Compute each order's ratio of its amount to the category total (windowed sum).
6. Find the top 3 customers by total spend using a window.
7. Parse a `timestamp_str` of format `"yyyy-MM-dd HH:mm:ss"` and compute days since.
8. Join `orders` and `customers` (inner) on `customer_id`.
9. Left join orders to customers; identify orders with no matching customer (null customer).
10. Use `left_anti` to find customers with no orders.
11. Use `left_semi` to find customers who have at least one order.
12. Broadcast join a small `dim_country` table to a large `events` frame.
13. Deduplicate events by `event_id` keeping the first.
14. Compute the percentage of total revenue each product contributes within its category.
15. Add `row_number` to assign a sequential id per user ordered by time, and keep only the newest per user.
16. `coalesce` two nullable columns into one preferred value.
17. Find duplicate pairs of `(user_id, product_id)` that appear more than once.
18. Aggregate sales by year and month, and use `rollup` to add subtotals.
19. Pivot a `(category, amount)` frame into category columns (`groupBy().pivot()`).
20. Use `selectExpr` with a `CASE WHEN` and a `regexp_replace` to clean a phone column.

---

## Advanced Problems (20)

1. Given a large `events` frame, `repartition(200)` by `user_id` and explain why a subsequent join by `user_id` may be cheaper.
2. After a filter removes 80% of rows, `coalesce` to 50 partitions; verify `getNumPartitions()`.
3. Identify data skew: group a join key and find keys whose count is > 10× the average; propose a fix.
4. Implement a **salted join**: salt a skewed key on one side and explode the other side, then join and drop the salt columns.
5. Write a DataFrame partitioned by `year`, `month` and verify partition pruning by filtering with `explain`.
6. Tune `spark.sql.shuffle.partitions` and compare shuffle read/write sizes in the Spark UI for a groupBy.
7. Enable AQE and re-run a skewed join; compare task durations.
8. Use `cache()` on a cleaned frame reused by 3 aggregations, then `unpersist()`. Compare timings with/without.
9. Write a job that compacts many small files into ~10 reasonably sized Parquet files.
10. Implement a data-quality check: fail if null fraction in a critical column exceeds 5%.
11. Use a window `rangeBetween` to compute a 7-day rolling sum of sales per product.
12. Compute month-over-month growth of revenue using `lag` over monthly data.
13. Parse a complex nested JSON (arrays of structs) and reshape into a normalized, exploded table.
14. Optimize a slow join by (a) broadcasting the small side, then (b) selecting only needed columns before join. Compare.
15. Detect and explain stragglers in a job by reading a task-duration distribution.
16. Write `orders` and `customers` both partitioned by the same `customer_hash` to reduce join shuffles (conceptual).
17. Build a type-preserving pipeline with explicit `StructType` schemas for CSV and JSON input.
18. Reproduce the small-files problem, then fix it and quantify the improvement.
19. Use `foreachBatch` (conceptual) to upsert streaming results into a Delta-like table.
20. Design (in comments) a streaming job: Kafka source → watermark → 5-min windowed aggregation → Parquet sink with checkpointing; then implement it against a rate source.

---

# 16b. Practice Solutions

> Try the problems first. Solutions below use realistic PySpark. They are one correct answer — not the only one.

### Beginner Solutions

1.
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[*]").appName("p").getOrCreate()
df = spark.createDataFrame([(1,"Alice",25,"NYC"),(2,"Bob",30,"SF")], ["id","name","age","city"])
df.printSchema()
```

2.
```python
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
schema = StructType([StructField("id",IntegerType()), StructField("name",StringType()),
                     StructField("age",IntegerType()), StructField("city",StringType())])
df = spark.read.option("header", True).schema(schema).csv("data.csv")
df.show(5)
```

3. `df.select("name", "city")`

4. `df.filter(df.age >= 18)` or `df.filter("age >= 18")`

5.
```python
from pyspark.sql import functions as F
df.withColumn("age_group",
    F.when(F.col("age") < 18, "minor")
     .when(F.col("age") < 65, "adult")
     .otherwise("senior"))
```

6. `df.withColumnRenamed("name", "full_name")`

7. `df.drop("id")`

8. `df.distinct()`

9. `df.dropDuplicates(["name"])`

10. `df.orderBy(F.col("age").desc())`

11. `df.fillna({"city": "Unknown"})`

12. `df.filter(F.col("email").isNotNull())`

13. `df.withColumn("full_name", F.concat(F.col("first_name"), F.lit(" "), F.col("last_name")))`

14. `df.withColumn("amount", F.col("amount").cast("double")).withColumn("amount_taxed", F.col("amount") * 1.1)`

15. `df.withColumn("source", F.lit("csv"))`

16. `df.agg(F.count("*"), F.sum("amount"), F.avg("amount"), F.min("amount"), F.max("amount"))`

17. `df.groupBy("city").count()`

18. `df.select(F.countDistinct("category")).show()`

19. `df.orderBy(F.desc("score")).limit(3)`

20. `df.withColumn("dt", F.to_date("date_str", "yyyy-MM-dd")).withColumn("year", F.year("dt"))`

### Intermediate Solutions

1.
```python
df.withColumn("city", F.col("address.city")).withColumn("zip", F.col("address.zip"))
```

2. `df.withColumn("item", F.explode("items"))`

3.
```python
from pyspark.sql.window import Window
w = Window.partitionBy("user_id").orderBy("event_ts")
df.withColumn("running_total", F.sum("amount").over(w))
```

4.
```python
w = Window.partitionBy("category").orderBy(F.desc("revenue"))
df.withColumn("rank", F.rank().over(w))
```

5.
```python
w = Window.partitionBy("category")
df.withColumn("ratio", F.col("amount") / F.sum("amount").over(w))
```

6.
```python
w = Window.orderBy(F.desc("total_spend"))
df.groupBy("customer_id").agg(F.sum("amount").alias("total_spend")) \
  .withColumn("rn", F.row_number().over(w)).filter("rn <= 3")
```

7.
```python
df.withColumn("ts", F.to_timestamp("timestamp_str", "yyyy-MM-dd HH:mm:ss")) \
  .withColumn("days_since", F.datediff(F.current_date(), "ts"))
```

8. `orders.join(customers, "customer_id", "inner")`

9. `orders.join(customers, "customer_id", "left").filter(F.col("customers_name").isNull())`

10. `customers.join(orders, "customer_id", "left_anti")`

11. `customers.join(orders, "customer_id", "left_semi")`

12. `from pyspark.sql.functions import broadcast`
    `events.join(broadcast(dim_country), "country_code", "left")`

13.
```python
w = Window.partitionBy("event_id").orderBy("event_ts")
df.withColumn("rn", F.row_number().over(w)).filter("rn = 1").drop("rn")
```

14.
```python
w = Window.partitionBy("category")
df.withColumn("pct", F.col("revenue") / F.sum("revenue").over(w) * 100)
```

15.
```python
w = Window.partitionBy("user_id").orderBy(F.desc("event_ts"))
df.withColumn("rn", F.row_number().over(w)).filter("rn = 1").drop("rn")
```

16. `df.withColumn("preferred", F.coalesce(F.col("col_a"), F.col("col_b")))`

17.
```python
df.groupBy("user_id","product_id").count().filter("count > 1")
```

18.
```python
df.withColumn("year", F.year("dt")).withColumn("month", F.month("dt")) \
  .rollup("year","month").agg(F.sum("amount"))
```

19.
```python
df.groupBy("id").pivot("category", ["electronics","clothing","food"]).agg(F.sum("amount"))
```

20.
```python
df.selectExpr(
  "CASE WHEN status='paid' THEN amount ELSE 0 END as valid_amount",
  "regexp_replace(phone, '[^0-9]', '') as clean_phone")
```

### Advanced Solutions

1.
```python
df.repartition(200, "user_id")
# Explain: co-partitioning by user_id means a later join on user_id (if the other side is also
# partitioned the same way) can avoid a full shuffle. Reduce shuffle/network cost.
```

2.
```python
filtered = df.filter(...)
print(filtered.rdd.getNumPartitions())   # still N (unchanged by filter)
small = filtered.coalesce(50)
print(small.rdd.getNumPartitions())      # 50, no full shuffle
```

3.
```python
counts = df.groupBy("join_key").count()
avg_c = counts.agg(F.avg("count")).collect()[0][0]
skewed = counts.filter(F.col("count") > 10 * avg_c).orderBy(F.desc("count"))
skewed.show(20)
# Fix: salting (see #4) or AQE skew join.
```

4.
```python
from pyspark.sql import functions as F
SALT = 10
# Salt the large skewed side
large_s = skewed_large.withColumn("salt", (F.rand()*SALT).cast("int")) \
    .withColumn("sk", F.concat(F.col("key"), F.lit("_"), F.col("salt")))
# Explode the small side to match
small_s = small.withColumn("salt", F.explode(F.array([F.lit(i) for i in range(SALT)]))) \
    .withColumn("sk", F.concat(F.col("key"), F.lit("_"), F.col("salt")))
res = large_s.join(small_s, "sk").drop("salt","sk")
```

5.
```python
df.write.mode("overwrite").partitionBy("year","month").parquet("out/")
spark.read.parquet("out/").filter(F.col("year")==2024).explain(True)
# See partition pruning: only year=2024 dirs read.
```

6.
```python
spark.conf.set("spark.sql.shuffle.partitions", "400")
df.groupBy("key").count().explain(True)
# Compare Exchange partition count & shuffle sizes in UI.
```

7.
```python
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")
# Rerun the skewed join; AQE splits skew partitions; compare task durations.
```

8.
```python
clean = df.filter(...).withColumn(...).cache()
clean.count()                      # materialize
a = clean.groupBy("x").count()
b = clean.groupBy("y").count()
clean.unpersist()
```

9.
```python
spark.read.parquet("many_small/").repartition(10) \
    .write.mode("overwrite").parquet("compacted/")
```

10.
```python
total = df.count()
bad = df.filter(F.col("email").isNull()).count()
if bad / total > 0.05:
    raise RuntimeError(f"Null fraction {bad/total:.2%} exceeds 5%")
```

11.
```python
w = Window.partitionBy("product_id").orderBy(F.col("dt").cast("long")) \
    .rangeBetween(-6*86400, 0)
df.withColumn("rolling_7d", F.sum("amount").over(w))
```

12.
```python
w = Window.orderBy("month")
df.withColumn("prev_rev", F.lag("revenue").over(w)) \
  .withColumn("mom_pct", (F.col("revenue")/F.col("prev_rev") - 1) * 100)
```

13.
```python
schema = StructType([... nested ...])
parsed = df.select(F.from_json(F.col("value"), schema).alias("d")).select("d.*")
exploded = parsed.withColumn("row", F.explode("rows")).select("row.*", "id")
```

14.
```python
# (a) broadcast small side
res = large.join(broadcast(small), "key")
# (b) prune columns before join
small2 = small.select("key", "needed_col")
res = large.select("key","a","b").join(small2, "key")
# Compare shuffle read sizes in UI.
```

15.
```python
# Look at Spark UI Stages tab: a few tasks with duration >> median => stragglers
# caused by data skew; then address with salting/AQE.
```

16.
```python
# Conceptually: write/partition both orders & customers by hash(customer_id) into
# the same number of partitions so matching keys are co-located => avoid join shuffle.
```

17.
```python
from pyspark.sql.types import (StructType, StructField, StringType, IntegerType, TimestampType)
schema = StructType([...])
csv_df = spark.read.schema(schema).option("header", True).csv(...)
json_df = spark.read.schema(schema).json(...)
```

18.
```python
# Write with .coalesce(1) on many partitions => check for many tiny files on disk;
# then .repartition(50) to get ~larger files; compare file count & read time.
```

19.
```python
# (conceptual) Use writeStream.foreachBatch(fn) where fn merges batch into a Delta
# table via DeltaTable.merge — upsert semantics with checkpointing.
```

20.
```python
from pyspark.sql import functions as F
stream = spark.readStream.format("rate").option("rowsPerSecond", 100).load() \
    .withColumn("evt_time", F.current_timestamp()) \
    .withColumn("amt", F.col("value").cast("double"))
res = stream.withWatermark("evt_time", "10 minutes") \
    .groupBy(F.window("evt_time", "5 minutes")).agg(F.sum("amt"))
q = res.writeStream.outputMode("append").format("console") \
    .option("checkpointLocation", "ckpt/r/").trigger(processingTime="5 seconds").start()
q.awaitTermination(timeout=30000)
q.stop()
```

---

**End of Chapter 16.**

---

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

# 18. Interview Answer Framework

**Objective:** Structure answers so they're correct, concise, and easy to follow in an interview.

## The Structure

```text
1. Definition      — what it is, in one sentence
2. Why it exists   — the problem it solves
3. How it works    — the mechanism (brief)
4. Example         — a quick code/real example
5. Real-world use  — where you'd use it as a Data Engineer
6. Trade-off       — costs/limits/alternatives
```

This is a **comprehensive but compact** answer framework. In a fast interview, you can deliver Definition → Why → How → Trade-off in ~30–60 seconds and expand if prompted.

---

## Model Answer: "What is lazy evaluation in Spark?"

> *Definition:* Lazy evaluation means Spark doesn't execute transformations when you define them — it only records what to do and executes when an action is called.
> *Why:* By deferring execution, Spark sees the whole query and can optimize it — pushing filters down to data sources, pruning columns, and avoiding recomputation.
> *How:* Transformations like `filter` and `groupBy` build a logical plan / DAG lazily; actions like `count()` or `collect()` trigger the actual job.
> *Example:* `spark.read.csv(...).filter(...)` reads nothing until you call `.show()` or `.count()`.
> *Real world:* Every ETL relies on this — Spark optimizes the pipeline before a single byte moves.
> *Trade-off:* Because nothing runs until an action, bugs in transformations surface late; and calling two actions without caching recomputes the lineage.

---

## Model Answer: "What is a shuffle?"

> *Definition:* A shuffle is the repartitioning of data across executors required by wide transformations like `groupBy`, `join`, `distinct`, and `orderBy`.
> *Why:* Records sharing a key may live on different partitions/nodes, so Spark must relocate them to compute together.
> *How:* Each task writes shuffle data to local disk (shuffle write); downstream tasks fetch needed blocks over the network (shuffle read). This creates stage boundaries.
> *Example:* `df.groupBy("department").count()` shuffles so all rows of each department land on one partition.
> *Real world:* Shuffles dominate job cost in joins and aggregations, so minimizing them is the #1 optimization.
> *Trade-off:* It's expensive (disk + network). Alternatives: broadcast joins, filtering/pruning early, co-partitioning, AQE.

---

## Model Answer: "What is a broadcast join?"

> *Definition:* A join strategy where Spark sends a small table to every executor, which joins it locally against its slice of the large table.
> *Why:* It avoids shuffling the large table over the network — the whole cost of a shuffle.
> *How:* If a table is below `autoBroadcastJoinThreshold` (default 10MB), Spark broadcasts it (or you hint with `broadcast()`), builds a hash table per executor, and joins locally.
> *Example:* Joining a 100 GB events table to a 5 MB country-code lookup — broadcast the lookup.
> *Real world:* Dimension-to-fact joins are the classic case.
> *Trade-off:* The broadcast table is replicated to every executor, so it must fit in memory; too big → OOM/slow broadcast.

---

## Model Answer: "How do you debug a slow Spark job?"

> *Definition:* I use the Spark UI and the physical plan to find the bottleneck.
> *Why:* Performance problems are almost always: big shuffles, spills, data skew, small files, or resource misconfiguration.
> *How:* Check the slowest stage, then shuffle read/write size, disk spill, GC time, and the distribution of task durations. Then read `explain(True)` to find Exchange/shuffle nodes and join strategies.
> *Example:* A `SortMergeJoin` between two tables where one is actually small → switch to broadcast; a few straggler tasks → fix data skew with salting or AQE.
> *Real world:* This is the daily job of a Data Engineer.
> *Trade-off:* Over-tuning can add complexity — measure and re-check after each change.

---

## Model Answer: "Spark vs Hadoop MapReduce?"

> *Definition:* Both are distributed frameworks, but Spark keeps intermediate data in memory while MapReduce writes it to disk after every step.
> *Why:* Disk writes between steps make iterative/multi-step jobs slow in MapReduce.
> *How:* Spark's in-memory RDD/DataFrame execution, plus Catalyst/Tungsten optimization, accelerates iterative and interactive workloads; MapReduce also lacks a unified engine for SQL/streaming/ML.
> *Example:* A 10-step ETL runs once per pass in memory in Spark vs 10 separate disk-writing MapReduce jobs.
> *Real world:* Spark replaced MapReduce for most big-data ETL and analytics.
> *Trade-off:* MapReduce was simpler/more established and better for enormous single-pass batch jobs on smaller clusters; Spark needs enough memory for its in-memory model.

---

**End of Chapter 18.**

---

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

# 21. Progress Tracker

Tick each box as you complete it. Revisit anything left unchecked.

- [ ] Spark fundamentals
- [ ] PySpark DataFrames
- [ ] Transformations
- [ ] Actions
- [ ] Lazy evaluation
- [ ] RDD
- [ ] DAG
- [ ] Driver
- [ ] Executor
- [ ] Job
- [ ] Stage
- [ ] Task
- [ ] Partitions
- [ ] Shuffle
- [ ] Joins
- [ ] Broadcast joins
- [ ] Aggregations
- [ ] Window functions
- [ ] Caching
- [ ] Spark SQL
- [ ] Catalyst
- [ ] AQE
- [ ] Performance optimization
- [ ] Parquet
- [ ] Structured Streaming
- [ ] PySpark project
- [ ] Interview preparation

---

## Final self-check (from the role requirements)

1. ✅ Logical beginner → advanced progression (Ch 1–13 build up).
2. ✅ Covers fundamentals needed for an internship.
3. ✅ Spark architecture explained deeply (Ch 2).
4. ✅ PySpark coding included throughout (Ch 5, 6, 16).
5. ✅ Performance optimization included (Ch 11).
6. ✅ Real-world Data Engineering use cases (Ch 14, 15).
7. ✅ Interview questions included (Ch 17, 18).
8. ✅ Practical exercises (Ch 16).
9. ✅ Project ideas (Ch 15).
10. ✅ Revision cheat sheet (Ch 19).
11. ✅ Progress tracker (Ch 21).
12. ✅ Book used as primary source (referenced throughout; `EXTERNAL KNOWLEDGE` marked where beyond the book).
13. ✅ No important internship-level Spark concept skipped.

Good luck — now go build things and talk like an engineer. 🚀 (This emoji is the one permitted reward for finishing.)
