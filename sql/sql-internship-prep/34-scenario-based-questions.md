# 34 — Scenario-Based Questions 🔥

**Priority: 🔥 MUST KNOW** — these are the questions interviewers ask to see if you can reason about real systems, not just syntax.

---

## Category 1: Data Modeling

**Q:** "Design a schema for a ride-sharing app's trip data."

**Answer structure:**
1. Identify entities: users, drivers, trips, payments, ratings.
2. Define relationships: a trip has one driver, one rider; a payment belongs to one trip.
3. Choose keys: surrogate PKs (`SERIAL`), FKs, unique constraints on natural keys (driver license, phone).
4. Add relevant columns: `status` (enum or CHECK), `created_at`, `updated_at`.

```sql
CREATE TABLE trips (
    trip_id     SERIAL PRIMARY KEY,
    driver_id   INT NOT NULL REFERENCES drivers(driver_id),
    rider_id    INT NOT NULL REFERENCES riders(rider_id),
    pickup_loc  POINT,
    dropoff_loc POINT,
    status      VARCHAR(20) NOT NULL DEFAULT 'requested',
    started_at  TIMESTAMPTZ,
    ended_at    TIMESTAMPTZ,
    fare        NUMERIC(10,2) CHECK (fare >= 0),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

Follow-up: "How do you handle trip cancellations?" → `status = 'cancelled'` + soft-delete pattern (don't delete the row).

---

## Category 2: Data Quality

**Q:** "A pipeline loads 1M rows daily, but users complain the dashboard shows wrong numbers. What do you check?"

**Answer (in order):**
1. Check row counts: source vs target.
2. Check for NULLs in key columns.
3. Check for duplicate rows.
4. Check for JOIN multiplication (more rows than expected after join).
5. Check for missing dates / timezones.
6. Compare aggregates: source `SUM(amount)` vs target `SUM(amount)`.
7. Check the watermark / last_run to see if data is stale.

```sql
-- Quick comparison
SELECT
    (SELECT COUNT(*) FROM source_table) AS src_count,
    (SELECT COUNT(*) FROM target_table) AS tgt_count,
    (SELECT SUM(amount) FROM source_table) AS src_sum,
    (SELECT SUM(amount) FROM target_table) AS tgt_sum;
```

---

## Category 3: Scale

**Q:** "How would this query work with millions of rows?"

**Answer structure:**
1. First: verify the plan uses an index (EXPLAIN).
2. Index on filtered columns, especially the JOIN keys and WHERE clause.
3. Consider partitioning by date if filtering by time range.
4. Aggregate before joining (reduce rows early).
5. If it's a dashboard: pre-compute into a summary table or materialized view.
6. For very large tables: consider approximate methods (HyperLogLog for distinct counts).

---

## Category 4: Pipeline Design

**Q:** "You receive a 1GB CSV file every hour. Design the ingestion pipeline."

**Answer:**
1. Load into a **staging table** (`COPY` or `psql \copy`).
2. **Validate** (row count, NULL checks, constraint checks) — if fails → quarantine.
3. **Deduplicate** (idempotent upsert using a natural key + ON CONFLICT).
4. **Transform** (JOIN to dimensions, clean, aggregate if needed).
5. **Load** to target tables (fact + summary).
6. **Update watermarks** for audit/debugging.
7. All in a **transaction** — atomic.

---

## Category 5: Failure handling

**Q:** "Your pipeline crashes halfway through loading 500M rows. What happens?"

**Answer:**
- If inside a transaction → nothing is committed; re-run from the start.
- If the load uses `COPY` without a transaction → partial data is committed. Fix: wrap in `BEGIN/COMMIT`, or use `COPY` into a staging table, then `INSERT ... SELECT` in one transaction.
- If using idempotent upserts → re-running is safe (duplicates are handled).
- The lesson: **never write directly to production tables without a staging+transaction layer.**

---

## Category 6: Query design interview

**Q:** "Find customers who purchased product X but never purchased product Y."

```sql
SELECT DISTINCT o1.customer_id
FROM order_items oi1
JOIN orders o1 ON o1.order_id = oi1.order_id
JOIN products p1 ON p1.product_id = oi1.product_id
WHERE p1.product_name = 'Product X'
  AND NOT EXISTS (
      SELECT 1
      FROM order_items oi2
      JOIN orders o2 ON o2.order_id = oi2.order_id
      JOIN products p2 ON p2.product_id = oi2.product_id
      WHERE o2.customer_id = o1.customer_id
        AND p2.product_name = 'Product Y'
  );
```

**Explain:** "I'm joining to find who bought X, then using NOT EXISTS to exclude anyone who also bought Y."

---

## Real-world scenario (Data Engineering)

**Q:** "You need to build a daily user-retention report — what SQL do you write?"

```sql
-- Cohort = month of account creation
-- Active = has at least one event in the month
WITH cohort AS (
    SELECT user_id,
           DATE_TRUNC('month', account_created)::DATE AS cohort_month
    FROM user_dim
),
monthly_active AS (
    SELECT DISTINCT user_id,
           DATE_TRUNC('month', event_ts)::DATE AS active_month
    FROM events
    WHERE event_name = 'page_view'
)
SELECT
    c.cohort_month,
    COUNT(DISTINCT c.user_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN ma.active_month = c.cohort_month THEN c.user_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN ma.active_month = c.cohort_month + INTERVAL '1 month' THEN c.user_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN ma.active_month = c.cohort_month + INTERVAL '2 months' THEN c.user_id END) AS month_2
FROM cohort c
LEFT JOIN monthly_active ma ON ma.user_id = c.user_id
GROUP BY c.cohort_month
ORDER BY 1;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "What if the data is stale?" / "How do you handle late-arriving data?" / "Pipeline failure recovery?"