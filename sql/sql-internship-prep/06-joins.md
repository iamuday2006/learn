# 06 — Joins 🔥

**Priority: 🔥 MUST KNOW** — the single most-tested SQL topic. Master every join, the NULL behavior, and the traps.

---

## Concept

A JOIN combines rows from two tables based on a condition (usually FK = PK). Conceptually: for each row in table A, try to match rows in table B.

Types:

| Join | Returns | NULLs | Duplicates |
|------|---------|-------|------------|
| **INNER JOIN** | Only matched rows | Never introduces NULLs | Can multiply |
| **LEFT JOIN** | All A + matched B | Unmatched B columns become NULL | Can multiply |
| **RIGHT JOIN** | Matched A + all B | Unmatched A columns become NULL | Can multiply |
| **FULL OUTER JOIN** | All rows from both | NULLs on the unmatched side | Can multiply |
| **CROSS JOIN** | A × B (every pair) | n/a | Always multiplies |
| **SELF JOIN** | A joined to itself | depends | depends |

The **"Why?"** is always the same: relational data lives in separate tables; joins reconstruct the full picture.

---

## Simple Example (3 tables, e-commerce)

```sql
SELECT o.order_id,
       c.first_name AS customer,
       p.product_name
FROM   orders o
JOIN   customers c ON c.customer_id = o.customer_id
JOIN   order_items oi ON oi.order_id = o.order_id
JOIN   products p    ON p.product_id = oi.product_id;
```

`JOIN` = `INNER JOIN`.

---

## 1. INNER JOIN — only matches

```sql
SELECT c.customer_id, o.order_id
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id;
```
Customers with **no orders** disappear.

## 2. LEFT JOIN — keep everything from left

```sql
SELECT c.customer_id, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id;
```
Customers with no orders still appear, with `o.order_id IS NULL`.

**Classic trap question — Why can a LEFT JOIN accidentally become an INNER JOIN?**

```sql
SELECT c.customer_id, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'delivered';   -- ← BUG!
```
The `WHERE` on the **right-side table** filters out the NULL rows created by the LEFT JOIN, silently converting it to an INNER JOIN.

**Correct fix — move the condition into the ON clause:**
```sql
SELECT c.customer_id, o.order_id
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id
      AND o.status = 'delivered';
```
Now unmatched customers still appear (with NULLs).

**Rule:** conditions on the **outer (preserved) table** can go in WHERE; conditions on the **matched (right) table** that must not drop the outer rows belong in ON.

## 3. RIGHT JOIN

```sql
SELECT o.order_id, c.customer_id
FROM customers c
RIGHT JOIN orders o ON o.customer_id = c.customer_id;
```
Rarely used — flip the tables and use LEFT JOIN for readability.

## 4. FULL OUTER JOIN

```sql
SELECT c.customer_id, o.order_id
FROM customers c
FULL OUTER JOIN orders o ON o.customer_id = c.customer_id;
```
Useful for **comparing two lists** — e.g., customers vs. a CRM export, find matching and non-matching on both sides.

## 5. CROSS JOIN

```sql
SELECT s.name, r.name
FROM students s CROSS JOIN rooms r;   -- every student × every room
```
Careful: A × B. On big tables this explodes (million × million). Used for generating combinations (dates × cities).

## 6. SELF JOIN (managers!)

```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;
```
`LEFT` keeps the CEO with a NULL manager. Self joins power **hierarchies** and row-to-row comparisons (previous/next record — see chapter 17).

---

## Interview Question (Level 3 — the classics)

**Q:** Customers who have never ordered — with JOIN and with NOT EXISTS.

```sql
-- LEFT JOIN approach
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- NOT EXISTS approach (usually cleaner/faster)
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o
                  WHERE o.customer_id = c.customer_id);
```

**Q:** Join vs EXISTS vs subquery — which is better?  
**A:** It depends. `EXISTS` stops at the first match and is usually best for existence checks; joins can **multiply rows** if the right side has duplicates. Correlated subqueries in SELECT can recompute per row. In PostgreSQL, rewrite correlated subqueries as joins/EXISTS when you notice repeated scans.

---

## Tricky Question (Level 5 — internship killer)

**Q:** Why does this JOIN return MORE rows than expected?

Orders (2 rows, customer "Gemma") and order_items for each order:

```sql
SELECT o.order_id, p.product_name
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p    ON p.product_id = oi.product_id;
```
If an order has **2 items**, the order row appears **twice** (once per item). That's not a bug — it's the multiplication. This is why counting `COUNT(DISTINCT o.order_id)` matters after joins, and why you should aggregate before joining when possible.

---

## Interview Follow-Up Chain

**Q:** "Find customers with an order in the last 30 days." — JOIN, EXISTS, or IN?

**Best:** EXISTS (or a join with DISTINCT). IN with a huge list is fine too.

```sql
SELECT c.customer_id
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= NOW() - INTERVAL '30 days'
);
```

**Q:** What's the difference between `IN` and `EXISTS`?  
**A:** `IN` materializes a list and can't optimize early-exit as reliably; `EXISTS` short-circuits on first match. Also `IN` (list) has the NULL trap (next chapter).

---

## Real-World Scenario

Report: **monthly revenue by country**, preserving all countries even with no sales that month — but months with no data need a calendar table:

```sql
SELECT cal.month, c.country, COALESCE(SUM(o.total_amount), 0) AS revenue
FROM   generate_series('2023-01-01'::date, '2023-12-01'::date, interval '1 month') AS cal(month)
CROSS JOIN (SELECT DISTINCT country FROM customers) c
LEFT JOIN orders o
       ON DATE_TRUNC('month', o.order_date) = cal.month
      AND o.customer_id IN (SELECT customer_id FROM customers cu WHERE cu.country = c.country)
GROUP BY cal.month, c.country
ORDER BY cal.month, c.country;
```

Key insight: **CROSS JOIN the dimensions (dates × countries), then LEFT JOIN the facts** — the outer-join trap prevention in reverse.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "LEFT JOIN vs INNER JOIN?" / "Why does a LEFT JOIN become INNER?" / "Join vs EXISTS?" / "Duplicate rows from join?" / "Self join for hierarchy?"