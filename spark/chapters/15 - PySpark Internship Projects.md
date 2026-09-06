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

