# Mock Interview 5: SQL + Database Concepts (20 Questions)

**Time: 60 minutes. Mix of written SQL and conceptual answers.**

---

## Questions

### Q1: What is ACID? Explain each property.
### Q2: What is the difference between a primary key and a unique constraint?
### Q3: What is MVCC?
### Q4: What is a deadlock? How do you prevent it?
### Q5: What is the difference between READ COMMITTED and REPEATABLE READ?
### Q6: What is a composite index? When would you use one?
### Q7: Why shouldn't you index every column?
### Q8: What is EXPLAIN ANALYZE? What do you look for?
### Q9: What is the difference between a B-tree and a GIN index?
### Q10: What is VACUUM and why does PostgreSQL need it?
### Q11: What is a connection pool? Why use one?
### Q12: What is the difference between OFFSET and keyset pagination?
### Q13: What is idempotency and why is it important for ETL?
### Q14: What is an anti-join? Write an example.
### Q15: What is a correlated subquery vs a non-correlated subquery?
### Q16: What is a covering index?
### Q17: What is the difference between DELETE and TRUNCATE in PostgreSQL?
### Q18: What is a partial index?
### Q19: What is a transaction? What happens if the application crashes mid-transaction?
### Q20: Write a query to find missing IDs in a sequence (1 to max).

---

## Answers

### Q1: ACID
**Atomicity:** all or nothing — either the entire transaction commits or none of it does.
**Consistency:** constraints (CHECK, FK, UNIQUE) are satisfied before and after.
**Isolation:** concurrent transactions don't interfere — each sees a consistent snapshot.
**Durability:** committed data survives crashes via WAL.

### Q2: PK vs UNIQUE
One PK per table; many UNIQUE constraints allowed. PK is implicitly NOT NULL; UNIQUE allows NULLs (in PostgreSQL, multiple NULLs). PK is used as the FK target.

### Q3: MVCC
Multiversion Concurrency Control: each transaction sees a snapshot of the database at the time it started. Old row versions are kept until VACUUM reclaims them. Readers never block writers.

### Q4: Deadlock
Two transactions each hold a lock the other needs. PostgreSQL detects and aborts one. Prevention: lock rows in the same order, keep transactions short.

### Q5: READ COMMITTED vs REPEATABLE READ
READ COMMITTED: each statement sees the latest committed data. REPEATABLE READ: the entire transaction sees one snapshot (no non-repeatable reads).

### Q6: Composite index
An index on multiple columns. Column order matters (leftmost prefix rule). Use when queries filter on multiple columns or need ORDER BY on multiple columns.

### Q7: Why not index every column?
Write overhead (INSERT/UPDATE/DELETE slower), storage cost, VACUUM overhead, planner confusion (too many indices → bad plan choices).

### Q8: EXPLAIN ANALYZE
Shows the actual execution plan with timing and row counts. Look for: Seq Scan on large tables (add index), estimated vs actual row mismatches (stale stats → ANALYZE), Sort nodes (index for ORDER BY).

### Q9: B-tree vs GIN
B-tree: sorted tree for =, <, >, BETWEEN, prefix LIKE. GIN: inverted index for composite values (JSONB, arrays, full-text). GIN is for containment/existence queries.

### Q10: VACUUM
PostgreSQL uses MVCC which creates dead tuples. VACUUM reclaims space from dead tuples and updates statistics. Autovacuum handles this automatically, but heavy write workloads may need tuning.

### Q11: Connection pool
Reuses existing PostgreSQL connections instead of creating new ones per query. Avoids process-per-connection overhead, prevents max_connections exhaustion, and bounds memory usage.

### Q12: OFFSET vs keyset pagination
OFFSET skips and discards rows (O(n)). Keyset uses `WHERE id > last_seen_id` (O(log n) via index). OFFSET supports random page access; keyset requires sequential access.

### Q13: Idempotency in ETL
An operation produces the same result whether applied once or many times. Critical for ETL because re-runs should not create duplicates. Achieved via idempotency key + UNIQUE constraint + ON CONFLICT.

### Q14: Anti-join
Rows in A with no match in B:
```sql
SELECT * FROM a WHERE NOT EXISTS (SELECT 1 FROM b WHERE b.id = a.id);
-- or
SELECT a.* FROM a LEFT JOIN b ON b.id = a.id WHERE b.id IS NULL;
```

### Q15: Correlated vs non-correlated
Correlated: references outer query, re-evaluated per outer row. Non-correlated: independent, runs once. Correlated can be slow; rewrite as JOIN when possible.

### Q16: Covering index
An index that includes all columns the query needs, so the planner never touches the heap (table):
```sql
CREATE INDEX idx ON orders (customer_id) INCLUDE (total_amount, status);
```

### Q17: DELETE vs TRUNCATE (PG)
Both are transactional. DELETE: row-by-row, fires triggers, can be rolled back. TRUNCATE: all at once, resets sequences, minimal logging, faster for large tables.

### Q18: Partial index
Index with a WHERE clause:
```sql
CREATE INDEX idx ON orders (customer_id) WHERE status = 'pending';
```
Smaller, faster for queries that always filter the same way.

### Q19: Transaction + crash
PostgreSQL rolls back automatically on disconnect. Nothing is partially applied. After COMMIT, data is durable (WAL). Before BEGIN, nothing to roll back.

### Q20: Missing IDs
```sql
SELECT s.n AS missing_id
FROM generate_series(1, (SELECT MAX(id) FROM t)) AS s(n)
LEFT JOIN t ON t.id = s.n
WHERE t.id IS NULL;
```