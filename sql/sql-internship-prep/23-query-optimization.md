# 23 — Query Optimization ⭐

**Priority: ⭐ HIGH VALUE** — the standard "can you optimize this?" interview ladder.

---

## Concept

Optimization = make the query **cheaper for the planner**: fewer rows early, fewer bytes moved, better join order, indexes used. The interview expects:

1. Filter **early** (WHERE before JOIN when possible — the planner usually does this for you, but you should say it).
2. **Project only needed columns** (no `SELECT *`).
3. Add **indexes** on filter/join/order columns.
4. Prefer **set-based** operations over correlated subqueries / row-by-row.
5. Use **EXISTS** instead of `COUNT(*)`/IN for existence.
6. Avoid **functions on columns** in WHERE (breaks index usage).
7. **Analyze** to refresh statistics.

---

## The classic optimization ladder

**Q:** Write: "customers with more than 3 completed orders."

**Slow-ish naive version:**
```sql
SELECT c.customer_id
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id
HAVING COUNT(*) > 3;
```
Fine! But could be improved. If we only *need* matching customers, EXISTS avoids materializing all orders:

```sql
SELECT c.customer_id
FROM customers c
WHERE (SELECT COUNT(*) FROM orders o
       WHERE o.customer_id = c.customer_id AND o.status = 'completed') > 3;
```
Correlated, heavy. Better: aggregate orders once:

```sql
SELECT customer_id
FROM orders
WHERE status = 'completed'
GROUP BY customer_id
HAVING COUNT(*) > 3;
```
(No join needed at all if only customer_id is required!)

---

## Optimization techniques summary

| Technique | Why it helps |
|-----------|--------------|
| Early filtering (WHERE before join) | fewer intermediate rows |
| Column projection (NOT `SELECT *`) | less I/O, smaller memory |
| Indexes on WHERE/JOIN/ORDER BY | avoid seq scans + sorts |
| EXISTS over COUNT/IN | short-circuits |
| Aggregate-before-join | fewer join replications |
| Avoid `WHERE func(col) = x` | keep index usable (index on expression instead) |
| `LIMIT` where possible | stops early |
| Partitioning / `BRIN` (bonus) | time-based queries on huge tables |
| `ANALYZE` | fresh statistics → better plans |

---

## Simple Example

```sql
-- before (ignores index on order_date)
SELECT * FROM orders WHERE EXTRACT(month FROM order_date) = 11;
-- after (sargable — index-usable)
SELECT * FROM orders WHERE order_date >= '2023-11-01' AND order_date < '2023-12-01';
```
**Sargable** = Search ARGument ABLE: the predicate matches the column shape so an index can be used.

---

## Interview Question (Level 3)

**Q:** Why is `WHERE lower(email) = 'x'` slow on a big table, and how do you fix it?

**A:** The function prevents normal index use (non-sargable). Fix options:
1. Expression index: `CREATE INDEX ON users (lower(email));`
2. Normalize data to lowercase before insert.
3. Use `ILIKE` carefully (with `pg_trgm`) if it's a prefix-match search.

---

## Tricky Question (Level 5)

**Q:** This query is slow on a 100M-row table. What do you check first?

```sql
SELECT * FROM events WHERE user_id = 42;
```
**Answer (in order):**
1. `EXPLAIN` → is it Seq Scan? (story time: check `SELECT *` — if lots of columns, index-covered scans become heap fetches).
2. Is there an index on `user_id`?
3. Percent of rows returned?  If `user_id = 42` maps to 50M rows, optimizer (correctly) does a seq scan.
4. Fresh statistics (`idle in analyze`).
5. If *all* needed columns fit the index → covering index (`INCLUDE`).

---

## Interview Follow-Up Chain

**Q:** "How would this work with millions of rows?" (the ultimate interviewer follow-up)
**A:** Say: "I'd first confirm the plan uses the index, keep the scan small with early filters + LIMIT, consider partition by month if date-filtered, and add a covering index for the exact column set."

**Q:** "Index vs statistics?"  
**A:** The index enables cheap access; the *statistics* (from ANALYZE) let the planner decide to use it. Stale stats → seq scans.

**Q:** "Can you rewrite this slow correlated subquery?"  
**A:** Replace with JOIN + aggregation (ch 07 example).

---

## Real-world scenario

The BI team complains the monthly revenue dashboard is slow:

```sql
SELECT DATE_TRUNC('month', order_ts)::DATE AS month, c.country,
       SUM(o.amount) AS revenue
FROM orders_fact o
JOIN user_dim c ON c.user_id = o.user_id
WHERE o.status = 'completed'
  AND o.order_ts >= '2023-01-01'
GROUP BY 1, 2;
```
Optimization answers: index `(order_ts, status)` and `(user_id)`; filtered join; consider **materialized view** precomputing monthly revenue; or a **summary table** updated incrementally (ch 31).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Early filtering?" / "Sargable predicates?" / "Index choices?" / "EXISTS vs COUNT?" / "Materialized views?"