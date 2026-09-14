# 37 — Mock Interview 2: SQL Coding (10 Questions)

**Time: 40 minutes. Schema provided below. Write SQL for each.**

---

## Schema

```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name        VARCHAR(100),
    department  VARCHAR(50),
    manager_id  INT REFERENCES employees(employee_id),
    salary      NUMERIC(10,2),
    hire_date   DATE
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT,
    order_date  DATE,
    amount      NUMERIC(10,2),
    status      VARCHAR(20)
);
```

---

## Questions

### Q1: Find all employees who earn more than their manager.
**Expected approach:** Self join with salary comparison.

### Q2: Find the second-highest salary.
**Expected approach:** Subquery or DENSE_RANK.

### Q3: Find departments with more than 5 employees.
**Expected approach:** GROUP BY + HAVING.

### Q4: Find customers who have never placed an order.
**Expected approach:** LEFT JOIN + IS NULL or NOT EXISTS.

### Q5: For each department, find the employee with the highest salary.
**Expected approach:** ROW_NUMBER OVER (PARTITION BY department ORDER BY salary DESC).

### Q6: Find the running total of order amounts per customer.
**Expected approach:** SUM() OVER (PARTITION BY customer_id ORDER BY order_date).

### Q7: Find the month-over-month revenue growth percentage.
**Expected approach:** CTE with monthly aggregates + LAG.

### Q8: Delete duplicate rows from the orders table (keep the one with the lowest order_id).
**Expected approach:** CTE with ROW_NUMBER + DELETE WHERE rn > 1.

### Q9: Find employees hired in the last 30 days who are in the 'Engineering' department.
**Expected approach:** WHERE hire_date >= CURRENT_DATE - INTERVAL '30 days' AND department = 'Engineering'.

### Q10: Find the employee hierarchy (CEO at the top, direct reports, etc.) with their level.
**Expected approach:** Recursive CTE starting from employees where manager_id IS NULL.

---

## Solutions

### Q1: Employees who earn more than their manager
```sql
SELECT e.name AS employee, e.salary AS emp_salary,
       m.name AS manager,     m.salary AS mgr_salary
FROM employees e
JOIN employees m ON m.employee_id = e.manager_id
WHERE e.salary > m.salary;
```

### Q2: Second-highest salary
```sql
WITH ranked AS (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT DISTINCT salary FROM ranked WHERE rk = 2 LIMIT 1;
```

### Q3: Departments with more than 5 employees
```sql
SELECT department, COUNT(*) AS cnt
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;
```

### Q4: Customers who have never ordered
```sql
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```

### Q5: Highest salary per department
```sql
WITH ranked AS (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT name, department, salary FROM ranked WHERE rn = 1;
```

### Q6: Running total of order amounts per customer
```sql
SELECT customer_id, order_date, amount,
       SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
ORDER BY customer_id, order_date;
```

### Q7: Month-over-month revenue growth
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

### Q8: Delete duplicate rows (keep lowest order_id)
```sql
WITH ranked AS (
    SELECT order_id,
           ROW_NUMBER() OVER (PARTITION BY customer_id, order_date, amount
                              ORDER BY order_id) AS rn
    FROM orders
)
DELETE FROM orders WHERE order_id IN (SELECT order_id FROM ranked WHERE rn > 1);
```

### Q9: Employees hired in last 30 days in Engineering
```sql
SELECT employee_id, name, hire_date
FROM employees
WHERE department = 'Engineering'
  AND hire_date >= CURRENT_DATE - INTERVAL '30 days';
```

### Q10: Employee hierarchy with level (recursive CTE)
```sql
WITH RECURSIVE hierarchy AS (
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id, h.level + 1
    FROM employees e
    JOIN hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM hierarchy ORDER BY level, name;
```

---

## Score yourself

| Score | Meaning |
|-------|---------|
| 9–10 | Excellent coding |
| 7–8 | Strong, review window functions |
| 5–6 | Solid basics, practice patterns more |
| <5 | Re-read chapters 06–12, redo the mock