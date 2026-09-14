# Medium Interview Questions

**20 questions. Level 2–3. Target: 5–10 minutes each.**

---

## Joins

### Q1. What happens when you LEFT JOIN and put a WHERE condition on the right table?
The LEFT JOIN becomes effectively an INNER JOIN because the WHERE filters out the NULL rows that the LEFT JOIN created for unmatched left-side rows.

### Q2. Write a query to find customers who have never placed an order.
```sql
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```

### Q3. What is the difference between JOIN, EXISTS, and IN for "customers who have orders"?
All three produce the same result. JOIN can multiply rows if the right side has duplicates. EXISTS short-circuits on first match. IN materializes a list. Prefer EXISTS for existence checks.

---

## Subqueries

### Q4. What is a correlated subquery?
A subquery that references the outer query and is re-evaluated for each outer row. Often slower than a JOIN; rewrite when performance matters.

### Q5. What is the NOT IN NULL trap?
If the subquery returns any NULL, NOT IN returns no rows because `x NOT IN (1, 2, NULL)` evaluates to `x<>1 AND x<>2 AND x<>NULL` → NULL (unknown) → not TRUE. Fix: use NOT EXISTS.

### Q6. Write a query to find employees who earn more than their department's average salary.
```sql
SELECT e.name, e.salary, e.department
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees WHERE department = e.department);
```

---

## Window Functions

### Q7. What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?
ROW_NUMBER: strictly unique per partition (1,2,3). RANK: ties share rank, then gaps (1,1,3). DENSE_RANK: ties share rank, no gaps (1,1,2).

### Q8. Write a query to find the second-highest salary.
```sql
WITH ranked AS (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT DISTINCT salary FROM ranked WHERE rk = 2 LIMIT 1;
```

### Q9. Write a query to find the top 3 highest-paid employees per department.
```sql
WITH ranked AS (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT name, department, salary FROM ranked WHERE rn <= 3;
```

---

## CTEs

### Q10. What is a CTE and why use it?
A CTE (WITH clause) is a named temporary result set. It makes complex queries readable, allows reuse, and supports recursive queries for hierarchies.

### Q11. Write a recursive CTE to find the employee hierarchy.
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

---

## CASE + Aggregation

### Q12. Write a conditional count: count delivered vs cancelled orders.
```sql
SELECT
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled
FROM orders;
```

### Q13. What does COALESCE do?
Returns the first non-NULL argument. `COALESCE(NULL, NULL, 'x')` → 'x'.

---

## Dates

### Q14. Write a query to find orders from the last 30 days.
```sql
SELECT * FROM orders WHERE order_date >= NOW() - INTERVAL '30 days';
```

### Q15. Write a query to group orders by month.
```sql
SELECT DATE_TRUNC('month', order_date)::DATE AS month, COUNT(*)
FROM orders GROUP BY 1 ORDER BY 1;
```

---

## NULL

### Q16. What happens when you use `WHERE amount <> 100` and some amounts are NULL?
NULLs are excluded. NULL <> 100 is NULL (unknown), not TRUE. To include NULLs: `WHERE amount <> 100 OR amount IS NULL`.

### Q17. What does COUNT(NULL) return?
0. COUNT ignores NULL values.

---

## Deduplication

### Q18. Write a query to remove duplicate emails from a users table, keeping the lowest user_id.
```sql
WITH ranked AS (
    SELECT user_id,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY user_id) AS rn
    FROM users
)
DELETE FROM users WHERE user_id IN (SELECT user_id FROM ranked WHERE rn > 1);
```

---

## Set Operations

### Q19. What is the difference between INTERSECT and INNER JOIN for set comparison?
INTERSECT compares full rows across two result sets and returns distinct matches. INNER JOIN compares on a key and can multiply rows if the join key isn't unique. INTERSECT is cleaner for whole-row comparison.

### Q20. Write a query to find products that exist in both order_items and sale_items.
```sql
SELECT product_id FROM order_items
INTERSECT
SELECT product_id FROM sale_items;
```