# Mock Interview 6: Final Internship Interview

**Time: 90 minutes. Combined SQL + PostgreSQL + Optimization + Data Engineering + Scenario.**

This is a **realistic final-round** interview for a Data Engineering Intern. The interviewer will mix topics to test breadth and depth.

---

## Part A: SQL Fundamentals + Joins (20 minutes, 8 questions)

### Q1: What is the logical order of query execution?
FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT.

### Q2: Why can't you use an aggregate in WHERE?
WHERE runs before grouping (step 2). Aggregates exist after GROUP BY (step 3). That's what HAVING is for.

### Q3: What is the difference between INNER JOIN and LEFT JOIN?
INNER: only matched rows. LEFT: all left rows + matches; unmatched right-side columns are NULL.

### Q4: Why can a LEFT JOIN accidentally become an INNER JOIN?
When you put a WHERE condition on the right table, it filters out the NULL rows created by the LEFT JOIN. Fix: move the condition to the ON clause.

### Q5: What is the NOT IN NULL trap?
If the subquery returns any NULL, NOT IN returns no rows. Use NOT EXISTS instead.

### Q6: Write a query to find customers with no orders.
```sql
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```

### Q7: What does COUNT(*) count vs COUNT(column)?
COUNT(*): all rows. COUNT(column): non-NULL values only.

### Q8: Write a query to find the second-highest salary.
```sql
WITH ranked AS (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT DISTINCT salary FROM ranked WHERE rk = 2 LIMIT 1;
```

---

## Part B: Window Functions + CTEs (20 minutes, 5 questions)

### Q9: What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?
ROW_NUMBER: unique 1,2,3. RANK: ties share rank, gaps. DENSE_RANK: ties share rank, no gaps.

### Q10: Write a query to find the top 3 products by revenue per category.
```sql
WITH prod_rev AS (
    SELECT p.category_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY p.category_id, p.product_name
),
ranked AS (
    SELECT category_id, product_name, revenue,
           ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY revenue DESC) AS rn
    FROM prod_rev
)
SELECT * FROM ranked WHERE rn <= 3;
```

### Q11: Write a recursive CTE for the employee hierarchy.
```sql
WITH RECURSIVE org AS (
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name, e.manager_id, o.level + 1
    FROM employees e JOIN org o ON e.manager_id = o.employee_id
)
SELECT * FROM org ORDER BY level;
```

### Q12: Write a query to find the month-over-month revenue growth percentage.
```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'delivered'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS growth_pct
FROM monthly ORDER BY 1;
```

### Q13: Write a query to find the running total of order amounts per customer.
```sql
SELECT customer_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders ORDER BY customer_id, order_date;
```

---

## Part C: PostgreSQL + Optimization (20 minutes, 5 questions)

### Q14: What is the difference between PostgreSQL and MySQL?
PostgreSQL: transactional DDL, JSONB (indexable), UPSERT (ON CONFLICT), ARRAY, IDENTITY, RETURNING, multiple NULLs in UNIQUE. MySQL: simpler OLTP, faster for trivial lookups, AUTO_INCREMENT, DDL auto-commits.

### Q15: Why might PostgreSQL ignore an index on customer_id?
Low selectivity (most rows match), stale statistics (ANALYZE needed), function on the column, or the planner determined a seq scan is cheaper.

### Q16: What is EXPLAIN ANALYZE and what do you look for?
Shows actual execution plan with timing. Look for: Seq Scan on large tables → add index; estimated vs actual row mismatch → ANALYZE; Sort nodes → index for ORDER BY.

### Q17: What is VACUUM?
Reclaims dead tuples (MVCC byproduct) and updates statistics. Without it, tables bloat and queries slow. Autovacuum runs automatically; heavy workloads may need tuning.

### Q18: Write an idempotent upsert for an ETL pipeline.
```sql
INSERT INTO orders_fact (order_id, customer_id, amount, order_ts)
SELECT order_id, customer_id, amount, order_ts FROM staging_orders
ON CONFLICT (order_id) DO UPDATE
SET amount = EXCLUDED.amount, order_ts = EXCLUDED.order_ts;
```

---

## Part D: Data Engineering + Scenarios (30 minutes, 5 questions)

### Q19: Design a daily revenue pipeline.
1. Load raw data to staging table (COPY/INSERT).
2. Validate (NULL checks, referential integrity, range checks).
3. Dedup with ON CONFLICT.
4. Upsert to production fact table.
5. Compute daily metrics into summary table.
6. All in a transaction. Watermark updated after success.

### Q20: How do you handle a schema change in a running pipeline?
Options: (1) add new columns with defaults, (2) version staging tables, (3) schema validation in a quality check, (4) use semi-structured columns (JSONB) for evolving fields.

### Q21: Write a data quality check: find orders with NULL customer_id or negative amounts.
```sql
SELECT order_id, customer_id, amount,
       CASE WHEN customer_id IS NULL THEN 'missing_customer'
            WHEN amount < 0 THEN 'negative_amount'
            ELSE 'ok' END AS flag
FROM orders
WHERE customer_id IS NULL OR amount < 0;
```

### Q22: Write a query to find daily active users for the last 7 days.
```sql
SELECT DATE_TRUNC('day', event_ts)::DATE AS day,
       COUNT(DISTINCT user_id) AS dau
FROM events
WHERE event_ts >= NOW() - INTERVAL '7 days'
  AND event_name = 'page_view'
GROUP BY 1 ORDER BY 1;
```

### Q23: Write a query to find customers who ordered both 'Product A' and 'Product B' but never 'Product C'.
```sql
SELECT o1.customer_id
FROM orders o1
JOIN order_items oi1 ON oi1.order_id = o1.order_id
JOIN products p1 ON p1.product_id = oi1.product_id AND p1.product_name = 'Product A'
WHERE EXISTS (
    SELECT 1 FROM orders o2
    JOIN order_items oi2 ON oi2.order_id = o2.order_id
    JOIN products p2 ON p2.product_id = oi2.product_id AND p2.product_name = 'Product B'
    WHERE o2.customer_id = o1.customer_id
)
AND NOT EXISTS (
    SELECT 1 FROM orders o3
    JOIN order_items oi3 ON oi3.order_id = o3.order_id
    JOIN products p3 ON p3.product_id = oi3.product_id AND p3.product_name = 'Product C'
    WHERE o3.customer_id = o1.customer_id
)
GROUP BY o1.customer_id;
```

---

## Scoring

| Section | Weight | Max |
|---------|--------|-----|
| A: SQL Fundamentals | 30% | 30 |
| B: Window Functions + CTE | 25% | 25 |
| C: PostgreSQL + Optimization | 20% | 20 |
| D: Data Engineering | 25% | 25 |
| **Total** | | **100** |

| Score | Result |
|-------|--------|
| 80–100 | Strong pass |
| 60–79 | Pass with minor gaps |
| 40–59 | Borderline — review weak areas |
| <40 | Not ready — re-study chapters 01–35 |