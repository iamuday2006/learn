# Hard Interview Questions

**15 questions. Level 4–5. Target: 10–15 minutes each.**

---

## Window Functions

### Q1. Find the median salary.
```sql
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median
FROM employees;
```
Or using ROW_NUMBER for even/odd counts:
```sql
WITH ordered AS (
    SELECT salary, ROW_NUMBER() OVER (ORDER BY salary) AS rn,
           COUNT(*) OVER () AS cnt
    FROM employees
)
SELECT AVG(salary) FROM ordered
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2);
```

### Q2. Find the employee whose salary is closest to the average.
```sql
SELECT name, salary,
       ABS(salary - (SELECT AVG(salary) FROM employees)) AS diff
FROM employees
ORDER BY diff
LIMIT 1;
```

### Q3. Find the month with the highest revenue for each year.
```sql
WITH monthly AS (
    SELECT EXTRACT(YEAR FROM order_date) AS yr,
           EXTRACT(MONTH FROM order_date) AS mo,
           SUM(amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY 1, 2
),
ranked AS (
    SELECT yr, mo, revenue,
           ROW_NUMBER() OVER (PARTITION BY yr ORDER BY revenue DESC) AS rn
    FROM monthly
)
SELECT yr, mo, revenue FROM ranked WHERE rn = 1;
```

---

## CTE + Recursion

### Q4. Generate a date series for the last 30 days and find days with zero orders.
```sql
WITH dates AS (
    SELECT generate_series(
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE,
        INTERVAL '1 day'
    )::DATE AS day
)
SELECT d.day
FROM dates d
LEFT JOIN orders o ON o.order_date = d.day
WHERE o.order_id IS NULL;
```

### Q5. Find the longest consecutive sequence of active days per user.
```sql
WITH daily AS (
    SELECT DISTINCT user_id, event_ts::DATE AS day FROM events
),
numbered AS (
    SELECT user_id, day,
           day - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY day) * INTERVAL '1 day' AS grp
    FROM daily
)
SELECT user_id, MIN(day) AS streak_start, MAX(day) AS streak_end, COUNT(*) AS days
FROM numbered
GROUP BY user_id, grp
ORDER BY user_id, days DESC;
```

---

## Data Engineering

### Q6. Write an ETL pipeline that loads a daily batch of data idempotently.
```sql
BEGIN;
WITH incoming AS (
    SELECT * FROM staging_orders WHERE load_date = CURRENT_DATE
)
INSERT INTO orders_fact (order_id, customer_id, amount, order_ts)
SELECT order_id, customer_id, amount, order_ts FROM incoming
ON CONFLICT (order_id) DO UPDATE
SET amount   = EXCLUDED.amount,
    order_ts = EXCLUDED.order_ts;
UPDATE etl_watermarks SET last_watermark = NOW() WHERE table_name = 'orders';
COMMIT;
```

### Q7. Find rows that exist in table A but not in table B (three ways).
```sql
-- EXCEPT
SELECT id FROM a EXCEPT SELECT id FROM b;

-- NOT EXISTS
SELECT a.id FROM a WHERE NOT EXISTS (SELECT 1 FROM b WHERE b.id = a.id);

-- LEFT JOIN
SELECT a.id FROM a LEFT JOIN b ON b.id = a.id WHERE b.id IS NULL;
```

### Q8. Design a schema for user_event_logs with JSONB payload, partitioned by month.
```sql
CREATE TABLE user_events (
    event_id  BIGSERIAL,
    user_id   INT NOT NULL,
    event_name VARCHAR(50),
    payload   JSONB,
    event_ts  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (event_id, event_ts)
) PARTITION BY RANGE (event_ts);

CREATE TABLE user_events_2024_01 PARTITION OF user_events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE INDEX idx_events_user_ts ON user_events (user_id, event_ts);
CREATE INDEX idx_events_payload ON user_events USING GIN (payload);
```

---

## Optimization

### Q9. This query is slow on 10M rows. Diagnose it.
```sql
SELECT * FROM orders WHERE EXTRACT(month FROM order_date) = 11;
```
**Answer:** `EXTRACT(month FROM order_date)` is non-sargable — the index on `order_date` can't be used. Rewrite:
```sql
SELECT * FROM orders
WHERE order_date >= '2023-11-01' AND order_date < '2023-12-01';
```

### Q10. Why might PostgreSQL ignore your index on `customer_id`?
Possible reasons: low selectivity (most rows match), stale statistics (ANALYZE needed), function on the column in WHERE, or the planner determined a seq scan is cheaper for the query.

---

## Concurrency

### Q11. What is a deadlock? How do you avoid it?
Two transactions each hold a lock the other needs. PostgreSQL detects it and aborts one. Avoid: lock rows in the same order, keep transactions short.

### Q12. What does SERIALIZABLE isolation add over REPEATABLE READ?
SERIALIZABLE detects serialization conflicts — situations where the concurrent execution order wouldn't match any serial order — and aborts with error 40001. You retry the transaction.

---

## Complex Patterns

### Q13. Find customers who purchased both 'Product A' and 'Product B' but never 'Product C'.
```sql
SELECT o1.customer_id
FROM order_items oi1
JOIN orders o1 ON o1.order_id = oi1.order_id
JOIN products p1 ON p1.product_id = oi1.product_id AND p1.product_name = 'Product A'
WHERE EXISTS (
    SELECT 1 FROM order_items oi2
    JOIN orders o2 ON o2.order_id = oi2.order_id
    JOIN products p2 ON p2.product_id = oi2.product_id AND p2.product_name = 'Product B'
    WHERE o2.customer_id = o1.customer_id
)
AND NOT EXISTS (
    SELECT 1 FROM order_items oi3
    JOIN orders o3 ON o3.order_id = oi3.order_id
    JOIN products p3 ON p3.product_id = oi3.product_id AND p3.product_name = 'Product C'
    WHERE o3.customer_id = o1.customer_id
)
GROUP BY o1.customer_id;
```

### Q14. Find the percentage of revenue from each product category.
```sql
WITH cat_rev AS (
    SELECT p.category, SUM(oi.quantity * oi.unit_price) AS rev
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY p.category
)
SELECT category, rev,
       ROUND(100.0 * rev / SUM(rev) OVER (), 1) AS pct
FROM cat_rev
ORDER BY rev DESC;
```

### Q15. Find the first product each customer ever purchased.
```sql
WITH ranked AS (
    SELECT o.customer_id, p.product_name, o.order_date,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS rn
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
)
SELECT customer_id, product_name, order_date FROM ranked WHERE rn = 1;
```