# 21 — Isolation and Concurrency 🟡

**Priority: 🟡 GOOD TO KNOW** — know the levels + one concrete scenario. Don't get lost in internals.

---

## Concept

When transactions run **concurrently**, they can interfere:

| Problem | Description |
|---------|-------------|
| **Lost update** | T2 overwrites T1's committed change (read-modify-write race) |
| **Dirty read** | T2 reads T1's **uncommitted** data (then T1 rolls back) |
| **Non-repeatable read** | T2 reads a row, T1 updates it, T2 re-reads → different value |
| **Phantom row** | T2 queries a range, T1 inserts a matching row, T2 re-queries → extra row |

### Isolation levels (ANSI + PostgreSQL)
Stricter ⇒ safer, but more locking/serialization.

| Level | Dirty read | Non-repeatable | Phantom | PG default support |
|-------|-----------|----------------|---------|--------------------|
| READ UNCOMMITTED | possible | possible | possible | PG maps to READ COMMITTED (doesn't allow dirty reads) |
| READ COMMITTED | no | possible | possible | ✅ default |
| REPEATABLE READ | no | no | possible¹ | ✅ (snapshot) |
| SERIALIZABLE | no | no | no | ✅ (SSI) |

¹ In PostgreSQL, REPEATABLE READ actually blocks phantoms *within the same statement* too, because it uses a full snapshot — but concurrent inserts between statements can still appear.

---

## How PostgreSQL implements isolation: MVCC (🟡, know the gist)

- PostgreSQL uses **Multiversion Concurrency Control** (MVCC): every transaction sees a **snapshot**.
- Writers don't block readers and readers don't block writers (mostly).
- Each row version carries `xmin`/`xmax`; DELETE/UPDATE create new versions, old ones become **dead tuples** cleaned later by **VACUUM** (ch 25).

**Interview one-liner:** "PostgreSQL uses MVCC so readers never block writers — each transaction works on its own snapshot."

---

## Simple scenario — lost update (marketing campaign counter)

```sql
-- Two concurrent processes both run:
UPDATE campaign SET clicks = clicks + 1 WHERE campaign_id = 1;
```
Without locking this is actually **safe in PostgreSQL** — `UPDATE` takes a row lock, so the second waits and reads the new value. Lost updates are only possible if you read first, then update based on the stale read:

```sql
-- BAD pattern (lost update risk):
SELECT clicks FROM campaign WHERE campaign_id = 1;  -- reads 5
-- ... think ...
UPDATE campaign SET clicks = 5 + 1 ...;             -- based on stale 5
```
**Fix:** `UPDATE ... SET clicks = clicks + 1` (atomic), or `SELECT ... FOR UPDATE` when you must read-then-write:

```sql
BEGIN;
SELECT clicks INTO strict_mode_var FROM campaign WHERE campaign_id = 1 FOR UPDATE;
UPDATE campaign SET clicks = clicks + 1 WHERE campaign_id = 1;
COMMIT;
```

---

## Interview Question (Level 3)

**Q:** What is a **deadlock**? How do you avoid it?

**A:** Two transactions each hold a lock the other needs:

```sql
-- T1: UPDATE accounts SET ... WHERE id = 1;  UPDATE accounts SET ... WHERE id = 2;
-- T2: UPDATE accounts SET ... WHERE id = 2;  UPDATE accounts SET ... WHERE id = 1;
```
PostgreSQL detects deadlock and aborts one with an error (`deadlock detected`). Avoidance: **always lock rows in the same order** (e.g., by id), keep transactions short.

---

## Tricky Question (Level 5)

**Q:** Transaction A updates row X. Transaction B tries to read X at READ COMMITTED. What happens — does B block?

**A:** In PostgreSQL, B does **not block** — it sees the **pre-commit** version (the old snapshot). That's the beauty of MVCC: readers never wait on writers. B's *later* reads in the same transaction might see new versions of other rows → non-repeatable read at READ COMMITTED.

---

## Interview Follow-Up Chain

**Q:** "When would you use SERIALIZABLE?"  
**A:** For **money math / constraint-critical invariants** where concurrent interleaving could break business rules and you'd rather fail loudly (serialization error) than corrupt data. E.g., booking last seat, total balance dedup guarantees.

**Q:** "What does SERIALIZABLE add over REPEATABLE READ?"  
**A:** It detects **serialization conflicts** across transactions (your snapshot would not match a linear serial order) and aborts with error 40001 — you retry the transaction.

**Q:** "READ COMMITTED vs REPEATABLE READ for a report that runs twice?"  
**A:** REPEATABLE READ gives a **stable snapshot** — the report sees the same data across statements. Good for long analytical reads.

---

## Real-world scenario

An ETL reads a big table while a nightly cleanup deletes old rows. With READ COMMITTED, the ETL sees consistent-mostly data (each statement a fresh snapshot). With REPEATABLE READ, the **whole transaction** sees one consistent snapshot — critical for producing a consistent export. Explain the trade-off (snapshot holds old row versions alive longer → VACUUM lag).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "MVCC?" / "Deadlock?" / "Isolation levels + which default?" / "SELECT FOR UPDATE?" / "SERIALIZABLE?"