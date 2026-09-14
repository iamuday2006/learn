# 39 — Final Revision 🔥

**Priority: 🔥 MUST KNOW** — read this the day before, the hour before, and the 10 minutes before your interview.

---

## 1-Day Before Interview

Focus on **recognition and recall** — do NOT learn new material.

### MUST KNOW (you should be able to explain these instantly)

| Topic | Key points |
|-------|-----------|
| SELECT order | FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT |
| NULL behavior | NULL = NULL is NULL, NOT IN trap, IS NULL vs = NULL |
| JOIN types | INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF; LEFT JOIN becoming INNER |
| GROUP BY + HAVING | WHERE filters rows, HAVING filters groups |
| Aggregate functions | COUNT(*), COUNT(col), COUNT(DISTINCT col), SUM, AVG, MIN, MAX |
| Subqueries | Scalar, correlated, non-correlated; EXISTS vs IN vs NOT IN |
| CTEs | WITH cte AS (...), recursive CTEs, multiple CTEs |
| Window functions | ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM() OVER, PARTITION BY |
| Interview patterns | Top-N per group, latest record, dedup, gaps & islands, running total |
| ACID | Atomicity, Consistency, Isolation, Durability |
| Indexes | B-tree, composite, partial, expression; why not index every column |
| PostgreSQL features | JSONB, ARRAY, IDENTITY, TIMESTAMPTZ, UPSERT, transactional DDL |
| Idempotency | ON CONFLICT DO NOTHING/UPDATE; idempotency key + UNIQUE |

### HIGH VALUE (should know these well)

| Topic | Key points |
|-------|-----------|
| PostgreSQL vs MySQL | Transactional DDL, JSONB vs JSON, UPSERT syntax, NULL in UNIQUE |
| Connection pooling | Why expensive; PgBouncer; max_connections |
| Pagination | OFFSET (simple) vs keyset (efficient) |
| EXPLAIN ANALYZE | Seq Scan → add index; stale stats → ANALYZE |
| Transactions | BEGIN/COMMIT/ROLLBACK; crash behavior; SAVEPOINT |
| Isolation levels | READ COMMITTED (default), REPEATABLE READ, SERIALIZABLE |

### Quick self-test

Say out loud:
1. "Logical query execution order" — list all 7 steps.
2. "LEFT JOIN WHERE right_col = X" — what happens to NULLs?
3. "ROW_NUMBER vs RANK vs DENSE_RANK" — one sentence each.
4. "NOT IN with NULLs" — why it's dangerous.
5. "ON CONFLICT DO UPDATE" — syntax.

---

## 1-Hour Before Interview

Skim these **cheat sheet patterns**:

```sql
-- Top N per group
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY grp ORDER BY val DESC) AS rn
    FROM t
) SELECT * FROM ranked WHERE rn <= N;

-- Anti-join
SELECT * FROM a WHERE NOT EXISTS (SELECT 1 FROM b WHERE b.id = a.id);

-- Running total
SELECT SUM(x) OVER (ORDER BY t ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM t;

-- Dedup
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY key ORDER BY ts DESC) AS rn
    FROM t
) DELETE FROM t WHERE ctid IN (SELECT ctid FROM ranked WHERE rn > 1);

-- Upsert
INSERT INTO t (id, col) VALUES ($1, $2)
ON CONFLICT (id) DO UPDATE SET col = EXCLUDED.col;

-- Missing values
SELECT g.n FROM generate_series(1, 100) g(n)
LEFT JOIN t ON t.id = g.n WHERE t.id IS NULL;

-- Daily active users
SELECT DATE_TRUNC('day', event_ts)::DATE, COUNT(DISTINCT user_id)
FROM events GROUP BY 1 ORDER BY 1;

-- Month-over-month growth
WITH m AS (
    SELECT DATE_TRUNC('month', ts)::DATE AS month, SUM(amount) AS rev
    FROM orders GROUP BY 1
)
SELECT month, rev,
       LAG(rev) OVER (ORDER BY month) AS prev,
       ROUND(100.0 * (rev - LAG(rev) OVER (ORDER BY month))
             / NULLIF(LAG(rev) OVER (ORDER BY month), 0), 1) AS pct
FROM m;
```

---

## 10-Minute Before Interview

**Mindset check:**
- You will be asked to explain your reasoning out loud — do it.
- If stuck, ask a clarifying question ("what if there are ties?").
- NULLs are almost always part of the trap — check for them.
- Say "let me think about edge cases" before writing SQL.
- You know this material. Trust your preparation.

**Last-second recall:**
1. NULL = NULL → NULL (use IS NULL).
2. LEFT JOIN + WHERE on right table → becomes INNER.
3. COUNT(*) vs COUNT(col) → same vs ignores NULLs.
4. NOT IN + NULL → empty result (use NOT EXISTS).
5. Window functions keep all rows; GROUP BY collapses.
6. UPSERT → ON CONFLICT.
7. Idempotency → same key → same result.
8. Pool exhaustion → requests block/fail.
9. VACUUM → reclaims dead tuples (MVCC).
10. EXPLAIN → check for Seq Scan on big tables.

---

## Final checklist

- [ ] Can explain logical query execution order
- [ ] Can write a window function for top-N per group
- [ ] Can explain the NOT IN NULL trap
- [ ] Can write an UPSERT
- [ ] Can explain LEFT JOIN becoming INNER
- [ ] Can explain ACID in one sentence each
- [ ] Can explain why indexes aren't free
- [ ] Can explain idempotency with a SQL example
- [ ] Can explain connection pooling
- [ ] Can explain PostgreSQL vs MySQL trade-offs