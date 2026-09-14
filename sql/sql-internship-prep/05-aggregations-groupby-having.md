# 05 — Aggregations, GROUP BY, HAVING 🔥

**Priority: 🔥 MUST KNOW** — the backbone of analytics SQL.

---

## Concept

**Aggregation** collapses many rows into one summary value. Every aggregate in PostgreSQL:
- Ignores NULL rows for `COUNT(col)`, `SUM`, `AVG`, `MIN`, `MAX`.
- Returns `NULL` for `SUM`/`AVG` when there are zero non-null rows (exception: `COUNT` returns 0).

Core aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.

### GROUP BY
- Groups rows by one or more columns.
- Every non-aggregated column in SELECT **must** appear in GROUP BY (PostgreSQL enforces this).

### HAVING
- Filters **groups** after aggregation.

---

## Simple Example

```sql
SELECT department, COUNT(*) AS employees, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;
```

Department with count and avg — classic.

---

## The BIG trap — non-aggregated column not in GROUP BY

```sql
-- PostgreSQL ERROR: column "e.name" must appear in the GROUP BY clause
SELECT department, name, COUNT(*)
FROM employees
GROUP BY department;
```
Different DBs allow this (MySQL does, returning garbage), but **PostgreSQL rejects it**. Two fixes:
1. Add `name` to GROUP BY.
2. Remove `name` from SELECT.

---

## Interview Question (Level 2)

**Q:** WHERE vs HAVING — can you use an aggregate in each?

**A:** `WHERE` runs before grouping → no aggregates. `HAVING` runs after grouping → aggregates allowed.

```sql
SELECT department, COUNT(*)
FROM employees
WHERE salary > 50000                      -- row filter first
GROUP BY department
HAVING COUNT(*) >= 3;                     -- group filter second
```

---

## Tricky Question (Level 5 — internship killer)

**Q:** `COUNT(*)` vs `COUNT(1)` vs `COUNT(column)` — are they the same?

**A:**
- `COUNT(*)` and `COUNT(1)` → count **rows** (same result, same plan in PG).
- `COUNT(column)` → counts **non-NULL values** of that column.

```sql
SELECT COUNT(*)          AS all_rows,
       COUNT(amount)     AS non_null,
       COUNT(DISTINCT amount) AS distinct_non_null
FROM payments;
```

---

## Difficult interview problems to practice

With `datasets/ecommerce.sql`:

1. **Revenue per customer**
```sql
SELECT c.customer_id,
       c.first_name,
       COUNT(o.order_id)        AS orders,
       COALESCE(SUM(o.total_amount), 0) AS revenue
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id
      AND o.status <> 'cancelled'
GROUP BY c.customer_id;
```
2. **Products ordered at least twice**
3. **Orders per month** (see chapter 09 for date grouping)
4. **Average order value per customer**, only for customers with 2+ orders

---

## Interview Follow-Up Chain

**Q:** Filter to departments where average salary exceeds overall company average.

```sql
SELECT department, AVG(salary) AS avg_sal
FROM employees
GROUP BY department
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees);
```
A scalar subquery in HAVING — connects to chapter 07.

**Q:** What does this do if department is NULL?  
**A:** All NULL departments group into one bucket.

**Q:** Can you use an alias from SELECT inside HAVING?  
**A:** Some DBs allow it; in PostgreSQL, **no** — you must repeat the expression. (You CAN use aliases in ORDER BY.)

---

## Real-World Scenario

Analytics: monthly revenue per country, showing only profitable months:

```sql
SELECT country,
       DATE_TRUNC('month', order_date)::DATE AS month,
       SUM(total_amount) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'delivered'
GROUP BY country, DATE_TRUNC('month', order_date)::DATE
HAVING SUM(total_amount) > 1000
ORDER BY country, month;
```

Note the GROUP BY uses the same expression as SELECT — **not** the alias `month`. In PostgreSQL you can use ordinal position (`GROUP BY 1, 2`) but the expression form is clearer and safer.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "COUNT variants?" / "WHERE vs HAVING?" / "Non-grouped columns error?" / "NULL in aggregates?" / "Alias in HAVING?"