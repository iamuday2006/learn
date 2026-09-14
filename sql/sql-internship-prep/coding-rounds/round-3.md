# Coding Round 3: Medium

**10 questions, 30 minutes. Schema from `datasets/employee.sql` and `datasets/ecommerce.sql`.**

---

## Problems

### P1: Find the second-highest salary in the employees table.
```sql
WITH ranked AS (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT DISTINCT salary FROM ranked WHERE rk = 2 LIMIT 1;
```

### P2: Find employees who earn more than their department's average salary.
```sql
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_sal FROM employees GROUP BY department_id
)
SELECT e.name, e.salary, e.department_id
FROM employees e
JOIN dept_avg d ON d.department_id = e.department_id
WHERE e.salary > d.avg_sal;
```

### P3: Find the top 3 highest-paid employees per department.
```sql
WITH ranked AS (
    SELECT name, department_id, salary,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT * FROM ranked WHERE rn <= 3;
```

### P4: Find the most recent salary for each employee (salary history).
```sql
WITH ranked AS (
    SELECT employee_id, salary, effective_from,
           ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY effective_from DESC) AS rn
    FROM salaries
)
SELECT employee_id, salary, effective_from FROM ranked WHERE rn = 1;
```

### P5: Find customers with the highest total revenue.
```sql
WITH customer_rev AS (
    SELECT customer_id, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'delivered'
    GROUP BY customer_id
)
SELECT customer_id, revenue
FROM customer_rev
WHERE revenue = (SELECT MAX(revenue) FROM customer_rev);
```

### P6: Find all products that have never been ordered.
```sql
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;
```

### P7: Find the running total of order amounts per customer.
```sql
SELECT customer_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
ORDER BY customer_id, order_date;
```

### P8: Find employees hired in the same month as at least one other employee.
```sql
WITH hired AS (
    SELECT employee_id, name, DATE_TRUNC('month', hire_date)::DATE AS month
    FROM employees
)
SELECT h1.employee_id, h1.name, h1.month
FROM hired h1
JOIN hired h2 ON h1.month = h2.month AND h1.employee_id <> h2.employee_id;
```

### P9: Find orders where the payment amount doesn't match the order total.
```sql
SELECT o.order_id, o.total_amount, p.amount
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.total_amount <> p.amount;
```

### P10: Find customers who have orders in every status ('pending', 'shipped', 'delivered').
```sql
SELECT customer_id
FROM orders
WHERE status IN ('pending', 'shipped', 'delivered')
GROUP BY customer_id
HAVING COUNT(DISTINCT status) = 3;
```