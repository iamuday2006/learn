# 11 — CTEs (Common Table Expressions) 🔥

**Priority: 🔥 MUST KNOW** — CTEs make complex queries readable, reusable, and testable, exactly what interviewers want to see.

---

## Concept

A **CTE** is a named temporary result set that exists for the duration of **one query**. It makes nested logic readable.

```sql
WITH revenue_by_customer AS (
    SELECT customer_id, SUM(amount) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT *
FROM revenue_by_customer
WHERE revenue > 100;
```

### Why CTEs exist
1. **Readability** — top-down logic instead of nested subqueries.
2. **Reuse** — reference the same CTE multiple times.
3. **Partitioning a problem** — build intermediate steps.

### Multiple CTEs — just comma-separate

```sql
WITH
active_customers AS (
    SELECT customer_id FROM customers WHERE is_active
),
revenue AS (
    SELECT customer_id, SUM(amount) AS revenue
    FROM orders
    GROUP BY customer_id
)
SELECT a.customer_id, r.revenue
FROM active_customers a
JOIN revenue r USING (customer_id);
```

---

## Simple Example

```sql
-- Latest order time per customer, then join back for details
WITH latest AS (
    SELECT customer_id, MAX(order_date) AS last_order
    FROM orders
    GROUP BY customer_id
)
SELECT c.first_name, l.last_order
FROM customers c
JOIN latest l USING (customer_id);
```

---

## Interview Question (Level 3): stepwise thinking is the point

**Q:** Find the top 3 highest-paid employees **per department**.

```sql
WITH ranked AS (
    SELECT e.name, e.department, e.salary,
           ROW_NUMBER() OVER (PARTITION BY department
                              ORDER BY salary DESC) AS rn
    FROM employees e
)
SELECT name, department, salary
FROM ranked
WHERE rn <= 3;
```
Two-step reasoning: first rank everything, then filter. This is the classic "**rank then filter**" pattern.

---

## Tricky Question (Level 5)

**Q:** Does a CTE `SELECT *` from itself in a loop — is it recursive?

```sql
WITH t AS (SELECT t.* FROM t)  -- ERROR: infinite recursion banned without RECURSIVE
```
You must write `WITH RECURSIVE t AS (...)`. Without RECURSIVE it's a plain reference error and the CTE can't reference itself.

---

## Recursive CTE basics (🟡)

Used for hierarchies and graph traversal — a classic **employee org chart**:

```sql
WITH RECURSIVE org_tree AS (
    -- anchor: the CEO
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- recursion: direct reports of the previous level
    SELECT e.employee_id, e.name, e.manager_id, ot.level + 1
    FROM employees e
    JOIN org_tree ot ON e.manager_id = ot.employee_id
)
SELECT * FROM org_tree ORDER BY level;
```

The recursion repeats until nothing new is produced (or a `WHERE` stops it). Watch for **cycles** — a loop in manager→employee data can run forever; PostgreSQL has `CYCLE` detection (`WITH RECURSIVE ... CYCLE ... SET ...`) in PG14+.

---

## Interview Follow-Up Chain

**Q:** CTE vs subquery — when do you use which?

**A:** Same semantics — the optimizer can inline either. Use a CTE when the query is long or you reference it multiple times, for readability. Subqueries (derived tables) are fine for one-off short usage. Historical note: older PG versions **materialized** CTEs (executed once), which could be faster — since PG 12 they may be **inlined**; if you specifically need materialization, add `AS MATERIALIZED`.

**Q:** Can you use a CTE in DML (INSERT/UPDATE/DELETE)?  
**A:** Yes! See chapter 30 (UPSERT) — `INSERT ... ON CONFLICT` with a CTE is a real DE pattern.

**Q:** Do CTEs create temp tables?  
**A:** No, they're mostly inlined views; only `AS MATERIALIZED` forces a separate intermediate, subject to the optimizer.

---

## Real-World Scenario

ETL staging: compute daily revenue, then flag days below the 30-day rolling average (needs two windows — see chapter 17 for the running-average pattern; here CTE stages the intermediate):

```sql
WITH daily_revenue AS (
    SELECT DATE_TRUNC('day', order_ts)::DATE AS day,
           SUM(amount) AS revenue
    FROM orders_fact
    WHERE status = 'completed'
    GROUP BY 1
),
with_avg AS (
    SELECT day, revenue,
           AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) AS rolling_avg
    FROM daily_revenue
)
SELECT day, revenue,
       CASE WHEN revenue < rolling_avg THEN 'below_avg' ELSE 'ok' END AS flag
FROM with_avg
ORDER BY day;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "CTE vs subquery?" / "Multiple CTEs?" / "Recursive CTE?" / "Materialized vs inlined CTE?"