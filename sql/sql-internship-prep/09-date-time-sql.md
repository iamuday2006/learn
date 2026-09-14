# 09 — Date and Time in SQL ⭐

**Priority: ⭐ HIGH VALUE** — every analytics/Empire Data Engineering question involves dates.

---

## Concept

Dates are the most error-prone area in interview SQL. In PostgreSQL, understand the types first:

| Type | Stores | `NOW()` behavior |
|------|--------|------------------|
| `TIMESTAMP` | date + time, no zone | assumes session timezone |
| `TIMESTAMPTZ` | date + time, **with** zone for display | proper UTC storage |
| `DATE` | date only | |
| `TIME` | time only | |
| `INTERVAL` | a span of time | used in arithmetic |

Key functions:

| Function | Returns |
|----------|---------|
| `NOW()` / `CURRENT_TIMESTAMP` | current timestamp (tz-aware) |
| `CURRENT_DATE` | today's date |
| `CURRENT_TIME` | current time |
| `DATE_TRUNC('month', ts)` | truncated timestamp (month/day/hour…) |
| `EXTRACT(month FROM ts)` | a part (year/month/day/hour/dow…) |
| `AGE(ts)` | interval since date/time |
| `ts1 - ts2` | interval difference |
| `ts + INTERVAL '1 day'` | add/subtract an interval |
| `TO_CHAR(ts, 'YYYY-MM-DD')` | format to text |
| `::date` / `::timestamp` | cast |

**dow note:** `EXTRACT(dow FROM ts)` returns 0=Sunday…6=Saturday. `ISODOW` returns 1=Monday…7=Sunday.

---

## Simple Example

```sql
-- Orders from the last 90 days
SELECT * FROM orders
WHERE order_date >= NOW() - INTERVAL '90 days';

-- Orders per month
SELECT DATE_TRUNC('month', order_date)::DATE AS month, COUNT(*)
FROM orders
GROUP BY 1
ORDER BY 1;
```

---

## Interview Question (Level 3)

**Q:** Calculate each order's delivery time in hours and flag orders that took > 2 hours.

```sql
SELECT order_id,
       delivered_time - order_time                          AS delivery_interval,
       EXTRACT(EPOCH FROM (delivered_time - order_time))/3600 AS hours,
       CASE WHEN (delivered_time - order_time) > INTERVAL '120 minutes'
            THEN 'slow' ELSE 'on_time' END                   AS flag
FROM orders
WHERE delivered_time IS NOT NULL;
```
(see `datasets/food_delivery.sql` for `delivered_time`.)

---

## Tricky Question (Level 5)

**Q:** `NOW()::date` vs `CURRENT_DATE` vs `DATE(NOW())`?

- All return today's date; prefer `CURRENT_DATE`.
- **Bigger trap:** comparing `DATE` column to `TIMESTAMPTZ` — a `DATE >= '2023-01-01'` comparison may silently treat the date as midnight in the session timezone, causing timezone-related off-by-one errors. In PG, comparing `timestamptz` with a date casts the date to timestamptz at midnight in the session TZ.

**Follow-up:** what does `DATE_TRUNC('week', ts)` return on Sunday vs Monday? (week starts Monday in PG).

---

## Interview Follow-Up Chain

**Q:** Find the daily active users for the last 7 days.

```sql
SELECT DATE_TRUNC('day', event_ts)::DATE AS day,
       COUNT(DISTINCT user_id)            AS dau
FROM events
WHERE event_ts >= NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Q:** What if timestamps arrive in different timezones?  
**A:** Store `TIMESTAMPTZ` and always record event times in UTC; let display handle conversions. Mixing naive/local timestamps is how retention metrics drift by an hour.

**Q:** "month-over-month revenue change" — the pattern: group by month, then use LAG (chapter 12).

```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) /
             NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS mom_pct
FROM monthly
ORDER BY month;
```

---

## Real-World Scenario

Analytics: hourly order volume to find peak hours:

```sql
SELECT EXTRACT(hour FROM order_time) AS hour_of_day,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;
```

And weekly seasonality:
```sql
SELECT EXTRACT(isodow FROM order_time) AS weekday,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;
```

---

## MySQL differences (interviews compare)

| PostgreSQL | MySQL |
|------------|-------|
| `DATE_TRUNC('month', ts)` | `DATE_FORMAT(ts, '%Y-%m-01')` or `LAST_DAY()` tricks |
| `EXTRACT(month FROM ts)` | `MONTH(ts)`, `YEAR(ts)` |
| `ts + INTERVAL '1 day'` | `DATE_ADD(ts, INTERVAL 1 DAY)` |
| `NOW()` | `NOW()` |
| `CURRENT_DATE` | `CURDATE()` |
| difference → INTERVAL | `DATEDIFF(ts1, ts2)` (days) |
| `AGE()` | `TIMESTAMPDIFF(...)` |

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "TIMESTAMP vs TIMESTAMPTZ?" / "Group by month?" / "Date arithmetic?" / "Timezone pitfalls?" / "EXTRACT(DOW)?"