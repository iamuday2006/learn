# 38 — Mock Interview 3: Data Engineering SQL (15 Questions)

**Time: 60 minutes. Mix of written SQL and conceptual answers.**

---

## Setup

You are interviewing for a **Data Engineering Intern** role. The interviewer focuses on data pipelines, PostgreSQL, optimization, and real-world scenarios.

---

## Questions

### Q1: What is an idempotent write? Give a SQL example.
### Q2: Write a query to deduplicate a table using ROW_NUMBER.
### Q3: Your ETL job re-runs and loads the same data. How do you prevent duplicates?
### Q4: What is the difference between a staging table and a production table?
### Q5: Write a query that uses ON CONFLICT (upsert) to update a dimension table.
### Q6: What is a watermark in incremental loading?
### Q7: Write a query to find data quality issues: orders with NULL customer_id or negative amounts.
### Q8: Write a query that computes daily active users for the last 7 days.
### Q9: Write a query that computes month-over-month revenue growth.
### Q10: Write a query that finds the top 3 products by revenue per category.
### Q11: What is the difference between LIMIT/OFFSET pagination and keyset pagination?
### Q12: What happens if your database connection pool is exhausted?
### Q13: What is the purpose of VACUUM in PostgreSQL?
### Q14: Write a query to compare two snapshots of a table and find deleted rows.
### Q15: Design a simple schema for a food delivery app's orders, customers, and restaurants.

---

## Solutions

### Q1: Idempotent write
An idempotent write is one that produces the same result whether applied once or many times. Example:
```sql
INSERT INTO payments (request_id, amount, user_id)
VALUES ('req-abc-123', 100, 1)
ON CONFLICT (request_id) DO NOTHING;
```
Re-running this is safe — duplicates are prevented by the UNIQUE constraint on `request_id`.

### Q2: Deduplicate with ROW_NUMBER
```sql
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY natural_key ORDER BY created_at DESC) AS rn
    FROM my_table
)
DELETE FROM my_table WHERE ctid IN (
    SELECT ctid FROM ranked WHERE rn > 1
);
```
(Using `ctid` for physical row identification; alternatively use a primary key if available.)

### Q3: Prevent duplicates on re-run
Use an idempotency key (natural business key or explicit request_id) with a UNIQUE constraint + ON CONFLICT. Alternatively, truncate the target table before loading (if the load is all-or-nothing for that partition).

### Q4: Staging vs production table
- **Staging:** raw, unvalidated data from the source. May contain duplicates, NULLs, invalid values. Used as an intermediate landing zone.
- **Production:** cleaned, validated, deduplicated data that downstream consumers query. Only trusted data reaches production.

The flow: source → staging → validate/clean → production.

### Q5: Upsert a dimension table
```sql
INSERT INTO products (product_id, product_name, category, price)
SELECT product_id, product_name, category, price
FROM staging_products
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    category     = EXCLUDED.category,
    price        = EXCLUDED.price;
```

### Q6: Watermark in incremental loading
A watermark is a timestamp or marker that records the last successfully processed data point. On the next run, you only process rows where `created_at > last_watermark`. This prevents re-processing old data and enables restart-after-failure.

### Q7: Data quality check
```sql
SELECT order_id, amount,
       CASE WHEN customer_id IS NULL THEN 'missing_customer'
            WHEN amount < 0 THEN 'negative_amount'
            ELSE 'ok' END AS quality_flag
FROM orders
WHERE customer_id IS NULL OR amount < 0;
```

### Q8: Daily active users (last 7 days)
```sql
SELECT DATE_TRUNC('day', event_ts)::DATE AS day,
       COUNT(DISTINCT user_id) AS dau
FROM events
WHERE event_ts >= NOW() - INTERVAL '7 days'
  AND event_name = 'page_view'
GROUP BY 1
ORDER BY 1;
```

### Q9: Month-over-month revenue growth
```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(amount) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS growth_pct
FROM monthly
ORDER BY 1;
```

### Q10: Top 3 products by revenue per category
```sql
WITH revenue AS (
    SELECT p.category, p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS rev
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
    SELECT category, product_name, rev,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY rev DESC) AS rn
    FROM revenue
)
SELECT category, product_name, rev FROM ranked WHERE rn <= 3;
```

### Q11: OFFSET vs keyset pagination
- **OFFSET:** `LIMIT 10 OFFSET 100` — skips 100 rows (reads and discards them). O(n) per page.
- **Keyset:** `WHERE id > last_seen_id ORDER BY id LIMIT 10` — jumps directly to the right position via index. O(log n). Better for large offsets, but requires sequential access (can't jump to page N).

### Q12: Connection pool exhaustion
When the pool is empty, new requests **block** (wait for a connection) or **fail** with an error. Symptoms: increased latency, 500 errors. Fix: increase pool size, reduce query duration, add a separate read-only pool, or investigate long-running queries holding connections.

### Q13: VACUUM purpose
PostgreSQL uses MVCC, which keeps old row versions (dead tuples) until cleaned up. VACUUM reclaims space from dead tuples and updates table statistics (with ANALYZE). Without VACUUM, tables bloat and queries slow down. PostgreSQL's autovacuum runs this automatically, but heavy write workloads may need tuning.

### Q14: Compare two snapshots, find deleted rows
```sql
-- Rows in yesterday's snapshot but not today's
SELECT *
FROM snapshot_yesterday
EXCEPT
SELECT *
FROM snapshot_today;
```
Or with a key-based approach:
```sql
SELECT y.id
FROM snapshot_yesterday y
LEFT JOIN snapshot_today t ON y.id = t.id
WHERE t.id IS NULL;
```

### Q15: Food delivery schema
```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    city        VARCHAR(50)
);

CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    cuisine       VARCHAR(30),
    city          VARCHAR(50),
    rating        NUMERIC(2,1)
);

CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id),
    order_time    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_time TIMESTAMPTZ,
    status        VARCHAR(20) NOT NULL DEFAULT 'placed',
    total_amount  NUMERIC(10,2) NOT NULL DEFAULT 0
);
```
Explain each choice: FKs for referential integrity, CHECK on status, TIMESTAMPTZ for timezone correctness, default values for safe inserts.

---

## Score yourself

| Score | Meaning |
|-------|---------|
| 13–15 | DE-ready |
| 10–12 | Strong, review weak areas |
| 7–9 | Good foundation, more practice needed |
| <7 | Re-read chapters 27–35 before the real interview