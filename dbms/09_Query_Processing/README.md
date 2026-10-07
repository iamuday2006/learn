# 09. Query Processing

> Covers lifecycle: Parse→Validate→Rewrite→Optimize→Plan→Execute→Result, cost-based optimization, join strategies (Nested Loop/Hash/Merge), EXPLAIN.

## 1. What is Query Processing?

**Query Processing** is the sequence of steps a DBMS takes to transform a high-level **SQL query** into an **efficient execution plan** and return results.

**Goal**: Find **correct** answer efficiently (minimize I/O, CPU, memory).

## 2. Query Processing Lifecycle

`	ext
SQL Query
  ↓
1. Parsing
  ↓
2. Validation (Semantic Checking)
  ↓
3. Query Rewriting (Normalization)
  ↓
4. Query Optimization
  ↓
5. Execution Plan Generation
  ↓
6. Query Execution (Execution Engine)
  ↓
7. Result Set Returned
`

### Step 1: Parsing
- Checks **syntax** (grammar). If wrong → syntax error.
- Builds **parse tree (abstract syntax tree)** representing query structure.
- Breaks SQL into tokens (SELECT, FROM, WHERE...).

### Step 2: Validation (Semantic Checking)
- Verifies **schema**: tables/columns/views exist, types compatible.
- Checks **permissions/authorization** (user can SELECT from table).
- Validates expressions, subqueries, joins.
- Converts to **relational algebra** (internal representation).

### Step 3: Query Rewriting (Logical Transformation)
- DBMS rewrites query to **logically equivalent, more efficient** form.
- Examples: Flatten subqueries, push predicates (WHERE) down, eliminate redundant joins, view expansion, constant folding.
- **Heuristic-based** transformations (rules) applied.

**Goal**: Reduce work before optimization.

### Step 4: Query Optimization
Finds **best execution strategy** among alternatives. Two approaches (conceptual):

| Type | Basis | Notes |
|---|---|---|
| **Heuristic (Rule-based)** | Fixed rules (push filters down, project early) | Older, less adaptive |
| **Cost-Based (CBO)** | Estimates **cost** (I/O, CPU, memory, cardinality) using stats | **Modern default** (Postgres, MySQL InnoDB, Oracle) |

**Cost-Based Optimization (CBO)** uses **table statistics**: row counts, distinct values, data distribution, index sizes. Chooses plan with **lowest estimated cost**.

### Step 5: Execution Plan Generation
- Produces a **query execution plan (QEP)** / **plan tree**.
- Tree of operators: **Scan**, **Join**, **Filter (Selection)**, **Project**, **Sort**, **Aggregate**, etc.
- Each node = physical operation with access method (Seq Scan vs Index Scan).

### Step 6: Query Execution (Execution Engine)
- **Execution Engine** runs the chosen plan step by step.
- Calls **Storage Manager/Buffer Manager** to fetch data (pages).
- Uses iterator model (pipelined) or materialized as appropriate.
- Applies operators in plan order.

### Step 7: Results Returned
- Result set formatted and sent to client via driver.

## 3. Access Methods (Scans)

| Scan Type | When Used | Notes |
|---|---|---|
| **Sequential Scan (Table Scan)** | No useful index, small table, low selectivity, or need most rows | Reads all pages/rows. Simple, low overhead |
| **Index Scan** | Index exists + selective condition | Traverses B-tree, fetches matching row locators |
| **Index-Only Scan (Covering)** | All needed cols in index | No heap fetch → fastest for covered queries (Postgres supports) |
| **Bitmap Scan** | Multiple conditions/indexes OR/AND (Postgres) | Builds bitmaps, combines efficiently |
| **Parallel Scan** | Large tables, parallel workers available | Modern DBs (Postgres 9+, others) |

## 4. Join Strategies

When joining tables, optimizer chooses among strategies based on table sizes, join type, indexes, stats.

| Join Strategy | How It Works | Best For | Complexity |
|---|---|---|---|
| **Nested Loop Join (NLJ)** | For each row in outer, scan inner table to find matches | **Small outer** table (or one has index on join key) | O(M*N) worst case |
| **Hash Join** | Build **hash table** on smaller (build) table by join key, probe with larger (probe) table | **Large, unsorted** tables, equality joins (=) | O(M+N) build+probe |
| **Merge Join (Sort-Merge)** | **Sort** both tables by join key (or if already sorted), merge like merge-sort | **Sorted** inputs or range joins (< >), large tables | O(M log M + N log N) due to sort (0 if pre-sorted) |

### Notes

- **Nested Loop**: Simple. With index on inner join key → becomes **Indexed Nested Loop** (much better, avoids full inner scan).
- **Hash Join**: Great for equality joins, needs memory for hash table. Doesn’t preserve order.
- **Merge Join**: Efficient if already sorted (clustered/indexed on join key). Works for equality + some range inequalities.
- **Optimizer picks** based on estimated sizes/cost. Small tables often NLJ, large unindexed → Hash/Merge.

## 5. Query Optimization Examples (Conceptual)

**Example 1: Predicate Pushdown**

`sql
SELECT u.name FROM users u
JOIN orders o ON u.id=o.user_id
WHERE u.is_active = true AND o.status='PAID';
`

Optimizer pushes u.is_active=true down to users scan, o.status='PAID' down to orders → filters early, fewer rows joined.

**Example 2: Projection Pushdown**

Select only needed columns early (reduce I/O/memory).

**Example 3: Rewriting Subquery**

Correlated subquery may rewrite to join (sometimes better).

## 6. EXPLAIN – Understanding Execution Plans

Most RDBMS have EXPLAIN (and EXPLAIN ANALYZE in Postgres) to show chosen plan.

**Purpose**: Diagnose slow queries, see scans/joins chosen, detect missing indexes, understand cost.

### Basic Usage (PostgreSQL)

`sql
EXPLAIN SELECT * FROM users WHERE email='test@example.com';
EXPLAIN ANALYZE SELECT * FROM users WHERE email='test@example.com';
`

**EXPLAIN** = estimated. **EXPLAIN ANALYZE** = actual run time + estimates (runs query).

### What to Look For

- **Scan Type**: Seq Scan (red flag if large + selective) vs Index Scan/Index Only
- **Cost**: Estimated (arbitrary units, relative)
- **Rows**: Estimated vs actual (big mismatch → stats outdated, run ANALYZE)
- **Join Type/Order**: Nested Loop/Hash/Merge, which table outer
- **Filter Conditions**: Applied when (rows reduced early?)
- **Buffers/Time** (ANALYZE): Actual I/O/time

**Rule of thumb**: If seeing **Seq Scan** on large table with highly selective WHERE + index exists → likely missing/up-to-date stats or index not usable (function on column, type mismatch).

## 7. Cost-Based Optimization: What Influences Cost?

| Factor | Impact |
|---|---|
| **I/O** | Page reads (dominant usually) – sequential vs random |
| **CPU** | Comparisons, sorting, hashing |
| **Memory** | Sort/hash workspaces (can spill to disk) |
| **Cardinality/Selectivity** | How many rows filtered/joined (biggest driver) |
| **Statistics** | Table size, distinct values, histograms |
| **Available Indexes** | Access paths (scan vs index) |
| **Parallelism** | Workers reduce time for large scans/joins |

**Note**: CBO relies on **up-to-date statistics** (ANALYZE in Postgres updates stats).

## 8. Query Processing Trade-offs

- **Optimization time vs execution time**: Spend a bit planning to save much executing (worth it for complex/large).
- **Heuristic fast, CBO better for complex**.
- **Plan stability vs adaptivity**: Stats change → plan can change.

## Key Takeaways (Interview)

- **Lifecycle**: Parse (syntax) → Validate (schema/privileges) → Rewrite → Optimize → Plan → Execute → Results.
- **Optimizer** chooses best plan (Cost-Based in modern DBs) using stats.
- **Joins**: NLJ (small/with index), Hash (equality, large unindexed), Merge (sorted/range).
- **Predicate/projection pushdown** = filter/project early → less work.
- **EXPLAIN** is essential to debug performance (Seq Scan on large selective query = red flag).
- **I/O dominates cost**; indexes + stats + good plans reduce I/O.

## Interview Qs

**Q1. Explain query processing steps in order.**
- Parse (syntax), Validate (semantics/privileges), Rewrite (logical), Optimize (cost-based), Plan, Execute (engine+buffer), Return.

**Q2. Cost-Based vs Rule-Based Optimization?**
- Rule-based: fixed heuristic rules. Cost-based: estimates I/O/CPU using statistics, picks lowest cost. Modern use CBO.

**Q3. Nested Loop vs Hash Join vs Merge Join – when use?**
- NLJ: small outer or inner indexed. Hash: large equality joins, unsorted. Merge: sorted inputs or range joins.

**Q4. What is EXPLAIN used for?**
- Shows execution plan (scans/joins/order/cost). EXPLAIN ANALYZE shows actual time/rows. Find slow paths, missing indexes, stale stats.

**Q5. Predicate Pushdown – what and why?**
- Move WHERE filters as early as possible (towards scans). Reduces rows earlier → less I/O/memory/join work.

**Q6. Why might optimizer choose Seq Scan over Index Scan?**
- Table very small, query returns high % of rows (low selectivity), index not selective/covering, stats outdated, or function/type mismatch prevents index use.
