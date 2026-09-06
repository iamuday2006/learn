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

