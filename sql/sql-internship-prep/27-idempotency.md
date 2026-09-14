# 27 — Idempotency ⭐

**Priority: ⭐ HIGH VALUE** — this is what separates SQL literacy from Data Engineering literacy.

---

## What is idempotency?

An operation is **idempotent** if applying it **once** or **many times** gives the **same result**. Retries are inevitable in distributed systems — without idempotency, a retry creates duplicates.

**Concrete example:** you POST `{amount: 100, user: "alice"}` to charge alice 100. Network fails after charge but before ACK → you retry → alice is charged twice. Bad.

---

## Why it matters for databases

- API requests can be retried.
- ETL jobs can re-run.
- Message queues can deliver twice.
- Network partitions cause retries.

All of these can **duplicate rows** unless the write is idempotent.

---

## How to make database writes idempotent

Pattern 1: **idempotency key + UNIQUE constraint + ON CONFLICT**

```sql
-- A unique request_id makes this safe to retry
INSERT INTO payments (request_id, amount, user_id)
VALUES ('req-abc-123', 100, 1)
ON CONFLICT (request_id) DO NOTHING;
```

Pattern 2: **idempotency key + UPSERT (ON CONFLICT DO UPDATE)**

```sql
INSERT INTO events (event_id, event_name, payload)
VALUES ('evt-777', 'click', '{"url":"/home"}')
ON CONFLICT (event_id) DO UPDATE
SET payload = EXCLUDED.payload;  -- keep latest version
```

Pattern 3: **conditional insert**

```sql
INSERT INTO account_balance_changes (account_id, delta, request_id)
SELECT 1, -100, 'req-abc-123'
WHERE NOT EXISTS (SELECT 1 FROM account_balance_changes
                  WHERE request_id = 'req-abc-123');
```

Pattern 4: **transaction + idempotency key + UNIQUE**

```sql
BEGIN;
INSERT INTO orders (customer_id, idempotency_key, total)
VALUES (5, 'key-xyz', 200);
INSERT INTO order_items (order_id, product_id, quantity)
VALUES (CURRVAL('orders_order_id_seq'), 10, 2);  -- order_items is safe because FK is in the same tx
COMMIT;
```

---

## Common mistakes

1. Using an auto-increment `id` as the idempotency key — impossible to predict before insert.
2. `INSERT ... ON CONFLICT` without a UNIQUE index on the key → no protection.
3. Missing the transaction — in multi-table writes, the idempotency key only protects one table.
4. Not storing the idempotency key for future requests — you need to return the same result on retry.

---

## SQL practice (using data_engineering.sql)

```sql
-- Suppose ETL re-runs. Use request_id to prevent duplicate events
INSERT INTO events (user_id, event_name, event_ts, page)
SELECT 1, 'signup', '2023-01-05 08:10:00+00', '/signup'
WHERE NOT EXISTS (SELECT 1 FROM events
                  WHERE user_id = 1
                    AND event_name = 'signup'
                    AND event_ts = '2023-01-05 08:10:00+00');
```

---

## Interview Question (Level 3)

**Q:** "How do you design an ETL pipeline that can safely re-run?"

**Answer:** "Every write uses an idempotency key (natural business key or explicit request_id). We use `INSERT ... ON CONFLICT` or `UPDATE ... RETURNING` patterns. In a transaction, the whole batch is atomic. We log what was processed (watermark/chunk identifier) so a retry starts from the right point and doesn't duplicate data."

---

## Tricky Question (Level 5)

**Q:** Why is `DELETE` NOT idempotent by default?

**A:** `DELETE WHERE status = 'failed'` can succeed 0 or many times (idempotent). But `DELETE WHERE id = 100` succeeds once then fails the second time (different behavior). **Safe idempotent delete:** ensure a state field (soft delete) is set, then set it again — ON CONFLICT is not applicable, but the update is idempotent:

```sql
UPDATE accounts SET is_closed = TRUE WHERE account_id = 5 AND NOT is_closed;
-- second time: rows updated = 0, but no error
```

---

## Real-world scenario

You receive a Kafka message to charge a user. Network fails after writing to `payments`. When the message is re-delivered:

```sql
-- Payment idempotency key
INSERT INTO payments (request_id, user_id, amount, payment_date)
VALUES ($request_id, $user_id, $amount, NOW())
ON CONFLICT (request_id) DO NOTHING;
```
Then trigger the balance update. If the balance update was also idempotent (delta keyed by request_id), the entire flow is safe.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Why idempotency key + UNIQUE?" / "Multi-table idempotency?" / "DELETE not idempotent?" / "Retry-safe ETL?"