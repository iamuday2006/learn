# 19 — Real-World SQL Patterns 🔥

**Priority: 🔥 MUST KNOW** — a pattern cookbook. Each pattern = recognize → technique → example → mistake → variation (chapters 14–18 go deep; here it's the overview and the "extra" patterns).

---

## 1. Top N per group (deep: ch 15)

`ROW_NUMBER() OVER (PARTITION BY group ORDER BY value DESC)` then `WHERE rn <= N`.

## 2. Latest row per customer (deep: ch 16)

`ROW_NUMBER() OVER (PARTITION BY id ORDER BY ts DESC)` then `WHERE rn = 1`.

## 3. Duplicate records / remove duplicates (deep: ch 14)

`GROUP BY natural_key HAVING COUNT(*) > 1` → `ROW_NUMBER` → delete rn > 1.

## 4. Second / Nth highest (deep: ch 15)

`SELECT DISTINCT ... ORDER BY DESC OFFSET n-1 LIMIT 1` or `DENSE_RANK`.

## 5. Running total / moving average (deep: ch 17)

`SUM/AVG OVER (ORDER BY t ROWS BETWEEN .. AND CURRENT ROW)`.

## 6. Previous / next row (deep: ch 17, 14)

`LAG(col)` / `LEAD(col)` — see also self-join alternative.

## 7. Gaps and islands (deep: ch 18)

`X - ROW_NUMBER()` grouping; `generate_series` for missing.

## 8. Missing records

"Customers who never ordered", "dates with zero revenue". Use `LEFT JOIN ... IS NULL`, `NOT EXISTS`, `generate_series` + LEFT JOIN.

## 9. Self join (deep: ch 06)

Hierarchies (`manager_id`), row-to-row distances (e.g., pairs of products bought together).

## 10. Anti join

Rows in A with no match in B: `LEFT JOIN ... WHERE b.id IS NULL` or `NOT EXISTS`. Fast to say: "an anti join is a left join filtered to unmatched rows."

## 11. Conditional aggregation (deep: ch 08)

`COUNT(*) FILTER (WHERE status='x')` or `SUM(CASE WHEN ... )`.

## 12. Retention (deep: ch 31)

Users active in month 0 also active in month N — self-join of activity months or window LAG of months.

## 13. Time-series analysis (deep: ch 17)

Running totals, moving averages, MoM/WoW change, seasonality via `EXTRACT(dow)`.

## 14. Cohort analysis (deep: ch 31)

Group by acquisition month (signup), compute per-cohort retained fraction per month.

---

## Extra high-value patterns

### PIVOT-style counts per column (conditional agg)

```sql
SELECT department,
       COUNT(*) FILTER (WHERE status = 'active') AS active_cnt,
       COUNT(*) FILTER (WHERE status = 'left')   AS left_cnt
FROM employees GROUP BY department;
```

### "Change from previous row" (LAG + percent change)

```sql
WITH days AS (
    SELECT DATE_TRUNC('day', order_ts)::DATE AS day, SUM(amount) AS rev
    FROM orders_fact WHERE status='completed' GROUP BY 1
)
SELECT day, rev,
       rev - LAG(rev) OVER (ORDER BY day)                AS delta,
       ROUND(100.0 * rev / NULLIF(LAG(rev) OVER (ORDER BY day),0) - 100, 1) AS pct
FROM days;
```

### "First occurrence" (FIRST_VALUE / MIN)

```sql
SELECT customer_id,
       ARRAY_AGG(product_id ORDER BY order_ts) AS purchase_order
FROM orders_fact GROUP BY customer_id;
```

### "Consecutive decrease check" — flag drops

```sql
SELECT day, rev,
       CASE WHEN rev < LAG(rev) OVER (ORDER BY day) THEN 'down' ELSE 'up' END AS trend
FROM days;
```

---

## How to recognize a pattern under pressure

1. "**per X / for each X**" → PARTITION BY or GROUP BY X.
2. "**most recent / latest**" → ROW_NUMBER partition by id order by ts desc.
3. "**top N of X**" → window rank over partition.
4. "**difference vs previous**" → LAG.
5. "**consecutive / streak / range**" → gaps-and-islands.
6. "**count by category side by side**" → conditional aggregation.
7. "**missing / who hasn't**" → anti join (LEFT JOIN IS NULL / NOT EXISTS).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** Point to the pattern in the previous chapter and drill the "variations" lists.