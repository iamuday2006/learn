# 12 — Window Functions 🔥

**Priority: 🔥 MUST KNOW** — the #1 differentiator for Data Engineering interviews.

---

## Concept

A **window function** computes a value across a set of rows *related to the current row*, WITHOUT collapsing rows (unlike GROUP BY). Every row keeps its identity.

```sql
FUNCTION() OVER (
    [PARTITION BY col]      -- window group (like GROUP BY, but no collapse)
    [ORDER BY col]          -- order inside window → enables running, ranking
    [frame clause]          -- which rows within the window (default: to current row when ORDER BY present)
)
```

### Core functions

| Function | What it gives |
|----------|---------------|
| `ROW_NUMBER()` | 1,2,3,… strictly unique per partition |
| `RANK()` | ties share rank, then gap (1,1,3) |
| `DENSE_RANK()` | ties share rank, no gap (1,1,2) |
| `LAG(col, n)` | value n rows *before* current (default n=1) |
| `LEAD(col, n)` | value n rows *after* current |
| `SUM(col) OVER` | running/partitioned total |
| `AVG/MAX/MIN/COUNT OVER` | running/partitioned stats |
| `FIRST_VALUE(col)` / `LAST_VALUE` | first/last in window |

---

## The three family differences — interview golden answer

```sql
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn,
       RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS rk,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS drk
FROM employees;
```
Salaries `100, 100, 90` in dept:
- `ROW_NUMBER`: 1,2,3 (ties broken arbitrarily)
- `RANK`: 1,1,3 (gaps)
- `DENSE_RANK`: 1,1,2 (no gaps)

**Rule of thumb:** `DENSE_RANK` when you want "position in leaderboard" (no gaps), `RANK` when you want "competition rank with counts", `ROW_NUMBER` when you need a unique row id (dedup!).

---

## Simple Example — running total

```sql
SELECT customer_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id
                               ORDER BY order_date) AS running_total
FROM orders
ORDER BY customer_id, order_date;
```
With `ORDER BY` inside `OVER`, the default frame is **ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW** → running total.

---

## SQL Practice — the 15 must-solve problems

Load `datasets/employee.sql`, `datasets/ecommerce.sql`, `datasets/data_engineering.sql`.

**1. Second highest salary**
```sql
SELECT DISTINCT salary AS second_highest
FROM employees
ORDER BY salary DESC
OFFSET 1 LIMIT 1;
```
Window version:
```sql
WITH ranked AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM employees
)
SELECT salary FROM ranked WHERE rk = 2 LIMIT 1;
```

**2. Nth highest salary** — replace `rk = 2` with `rk = N`.

**3. Top 3 employees per department** (chapter 11 example).

**4. Latest order per customer**
```sql
WITH ranked AS (
    SELECT order_id, customer_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
)
SELECT * FROM ranked WHERE rn = 1;
```

**5. Duplicate detection** — count rows per natural key:
```sql
SELECT email, COUNT(*) AS cnt
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

**6. Deduplication** (delete/keep one):
```sql
WITH ranked AS (
    SELECT event_id, user_id, event_name, event_ts,
           ROW_NUMBER() OVER (PARTITION BY user_id, event_name, event_ts
                              ORDER BY event_id) AS rn
    FROM events
)
DELETE FROM events
WHERE event_id IN (SELECT event_id FROM ranked WHERE rn > 1);
```

**7. Running total** — see Simple Example.

**8. Moving average** (3-day):
```sql
SELECT order_date,
       SUM(amount) AS daily,
       AVG(SUM(amount)) OVER (ORDER BY order_date
                              ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_7d
FROM orders_fact
WHERE status = 'completed'
GROUP BY order_date;
```

**9. Previous transaction** — LAG:
```sql
SELECT account_id, txn_date, amount,
       LAG(amount) OVER (PARTITION BY account_id ORDER BY txn_date) AS prev_amount
FROM transactions;
```

**10. Next transaction** — LEAD.

**11. Month-over-month growth** — chapter 09 example.

**12. Ranking** — RANK/DENSE_RANK per partition.

**13. Consecutive records** — LAG combined with row diff (gaps & islands, chapter 18):
```sql
SELECT user_id, event_ts,
       LAG(event_ts) OVER (PARTITION BY user_id ORDER BY event_ts) AS prev_ts,
       event_ts - LAG(event_ts) OVER (PARTITION BY user_id ORDER BY event_ts) AS delta
FROM events;
```

**14. Gaps and islands** — chapter 18 deep-dive.

**15. Customer purchase sequence** — order purchase index + prev product:
```sql
SELECT customer_id, order_ts,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_ts) AS purchase_no,
       LAG(product_id) OVER (PARTITION BY customer_id ORDER BY order_ts) AS prev_product
FROM orders_fact;
```

---

## Interview Question (Level 3)

**Q:** RANK vs DENSE_RANK vs ROW_NUMBER — when would you pick each?

**30-second answer:** ROW_NUMBER gives each row a unique number (useful for dedup, pagination). RANK gives ties the same rank but leaves gaps, useful in leaderboards. DENSE_RANK doesn't leave gaps — for "top N distinct values per group." Then drop the table example above.

---

## Tricky Question (Level 5 — the frame trap)

**Q:** What's wrong with this running total?

```sql
SELECT order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id) AS running_total
FROM orders;
```
**Answer:** Without `ORDER BY` (and without an explicit frame), the window includes ALL rows of the partition — so `running_total` is the *grand total per customer*, not a running total. Running totals REQUIRE an ORDER BY (or explicit frame).

**Follow-up:** What if there are **duplicate order_date** values within a customer? Rank functions will order them non-deterministically; use a tiebreaker column in ORDER BY (e.g., `order_id`) included as a second sort key.

---

## Interview Follow-Up Chain

**Q:** "What are window functions?" — one-liner: row-level functions computing across a related window without grouping.

**Q:** "Window vs aggregate?" — aggregates collapse rows; windows keep all rows.

**Q:** "Performance with millions of rows?" — window functions usually sort the partition once; chained windows can re-sort; frame clauses affect memory.

**Q:** What's `NTILE(4)`? — buckets rows into 4 groups (quartiles).

---

## Real-World Scenario

Data Engineering: cohort analysis — number of users doing a purchase within 7 days of signup:

```sql
WITH first_purchase AS (
    SELECT user_id,
           MIN(event_ts) AS first_purchase_ts
    FROM events
    WHERE event_name = 'purchase'
    GROUP BY user_id
)
SELECT
    CASE WHEN first_purchase_ts - account_created <= INTERVAL '7 days'
         THEN 'converted_7d' ELSE 'slow' END AS bucket,
    COUNT(*)
FROM user_dim u
LEFT JOIN first_purchase fp USING (user_id)
GROUP BY 1;
```
(Alternative: use `FIRST_VALUE` to find first event time per user in one pass.)

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "ROW_NUMBER vs RANK?" / "Running total needs ORDER BY?" / "Frame clause?" / "LAG vs self join?" / "Window vs GROUP BY?"