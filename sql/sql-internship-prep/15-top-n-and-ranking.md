# 15 — Top-N and Ranking 🔥

**Priority: 🔥 MUST KNOW** — "second highest salary" is the most famous SQL interview question ever.

---

## How to recognize it

"Top 3 of each group", "second highest", "nth highest", "highest per department/category", "top N".

---

## Recommended SQL technique

1. **Whole-table top N:** simple `ORDER BY ... LIMIT N` (or `OFFSET` for Nth).
2. **Top N per group:** window `ROW_NUMBER/RANK/DENSE_RANK` OVER `PARTITION BY group ORDER BY value DESC`, then filter rank ≤ N.

---

## Example — second highest salary

There are **at least 4 ways**. Know them all:

```sql
-- 1. Subquery: exclude the max, take the new max
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- 2. LIMIT/OFFSET with DISTINCT (best for ties)
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 1 LIMIT 1;   -- one if exactly one max exists

-- 3. Window function with DENSE_RANK
WITH ranked AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT salary FROM ranked WHERE rk = 2 LIMIT 1;

-- 4. Correlated count
SELECT DISTINCT salary
FROM employees e
WHERE (SELECT COUNT(DISTINCT salary) FROM employees
       WHERE salary > e.salary) = 1;
```

**Ties note:** with duplicate top salaries (100, 100), DENSE_RANK treats both as rank 1 → `rk = 2` finds the next distinct value (90) — the *correct* reading of "second highest". `OFFSET 1` with `SELECT DISTINCT` also handles it. `ROW_NUMBER` would give 100 at both rank 1 and 2 — wrong for "second distinct highest."

---

## Top 3 per department

```sql
WITH ranked AS (
    SELECT e.name, e.department, e.salary,
           DENSE_RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS rk
    FROM employees e
)
SELECT name, department, salary
FROM ranked
WHERE rk <= 3;
```

Deliberately used `DENSE_RANK` so ties don't produce gaps (4th place with equal salary still appears if within 3 distinct ranks). For "exactly 3 rows per department, ties be damned," use `ROW_NUMBER`.

---

## Common mistake

- Using `LIMIT` **after** a JOIN that multiplies rows → wrong top-N.
- Forgetting `DISTINCT` → duplicate salaries counted twice → wrong "highest".
- Using `RANK` where gaps break `<= 3` (two people tied #1 → #4 excluded).

---

## Interview variations

1. **Nth highest** — parametrize the window or use `OFFSET N-1`.
2. **Top N per department/category/city** — PARTITION BY.
3. **Second highest *per department*** — PARTITION BY department, filter rk=2.
4. **Median salary** — `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)` or offset arithmetic:
```sql
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median FROM employees;
```
5. **Highest growth product** — compute growth, then rank.

---

## Real-world scenario

"Give me the top 3 products by revenue, per category."

```sql
WITH revenue AS (
    SELECT p.product_id, p.category, SUM(oi.quantity * oi.unit_price) AS rev
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY p.product_id
),
ranked AS (
    SELECT category, product_id, rev,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY rev DESC) AS rn
    FROM revenue
)
SELECT * FROM ranked WHERE rn <= 3;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Second highest with ties?" / "Top-N per group?" / "RANK vs DENSE_RANK vs ROW_NUMBER?" / "Median?"