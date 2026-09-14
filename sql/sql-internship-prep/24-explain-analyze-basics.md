# 24 — EXPLAIN ANALYZE Basics ⭐

**Priority: ⭐ HIGH VALUE** — "walk me through why this is slow" is a real interview segment.

---

## Concept

`EXPLAIN` shows the **execution plan** the optimizer chose (no execution). `EXPLAIN ANALYZE` **executes** the query and reports actual timings and row counts.

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 5;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE customer_id = 5;
```

Level: you should be able to **spot obvious problems** — you don't need to be a performance engineer.

---

## How to read a plan (top-down)

Each node (indented deeper = executed first) reports:

| Element | Meaning | Red flag |
|---------|---------|----------|
| **Seq Scan** | reads the whole table | big table + no index = suspect |
| **Index Scan** | uses an index | fine |
| **Bitmap Heap Scan** | index for many rows | fine |
| **rows=... (actual=...)** | estimated vs actual rows | **big gap = stale statistics** |
| **cost=...** | planner cost units (not seconds) | relative compare |
| **Filter** | applies a WHERE | check selectivity |
| **Join methods** | Nested Loop / Hash Join / Merge Join | see below |
| **Planning Time / Execution Time** | the only real "seconds" | |

---

## Join methods — the 3 to know

| Method | When | Notes |
|--------|------|-------|
| **Nested Loop** | one side tiny (or unique lookups per outer row) | inner index makes it fast |
| **Hash Join** | bigger equi-joins, no index needed | builds hash table on one side |
| **Merge Join** | both sorted on join key | needs sort or pre-sorted (index) |

---

## Simple Example

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, c.email
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date >= '2023-01-01';
```
Good enough interpretation:
- If `orders` is huge and has no index on `order_date` → **Seq Scan on orders** — add `index`.
- If `customer_id` join causes a per-row **index lookup** → Nested Loop is fine.
- `actual rows` way off from `rows` → run `ANALYZE`.

---

## Interview Question (Level 3)

**Q:** Your query is slow. List the first 3 things you check.

**A:**
1. `EXPLAIN ANALYZE` — Seq Scan on a big table? No usable index?
2. Index/filter coverage — is the WHERE column indexed, is the predicate sargable?
3. Statistics — `ANALYZE <table>`; look at estimated vs actual rows.
Then: remove `SELECT *`, reduce rows early, consider a covering index.

---

## Tricky Question (Level 5)

**Q:** Plan says `Seq Scan on orders (cost=0.00..200000.00 rows=5000000)` but actual is fast. What's going on?

**A:** Cost is an *estimate*; execution time is the truth. A Seq Scan isn't automatically bad — for small tables or low-selectivity filters it's normal. Also possible: the query touched few rows anyway (LIMIT) or the planner decided correctly. Don't "optimize" plans without data — optimize the *actual* bottlenecks.

---

## Interview Follow-Up Chain

**Q:** "Why is PostgreSQL ignoring my index?" → recap ch 22 list (selectivity, function-on-column, type mismatch, stale stats).

**Q:** "You see one huge sort — why?" → `ORDER BY` without an index on that column, or `GROUP BY`/`DISTINCT`.

**Q:** "Which would you trust, `Planning Time` or `cost`?" → Neither for production — use `Execution Time` from `EXPLAIN ANALYZE` (and real workload benchmarks).

---

## Real-world scenario

Performance ticket: dashboard query is 4 seconds on `events` (50M rows). You run:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_name, COUNT(*)
FROM events
WHERE event_ts >= NOW() - INTERVAL '7 days'
GROUP BY 1;
```
- You see `Seq Scan ... rows=48M` → the date filter is barely selective.
- Fixes: index `(event_ts)` or better **BRIN index** on time series, or **partition by month/chunk** for time-based data.
- Then the GROUP BY on `event_name` still sorts 48M rows → consider a **pre-aggregated rollup** for the dashboard (ch 31).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Seq vs Index scan?" / "Bytes read?" / "Join methods?" / "Estimate vs actual?" / "Bufreads?"