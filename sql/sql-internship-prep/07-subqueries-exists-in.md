# 07 — Subqueries, EXISTS, IN 🔥

**Priority: 🔥 MUST KNOW** with the classic NULL/`NOT IN` trap.

---

## Concept

A **subquery** is a query nested inside another query. Three flavors:

1. **Scalar subquery** — returns a single value (one row, one column). Used in SELECT, WHERE, HAVING.
2. **Non-correlated subquery** — independent of the outer query; runs once.
3. **Correlated subquery** — references the outer query; conceptually runs **once per outer row**.

`EXISTS` / `NOT EXISTS` / `IN` / `NOT IN` test subquery results.

---

## 1. Scalar subquery — a single value

```sql
SELECT name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);  -- single value
```

## 2. Non-correlated — independent inner query

```sql
SELECT department, AVG(salary)
FROM employees
WHERE department IN (SELECT DISTINCT department FROM departments);  -- list
```
The inner query is computed once, then reused.

## 3. Correlated — inner references outer

```sql
SELECT e1.name, e1.salary
FROM   employees e1
WHERE  e1.salary > (SELECT AVG(e2.salary)
                    FROM employees e2
                    WHERE e2.department = e1.department);
```
"Give me every employee earning more than their department's average." The subquery is evaluated per employee row — that's why correlated subqueries can be slow, and why the same result is often better as a JOIN:

```sql
SELECT e.name, e.salary
FROM employees e
JOIN (SELECT department, AVG(salary) AS avg_sal
      FROM employees
      GROUP BY department) d ON d.department = e.department
WHERE e.salary > d.avg_sal;
```

---

## EXISTS vs IN vs NOT IN — and the NULL trap 🔥

### EXISTS (stops at first match — good)

```sql
SELECT name FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```
`SELECT 1` is a convention meaning "I don't care about the columns". EXISTS returns TRUE/FALSE per row.

### IN (list membership)

```sql
SELECT name FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);
```

### NOT IN (⚠️ NULL trap)

If the subquery returns **any NULL**, `NOT IN` returns **no rows** (or no TRUE results) because:

```sql
x NOT IN (1, 2, NULL)  ==  x <> 1 AND x <> 2 AND x <> NULL
                             → ... AND NULL  → NULL (unknown) → not TRUE
```

So the fix is **NOT EXISTS**:
```sql
SELECT name FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```

**Interview rule of thumb:** prefer `EXISTS`/`NOT EXISTS` for subquery-driven logic; `NOT IN` is a foot-gun.

---

## Simple Example

```sql
-- Second highest salary (multiple techniques, full treatment in chapter 15)
SELECT MAX(salary) FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

---

## SQL Practice

Dataset: `datasets/ecommerce.sql`

1. Orders above the average order amount (scalar subquery).
2. Customers who have never ordered (NOT EXISTS + LEFT JOIN both).
3. Products never ordered (NOT EXISTS).
4. Rewrite correlated subquery as a JOIN group-by and compare.

---

## Interview Question (Level 3)

**Q:** Find employees whose salary is above average *of their department*.

**Correct (correlated or join):**
```sql
SELECT e.name, e.salary, e.department
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM employees
    WHERE department = e.department
);
```

**Common mistake:** comparing to overall average instead of departmental.
```sql
WHERE salary > (SELECT AVG(salary) FROM employees)   -- WRONG for the question
```

---

## Tricky Question (Level 5 — internship killer)

**Q:** `SELECT ... WHERE city NOT IN ('Berlin', 'Munich')` — a customer with `city IS NULL` is...?  
**A:** Excluded. `NULL NOT IN (...)` is NULL → not TRUE. To include them use `city IS NULL OR city NOT IN (...)`. Interviewers love this variant of the NULL trap.

---

## Interview Follow-Up Chain

**Q:** Which query returns "employees NOT in Sales" including NULLs?
```sql
WHERE department NOT IN ('Sales') OR department IS NULL     -- includes NULLs
WHERE department <> 'Sales'                                  -- excludes NULLs
```

**Q:** When is a correlated subquery a bad idea?  
**A:** On large tables — it can become N separate scans. Prefer a JOIN/EXISTS or a pre-aggregated derived table, and verify with EXPLAIN.

**Q:** What is `SELECT 1` in EXISTS?  
**A:** Convention — only checks for existence of rows; the optimizer ignores the selected constant (though PG will still plan the scan).

---

## Real-World Scenario

Data quality: find **referential integrity violations** — order_items whose product_id doesn't exist in products:

```sql
SELECT oi.order_item_id, oi.product_id
FROM   order_items oi
WHERE  NOT EXISTS (SELECT 1 FROM products p WHERE p.product_id = oi.product_id);
```

Then rewrite with an anti-join (LEFT JOIN + IS NULL) and discuss which the optimizer prefers.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Scalar vs correlated subquery?" / "NOT IN NULL trap?" / "EXISTS vs IN?" / "EXISTS vs JOIN?"