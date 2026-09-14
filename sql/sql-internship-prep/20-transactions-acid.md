# 20 — Transactions and ACID 🔥

**Priority: 🔥 MUST KNOW** — a guaranteed topic when they ask "what happens internally?"

---

## Concept

A **transaction** is a group of operations executed as one unit: **all or nothing**.

```sql
BEGIN;                  -- start transaction
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;                 -- atomically apply both
-- or
ROLLBACK;               -- undo both
```

### SAVEPOINT — partial rollback

```sql
BEGIN;
INSERT INTO orders (customer_id, total_amount) VALUES (1, 25);
SAVEPOINT sp1;
INSERT INTO order_items ...;         -- oops
ROLLBACK TO sp1;                     -- undo only the items insert
COMMIT;                              -- keep the order
```

---

## ACID — memorize exactly

| Letter | Meaning | Example |
|--------|---------|---------|
| **A** | **Atomicity** — all or nothing | the two updates above |
| **C** | **Consistency** — invariants hold before/after (constraints, "no negative balance", "sum preserved") | CHECK/UNIQUE/FK enforced between statements |
| **I** | **Isolation** — concurrent transactions don't interfere (levels vary) | two transfers on same account |
| **D** | **Durability** — committed data survives crashes (WAL in PostgreSQL) | power loss after COMMIT |

---

## Simple Example — the bank transfer (say this out loud)

```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1 AND balance >= 100;
-- if zero rows updated → rollback (insufficient funds)
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```

**Interview answer:** "I would wrap a bank transfer in a transaction so that a debit without a credit can never happen. Atomicity guarantees the pair commits together or not at all. If the application crashes between the two UPDATEs, the DB rolls back on connection loss — the money is neither 'gone' nor 'doubled'."

---

## What happens if the application crashes halfway? (THE question)

- Statement-level: if the connection dies mid-transaction, PostgreSQL **rolls back** automatically on disconnect. Nothing is partially applied.
- If it crashes *after COMMIT* — durable via WAL; transaction is recorded.
- If it crashes *before BEGIN* — nothing to roll back.

**Order + payment example:**
```sql
BEGIN;
INSERT INTO orders (...);
INSERT INTO payments (...);
UPDATE inventory SET stock_qty = stock_qty - 1 WHERE product_id = ...;
COMMIT;
```
An order without a payment, or a payment without stock decrement, can never persist.

---

## Interview Question (Level 3)

**Q:** Can DDL (CREATE/ALTER/DROP) be inside a transaction in PostgreSQL?

**A:** Yes — PostgreSQL supports **transactional DDL**. A failed `CREATE TABLE` inside a transaction doesn't leave partial objects. (MySQL's DDL auto-commits in most engines — a good PG-vs-MySQL point.)

---

## Tricky Question (Level 5)

**Q:** Both accounts have balance 100. Transaction A moves 100 from 1→2. Transaction B moves 100 from 2→1. With default isolation (READ COMMITTED), both COMMIT. Final balance?

**A:** Depends on execution order, but a possible **lost update / interleaving** scenario exists. Under stricter isolation (REPEATABLE READ / SERIALIZABLE) PostgreSQL uses **row locks + snapshotting** and one transaction would fail on serialization conflict. The safe pattern is *"read the rows you modify, in the same order, in a transaction, and check conflicts"*. (More in chapter 21.)

---

## Interview Follow-Up Chain

**Q:** "Where do you put transactions in a pipeline?"  
**A:** Around batch loads (`BEGIN ... COPY ... COMMIT`) so a failed load leaves no partial batch. In a `INSERT ... ON CONFLICT` upsert, the whole statement is one transaction anyway; multi-statement logic needs explicit BEGIN/COMMIT.

**Q:** "Auto-commit?"  
**A:** Every single SQL statement outside an explicit transaction is implicitly wrapped — PostgreSQL runs it in a single-statement transaction.

**Q:** "Isolation default?"  
**A:** READ COMMITTED in PostgreSQL.

---

## Real-world scenario — inventory update with oversell guard

```sql
BEGIN;
UPDATE products
SET stock_qty = stock_qty - 2
WHERE product_id = 7 AND stock_qty >= 2;
-- check rows affected:
SELECT stock_qty FROM products WHERE product_id = 7;
COMMIT;
```
If the WHERE guard matched 0 rows → ROLLBACK → "not enough stock". The CHECK on `stock_qty >= 0` is safety belt #2.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Crash mid-transaction?" / "SAVEPOINT?" / "Transactional DDL?" / "Where to use transactions in pipelines?"