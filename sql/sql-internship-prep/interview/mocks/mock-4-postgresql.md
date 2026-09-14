# Mock Interview 4: PostgreSQL (15 Questions)

**Time: 45 minutes. Mix of SQL and conceptual.**

---

## Questions

### Q1: What is JSONB? When would you use it over a regular column?
### Q2: What is the difference between SERIAL and GENERATED AS IDENTITY?
### Q3: Write a JSONB query to find events where payload contains `{"action": "click"}`.
### Q4: What is a GIN index and when would you use one?
### Q5: Write an UPSERT to insert a row or update it if the key exists.
### Q6: What is a partial index? Give an example.
### Q7: What is the difference between TIMESTAMPTZ and TIMESTAMP?
### Q8: Write a query using the FILTER clause instead of CASE.
### Q9: What is DISTINCT ON and when would you use it?
### Q10: What is a BRIN index and when is it useful?
### Q11: Write a query to extract a value from a JSONB column.
### Q12: What is transactional DDL? Why is it useful?
### Q13: What is generate_series and when would you use it?
### Q14: What is the difference between LIMIT and FETCH FIRST?
### Q15: Write a query using an ARRAY column with ANY.

---

## Answers

### Q1: JSONB
JSONB is binary JSON: parsed, stored efficiently, supports indexing. Use it for semi-structured data (event payloads, form responses). Use a regular column when you always query the same fields.

### Q2: SERIAL vs IDENTITY
SERIAL creates a sequence + default (you can manually insert into the ID column). IDENTITY (GENERATED ALWAYS) prevents manual inserts unless you use BY DEFAULT. IDENTITY is the standard SQL approach, recommended for new code.

### Q3: JSONB containment query
```sql
SELECT * FROM events WHERE payload @> '{"action": "click"}';
```

### Q4: GIN index
Generalized Inverted Index — used for indexing composite values: JSONB, arrays, full-text search. Essential for `@>`, `?`, `?|`, `?&` operators on JSONB.

### Q5: UPSERT
```sql
INSERT INTO t (id, col1, col2)
VALUES ($1, $2, $3)
ON CONFLICT (id) DO UPDATE
SET col1 = EXCLUDED.col1, col2 = EXCLUDED.col2;
```

### Q6: Partial index
An index with a WHERE clause that only indexes a subset of rows:
```sql
CREATE INDEX idx_active ON users (email) WHERE is_active;
```
Smaller, faster, cheaper to maintain than a full index.

### Q7: TIMESTAMPTZ vs TIMESTAMP
TIMESTAMPTZ stores date+time in UTC and displays in session timezone. TIMESTAMP stores date+time with no timezone awareness. Always use TIMESTAMPTZ for distributed systems.

### Q8: FILTER clause
```sql
-- Instead of SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END)
SELECT SUM(amount) FILTER (WHERE status = 'completed') AS completed_revenue
FROM orders;
```

### Q9: DISTINCT ON
PostgreSQL-specific: `SELECT DISTINCT ON (col1) * FROM t ORDER BY col1, ts DESC` — returns one row per col1 value (the one with the latest ts). Clean alternative to ROW_NUMBER for "latest per group."

### Q10: BRIN index
Block Range INdex — stores the min/max of block ranges. Tiny, fast to maintain, efficient for data that's physically ordered (e.g., time-series on timestamp). Not good for random-access lookups.

### Q11: JSONB value extraction
```sql
SELECT payload->>'user_id' AS user_id,
       payload->>'action' AS action
FROM events;
```
`->>` returns text; `->` returns JSON.

### Q12: Transactional DDL
PostgreSQL allows DDL (CREATE, ALTER, DROP) inside transactions. A failed DDL doesn't leave partial objects. MySQL's DDL auto-commits.

### Q13: generate_series
Generates a series of numbers or dates:
```sql
SELECT * FROM generate_series('2023-01-01'::date, '2023-01-31'::date, '1 day');
```
Use for filling missing dates, creating ranges, generating test data.

### Q14: LIMIT vs FETCH FIRST
`LIMIT 10` (PostgreSQL/MySQL) vs `FETCH FIRST 10 ROWS ONLY` (SQL standard). PostgreSQL supports both. FETCH FIRST is more portable.

### Q15: ARRAY with ANY
```sql
SELECT * FROM users WHERE 'sql' = ANY(interests);
```
Returns users whose `interests` array contains 'sql'. Requires a GIN index for performance.