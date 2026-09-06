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

