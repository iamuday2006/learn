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

