# SQL Interview Cheat Sheet

**Clauses order (logical)**: FROM→WHERE→GROUP BY→HAVING→SELECT→DISTINCT→ORDER BY→LIMIT

**WHERE vs HAVING**: pre-group vs post-group (aggs in HAVING)

**Joins**: INNER matched, LEFT all left+NULL, RIGHT, FULL, CROSS (cartesian), SELF

**CTE vs Subquery**: WITH reusable/readable, recursive possible

**NULL**: IS NULL/IS NOT NULL, COALESCE(first non-null), 3-valued logic

**Window**: ROW_NUMBER unique, RANK gaps, DENSE_RANK no gaps. OVER (PARTITION BY ... ORDER BY ...)

**Top-N per group**: use ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) rn WHERE rn<=N

**UNION vs UNION ALL**: UNION dedups, UNION ALL keeps

**Keys**: PK, FK, UNIQUE, COMPOSITE

**Constraints**: NOT NULL, CHECK, DEFAULT

**EXPLAIN**: see plan (seq/index scan, joins). EXPLAIN ANALYZE actual.
