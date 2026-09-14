# 40 — SQL Cheat Sheet 🔥

**Priority: 🔥 MUST KNOW** — print this, keep it on your desk.

---

## Query execution order

```
FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

---

## SELECT basics

```sql
SELECT col1, col2 FROM table WHERE col = 'x' ORDER BY col1 LIMIT 10 OFFSET 5;
SELECT DISTINCT col FROM table;
SELECT col FROM table WHERE col LIKE '%pattern%';   -- % = any chars, _ = one char
SELECT col FROM table WHERE col ILIKE '%pattern%';  -- case-insensitive (PG)
```

---

## NULL

```sql
WHERE col IS NULL
WHERE col IS NOT NULL
COALESCE(col, default)          -- first non-NULL
NULLIF(a, b)                    -- NULL if a = b (divide-by-zero safe)
```

---

## Aggregation

```sql
COUNT(*), COUNT(col), COUNT(DISTINCT col)
SUM(col), AVG(col), MIN(col), MAX(col)
GROUP BY col HAVING COUNT(*) > 5
```

---

## JOINs

```sql
A INNER JOIN B ON a.id = b.a_id   -- matches only
A LEFT  JOIN B ON a.id = b.a_id   -- all A + matches
A RIGHT JOIN B ON a.id = b.a_id   -- all B + matches (flip + use LEFT instead)
A FULL  JOIN B ON a.id = b.a_id   -- all from both
A CROSS JOIN B                     -- every pair (A × B)
A JOIN B ON a.id = b.a_id         -- self join: use aliases
```

**LEFT JOIN + WHERE on right table = INNER JOIN** — move condition to ON.

---

## Subqueries

```sql
-- Scalar (returns one value)
WHERE col = (SELECT MAX(col) FROM t)

-- EXISTS (fast existence check)
WHERE EXISTS (SELECT 1 FROM t2 WHERE t2.id = t1.id)

-- NOT IN (⚠️ NULL trap: use NOT EXISTS instead)
WHERE col NOT IN (SELECT col FROM t2)

-- Correlated (references outer query — often rewriteable as JOIN)
WHERE col > (SELECT AVG(col) FROM t2 WHERE t2.group = t1.group)
```

---

## CTEs

```sql
WITH cte AS (
    SELECT ... FROM ...
)
SELECT ... FROM cte JOIN other ON ...;
```

---

## Window functions

```sql
ROW_NUMBER() OVER (PARTITION BY grp ORDER BY val DESC)
RANK()       OVER (PARTITION BY grp ORDER BY val DESC)  -- ties share rank, gaps
DENSE_RANK() OVER (PARTITION BY grp ORDER BY val DESC)  -- ties share rank, no gaps
LAG(col, 1)  OVER (ORDER BY t)
LEAD(col, 1) OVER (ORDER BY t)
SUM(col)     OVER (PARTITION BY grp ORDER BY t ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AVG(col)     OVER (ORDER BY t ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)  -- 7-day moving avg
```

---

## CASE

```sql
CASE WHEN condition THEN 'a'
     WHEN condition THEN 'b'
     ELSE 'c'
END

-- Conditional aggregation
COUNT(*) FILTER (WHERE status = 'done')
SUM(amount) FILTER (WHERE status = 'completed')
```

---

## Date/time (PostgreSQL)

```sql
NOW(), CURRENT_DATE, CURRENT_TIMESTAMP
DATE_TRUNC('month', ts), DATE_TRUNC('day', ts)
EXTRACT(month FROM ts), EXTRACT(dow FROM ts), EXTRACT(isodow FROM ts)
ts + INTERVAL '1 day', ts - INTERVAL '30 days'
AGE(ts), ts1 - ts2
TO_CHAR(ts, 'YYYY-MM-DD')
```

---

## PostgreSQL-specific

```sql
-- UPSERT
INSERT INTO t (id, col) VALUES ($1, $2)
ON CONFLICT (id) DO UPDATE SET col = EXCLUDED.col;

-- DISTINCT ON (PG gem)
SELECT DISTINCT ON (grp) * FROM t ORDER BY grp, ts DESC;

-- FILTER clause
SELECT COUNT(*) FILTER (WHERE x > 5) FROM t;

-- JSONB
WHERE payload @> '{"key":"value"}'
payload->>'key'
CREATE INDEX ON t USING GIN (payload);

-- generate_series
SELECT * FROM generate_series(1, 10);
```

---

## PostgreSQL vs MySQL quick reference

| Feature | PostgreSQL | MySQL |
|---------|-----------|-------|
| UPSERT | `ON CONFLICT DO UPDATE` | `ON DUPLICATE KEY UPDATE` |
| LIMIT | `LIMIT n OFFSET m` | `LIMIT m, n` or `LIMIT n OFFSET m` |
| String concat | `\|\|` | `CONCAT()` |
| Date diff | `ts1 - ts2` → interval | `DATEDIFF(ts1, ts2)` |
| Date format | `TO_CHAR(ts, fmt)` | `DATE_FORMAT(ts, fmt)` |
| Transactional DDL | ✅ | ❌ (auto-commits) |
| NULL in UNIQUE | Multiple NULLs allowed | One NULL allowed |
| RETURNING | ✅ `UPDATE ... RETURNING *` | ❌ |

---

## Index basics

```sql
CREATE INDEX idx ON table (col);
CREATE INDEX idx ON table (col1, col2);             -- composite
CREATE INDEX idx ON table (col) WHERE condition;    -- partial
CREATE INDEX idx ON table USING GIN (jsonb_col);    -- GIN for JSONB
CREATE INDEX idx ON table (col1) INCLUDE (col2);    -- covering
```

---

## Transactions

```sql
BEGIN;
UPDATE ... ;
SAVEPOINT sp1;
ROLLBACK TO sp1;
COMMIT;
```

---

## Common interview patterns

| Pattern | SQL |
|---------|-----|
| Top N per group | `ROW_NUMBER() OVER (PARTITION BY grp ORDER BY val DESC)` then `WHERE rn <= N` |
| Latest record | `ROW_NUMBER() OVER (PARTITION BY id ORDER BY ts DESC)` then `WHERE rn = 1` |
| Dedup | `ROW_NUMBER() OVER (PARTITION BY natural_key ORDER BY id)` then `DELETE WHERE rn > 1` |
| Anti-join | `LEFT JOIN ... WHERE b.id IS NULL` or `NOT EXISTS` |
| Running total | `SUM(col) OVER (ORDER BY t ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` |
| Month-over-month | `LAG(rev) OVER (ORDER BY month)` then `(rev - prev) / prev * 100` |
| Consecutive streak | `day - ROW_NUMBER() * INTERVAL '1 day'` → GROUP BY |
| Missing values | `generate_series(min, max) LEFT JOIN ... WHERE id IS NULL` |
| Conditional count | `COUNT(*) FILTER (WHERE status = 'done')` |
| COALESCE + LEFT JOIN | `COALESCE(b.col, default)` |

---

## Quick memory jogger

1. NULL = NULL → NULL (always IS NULL)
2. LEFT JOIN + WHERE right = INNER (move to ON)
3. NOT IN + NULL → empty (use NOT EXISTS)
4. COUNT(*) ≠ COUNT(col) (NULLs)
5. Window functions keep all rows
6. UPSERT → ON CONFLICT
7. Idempotency → UNIQUE key + ON CONFLICT
8. Pool exhaustion → requests block
9. VACUUM → dead tuple cleanup
10. EXPLAIN → Seq Scan on big table = add index