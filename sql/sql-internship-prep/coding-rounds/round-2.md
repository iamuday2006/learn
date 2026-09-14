# Coding Round 2: Easy/Medium

**10 questions, 25 minutes. Schema from `datasets/ecommerce.sql`.**

---

## Schema

```sql
-- customers: customer_id, email, first_name, last_name, city, country, signup_date, is_active
-- products: product_id, product_name, category_id, price, stock_qty
-- orders: order_id, customer_id (FK), order_date, status, total_amount
-- order_items: order_item_id, order_id (FK), product_id (FK), quantity, unit_price
-- payments: payment_id, order_id (FK), amount, payment_date, method
```

---

## Problems

### P1: Find all orders with status 'delivered', ordered by total_amount descending.
```sql
SELECT * FROM orders WHERE status = 'delivered' ORDER BY total_amount DESC;
```

### P2: Find customers who signed up in 2023.
```sql
SELECT * FROM customers WHERE signup_date >= '2023-01-01' AND signup_date < '2024-01-01';
```

### P3: Find the total revenue from delivered orders.
```sql
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';
```

### P4: Find the number of orders per status.
```sql
SELECT status, COUNT(*) FROM orders GROUP BY status;
```

### P5: Find customers who have placed at least 2 orders.
```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders GROUP BY customer_id HAVING COUNT(*) >= 2;
```

### P6: Find all products with price > 50, ordered by price.
```sql
SELECT * FROM products WHERE price > 50 ORDER BY price;
```

### P7: Find customers who live in 'Dublin'.
```sql
SELECT * FROM customers WHERE city = 'Dublin';
```

### P8: Find the average order total for delivered orders.
```sql
SELECT AVG(total_amount) FROM orders WHERE status = 'delivered';
```

### P9: Find customers who have never placed an order.
```sql
SELECT c.customer_id, c.first_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
```

### P10: Find the total revenue per customer (for customers with orders).
```sql
SELECT customer_id, SUM(total_amount) AS revenue
FROM orders WHERE status = 'delivered'
GROUP BY customer_id
ORDER BY revenue DESC;
```