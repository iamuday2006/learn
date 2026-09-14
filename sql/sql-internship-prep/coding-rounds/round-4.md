# Coding Round 4: Medium/Hard

**10 questions, 35 minutes. Schema from `datasets/data_engineering.sql` and `datasets/ecommerce.sql`.**

---

## Problems

### P1: Find customers who ordered at least 3 different products.
```sql
SELECT customer_id, COUNT(DISTINCT product_id) AS distinct_products
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
GROUP BY customer_id
HAVING COUNT(DISTINCT product_id) >= 3;
```

### P2: Find the month-over-month revenue growth.
```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(total_amount) AS revenue
    FROM orders WHERE status = 'delivered'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS pct
FROM monthly ORDER BY 1;
```

### P3: Find duplicate event records (using data_engineering.sql events table).
```sql
SELECT user_id, event_name, event_ts, COUNT(*) AS cnt
FROM events
GROUP BY user_id, event_name, event_ts
HAVING COUNT(*) > 1;
```

### P4: Find daily active users for the last 7 days.
```sql
SELECT DATE_TRUNC('day', event_ts)::DATE AS day,
       COUNT(DISTINCT user_id) AS dau
FROM events
WHERE event_ts >= NOW() - INTERVAL '7 days'
  AND event_name = 'page_view'
GROUP BY 1 ORDER BY 1;
```

### P5: Find users who have an order but no payment record.
```sql
SELECT o.customer_id, o.order_id
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL;
```

### P6: Find the longest gap (in days) between consecutive orders per customer.
```sql
WITH ordered AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id,
       MAX(order_date - prev_date) AS max_gap
FROM ordered
WHERE prev_date IS NOT NULL
GROUP BY customer_id;
```

### P7: Find orders where the total amount doesn't match the sum of order_items.
```sql
SELECT o.order_id, o.total_amount, SUM(oi.quantity * oi.unit_price) AS item_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(oi.quantity * oi.unit_price);
```

### P8: Find the first product each customer ever purchased.
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

### P9: Find the top 5 customers by revenue per country.
```sql
WITH cust_rev AS (
    SELECT c.country, c.customer_id, SUM(o.total_amount) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'delivered'
    GROUP BY c.country, c.customer_id
),
ranked AS (
    SELECT country, customer_id, revenue,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY revenue DESC) AS rn
    FROM cust_rev
)
SELECT * FROM ranked WHERE rn <= 5;
```

### P10: Find customers who have ordered every product in the 'Electronics' category.
```sql
-- Products in Electronics (category_id = 1)
-- Customers who ordered ALL of them
SELECT o.customer_id
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE p.category_id = 1
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.product_id) = (SELECT COUNT(*) FROM products WHERE category_id = 1);
```