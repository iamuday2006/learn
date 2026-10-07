# 01. DBMS Architecture

> Covers: 00:44:13 – DBMS Architecture and DBA (video). Expands with end-to-end query flow.

## 1. Architectural Levels (Recap)

As covered in 00_Fundamentals: External (View) → Conceptual (Logical) → Internal (Physical). DBMS architecture describes how components interact.

## 2. DBMS Architecture Types

### Single-Tier Architecture
- **User, App, DB all on same machine**.
- DBMS directly accessed (e.g. SQLite local app).
- Simple, but poor for multi-user sharing.
- **Use case**: Desktop apps, local tools.

### Two-Tier Architecture (Client–Server)
`	ext
Client (UI + App logic) ←→ DB Server (DBMS + Data)
`
- **Client**: Presentation + application logic, sends SQL queries.
- **Server**: DBMS processes queries, returns results.
- **Pros**: Better than 1-tier, direct communication.
- **Cons**: Heavy client if app logic thick; difficult to maintain across clients.
- **Examples**: Legacy client apps connecting to DB server.

### Three-Tier Architecture (Most Common for Web Apps)
`	ext
Client (Browser/UI) → Application Server (Business Logic) → Database Server (DBMS)
`
- **Presentation Tier**: UI (browser/mobile)
- **Application/Middle Tier**: Business rules, validation, auth, APIs
- **Data Tier**: DBMS, storage
- **Pros**: Separation of concerns, scalable, secure (DB not exposed directly), easier maintenance
- **Cons**: More complex setup
- **Examples**: E-com sites, banking apps, most backend systems.

## 3. DBMS Components (Core Modules)

A DBMS has several interacting components. Key ones:

| Component | Purpose | Notes |
|---|---|---|
| **Query Processor** | Parses, validates, optimizes, executes SQL | Turns SQL into efficient execution plan |
| **Parser** | Checks syntax, builds parse tree | First step for query |
| **Query Translator/Verifier** | Validates tables/columns/permissions | Semantic checks |
| **Query Optimizer** | Chooses best plan (cost-based in modern RDBMS) | Impacts performance |
| **Execution Engine** | Runs chosen plan, interacts with Storage Manager | Executes operators (scan/join) |
| **Storage Manager (DB Manager)** | Manages data access, consistency, security, concurrency | Bridge between query engine & disk |
| **Authorization & Integrity Manager** | Checks privileges, enforces constraints (PK/FK/UNIQUE/CHECK) | Security + correctness |
| **Transaction Manager** | Ensures ACID properties, manages commits/rollbacks | Critical for correctness |
| **Concurrency Control Manager** | Handles locks, MVCC coordination | Prevents conflicts |
| **Buffer Manager** | Manages buffer pool (in-memory pages) | Minimizes disk I/O |
| **File Manager** | Manages disk files, allocation, organization | Low-level file access |
| **Recovery Manager** | Uses logs (WAL), undo/redo, checkpoints for crash recovery | Durability + Atomicity |

## 4. Typical DBMS Architecture Diagram (ASCII)

`	ext
+---------------------------+  (External/View)
|      User/Application     |  e.g. REST API, CLI, UI
+------------+--------------+
             | SQL/Queries
             v
+---------------------------+  (Interface)
|         DB Driver         |  JDBC/ODBC/psycopg etc.
+------------+--------------+
             | Network (or local)
             v
+---------------------------+  (Database Server)
|  Query Processor           |
|    - Parser                |
|    - Validator             |
|    - Optimizer             |
|    - Execution Engine      |
+------------+--------------+
             | Data requests
             v
|  Storage Manager           |
|    - Authorization/Integrity|
|    - Transaction Manager   |
|    - Concurrency Control   |
|    - Buffer Manager        |
|    - File Manager          |
+------------+--------------+
             | Page/Block I/O
             v
+---------------------------+  (Storage)
|  Disk/SSD (Data Files,    |
|   Index Files, Log Files)  |
+---------------------------+
`

Also shows **Transaction Log/WAL** files used by Recovery Manager (separate from data files).

## 5. What Happens When You Run SELECT * FROM users WHERE id = 10;

Let's trace end-to-end through the system:

1. **Application**: Sends SQL via DB driver (e.g. psycopg2, JDBC).
2. **Connection**: Driver connects to DB server (connection pooling may be used).
3. **Query Processor – Parser**: Checks SQL syntax. If invalid → syntax error.
4. **Query Processor – Validator/Semantic Check**: Verifies users table exists, id column exists, user has SELECT privilege.
5. **Query Processor – Query Rewriter** (optional): Simplifies/normalizes (views, rules).
6. **Query Processor – Optimizer**: Generates multiple execution plans, estimates cost (I/O, CPU). Picks cheapest/efficient plan.
   - Options: **Sequential Scan** (full table) or **Index Scan** (if index on id exists)
7. **Query Processor – Execution Engine**: Takes plan, requests data from Storage Manager.
8. **Storage Manager – Authorization/Integrity**: Re-checks access/constraints as needed.
9. **Storage Manager – Buffer Manager**: Checks if required page(s) containing row with id=10 are in **Buffer Pool** (memory).
   - If **yes (cache hit)**: Return from memory (fast).
   - If **no (cache miss)**: Request File Manager to read page from disk into buffer pool.
10. **File Manager**: Reads data page(s) from disk (data files). Does I/O.
11. **Buffer Manager**: Places page in buffer pool (uses replacement policy if full: LRU-like), pins/locks as needed.
12. **Storage Manager – Concurrency Control**: Ensures consistent read (MVCC in Postgres: reads snapshot, doesn't block writers typically).
13. **Execution Engine**: Filters/Projects as per plan (here: WHERE id=10, return all cols). Formats result.
14. **Back to Application**: Result set returned via driver to app.

**Key Point**: Most time often spent in **disk I/O** + **buffer pool lookups**. Indexes help avoid full table scans.

## 6. Buffer Manager, Transaction Manager, Recovery Manager (Details)

| Manager | Role | Interview Angle |
|---|---|---|
| **Buffer Manager** | Caches disk pages in RAM (buffer pool). Reduces I/O. Handles page replacement (e.g. clock/LRU variants). | "Why is DB fast? Because of buffer pool reducing disk I/O." |
| **Transaction Manager** | Coordinates transactions, enforces ACID. Manages transaction states, BEGIN/COMMIT/ROLLBACK. | "Ensures all-or-nothing + correct state." |
| **Recovery Manager** | Uses **Write-Ahead Log (WAL)** + undo/redo + checkpoints to restore DB to consistent state after crash. Ensures **Durability** (committed data survives) & helps with **Atomicity**. | See 06_Transactions for full WAL details. |

## 7. Client–Server vs 3-Tier (Quick Comparison)

| Aspect | 2-Tier (Client–Server) | 3-Tier (Web Apps) |
|---|---|---|
| Layers | Client + DB Server | Client + App Server + DB Server |
| Business Logic | Often in client (or split) | Centralized in App Server |
| Security | DB exposed to clients | DB behind app server (better) |
| Scalability | Limited | Easier to scale app tier |
| Maintenance | Harder (update all clients) | Easier (central logic) |
| Typical Use | Desktop apps, internal tools | Web/mobile apps, APIs |

## Key Takeaways (Interview)

- **3-tier is standard** for modern apps (separates UI, logic, data).
- **Query flow**: SQL → Parser → Optimizer → Execution Engine → Buffer/Storage → Disk → Result back.
- **Buffer Pool** is critical: hitting memory avoids disk I/O.
- **Transaction/Concurrency/Recovery Managers** enforce ACID + correctness under failures/concurrency.
- **Optimizer chooses plan** (index vs full scan) — that's why indexing matters.

## Quick Interview Qs

**Q1. Explain 3-tier DBMS architecture with diagram (conceptually)?**
- Presentation (UI) → Application (Business Logic) → Data (DBMS). Promotes separation, security, scalability.

**Q2. What happens internally when you execute a SQL query?**
- Parse (syntax), validate (schema/privileges), optimize (choose best plan), execute via engine, buffer manager checks cache, file manager reads from disk if miss, concurrency control ensures consistent view, result returned.

**Q3. Role of Buffer Manager?**
- Caches pages in memory to minimize disk I/O; critical for performance.
