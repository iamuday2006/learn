# 07. Concurrency Control

> Critical for interviews. Covers concurrent issues, isolation levels, locks, deadlocks, MVCC (conceptual). PostgreSQL/MySQL notes.

## 1. What is Concurrency Control?

**Concurrency Control** ensures that when **multiple transactions** run simultaneously (multi-user), the database remains **correct, consistent, and isolated** — preventing data corruption/race conditions.

**Goal**: Maximize **concurrency (throughput)** while preserving **correctness (ACID - Isolation)**.

## 2. Problems with Concurrent Transactions (Read/Write Conflicts)

These are **phenomena** (anomalies) that occur if isolation is weak.

| Anomaly | Type | What Happens | Example |
|---|---|---|---|
| **Lost Update** | Write–Write | Two transactions update same row, one overwrites other's update (lost). | T1 sets x=10, T2 sets x=20 at same time; final 20 but T1’s effect lost. |
| **Dirty Read** | Read–Write | T2 reads **uncommitted** data from T1 that later gets **rolled back**. | T1 debits, T2 sees new balance, T1 rolls back → T2 saw "dirty" (invalid) data. |
| **Non-Repeatable Read (NRR)** | Read–Read (with intervening write) | Same row read **twice** in same transaction gives **different** values (because T2 updated+committed in between). | T1 reads balance=500. T2 updates to 600+commits. T1 reads again → 600 (inconsistent within transaction). |
| **Phantom Read** | Read–Range (with intervening insert/delete) | Same **query range** executed twice returns **different set of rows** (phantoms appear/disappear). | T1: "all accounts > 1000". T2 inserts new account>1000+commits. T1 re-runs → sees extra row ("phantom"). |

**Key Distinction**:
- **Non-Repeatable**: Same row, different values
- **Phantom**: Same query, different row **set** (due to inserts/deletes)

## 3. Transaction Isolation Levels

SQL defines 4 isolation levels (ANSI/ISO). Higher isolation → fewer anomalies, less concurrency (more locking). Lower → more concurrency, more anomalies.

| Isolation Level | Lost Update | Dirty Read | Non-Repeatable Read | Phantom Read | Notes |
|---|---|---|---|---|---|
| **Read Uncommitted (RU)** | Possible | **Allowed (Yes)** | Possible | Possible | No isolation. Fastest, most unsafe. Rarely used. |
| **Read Committed (RC)** | Prevented (usually) | **Prevented (No)** | **Allowed (Yes)** | Possible | Default in **PostgreSQL, Oracle** (Postgres RC uses MVCC snapshot per statement in effect, but default behavior RC semantics). |
| **Repeatable Read (RR)** | Prevented | Prevented | **Prevented (No)** | **Possible in some DBs** (MySQL InnoDB prevents with gap locks, PG prevents in practice via snapshot) | Default in **MySQL InnoDB**. PostgreSQL RR = Serializable in effect historically; PG implements RR as snapshot isolation (prevents phantoms in PG semantics). |
| **Serializable (SERIALIZABLE)** | Prevented | Prevented | Prevented | **Prevented (No)** | Highest isolation. As if transactions ran serially. Most correct, slowest (locks or SSI). |

**Important Nuance (Implementation-Dependent)**:
- **PostgreSQL**: Uses **MVCC**. READ COMMITTED = sees committed data per statement. REPEATABLE READ = snapshot for entire transaction (prevents non-repeatable + phantoms in PG). SERIALIZABLE uses Serializable Snapshot Isolation (SSI).
- **MySQL (InnoDB)**: REPEATABLE READ uses MVCC + **gap locks** → prevents phantom reads. READ COMMITTED similar.

> **Implementation varies** between DBs. Concepts above are ANSI; real behavior differs slightly (especially phantoms).

## 4. Locks (Pessimistic Concurrency)

**Locks** prevent conflicting access to same data. Used in 2PL (Two-Phase Locking) or explicit locking.

### Lock Types

| Lock Type | Mode | Grants Access To | Blocks |
|---|---|---|---|
| **Shared Lock (S)** | Read lock | Multiple transactions can **read** simultaneously | Writers (Exclusive) |
| **Exclusive Lock (X)** | Write lock | Only **one** transaction can read/write | All others (S and X) |

**Compatibility**: S–S compatible. S–X/X–S incompatible. X–X incompatible.

### Lock Granularity

| Granularity | What Locked | Concurrency | Overhead |
|---|---|---|---|
| **Table-level** | Entire table | Low (blocks many rows) | Low overhead |
| **Row-level** | Individual rows | High (fine-grained) | Higher overhead (more locks) |
| **Page/Block** | Data pages | Middle | Middle |
| **Database-level** | Whole DB | Very low | Minimal |

**Trade-off**: Finer granularity = higher concurrency + higher lock management overhead.

### Two-Phase Locking (2PL) – Conceptual

Protocol to ensure serializability:
1. **Growing Phase**: Acquire locks (no releases)
2. **Shrinking Phase**: Release locks (no new acquisitions)

Strict 2PL: Hold exclusive locks until COMMIT/ROLLBACK (prevents cascading rollbacks).

## 5. Deadlocks

**Deadlock**: Two+ transactions wait forever for each other to release locks (circular wait).

**Example**:
- T1 locks Row A, waits for Row B
- T2 locks Row B, waits for Row A → Deadlock

### Deadlock Handling

1. **Deadlock Prevention**: Prevent circular wait (timeouts, lock ordering, pre-acquisition). Can hurt concurrency.
2. **Deadlock Detection**: DB detects cycles (wait-for graph), chooses **victim** (usually transaction doing least work) and **ROLLBACKs** it.
3. **Timeouts**: If lock not acquired in time → abort transaction.

**RDBMS behavior**: Most detect+resolve (Postgres, MySQL InnoDB auto-detect, roll back victim).

## 6. MVCC (Multi-Version Concurrency Control) – Optimistic/Pessimistic Hybrid

**MVCC** is how modern RDBMS achieve **high concurrency** without locking reads. Instead of locking rows, it keeps **multiple versions** of data for concurrent transactions.

**Core idea**: **Readers don't block writers, writers don't block readers.**

### How MVCC Works (Conceptual)

- When a row is **updated**, DB creates a **new version** (copy with new values), keeps old version(s).
- Each transaction sees a **consistent snapshot** of data at its **start time** (or statement time, depending on isolation level).
- Uses **transaction IDs (XIDs)/timestamps** to determine row visibility: "Is this version visible to my transaction?"

**Result**:
- **Reads** = see snapshot (consistent) → no shared locks needed for SELECT
- **Writes** = create new versions → conflicts resolved on write/commit
- Helps prevent **Dirty Reads, Non-Repeatable Reads, Phantoms** depending on snapshot scope.

### MVCC Benefits

- **High concurrency**: Read-heavy workloads scale well
- **Less locking overhead**
- **Non-blocking reads** → better performance
- **Snapshot Isolation** naturally avoids many anomalies

### Trade-offs

- **Extra storage**: Multiple row versions (old versions kept until "vacuumed")
- **Cleanup overhead**: VACUUM (Postgres) removes old versions no longer visible to any transaction
- **Write conflicts** still possible (optimistic concurrency control on updates)

### DB Implementation Notes

- **PostgreSQL**: Pure MVCC. Uses **visibility info** + VACUUM (autovacuum) to reclaim old versions (tuple bloat managed).
- **MySQL InnoDB**: MVCC + row-level locks + gap locks. Also uses undo logs for versions.
- **Oracle**: Similar MVCC (read consistency).
- **SQL Server**: Snapshot isolation available (MVCC-based).

**Key Point**: MVCC is why READ COMMITTED/REPEATABLE READ in modern DBs are efficient and avoid many locking bottlenecks.

## 7. Isolation Levels vs Implementation (Practical)

| Aspect | Locks (Pessimistic) | MVCC (Optimistic-like snapshots) |
|---|---|---|
| Reads | May acquire S locks | No locks, read snapshot versions |
| Blocking | Readers block writers (if S held long) or vice versa | Minimal blocking (readers/writers don't block each other) |
| Concurrency | Lower | Higher |
| Used By | Traditional 2PL | PostgreSQL, Oracle, MySQL InnoDB (hybrid) |

Modern systems use **hybrid** (MVCC for reads + locks for writes/conflicts).

## 8. Choosing Isolation Level

| Use Case | Recommended | Rationale |
|---|---|---|
| **Read-heavy analytics/reports** | READ COMMITTED | Good balance, consistent per statement |
| **Banking/payments (critical)** | **SERIALIZABLE** | Max correctness (avoid any anomalies). Accept perf trade-off |
| **General web apps** | READ COMMITTED | Default, safe enough, good concurrency |
| **Inventory counts needing consistency across reads** | REPEATABLE READ or SERIALIZABLE | Avoid non-repeatable/phantoms |
| **Bulk reporting, no concurrent writes concern** | READ COMMITTED/UNCOMMITTED (rare) | Performance |

## 9. Concurrency Control Summary Table

| Issue | Caused By | Prevented At |
|---|---|---|
| Lost Update | Write–Write | RC+ (locks or version checks) |
| Dirty Read | Read uncommitted Write | >= READ COMMITTED |
| Non-Repeatable Read | Read, Write+Commit, Read again | >= REPEATABLE READ |
| Phantom Read | Range Read, Insert/Delete+Commit, Read again | **SERIALIZABLE** (and often RR in modern MVCC DBs with gap locks) |

## Key Takeaways (Interview)

- **Concurrency Control** balances correctness (Isolation) vs throughput.
- **Dirty/Non-repeatable/Phantom** are key anomalies – know differences clearly.
- **READ COMMITTED** default in PG/Oracle, **REPEATABLE READ** default in MySQL InnoDB.
- **MVCC** = readers don't block writers → high concurrency via versioned snapshots. Achieved via undo/version storage + visibility rules.
- **Locks** enforce exclusivity (writes). **Deadlocks** detected/resolved by DB.
- **SERIALIZABLE** gives strongest correctness (serial execution equivalent) but lowest concurrency.
- **Implementation-dependent**: PG's RR prevents phantoms (snapshot), ANSI states may differ.

## Interview Qs

**Q1. Dirty Read vs Non-Repeatable Read vs Phantom Read?**
- Dirty: read uncommitted (later rolled back). NRR: same row, different values on re-read (intervening update). Phantom: same range query, different row set (intervening insert/delete).

**Q2. Explain MVCC. How does it help concurrency?**
- Multi-Version Concurrency: keeps row versions, transactions read consistent snapshots. Readers don’t block writers, writers don’t block readers → higher concurrency. Uses visibility by XID/timestamp.

**Q3. READ COMMITTED vs REPEATABLE READ vs SERIALIZABLE?**
- RC: sees committed data per statement (prevents dirty). RR: snapshot for whole txn (prevents dirty+NRR). SERIALIZABLE: full isolation, as-if serial (prevents all).

**Q4. What is a Deadlock? How handled?**
- Circular wait of locks. Handled by prevention (ordering/timeouts) or detection+victim rollback (most DBs detect cycles).

**Q5. Shared vs Exclusive Lock?**
- S (read): multiple readers OK, blocks writers. X (write): exclusive, blocks all.

**Q6. Lost Update anomaly?**
- Two txns overwrite each other’s write → lost. Prevented at RC+ (locking or optimistic version check).
