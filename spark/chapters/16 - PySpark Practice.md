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

