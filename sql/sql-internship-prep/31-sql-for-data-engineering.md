# 31 — SQL for Data Engineering 🔥

**Priority: 🔥 MUST KNOW** — this is the chapter that directly answers "how will you use SQL in a Data Engineering role?"

---

## Core DE tasks

Data Engineering SQL falls into **five buckets**: ETL pipelines, incremental loading, data quality, analytics, and schema design.

---

## 1. ETL — Cleaning + Transformation

```sql
-- Stage raw data, then clean
WITH cleaned AS (
    SELECT
        TRIM(LOWER(email))           AS email_clean,
        CASE WHEN age < 13 OR age > 120 THEN NULL ELSE age END AS age_clean,
        COALESCE(city, 'unknown')    AS city_clean
    FROM raw_customers
    WHERE email IS NOT NULL          -- drop completely broken rows
      AND LENGTH(TRIM(email)) > 5    -- basic validation
)
INSERT INTO customers_cleaned (email, age, city)
SELECT DISTINCT ON (email_clean) email_clean, age_clean, city_clean
FROM cleaned
ON CONFLICT (email) DO UPDATE
SET age  = EXCLUDED.age,
    city = EXCLUDED.city;
```

Key ideas: filter bad data early, normalize strings, handle NULLs, dedup with `DISTINCT ON`.

---

## 2. Incremental Loading

Use `created_at` / `updated_at` as **watermarks** — only process new or changed rows since last run:

```sql
-- Last run watermark is stored in metadata
-- Only insert rows newer than the watermark
INSERT INTO orders_fact (order_id, customer_id, amount, order_ts)
SELECT order_id, customer_id, amount, order_ts
FROM staging_orders
WHERE order_ts > (SELECT last_watermark FROM etl_watermarks WHERE table_name = 'orders')
  AND order_ts <= NOW();

-- Then update the watermark
UPDATE etl_watermarks
SET last_watermark = NOW()
WHERE table_name = 'orders';
```

**Partition approach for large tables:** process by date partition (e.g., `PARTITION BY RANGE (order_ts)`) and drop/load whole partitions.

---

## 3. Data Quality Checks

Before downstream consumers use a table, validate it:

```sql
-- Check 1: no NULLs in required columns
SELECT COUNT(*) AS null_count FROM orders WHERE customer_id IS NULL;

-- Check 2: no duplicate primary keys
SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

-- Check 3: referential integrity (orphaned order_items)
SELECT oi.order_item_id
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;  -- shouldn't exist

-- Check 4: reasonable ranges
SELECT COUNT(*) FROM employees WHERE salary < 0;  -- should be 0
```

---

## 4. Analytics — Business metrics

```sql
-- Daily active users (DAU)
SELECT DATE_TRUNC('day', event_ts)::DATE AS day,
       COUNT(DISTINCT user_id) AS dau
FROM events
WHERE event_name = 'page_view'
GROUP BY 1
ORDER BY 1;

-- Monthly revenue
SELECT DATE_TRUNC('month', order_ts)::DATE AS month,
       SUM(amount) AS revenue
FROM orders_fact
WHERE status = 'completed'
GROUP BY 1
ORDER BY 1;

-- Month-over-month revenue growth
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_ts)::DATE AS month,
           SUM(amount) AS revenue
    FROM orders_fact
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS growth_pct
FROM monthly
ORDER BY 1;

-- Cohort retention (users active in signup month AND month+1)
WITH cohort AS (
    SELECT u.user_id,
           DATE_TRUNC('month', u.account_created)::DATE AS cohort_month
    FROM user_dim u
),
activity AS (
    SELECT DISTINCT user_id,
           DATE_TRUNC('month', event_ts)::DATE AS active_month
    FROM events
)
SELECT c.cohort_month,
       COUNT(DISTINCT a.active_month) AS active_months,
       SUM(CASE WHEN a.active_month = c.cohort_month THEN 1 ELSE 0 END) AS in_cohort,
       SUM(CASE WHEN a.active_month = c.cohort_month + INTERVAL '1 month' THEN 1 ELSE 0 END) AS month_plus_1
FROM cohort c
LEFT JOIN activity a ON a.user_id = c.user_id
GROUP BY c.cohort_month
ORDER BY 1;
```

---

## 5. Data validation on write

```sql
-- Reject rows that fail business rules (or log and quarantine)
WITH valid AS (
    SELECT *
    FROM staging_orders
    WHERE amount > 0
      AND customer_id IS NOT NULL
      AND order_date <= NOW()
),
invalid AS (
    SELECT *
    FROM staging_orders
    WHERE amount <= 0
       OR customer_id IS NULL
       OR order_date > NOW()
)
-- Insert valid rows
INSERT INTO orders_fact (customer_id, amount, order_ts)
SELECT customer_id, amount, order_date FROM valid;

-- Quarantine invalid
INSERT INTO quarantine_orders
SELECT *, 'failed_validation' AS reason, NOW() AS quarantined_at
FROM invalid;
```

---

## Interview Question (Level 3)

**Q:** How do you handle a schema change in a running pipeline?

**A:** If a column is added upstream, the pipeline may break. Solutions: (1) add new columns with defaults, (2) version your staging tables, (3) use a schema registry for semi-structured data, (4) validate schema in a quality check before transforming.

---

## Tricky Question (Level 5)

**Q:** Your pipeline loads 100M rows daily. What happens if today's load fails halfway?

**A:** This is why we have:
1. **Transactions** — either the whole batch commits or none of it.
2. **Idempotent upserts** — re-running the load doesn't create duplicates.
3. **Watermarks** — only process new rows; if the load fails, today's watermark isn't committed, so tomorrow's retry starts at the right place.
4. **Staging table** — load to staging first, validate, then `INSERT ... SELECT` to the target. If validation fails, staging is dropped and nothing touches the production table.

---

## Real-world scenario

Build a daily revenue dashboard pipeline:
1. `staging_orders` receives raw data (from Kafka/file).
2. Clean + validate in a CTE.
3. Upsert into `orders_fact` using `ON CONFLICT`.
4. Compute daily metrics into a summary table.
5. Update the dashboard materialized view.

Each step is one transaction. The pipeline is idempotent (can re-run safely).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Incremental loading?" / "Data quality checks?" / "Schema change handling?" / "Pipeline failure strategy?"