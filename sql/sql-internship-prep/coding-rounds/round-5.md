# Coding Round 5: Hard

**10 questions, 45 minutes. Schema from `datasets/data_engineering.sql`, `datasets/ecommerce.sql`, `datasets/employee.sql`.**

---

## Problems

### P1: Find the percentage of total revenue each customer contributes.
```sql
WITH cust_rev AS (
    SELECT customer_id, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'delivered'
    GROUP BY customer_id
)
SELECT customer_id, revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM cust_rev ORDER BY revenue DESC;
```

### P2: Find consecutive days where the same customer placed an order.
```sql
WITH customer_days AS (
    SELECT DISTINCT customer_id, order_date::date AS day
    FROM orders
),
numbered AS (
    SELECT customer_id, day,
           day - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY day) * INTERVAL '1 day' AS grp
    FROM customer_days
)
SELECT customer_id, MIN(day) AS streak_start, MAX(day) AS streak_end, COUNT(*) AS days
FROM numbered
GROUP BY customer_id, grp
HAVING COUNT(*) >= 2
ORDER BY customer_id;
```

### P3: Find the cumulative percentage of customers by signup date.
```sql
WITH cumulative AS (
    SELECT signup_date::date AS day,
           COUNT(*) AS new_customers,
           SUM(COUNT(*)) OVER (ORDER BY signup_date::date) AS cumulative
    FROM customers
    GROUP BY 1
)
SELECT day, new_customers, cumulative,
       ROUND(100.0 * cumulative / (SELECT COUNT(*) FROM customers), 1) AS pct
FROM cumulative ORDER BY 1;
```

### P4: Find the month with the highest number of new users (from data_engineering.sql).
```sql
SELECT DATE_TRUNC('month', account_created)::DATE AS month,
       COUNT(*) AS new_users
FROM user_dim
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

### P5: Find the average time between consecutive orders per customer.
```sql
WITH ordered AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id,
       AVG(order_date - prev_date) AS avg_interval
FROM ordered
WHERE prev_date IS NOT NULL
GROUP BY customer_id;
```

### P6: Find customers who have purchased from at least 3 different categories.
```sql
SELECT o.customer_id, COUNT(DISTINCT p.category_id) AS categories
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category_id) >= 3;
```

### P7: Find the top 3 products by revenue in each category.
```sql
WITH prod_rev AS (
    SELECT p.category_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
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

### P8: Find the retention rate: users active in month 0 who are also active in month 1.
```sql
WITH cohort AS (
    SELECT user_id,
           DATE_TRUNC('month', account_created)::DATE AS cohort_month
    FROM user_dim
),
active AS (
    SELECT DISTINCT user_id,
           DATE_TRUNC('month', event_ts)::DATE AS active_month
    FROM events
)
SELECT c.cohort_month,
       COUNT(DISTINCT c.user_id) AS cohort_size,
       COUNT(DISTINCT CASE WHEN a.active_month = c.cohort_month THEN c.user_id END) AS month_0,
       COUNT(DISTINCT CASE WHEN a.active_month = c.cohort_month + INTERVAL '1 month' THEN c.user_id END) AS month_1
FROM cohort c
LEFT JOIN active a ON a.user_id = c.user_id
GROUP BY c.cohort_month
ORDER BY 1;
```

### P9: Find the second-most-popular product by order count.
```sql
WITH counts AS (
    SELECT product_name, COUNT(*) AS cnt
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY product_name
),
ranked AS (
    SELECT product_name, cnt,
           DENSE_RANK() OVER (ORDER BY cnt DESC) AS rk
    FROM counts
)
SELECT product_name, cnt FROM ranked WHERE rk = 2;
```

### P10: Find the country with the highest average revenue per customer.
```sql
WITH country_rev AS (
    SELECT c.country,
           SUM(o.total_amount) / COUNT(DISTINCT o.customer_id) AS avg_rev_per_cust
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.country
)
SELECT country, avg_rev_per_cust
FROM country_rev
ORDER BY avg_rev_per_cust DESC
LIMIT 1;
```