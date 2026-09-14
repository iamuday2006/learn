# 08 — CASE Expressions 🔥

**Priority: 🔥 MUST KNOW** — CASE enables conditional logic *inside* SQL, which is a daily pattern in analytics and interview questions.

---

## Concept

`CASE` evaluates conditions and returns a value — like an if/else inside a query. Two forms:

```sql
-- Simple CASE: compare one expression to values
CASE status
    WHEN 'placed' THEN 'new'
    WHEN 'delivered' THEN 'done'
    ELSE 'other'
END

-- Searched CASE: arbitrary boolean conditions (more common)
CASE
    WHEN amount > 1000 THEN 'big'
    WHEN amount > 100 THEN 'medium'
    ELSE 'small'
END
```

Notes:
- The first matching WHEN wins (evaluation order matters!).
- If no WHEN matches and no ELSE → NULL.
- Can appear in SELECT, WHERE, ORDER BY, GROUP BY — anywhere an expression is allowed.

---

## Simple Example

```sql
SELECT order_id, total_amount,
       CASE
           WHEN total_amount > 100 THEN 'high_value'
           WHEN total_amount > 30  THEN 'medium'
           ELSE 'low'
       END AS order_tier
FROM orders;
```

---

## Conditional Aggregation — the killer pattern

CASE inside an aggregate lets you compute **multiple metrics in one scan** — extremely common in analytics interviews.

```sql
-- Count by status in a single query without GROUP BY status
SELECT
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
    COUNT(*) FILTER (WHERE status = 'pending')   AS pending,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled
FROM orders;
```
PostgreSQL also supports the `FILTER` clause (cleaner than CASE). `SUM(amount) FILTER (WHERE ...)` works too. In MySQL use `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`.

**Pivot-style report:**
```sql
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_orders,
    SUM(total_amount) FILTER (WHERE status = 'delivered') AS delivered_revenue,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders
FROM orders
GROUP BY 1
ORDER BY 1;
```

---

## SQL Practice

Dataset: `datasets/ecommerce.sql` / `datasets/food_delivery.sql`

1. Label orders: high/medium/low by amount.
2. Order by label (put 'high' first) — CASE in ORDER BY.
3. Revenue by month, delivered vs cancelled, in one query.
4. Flag orders missing a rider (NULL check inside CASE).

```sql
-- CASE in ORDER BY
SELECT order_id, status, total_amount
FROM orders
ORDER BY CASE
             WHEN status = 'delivered' THEN 1
             WHEN status = 'shipped'   THEN 2
             ELSE 3
         END, total_amount DESC;
```

---

## Interview Question (Level 3)

**Q:** Write a query that returns revenue per month AND the revenue from last month as a column.

**Using CASE + window?** Cleaner with LAG (chapter 12). But a common CASE approach:

```sql
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY 1
ORDER BY 1;
```

Then extend with LAG to add previous-month revenue:
```sql
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
FROM (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY 1
) t;
```

---

## Tricky Question (Level 5)

**Q:** What does this return when `age` is out of range or NULL?

```sql
SELECT age,
       CASE WHEN age >= 18 THEN 'adult' ELSE 'minor' END AS bucket
FROM customers;
```
- `age = 25` → adult
- `age = NULL` → `NULL >= 18` is NULL → not TRUE → **minor** (ELSE branch fires because nothing matched TRUE)
- Actually careful: in CASE, a NULL condition is treated as "not matched", so ELSE fires → 'minor'. Interviewers expect you to point out that NULLs wrongly become 'minor'.

**Safer version…** `CASE WHEN age IS NULL THEN 'unknown' WHEN age >= 18 THEN 'adult' ELSE 'minor' END` — explicit NULL first.

---

## Interview Follow-Up Chain

**Q:** "Count how many orders are high vs low value per customer."

```sql
SELECT customer_id,
       COUNT(*) FILTER (WHERE total_amount > 100) AS high_orders,
       COUNT(*) FILTER (WHERE total_amount <= 100) AS low_orders
FROM orders
GROUP BY customer_id;
```

**Q:** Can you use CASE in a JOIN condition?  
**A:** Yes, but it's usually a design smell — better to normalize the field or join on a clean key.

**Q:** CASE vs COALESCE vs NULLIF?  
**A:** COALESCE/NULLIF are specialized shortcuts for NULL handling; CASE is the general conditional.

---

## Real-World Scenario

Analytics: weekly retention buckets — what fraction of orders shipped within 1/3/5+ days:

```sql
SELECT
    CASE
        WHEN delivered_time IS NULL THEN 'not_delivered'
        WHEN (delivered_time - order_time) <= INTERVAL '1 day' THEN 'within_1d'
        WHEN (delivered_time - order_time) <= INTERVAL '3 days' THEN 'within_3d'
        ELSE 'over_3d'
    END AS delivery_speed,
    COUNT(*) AS orders
FROM orders
GROUP BY 1;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Simple vs searched CASE?" / "CASE with NULL?" / "Conditional aggregation?" / "FILTER vs CASE?"