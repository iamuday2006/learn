# 17 — Running Total and Moving Average ⭐

**Priority: ⭐ HIGH VALUE** — classic time-series question for Data Engineering.

---

## How to recognize it

"Running / cumulative / rolling total", "moving average", "percentage of cumulative", "window till current row".

---

## Recommended SQL technique

Windows over an ordered partition with an **explicit frame**:

```sql
SUM(x)        OVER (PARTITION BY g ORDER BY t
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  -- running total
AVG(x)        OVER (ORDER BY t ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)   -- 3-point moving avg
SUM(x)        OVER (ORDER BY t ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)   -- 7-day rolling revenue
RANGE vs ROWS -- ROWS counts physical rows; RANGE uses the ORDER BY value (handles ties)
```

Default frame when `ORDER BY` present = `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, which for ties **includes all peer rows** — a subtle trap.

---

## Example — running total of order amount per customer

```sql
SELECT customer_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id
                               ORDER BY order_date
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
ORDER BY customer_id, order_date;
```

Result (conceptually):
```
cust  date        amount   running
1     2023-10-01  29.99    29.99
1     2023-11-05  139.98   169.97
1     2023-12-01  39.99    209.96
```

---

## Moving average (7-day revenue)

```sql
SELECT DATE_TRUNC('day', order_ts)::DATE AS day,
       SUM(amount) AS revenue,
       AVG(SUM(amount)) OVER (ORDER BY DATE_TRUNC('day', order_ts)::DATE
                              ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS revenue_7d_avg
FROM orders_fact
WHERE status = 'completed'
GROUP BY 1
ORDER BY 1;
```
Note: window functions can wrap aggregates — you group first, then window over the grouped result.

---

## Cumulative percentage — "cumulative revenue share"

```sql
WITH daily AS (
    SELECT DATE_TRUNC('day', order_ts)::DATE AS day,
           SUM(amount) AS revenue
    FROM orders_fact WHERE status = 'completed'
    GROUP BY 1
)
SELECT day, revenue,
       SUM(revenue) OVER (ORDER BY day) AS running_revenue,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY day) /
             SUM(revenue) OVER (), 2) AS pct_of_total
FROM daily
ORDER BY day;
```
`SUM(...) OVER ()` with empty parentheses = **grand total** (whole partition).

---

## Common mistake

- **Missing ORDER BY** → every row gets the whole-partition sum (no running).
- **Missing frame** + duplicate dates → `RANGE` default pulls in tied rows, double-counting.
- Running total across disjoint groups without `PARTITION BY` → cross-group accumulation.
- `ROWS` vs `RANGE` confusion with ties and sparse calendars (see below).

---

## Interview variations

1. **Running total per user** — add PARTITION BY.
2. **Moving 30-day average** — change frame.
3. **Cumulative count of signups** — `COUNT(*) OVER (ORDER BY signup_date)`.
4. **Running distinct count** didn't exist for a long time — PG 9.6. talk about approximation (HyperLogLog) as bonus.
5. **Sparse calendar note:** if a day has no data, gaps mean `ROWS 6 PRECEDING` counts "6 previous *rows*", not "previous 6 *calendar days*". For calendar-correct rolling windows, use `generate_series` to fill the calendar, or `RANGE` on a dense column.

---

## Real-world scenario

Alerting: today's revenue vs the previous 7-day average — "big dip today?"

```sql
WITH daily AS (
    SELECT DATE_TRUNC('day', order_ts)::DATE AS day,
           SUM(amount) AS revenue
    FROM orders_fact WHERE status = 'completed'
    GROUP BY 1
),
with_window AS (
    SELECT day, revenue,
           AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS prev_7d_avg
    FROM daily
)
SELECT day, revenue,
       ROUND(100.0 * revenue / NULLIF(prev_7d_avg, 0) - 100, 1) AS change_vs_7d_pct
FROM with_window
ORDER BY day;
```

`BETWEEN 7 PRECEDING AND 1 PRECEDING` = previous 7 days, **excluding today** — a nice frame-control flex for interviews.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Running total needs ORDER BY?" / "ROWS vs RANGE?" / "Fill sparse dates?" / "Moving vs cumulative?"