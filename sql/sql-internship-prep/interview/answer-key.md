# Answer Key

This file contains the full solutions to the coding rounds and interview banks. Use it to check your work after attempting each problem.

---

## Easy (interview/easy.md)

| Q# | Answer |
|----|--------|
| Q1 | A database is an organized collection of structured data stored electronically, managed by a DBMS. |
| Q2 | A DBMS manages any data; an RDBMS specifically stores data in related tables with keys and relationships (relational model + SQL). |
| Q3 | A column(s) that uniquely identifies each row, implicitly NOT NULL, one per table. |
| Q4 | A column referencing another table's PK, enforcing referential integrity (FK constraint). |
| Q5 | DELETE: row-by-row, can be rolled back, fires triggers. TRUNCATE: all at once, faster, resets sequences, minimal logging. |
| Q6 | `SELECT * FROM employees WHERE department = 'Data' AND salary > 80000;` |
| Q7 | Removes duplicate rows from the result set. |
| Q8 | WHERE filters rows before grouping; HAVING filters groups after aggregation. |
| Q9 | Unknown/missing/not-applicable data; not zero, not empty string. |
| Q10 | NULL (unknown). Always use IS NULL. |
| Q11 | INNER: only matches. LEFT: all left + matches (right NULL if unmatched). |
| Q12 | A table joined to itself, using aliases. For hierarchies or row-to-row comparisons. |
| Q13 | COUNT(*): all rows. COUNT(col): non-NULL values only. |
| Q14 | `SELECT department, COUNT(*) FROM employees GROUP BY department;` |
| Q15 | `SELECT department, COUNT(*) FROM employees GROUP BY department HAVING COUNT(*) > 3;` |
| Q16 | A function collapsing multiple rows: COUNT, SUM, AVG, MIN, MAX. |
| Q17 | Sorts the result set. DESC descending, ASC ascending (default). |
| Q18 | Restricts the number of rows returned. |
| Q19 | UNION: removes duplicates. UNION ALL: keeps all rows (faster). |
| Q20 | `SELECT MAX(salary) FROM employees;` |

---

## Medium (interview/medium.md)

| Q# | Key insight |
|----|-------------|
| Q1 | LEFT JOIN + WHERE on right table → filters NULLs → becomes INNER JOIN. Fix: move to ON clause. |
| Q2 | `NOT EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id)` |
| Q3 | All equivalent; EXISTS short-circuits; JOIN can multiply; IN materializes. Prefer EXISTS for existence. |
| Q4 | Subquery referencing outer query, re-evaluated per outer row. Often slower than JOIN. |
| Q5 | If subquery returns any NULL, NOT IN returns NULL for all rows. Use NOT EXISTS. |
| Q6 | Correlated subquery or JOIN+GROUP BY. |
| Q7 | ROW_NUMBER: unique 1,2,3. RANK: ties share, gaps (1,1,3). DENSE_RANK: ties share, no gaps (1,1,2). |
| Q8 | `DENSE_RANK() OVER (ORDER BY salary DESC)` then filter `rk = 2`. |
| Q9 | `ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC)` then `rn <= 3`. |
| Q10 | WITH clause; named temporary result set for readability and reuse. |
| Q11 | Recursive CTE: anchor (CEO) UNION ALL recursive (reports joining to previous level). |
| Q12 | `COUNT(*) FILTER (WHERE status = 'delivered')` or `SUM(CASE WHEN ...)` |
| Q13 | Returns first non-NULL argument. |
| Q14 | `WHERE order_date >= NOW() - INTERVAL '30 days'` |
| Q15 | `GROUP BY DATE_TRUNC('month', order_date)` |
| Q16 | NULLs excluded; NULL <> 100 is NULL (not TRUE). |
| Q17 | 0. COUNT ignores NULL. |
| Q18 | ROW_NUMBER partitioned by email ordered by user_id, delete rn > 1. |
| Q19 | INTERSECT: whole-row comparison, distinct. INNER JOIN: key-based, can multiply. |
| Q20 | `SELECT product_id FROM order_items INTERSECT SELECT product_id FROM sale_items;` |

---

## Hard (interview/hard.md)

| Q# | Key insight |
|----|-------------|
| Q1 | `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)` or ROW_NUMBER approach. |
| Q2 | `ABS(salary - (SELECT AVG(salary) FROM employees))` then ORDER BY diff LIMIT 1. |
| Q3 | CTE monthly aggregates + ROW_NUMBER partitioned by year, ordered by revenue DESC. |
| Q4 | `generate_series` + LEFT JOIN where order_id IS NULL. |
| Q5 | `day - ROW_NUMBER * INTERVAL '1 day'` → group by to find islands. |
| Q6 | Staging + ON CONFLICT + transaction + watermark update. |
| Q7 | EXCEPT, NOT EXISTS, LEFT JOIN IS NULL — three equivalent approaches. |
| Q8 | PARTITION BY RANGE on event_ts + monthly partition tables + GIN on JSONB. |
| Q9 | Non-sargable predicate: rewrite to `WHERE order_date >= ... AND order_date < ...`. |
| Q10 | Low selectivity, stale statistics, function on column, or seq scan cheaper. |
| Q11 | Two transactions hold conflicting locks. Fix: lock in same order, short transactions. |
| Q12 | Detects serialization conflicts and aborts (error 40001). Retry required. |
| Q13 | EXISTS for A∩B, NOT EXISTS for ¬C, GROUP BY to combine. |
| Q14 | `SUM() OVER ()` for grand total, then `100.0 * rev / grand_total`. |
| Q15 | ROW_NUMBER partitioned by customer_id ordered by order_date, filter rn = 1. |

---

## Internship Killer (interview/internship-killer.md)

| Q# | Correct answer | Trap |
|----|---------------|------|
| Q1 | 0 (no rows match → COUNT = 0) | People say NULL |
| Q2 | NULL (not TRUE or FALSE) | People say FALSE |
| Q3 | FALSE (1 IS in the list) | — |
| Q4 | NULL (NOT IN with any NULL → NULL) | People say TRUE |
| Q5 | No (WHERE runs before SELECT) | People say yes |
| Q6 | Both get rank 1 (DENSE_RANK) | People say 1 and 2 |
| Q7 | RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW | People say UNBOUNDED TO UNBOUNDED |
| Q8 | Only if WHERE doesn't filter left-side rows | People say always |
| Q9 | Empty result set (no error) | People say error |
| Q10 | Yes: `INSERT ... RETURNING id` (PostgreSQL) | People say no |
| Q11 | 0 rows affected, no error | People say error |
| Q12 | NULL (all args NULL → result NULL) | People say empty string |
| Q13 | Unlimited (PG treats NULLs as distinct) | People say one |
| Q14 | 0 (NULLs ignored) | People say 1 |
| Q15 | Yes (1:1 table: PK + FK) | People say no |