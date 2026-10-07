# 08. Indexing

> Covers: 07:29:25 – Indexing in DBMS. Includes B-Tree, Hash, composite/covering/partial, clustered vs non-clustered, selectivity/cardinality, trade-offs.

## 1. What is an Index?

An **Index** is a **data structure** (separate from table data) that improves **speed of data retrieval (SELECT)** by providing fast lookup path to rows, without scanning entire table.

**Analogy**: Index of a book – find page quickly vs reading cover-to-cover.

**Goal**: Reduce **disk I/O** by locating rows via index structure.

## 2. Why Indexes? Trade-offs

### Advantages
- **Faster SELECTs** (especially WHERE, JOIN, ORDER BY on indexed cols)
- **Efficient range queries** (with B-Tree)
- **Can enforce uniqueness** (UNIQUE index)
- **Helps with sorting/grouping**
- **Reduces I/O** (fewer pages read)

### Disadvantages (Trade-offs)
- **Slower writes** (INSERT/UPDATE/DELETE) – must update index too
- **Extra disk space** – index structures stored separately
- **Overhead on maintenance** – fragmentation, bloat over time
- **Too many indexes hurt** – each DML touches all affected indexes

**Rule**: Index columns that are **frequently filtered/joined/sorted** and have **good selectivity**. Avoid indexing columns with low selectivity or write-heavy tables indiscriminately.

## 3. Core Concepts

| Term | Meaning | Notes |
|---|---|---|
| **Full Table Scan (Sequential Scan)** | Read every row/page to find matches | Slow for large tables, low selectivity |
| **Index Scan** | Use index to locate matching rows | Faster if selective |
| **Selectivity** | % of rows matched by a condition | selectivity = (matching rows / total rows) * 100 |
| **Cardinality** | Number of **distinct** values in a column | High cardinality (emails, IDs) → better for indexing |
| **Covering Index** | Index contains **all columns** needed for query | Can answer from index only (no table lookup) |

**Good candidate**: High cardinality + high filtering frequency (e.g. email, user_id).
**Poor candidate**: Low cardinality (e.g. gender, status with 2–3 values) unless combined.

## 4. Index Data Structures

### 4.1 B-Tree Index (Most Common)

**B-Tree (Balanced Tree)** is default in most RDBMS (Postgres, MySQL InnoDB uses B+Tree variant).

- **Balanced**: All leaf nodes at same depth → O(log n) lookup
- **Sorted structure** → supports **equality** (=) and **range** (> < BETWEEN LIKE 'prefix%')
- **Leaf nodes** contain pointers/row locators to actual table rows (or data in clustered)
- **B+Tree**: Internal nodes hold keys only; leaf nodes linked → efficient range scans

**Best for**: General purpose, range queries, equality, ORDER BY.

### 4.2 Hash Index

Uses **hash function** on key → maps to bucket.

- **O(1)** lookup for equality
- **No ordering** → **cannot** do range queries (> < BETWEEN)
- **Cannot** do prefix LIKE
- **Collisions** handled internally
- Less common as general index; used in specific cases (memory engines, equality lookups)

**Best for**: Exact equality lookups only (e.g. WHERE user_id = 123)

**Comparison**: B-Tree is far more versatile.

## 5. Types of Indexes

| Index Type | Description | Example |
|---|---|---|
| **Single-Column** | Index on one column | CREATE INDEX idx_email ON users(email); |
| **Composite (Multi-Column)** | Index on multiple columns (column order matters) | CREATE INDEX idx_dept_sal ON emp(dept_id, salary); |
| **Unique Index** | Enforces uniqueness; no duplicates. Implicitly created for PK/UNIQUE | CREATE UNIQUE INDEX idx_email ON users(email); |
| **Partial (Filtered) Index** | Index only subset of rows matching condition | CREATE INDEX idx_active ON users(email) WHERE is_active = true; |
| **Covering Index** | Contains all needed columns (index-only scan possible) | Avoids heap/table fetch |
| **Function-Based/Expression** | Index on expression (e.g. LOWER(email)) | CREATE INDEX idx_lower_email ON users(LOWER(email)); |
| **Bitmap Index** | Good for low-cardinality columns (less common in OLTP) | Data warehousing context |

## 6. Clustered vs Non-Clustered Index

This is **one of the most frequent interview questions**.

| Aspect | **Clustered Index** | **Non-Clustered Index** |
|---|---|---|
| **Physical Order** | Reorders **actual table data** by index key | Index is **separate**; table data remains in heap/order of insertion |
| **Number Allowed** | **Only 1** per table (can’t physically sort data two ways) | **Multiple** per table (can have many) |
| **Data Storage** | Leaf nodes **contain actual data rows** | Leaf nodes contain **pointers/row locators** (RID or PK) to data |
| **Speed** | Faster for range scans + when selecting by clustered key | Slightly slower (may need **bookmark/lookup** to get full row) |
| **Size** | Table itself is the index structure | Extra index pages |
| **INSERT/UPDATE Impact** | Can cause page splits/reorg if middle insertions | Less impact on data order, but updates index |
| **When to use** | On **primary key** (common) or column with range queries | On foreign keys, search columns, JOIN cols |
| **Examples** | InnoDB PK is clustered. SQL Server: can choose clustered key. PostgreSQL: uses **heap + B-tree**, calls PK index but table is heap (no true clustered by default; "cluster" command reorders physically) |

**Important Note (Implementation-Dependent)**:
- **MySQL InnoDB**: Primary Key → **Clustered**. Data physically ordered by PK.
- **PostgreSQL**: Tables are **heaps** (unordered). Index points to **Tuple ID (CTID)**. CLUSTER table USING index rewrites heap in index order (one-time reorg, not maintained dynamically).
- **SQL Server**: Explicit choice (clustered/non-clustered).

**Key**: Clustered = table **is** index. Non-clustered = index **points to** table.

## 7. Composite Index & Column Order

**Composite Index** spans multiple columns. **Column order is critical** (leftmost prefix rule).

**Example**: CREATE INDEX idx(a,b,c) ON table(a,b,c)

**Can use for**:
- WHERE a = ? ✓
- WHERE a = ? AND b = ? ✓
- WHERE a = ? AND b = ? AND c = ? ✓
- WHERE a = ? AND c = ? – may use a only partially (depends on optimizer)
- WHERE b = ? ✗ (misses leftmost a)
- WHERE c = ? ✗

**Rule of thumb**: Put **most selective, most frequently filtered** columns **leftmost**. Also consider equality vs range.

## 8. Covering Index

If all columns in SELECT, WHERE, ORDER BY are in index → DB can answer **without accessing table** (index-only scan).

**Benefits**: Fewer I/O, faster (avoids heap lookups).

`sql
-- Index covers query
CREATE INDEX idx_user_email_name ON users(email, name);
SELECT name FROM users WHERE email = 'a@b.com'; -- index-only
`

## 9. Partial Index

Index only rows satisfying condition → smaller index, less writes.

`sql
CREATE INDEX idx_active_users ON users(email) WHERE is_active = true;
`

**Use when**: Large table, query filters same subset often (active users).

## 10. When to CREATE Index – Decision Guide

**Good candidates**:
- Primary/Foreign keys (often auto-indexed or should be)
- Columns used in **WHERE**, **JOIN ON**, **ORDER BY**, **GROUP BY**
- High **cardinality** columns (unique-ish)
- Columns with range queries (BETWEEN, >, <)
- Tables with **many reads, fewer writes**

**When NOT to create index**:
- Very **small tables** (full scan cheaper)
- **Low selectivity** (gender, boolean flags) – often not worth it
- **Write-heavy** tables (INSERT/UPDATE/DELETE frequent)
- Columns that are **rarely queried**
- **Too many** indexes on same table (DML overhead)
- Temporary tables (usually not needed)

## 11. Internal Lookup: What Changes?

Conceptually, with index on email:

**Without Index (Seq Scan)**:
1. Read page 1 → scan all rows
2. ...
3. Check email for each → find match (could read many pages)

**With B-Tree Index (Index Scan)**:
1. Traverse root → internal nodes → leaf node (O(log n))
2. Leaf gives **row locator** (CTID in Postgres / pointer in others)
3. Fetch **exact row page** via locator (heap fetch) → return
4. Much fewer I/O if selective

**If covering**: Step 3 skipped → even faster.

## 12. Indexing in PostgreSQL Notes

- Default: **B-tree** for CREATE INDEX
- PK & UNIQUE create implicit indexes
- EXPLAIN ANALYZE shows plan (Seq Scan vs Index Scan, Index Only Scan)
- pg_stat_user_indexes / stats help evaluate
- **VACUUM** needed to maintain (bloat, dead tuples) – autovacuum handles
- REINDEX rebuilds bloated index
- No true "clustered index" by default (heap); CLUSTER physically reorders once

## 13. Practical Example

`sql
-- Table
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,  -- clustered in InnoDB, indexed in PG
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  dept_id INT,
  is_active BOOLEAN
);

-- Additional indexes
CREATE INDEX idx_users_dept ON users(dept_id);
CREATE INDEX idx_active ON users(email) WHERE is_active = true;
CREATE INDEX idx_dept_active ON users(dept_id, is_active);

-- Query
EXPLAIN ANALYZE
SELECT name FROM users WHERE dept_id = 5 AND is_active = true;
`

Optimizer may use idx_dept_active (composite) or choose based on stats.

## Key Takeaways (Interview)

- **Indexes speed reads, slow writes** – fundamental trade-off.
- **B-Tree**: most versatile (equality + range). **Hash**: equality only.
- **Clustered**: 1 per table, reorders data (leaf = data). **Non-clustered**: many, separate, points to data.
- **Column order matters** in composite (leftmost prefix).
- **Covering index** avoids table lookup (index-only).
- **High cardinality + selective** queries benefit most.
- **Small tables, write-heavy, low selectivity** → often skip.

## Interview Qs

**Q1. What is an Index? Why use it? Trade-offs?**
- Data structure for fast lookup. Speeds SELECTs, reduces I/O. But slows writes (DML), uses space, needs maintenance.

**Q2. B-Tree vs Hash Index?**
- B-Tree: balanced, sorted → supports =, >, <, BETWEEN, prefix LIKE. Hash: O(1)= only, no range/prefix.

**Q3. Clustered vs Non-Clustered Index?**
- Clustered: reorders physical data, leaf=data, 1 per table (faster range). Non-clustered: separate index, leaf=pointer, multiple (needs lookup).

**Q4. When should you NOT create an index?**
- Small table, write-heavy, low selectivity columns, rarely queried, too many existing indexes.

**Q5. What is a Covering Index?**
- Index has all columns needed → query satisfied from index only (no table access). Faster.

**Q6. Composite index column order importance?**
- Leftmost prefix rule: (a,b) can use a or (a,b), not b alone. Put most selective/frequent leftmost.

**Q7. Why do indexes slow down writes?**
- On INSERT/UPDATE/DELETE, DB must update table + every affected index → extra I/O/work.
