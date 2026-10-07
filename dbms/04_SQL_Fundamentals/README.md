# 04. SQL Fundamentals

> Focus: Understanding **why** DB executes these operations (semantics), not just syntax. Includes practical window functions.

## 1. Core Clauses (Order of Execution Concept)

SQL is declarative. Logical processing order (conceptual): FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT. Actual varies by optimizer.

| Clause | Purpose | Notes |
|---|---|---|
| **SELECT** | Choose columns/expressions | Projection |
| **FROM** | Source tables/views | Joins happen here conceptually |
| **WHERE** | Filter rows **before** grouping | Row-level filter |
| **GROUP BY** | Group rows by column(s) | For aggregates |
| **HAVING** | Filter **after** grouping | Group-level filter |
| **ORDER BY** | Sort result | Can use aliases in many RDBMS (Postgres/MySQL) |
| **DISTINCT** | Remove duplicates | Affects whole selected row |
| **LIMIT/OFFSET** | Restrict rows | Pagination |

## 2. Joins

Combine rows from multiple tables based on related columns (FK/PK).

| Join | Meaning | Result |
|---|---|---|
| **INNER JOIN** | Matching rows in both tables | Intersection |
| **LEFT JOIN (LEFT OUTER)** | All from left + matching from right; NULL if no match | Left + matches |
| **RIGHT JOIN (RIGHT OUTER)** | All from right + matching from left | Right + matches |
| **FULL OUTER JOIN** | All rows from both; NULL where no match | Union of both |
| **CROSS JOIN** | Cartesian product (all combinations) | M*N rows |
| **SELF JOIN** | Table joined to itself (alias required) | Hierarchies (manager–employee) |

**Why joins?** Normalize (avoid redundancy) but need to reconstruct related data for queries.

## 3. Subqueries & CTEs

### Subquery
Query nested inside another. Can be in SELECT/FROM/WHERE.

- **Scalar subquery**: returns single value
- **Row subquery**: returns single row
- **Table subquery**: returns table

**Use when**: Need intermediate result, or filter by computed set.

### CTE (Common Table Expression) – WITH
Named temporary result, readable, can be recursive.

**CTE vs Subquery**:
- CTEs more readable for multi-step logic
- Can reference CTE multiple times (in same query)
- Often same performance (optimizer treats similarly)
- Recursive CTEs powerful for hierarchies

`sql
-- CTE example
WITH dept_counts AS (
  SELECT dept_id, COUNT(*) AS emp_count
  FROM employee
  GROUP BY dept_id
)
SELECT d.dept_name, dc.emp_count
FROM department d
JOIN dept_counts dc ON d.dept_id = dc.dept_id;
`

## 4. Aggregation

Functions that operate on groups: COUNT, SUM, AVG, MIN, MAX.

- **COUNT(*)** counts rows
- **COUNT(col)** counts non-NULL values
- Use with **GROUP BY** for per-group aggregates
- Filter groups with **HAVING**, not **WHERE**

`sql
SELECT dept_id, COUNT(*) AS total, AVG(salary) AS avg_sal
FROM employee
GROUP BY dept_id
HAVING COUNT(*) > 5;
`

## 5. CASE, NULL, COALESCE

### CASE (Conditional)
Like if-else in SQL.

`sql
SELECT name,
  CASE
    WHEN salary < 40000 THEN 'Junior'
    WHEN salary < 70000 THEN 'Mid'
    ELSE 'Senior'
  END AS level
FROM employee;
`

### NULL Handling
**NULL** means "unknown/missing", not 0 or empty string.
- Comparisons: = NULL is false; use IS NULL / IS NOT NULL
- NULL + 5 = NULL, NULL AND TRUE = NULL (3-valued logic)
- Aggregates ignore NULL (mostly)

### COALESCE
Returns **first non-NULL** value. Great for defaults.

`sql
SELECT name, COALESCE(phone, 'N/A') AS phone
FROM users;
`

Also NULLIF(a,b) returns NULL if equal.

## 6. Window Functions (Practical)

**Window Functions** perform calculations across a **set of rows related to current row** (a "window"), without collapsing groups like GROUP BY. Keep all rows.

**Syntax**: FUNCTION() OVER (PARTITION BY ... ORDER BY ...)

### Key Functions
| Function | Purpose | Use Case |
|---|---|---|
| **ROW_NUMBER()** | Assigns unique sequential number | Top-N per group, deduplication logic |
| **RANK()** | Ranking with gaps (ties get same rank, next skips) | Competition rankings |
| **DENSE_RANK()** | Ranking without gaps (ties same, next continues) | Dense ranking |
| **NTILE(n)** | Divides into n buckets | Quartiles/deciles |
| **LAG/LEAD** | Access previous/next row | Period-over-period |
| **FIRST_VALUE/LAST_VALUE** | First/last in window | Running context |
| **SUM/AVG/COUNT OVER** | Running totals/averages | Cumulative metrics |

### Examples (PostgreSQL style)

**Top 2 salaries per department (ROW_NUMBER)**

`sql
SELECT dept_id, name, salary
FROM (
  SELECT dept_id, name, salary,
         ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
  FROM employee
) ranked
WHERE rn <= 2;
`

**Rank employees by salary overall**

`sql
SELECT name, dept_id, salary,
       RANK() OVER (ORDER BY salary DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS drnk,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
FROM employee;
`

**Running total (SUM OVER)**

`sql
SELECT name, dept_id, salary,
       SUM(salary) OVER (PARTITION BY dept_id ORDER BY emp_id) AS running_total
FROM employee;
`

**Compare to previous salary (LAG)**

`sql
SELECT name, dept_id, salary,
       LAG(salary, 1) OVER (PARTITION BY dept_id ORDER BY emp_id) AS prev_sal
FROM employee;
`

## 7. Execution Semantics: Why DB Executes This Way

Understanding "why" helps debug & optimize.

| Concept | Why | Interview Point |
|---|---|---|
| **Declarative (not imperative)** | Say *what* you want, not *how*. Optimizer decides plan. | "SQL is declarative; optimizer chooses access paths." |
| **Filtering early (WHERE before HAVING)** | Reduces rows early → less work for grouping/joins. | WHERE is row-filter (pre-agg); HAVING group-filter (post-agg). |
| **Indexes affect choice** | Optimizer picks index scan vs seq scan based on selectivity/cost. | See 08_Indexing |
| **Joins order matters for cost** | Some join orders cheaper; optimizer evaluates. | Cost-based optimization. |
| **GROUP BY groups, loses detail** | Aggregation collapses rows. Window keeps detail. | Key distinction. |
| **NULL 3-valued logic** | NULL != NULL is unknown; must use IS NULL. | Common source of bugs. |
| **Window OVER preserves rows** | No grouping collapse → can compute ranks + keep all columns. | Powerful for analytics. |

## 8. Practical Tips

- **Prefer CTEs** over deeply nested subqueries for readability.
- **Use EXPLAIN** (conceptually) to see plan (09_Query_Processing).
- **Don't use DISTINCT to mask bad joins** – fix logic.
- **Be careful with CROSS JOIN** – can explode row count.
- **Window functions need PostgreSQL 8.4+ (all modern RDBMS support)**.
- **For "top-N per group"** use ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...).

## Key Takeaways (Interview)

- **Execution order awareness** helps write correct (esp. WHERE vs HAVING).
- **Joins implement relationships** from normalized schema.
- **CTEs improve clarity** for complex multi-step queries.
- **Window functions vs GROUP BY**: group collapses; window preserves.
- **NULL is tri-state** – handle with IS NULL/COALESCE.
- **Declarative nature** → optimizer responsible for "how".

## Quick Interview Qs

**Q1. WHERE vs HAVING difference?**
- WHERE filters before GROUP BY (rows). HAVING filters after GROUP BY (groups). Aggregate functions allowed in HAVING, not always needed in WHERE.

**Q2. INNER vs LEFT JOIN?**
- INNER: only matched. LEFT: all left + matched from right (NULL if none).

**Q3. ROW_NUMBER() vs RANK() vs DENSE_RANK()?**
- ROW_NUMBER: unique, no gaps. RANK: ties same, skips next ranks. DENSE_RANK: ties same, no skips.

**Q4. CTE vs Subquery?**
- CTE named, reusable in same query, more readable. Often equivalent performance-wise.

**Q5. Why doesn't WHERE col = NULL work?**
- NULL is unknown; 3-valued logic. Use IS NULL.
