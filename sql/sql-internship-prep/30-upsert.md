# 30 — UPSERT 🔥

**Priority: 🔥 MUST KNOW** — the "insert or update" pattern is daily in Data Engineering.

---

## What is an UPSERT?

An **upsert** = insert a row, or if it already exists (based on a unique key), update it.

PostgreSQL syntax:
```sql
INSERT INTO table_name (col1, col2, col3)
VALUES ($1, $2, $3)
ON CONFLICT (conflict_target)
DO UPDATE SET col2 = EXCLUDED.col2, col3 = EXCLUDED.col3
-- or
ON CONFLICT DO NOTHING;
```

MySQL syntax:
```sql
INSERT INTO table_name (col1, col2, col3)
VALUES ($1, $2, $3)
ON DUPLICATE KEY UPDATE col2 = VALUES(col2), col3 = VALUES(col3);
```

**EXCLUDED** = special table referencing the row that was not inserted (the conflicting row data).

---

## PostgreSQL `ON CONFLICT` in detail

```sql
-- Upsert a user's latest email
INSERT INTO users (user_id, email, last_seen)
VALUES (101, 'alice@example.com', NOW())
ON CONFLICT (user_id) DO UPDATE
SET email     = EXCLUDED.email,
    last_seen = EXCLUDED.last_seen;
```

**conflict target** can be:
- A column: `ON CONFLICT (user_id)`
- A constraint: `ON CONFLICT ON CONSTRAINT users_email_key`
- With a WHERE clause: `ON CONFLICT (user_id) WHERE is_active DO UPDATE ...` (partial upsert)

```sql
-- Only update if the existing row is inactive (active flag)
INSERT INTO users (user_id, email, is_active, last_seen)
VALUES (101, 'alice@example.com', TRUE, NOW())
ON CONFLICT (user_id)
WHERE NOT is_active
DO UPDATE SET email     = EXCLUDED.email,
              is_active = TRUE,
              last_seen = EXCLUDED.last_seen;
```

---

## `ON CONFLICT DO NOTHING`

Use when you just want to silently skip duplicates — useful for idempotent loads:

```sql
INSERT INTO events (event_id, event_name, event_ts)
VALUES ('evt-123', 'click', '2023-01-05 10:00:00+00')
ON CONFLICT (event_id) DO NOTHING;
```

---

## Simple Example — ETL incremental load

```sql
-- Upsert dimension table from a staging table
INSERT INTO products (product_id, product_name, category, price)
SELECT product_id, product_name, category, price
FROM staging_products
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    category     = EXCLUDED.category,
    price        = EXCLUDED.price;
```

---

## MySQL `ON DUPLICATE KEY UPDATE`

```sql
INSERT INTO products (product_id, product_name, price)
VALUES (7, 'New Product', 19.99)
ON DUPLICATE KEY UPDATE
    product_name = VALUES(product_name),
    price        = VALUES(price);
```
**Note:** MySQL uses `VALUES(col)` (or `new.col` in MySQL 8.0.19+) to reference the incoming row. PostgreSQL uses `EXCLUDED`. Also, MySQL upsert **always triggers the update** on any unique/primary conflict, while PG partial `ON CONFLICT ... WHERE` can skip it.

---

## Using CTE with upsert (powerful DE pattern)

```sql
-- Deduplicate + upsert in one transaction
WITH new_rows AS (
    SELECT product_id, product_name, category, price
    FROM staging_products
    -- e.g., exclude null PKs
    WHERE product_id IS NOT NULL
)
INSERT INTO products (product_id, product_name, category, price)
SELECT * FROM new_rows
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    category     = EXCLUDED.category,
    price        = EXCLUDED.price;
```
The CTE is executed, then the main statement upserts — atomic, one round trip.

---

## Common mistakes

1. **Conflict target must be unique** — referencing a non-unique column → error.
2. Forgetting `ON CONFLICT` → duplicate key error.
3. Using `EXCLUDED` when you mean the **current** value (use the target table alias):
```sql
ON CONFLICT (id) DO UPDATE SET access_count = products.access_count + 1;  -- not EXCLUDED.access_count
```
4. MySQL: `ON DUPLICATE KEY UPDATE` doesn't support partial conflict targets.

---

## Interview Question (Level 3)

**Q:** How do you do an upsert in PostgreSQL vs MySQL?

**Answer:** PostgreSQL: `INSERT ... ON CONFLICT (key) DO UPDATE SET ...`. MySQL: `INSERT ... ON DUPLICATE KEY UPDATE col = VALUES(col)`. PostgreSQL supports partial `ON CONFLICT` with a WHERE clause, making it more precise. MySQL 8+ added `INSERT ... ON DUPLICATE KEY UPDATE`.

---

## Tricky Question (Level 5)

**Q:** If the upsert target row is locked by another transaction, what happens?

**A:** The upsert **blocks** until the other transaction commits/rolls back. If it was a write, PG may retry internally. The CONFLICT must still be detected — once the lock is released and the row exists, the upsert proceeds with the UPDATE path.

---

## Real-world scenario

You load a daily dimension refresh:

```sql
BEGIN;
WITH incoming AS (
    SELECT * FROM staging_products WHERE loaded_date = CURRENT_DATE
)
INSERT INTO products (product_id, product_name, category, price)
SELECT * FROM incoming
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    category     = EXCLUDED.category,
    price        = EXCLUDED.price;
COMMIT;
```

On re-run: idempotent, atomic, no duplicates, no errors.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "EXCLUDED vs target table?" / "Partial ON CONFLICT?" / "MySQL ON DUPLICATE KEY?" / "CTE + UPSERT?"