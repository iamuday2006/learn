# 35 — PostgreSQL Interview 🔥

**Priority: 🔥 MUST KNOW** — this is the "Why PostgreSQL?" deep-dive chapter, specifically tailored for the interviewer follow-up chain.

---

## Topic 1: Architecture (high-level)

**30-second answer:** "PostgreSQL uses a process-per-connection model. Each query runs in a backend process that reads from shared buffers (backed by OS cache). Writes go to the Write-Ahead Log first for durability, then to the table files. MVCC provides snapshot isolation so readers never block writers."

Follow-up questions you should be ready for:

**Q:** What is WAL?  
**A:** Write-Ahead Log — every change is written to a sequential log before the actual table file. If the server crashes, WAL replays to restore committed data. WAL is also used for replication (streaming replicas) and point-in-time recovery.

**Q:** What is MVCC?  
**A:** Each transaction sees a consistent snapshot of the database at the time it started. Old row versions are kept in the table until VACUUM reclaims them. This avoids read locks but means dead tuples accumulate if VACUUM doesn't run.

---

## Topic 2: JSONB — when and how

JSONB is binary JSON: fast to parse, supports indexing, supports containment operators.

**When to use JSONB:**
- Event payloads, user preferences, form responses — data with no fixed schema.
- Semi-structured data from external APIs.
- Extension columns on an existing table.

**When NOT to use JSONB:**
- When you query a specific key frequently → extract to a real column instead.
- When the JSON is deeply nested and you need joins on nested attributes.

**GIN index on JSONB:**
```sql
CREATE INDEX idx_events_payload ON events USING GIN (payload);
SELECT * FROM events WHERE payload @> '{"action": "click"}';  -- uses GIN index
```

**Common JSONB operators:**
| Operator | Meaning | Example |
|----------|---------|---------|
| `->`  | Get JSON object by key | `payload->'user'` |
| `->>` | Get text by key | `payload->>'user_id'` |
| `@>`  | Contains | `payload @> '{"action":"click"}'` |
| `?`   | Key exists | `payload ? 'user_id'` |
| `#>>` | Path text extraction | `payload#>>'{user,name}'` |

---

## Topic 3: UPSERT (`ON CONFLICT`)

Already covered in chapter 30. For the interview, emphasize the **partial ON CONFLICT** pattern:

```sql
-- Only update if the existing row is older
INSERT INTO sync_events (event_id, payload, received_at)
VALUES ($1, $2, NOW())
ON CONFLICT (event_id)
WHERE received_at < EXCLUDED.received_at  -- only if newer
DO UPDATE SET payload   = EXCLUDED.payload,
              received_at = EXCLUDED.received_at;
```
This is a real-world pattern for deduplicating late-arriving data.

---

## Topic 4: Indexes in PostgreSQL

| Index type | Use case |
|-----------|----------|
| B-tree | Default, most common; =, <, >, BETWEEN, LIKE prefix, ORDER BY |
| GIN | JSONB containment, full-text search, arrays |
| GiST | Geospatial, range types, full-text |
| BRIN | Large tables with physically ordered data (e.g., time series on timestamp) |
| Partial | Index only rows matching a WHERE clause (smaller, faster) |
| Expression | Index on a function: `CREATE INDEX ON t (lower(email))` |
| Covering (INCLUDE) | `CREATE INDEX ON t (col1) INCLUDE (col2, col3)` — avoids heap fetch |

**BRIN note:** For a time-series table with billions of rows, a B-tree index is huge and slow to maintain. A BRIN index (Block Range INdex) is tiny and efficient because it knows data is roughly physically ordered by time.

---

## Topic 5: EXPLAIN ANALYZE — the right things to say

When a planner shows a slow plan:
1. Is there a Seq Scan on a large table? → Add an index.
2. Are estimated vs actual rows way off? → Run `ANALYZE`.
3. Is there a Sort node? → Index on the ORDER BY column.
4. Is it a Hash Join with a huge build side? → The planner might be wrong about data distribution; consider a hint (rare) or restructure the query.

---

## Topic 6: JSONB + ARRAY in practice

```sql
-- ARRAY column
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    interests TEXT[]  -- array of text
);
CREATE INDEX idx_interests ON users USING GIN (interests);
SELECT * FROM users WHERE interests @> ARRAY['sql'];  -- contains
SELECT unnest(interests) FROM users WHERE id = 1;     -- expand to rows

-- JSONB
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    payload JSONB
);
CREATE INDEX idx_payload ON events USING GIN (payload);
SELECT payload->>'page' FROM events WHERE payload @> '{"action":"signup"}';
```

---

## Interview Question (Level 5)

**Q:** "You have a 500M-row `events` table. Most queries filter by `event_ts` in the last 7 days. Design the best indexing strategy."

**Answer:**
1. `event_ts` is time-ordered, data physically correlated by time.
2. A **BRIN index** on `event_ts` is tiny and sufficient (low maintenance, great for time series).
3. For `event_name` queries: a B-tree on `(event_name, event_ts)`.
4. For JSONB payloads: a GIN index.
5. For full analytics: consider a **materialized view** that pre-aggregates daily metrics, refreshed incrementally.

**Follow-up:** "Why not a regular B-tree on `event_ts`?"  
**A:** B-tree on 500M rows is ~10GB+ and slow to maintain on every INSERT. BRIN is <100MB and handles time-ordered data perfectly because blocks contain physically adjacent timestamps.

---

## Real-world scenario

**Q:** "Build a user activity log table that supports: (1) fast inserts, (2) fast queries for a user's last 30 days of activity, (3) JSONB payload search."

```sql
CREATE TABLE activity_log (
    log_id    BIGSERIAL PRIMARY KEY,
    user_id   INT NOT NULL,
    action    VARCHAR(50),
    payload   JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index 1: user + time (for "last 30 days per user")
CREATE INDEX idx_activity_user_time ON activity_log (user_id, created_at DESC);

-- Index 2: BRIN on created_at for time-range scans
CREATE INDEX idx_activity_brin_time ON activity_log USING BRIN (created_at);

-- Index 3: GIN for JSONB payload search
CREATE INDEX idx_activity_payload ON activity_log USING GIN (payload);

-- Query
SELECT * FROM activity_log
WHERE user_id = 42
  AND created_at >= NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "BRIN vs B-tree?" / "JSONB indexing?" / "WAL purpose?" / "MVCC trade-offs?" / "Transaction DDL?"