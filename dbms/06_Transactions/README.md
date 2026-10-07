# 06. Transactions & ACID

> Covers: 06:32:06 – ACID Properties and Transactions, 07:08:42 – Atomicity Implementation. Includes WAL, Undo/Redo, Checkpoints, Crash Recovery.

## 1. What is a Transaction?

A **Transaction** is a **logical unit of work** (sequence of one or more SQL operations) that must be executed as a **single, indivisible** unit. Either **all** operations succeed (COMMIT) or **none** (ROLLBACK) — preserving database consistency.

**Real examples**: Bank transfer (debit A + credit B), placing order (deduct stock + create order + charge payment), online payment.

## 2. Transaction Lifecycle

`	ext
BEGIN (or implicit)
  ↓
Execute DML (INSERT/UPDATE/DELETE) / queries
  ↓
  ├─→ COMMIT (if all OK) → Permanent
  └─→ ROLLBACK (error/crash/explicit) → Undo changes
`

SQL commands: BEGIN; ... COMMIT; or START TRANSACTION; ... ROLLBACK;  
Also SAVEPOINT sp1; ... ROLLBACK TO sp1; (partial rollback).

**SAVEPOINT**: Create checkpoint within transaction to rollback partially without aborting entire transaction.

## 3. ACID Properties

ACID ensures **reliability, correctness, and integrity** of transactions, especially under failures/concurrency.

| Property | Meaning | Purpose | Example |
|---|---|---|---|
| **A – Atomicity** | All-or-nothing. Entire transaction completes or nothing changes. | Prevent partial updates | Transfer ₹500: both debit+credit must happen, else neither. |
| **C – Consistency** | Transaction brings DB from **consistent state → consistent state**. Must respect all constraints (PK/FK/CHECK, business rules). | Preserve integrity | Sum of accounts remains same after valid transfer. |
| **I – Isolation** | Concurrent transactions must not interfere. Each sees a consistent view as if executed alone (degree varies by isolation level). | Handle concurrency safely | Two transfers don't corrupt balances. |
| **D – Durability** | Once **COMMITTED**, changes are **permanent** even if system crashes immediately after. | Survive failures | After payment success screen, money deducted stays even if power fails. |

**Note**: Consistency is partly enforced by DB (constraints) and partly by application logic.

## 4. Bank Transfer Example (ACID in Action)

**Scenario**: Transfer ₹500 from A to B

`sql
BEGIN;
  UPDATE accounts SET balance = balance-500 WHERE acc_no='A';
  UPDATE accounts SET balance = balance+500 WHERE acc_no='B';
COMMIT;
`

- **Atomicity**: If second update fails (crash/network), first is rolled back. No money lost.
- **Consistency**: Total (A+B) same before/after. Constraints (balance>=0) enforced.
- **Isolation**: Other users see either old state or new state (not intermediate mix) depending on level.
- **Durability**: After COMMIT, both updates survive OS/DB crash.

**Crash Scenarios**:
- **Before BEGIN**: No change – consistent.
- **During (after 1st update, before 2nd)**: Atomicity → rollback on failure.
- **After 1st, before COMMIT**: Crash → recovery undoes partial.
- **After COMMIT**: Crash → recovery redoes to make durable.

## 5. Transaction States (Conceptual)

`	ext
Active (executing)
  ↓
  ├─→ Partially Committed (last op done, waiting COMMIT)
  │     ↓
  │     ├─→ Committed (success, durable)
  │     └─→ Failed/Aborted (on error)
  └─→ Failed (error) → Aborted → Rolled back
`

## 6. Atomicity & Durability Internals: How DB Achieves Them

To ensure Atomicity+Durability across crashes, RDBMS uses **Transaction Log** (also called **Redo/Undo Log**).

### 6.1 Transaction Log

**Transaction Log** is a sequential, append-only file recording all **changes** made by transactions (before applying to actual data pages). Critical for recovery.

- Stores: Transaction ID, operation type (update/insert/delete), old value (before), new value (after), page/block info, timestamp.
- Written to **stable storage** (disk) before/alongside data changes (WAL).
- Much smaller/faster to write sequentially than random data page writes.

### 6.2 Write-Ahead Logging (WAL)

**WAL Principle**: *"Write the log record describing the change to stable storage **before** writing the modified data page to disk."*

**Why WAL?**
- If crash after logging but before flushing data page → can **redo**.
- If crash after writing partial data but log says not committed → can **undo**.
- Ensures Atomicity + Durability.
- Allows **buffered** data writes (performance) while preserving correctness.

**Flow (simplified)**:
1. Modify page in **Buffer Pool** (memory)
2. Generate log record (old+new values)
3. **Flush log record to disk (WAL flush)** – at least by COMMIT time
4. Later **flush dirty pages** to data files (lazy, for performance)

**In PostgreSQL**: WAL is in pg_wal/ (or pg_xlog in older). COMMIT guarantees WAL flushed.

### 6.3 Undo & Redo

| Operation | Purpose | When |
|---|---|---|
| **Undo** | Restore old values for **uncommitted**/aborted transactions | On abort, or during crash recovery if transaction didn't commit |
| **Redo** | Reapply new values for **committed** transactions | During crash recovery if data pages not yet flushed to disk |

**Rule of thumb**:
- **Committed but data not on disk** → **Redo** (durability)
- **Not committed but data written to disk** → **Undo** (atomicity)

### 6.4 Checkpoints

**Checkpoint** is a point in time where DB writes all **dirty (modified) buffer pages** to data files and records checkpoint info in WAL.

**Purpose**:
- Shortens recovery time (don’t redo from beginning of WAL)
- Reduces amount of log to scan after crash
- Frees older WAL (in managed systems)

**How it helps**: Recovery starts from **last checkpoint** + redoes committed changes + undoes uncommitted ones.

**Types (conceptual)**: Sharp vs fuzzy checkpoints (implementation varies). Conceptually same goal.

### 6.5 Crash Recovery (ARIES-style conceptual view)

When DB restarts after crash:

`	ext
1. Analysis Phase
   - Find which transactions active at crash
   - Find dirty pages at crash (from checkpoint + WAL)

2. Redo Phase (Forward)
   - Reapply all logged changes for committed (and some in-doubt) from last checkpoint
   - Ensures Durability (committed effects present)

3. Undo Phase (Backward)
   - Undo effects of uncommitted/aborted transactions
   - Ensures Atomicity (no partial effects)
`

End result: **Consistent state** matching committed transactions only.

## 7. Implementation Notes (PostgreSQL/MySQL)

- **PostgreSQL**: Uses **WAL** (write-ahead logging). CHECKPOINT command forces checkpoint. Recovery uses WAL replay.
- **MySQL (InnoDB)**: Also uses **redo log** + **undo log**. Similar principles.
- **Difference naming**: "Transaction Log" vs "Redo Log" vs "WAL" — concept same (log-based recovery).
- **Implementation varies**; underlying concept is universal.

## 8. COMMIT vs ROLLBACK (Quick)

| Action | Effect | Durability |
|---|---|---|
| **COMMIT** | Makes all changes permanent. Triggers WAL flush guarantee. | Yes – survives crash |
| **ROLLBACK** | Undoes all changes in transaction. Restores state. | No – discarded |
| **ROLLBACK TO SAVEPOINT** | Undoes only after savepoint | Still in transaction (can COMMIT later) |

## Key Takeaways (Interview)

- **Transaction = all-or-nothing logical unit** ensuring consistency.
- **ACID**: Atomicity (all-or-nothing), Consistency (valid state), Isolation (no interference), Durability (survives crash).
- **WAL**: Write log before data → enables redo/undo on crash.
- **Undo** = fix uncommitted. **Redo** = preserve committed.
- **Checkpoints** = speed up recovery, limit WAL scan.
- **Durability means COMMIT is "final"** even on immediate crash (recovery will redo).

## Interview Qs

**Q1. What is a Transaction? Explain ACID with example.**
- Logical unit of work. ACID with bank transfer: A (all-or-nothing), C (total preserved), I (isolated), D (committed survives).

**Q2. How does DB ensure Atomicity and Durability?**
- Atomicity via transaction log + undo (rollback uncommitted). Durability via WAL + redo (replay committed). Checkpoints optimize.

**Q3. What is WAL? Why "write-ahead"?**
- Write-Ahead Log: log change to disk before data page. Ensures recovery possible if crash between.

**Q4. Difference between Undo and Redo?**
- Undo: revert uncommitted changes. Redo: reapply committed changes not yet on data disk.

**Q5. What is a Checkpoint?**
- Flushes dirty pages to disk + records point; reduces recovery time (start from checkpoint).
