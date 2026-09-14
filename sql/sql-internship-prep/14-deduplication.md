# 14 — Deduplication 🔥

**Priority: 🔥 MUST KNOW** — dedup is *the* most common Data Engineering SQL interview question.

---

## How to recognize it

"Remove duplicate rows", "find duplicates", "keep only one row per X", "our ETL loaded the same data twice".

---

## Recommended SQL technique

1. **Detect:** `GROUP BY` on the natural/business keys, `HAVING COUNT(*) > 1`.
2. **Identify which to keep:** `ROW_NUMBER() OVER (PARTITION BY natural_key ORDER BY keep_tiebreaker)`.
3. **Remove:** `DELETE` via CTE, or `DISTINCT ON` for selecting.

---

## Example

Detect duplicates in `events` (by unique event identity, from `datasets/data_engineering.sql` which intentionally contains duplicates):

```sql
SELECT user_id, event_name, event_ts, COUNT(*) AS cnt
FROM events
GROUP BY user_id, event_name, event_ts
HAVING COUNT(*) > 1;
```

Remove all but one copy, keeping the lowest `event_id`:

```sql
WITH ranked AS (
    SELECT event_id,
           ROW_NUMBER() OVER (PARTITION BY user_id, event_name, event_ts
                              ORDER BY event_id) AS rn
    FROM events
)
DELETE FROM events
WHERE event_id IN (SELECT event_id FROM ranked WHERE rn > 1);
```

Verify: rerun detection → empty.

---

## Alternative: `SELECT DISTINCT ON` (PostgreSQL gem)

```sql
SELECT DISTINCT ON (user_id, event_name, event_ts)
       event_id, user_id, event_name, event_ts
FROM events
ORDER BY user_id, event_name, event_ts, event_id;
```
Keeps one row per `(user_id, event_name, event_ts)` — the lexicographically first by `ORDER BY`. The columns in `DISTINCT ON` must appear first in ORDER BY.

---

## Common mistake

- Using `DISTINCT` blindly → collapses legitimate duplicates (e.g., two *different* orders with same amount/day).
- Deleting duplicates without a **deterministic tiebreaker** → keeps random row.
- Using `GROUP BY` with `MIN()` to keep a row, then joining back and still getting duplicates because the join keys aren't unique.

---

## Interview variations

1. "Find duplicate customers by email." → GROUP BY + HAVING.
2. "Keep the latest version of each record (like CDC with no unique key)." → ROW_NUMBER ordered by `updated_at DESC`, keep rn=1.
3. "Delete duplicates from a table without a primary key."
4. "Dedupe a fact table by its logical key before aggregating."

```sql
-- Question 2 pattern: keep latest row per natural key
WITH latest_version AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY natural_key ORDER BY updated_at DESC) AS rn
    FROM raw_table
)
SELECT * FROM latest_version WHERE rn = 1;
```

---

## Real-world scenario

An ETL job ran twice and appended duplicate `orders_fact` rows. Write the clean-up **inside a transaction** and verify counts before/after:

```sql
BEGIN;
WITH ranked AS (
    SELECT order_id,
           ROW_NUMBER() OVER (PARTITION BY user_id, product_id, order_ts, amount
                              ORDER BY order_id) AS rn
    FROM orders_fact
)
DELETE FROM orders_fact
WHERE order_id IN (SELECT order_id FROM ranked WHERE rn > 1);
SELECT COUNT(*) FROM orders_fact;
COMMIT;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Which duplicate to keep?" / "DISTINCT vs ROW_NUMBER dedup?" / "Dedup without unique key?" / "Preventing duplicates (UNIQUE + ON CONFLICT)?"