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

