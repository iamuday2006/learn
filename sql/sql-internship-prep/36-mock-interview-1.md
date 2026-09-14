# 36 — Mock Interview 1: Fundamentals (20 Questions)

**Time: 45 minutes. No IDE. Explain each answer out loud.**

---

## Setup

You are interviewing for a **Data Engineering Intern** role. The interviewer begins with SQL fundamentals and works through joins, aggregation, NULL, and subqueries.

---

## Questions

### Q1. What is a primary key?
### Q2. What is a foreign key? What happens when you delete a referenced row?
### Q3. What is the difference between WHERE and HAVING?
### Q4. What does COUNT(*) count vs COUNT(column)?
### Q5. Why can't you use an aggregate function in WHERE?
### Q6. What is three-valued logic?
### Q7. What does `NULL = NULL` return?
### Q8. What is the difference between INNER JOIN and LEFT JOIN?
### Q9. Why can a LEFT JOIN accidentally become an INNER JOIN?
### Q10. What is a self join? Give an example use case.
### Q11. What is the difference between UNION and UNION ALL?
### Q12. What does COALESCE do?
### Q13. What is the difference between IN and EXISTS?
### Q14. What is the NOT IN NULL trap?
### Q15. What is a correlated subquery?
### Q16. What is a composite key? When would you use one?
### Q17. What does SELECT DISTINCT do?
### Q18. What is the difference between DELETE and TRUNCATE?
### Q19. What is the logical order of query execution?
### Q20. What is the difference between a natural key and a surrogate key?

---

## Answers

### Q1: What is a primary key?
**30s:** A column (or set of columns) that uniquely identifies each row. It is implicitly NOT NULL. Only one PK per table.
**Follow-up:** Can a PK be composite? Yes — e.g., `PRIMARY KEY (order_id, product_id)` for order_items.

### Q2: Foreign key + delete behavior?
**30s:** A foreign key references a PK in another table, enforcing referential integrity. On delete: default RESTRICT (blocks the delete), or you can set ON DELETE CASCADE (deletes child rows) or ON DELETE SET NULL.
**Follow-up:** When would you use CASCADE? When child rows are meaningless without the parent. When would you avoid it? When you need an audit trail.

### Q3: WHERE vs HAVING?
**30s:** WHERE filters rows before grouping; HAVING filters groups after aggregation. You cannot use aggregate functions (COUNT, SUM) in WHERE — only in HAVING.
**Follow-up:** Write a query that uses both. `SELECT dept, COUNT(*) FROM emp WHERE salary > 50000 GROUP BY dept HAVING COUNT(*) > 3;`

### Q4: COUNT(*) vs COUNT(column)?
**30s:** COUNT(*) counts all rows. COUNT(column) counts only non-NULL values. COUNT(DISTINCT column) counts distinct non-NULL values.
**Follow-up:** If every row has column=NULL, COUNT(*) returns the total but COUNT(column) returns 0.

### Q5: Aggregate in WHERE?
**30s:** WHERE runs before grouping (step 2 in logical execution). Aggregates only exist after GROUP BY (step 3). That's what HAVING is for.

### Q6: Three-valued logic?
**30s:** Every comparison in SQL can be TRUE, FALSE, or NULL (unknown). NULL compared to anything is NULL. This affects AND/OR: FALSE dominates AND, TRUE dominates OR, anything with NULL usually yields NULL.

### Q7: NULL = NULL?
**30s:** NULL. NULL is unknown, so it's not equal to itself. Always use IS NULL / IS NOT NULL.

### Q8: INNER vs LEFT JOIN?
**30s:** INNER returns only matched rows from both sides. LEFT returns all rows from the left table plus matches from the right; unmatched right-side columns are NULL.

### Q9: LEFT JOIN becoming INNER?
**30s:** When you put a WHERE condition on the right (preserved) table, it filters out the NULL rows created by the LEFT JOIN. Fix: move the condition into the ON clause.

### Q10: Self join?
**30s:** A table joined to itself, typically for hierarchies (employees/managers) or row-to-row comparisons (previous/next record). Uses table aliases to distinguish the two copies.

### Q11: UNION vs UNION ALL?
**30s:** UNION deduplicates (slower). UNION ALL keeps all rows (faster). Use UNION ALL when duplicates are impossible or harmless.

### Q12: COALESCE?
**30s:** Returns the first non-NULL argument. `COALESCE(NULL, NULL, 'fallback')` → 'fallback'. Used to provide default values for potentially-NULL columns.

### Q13: IN vs EXISTS?
**30s:** IN materializes a list and checks membership. EXISTS checks for the existence of at least one row and short-circuits. NOT EXISTS is generally preferred over NOT IN because NOT IN has the NULL trap.

### Q14: NOT IN NULL trap?
**30s:** If the subquery returns any NULL, NOT IN returns no rows because `x NOT IN (1, 2, NULL)` evaluates to `x<>1 AND x<>2 AND x<>NULL` → NULL (unknown) → not TRUE. Fix: use NOT EXISTS instead.

### Q15: Correlated subquery?
**30s:** A subquery that references the outer query and is re-evaluated for each outer row. Often slower than an equivalent JOIN — rewrite when performance matters.

### Q16: Composite key?
**30s:** A PK made of multiple columns. Used when no single column uniquely identifies a row — e.g., order_items: (order_id, product_id). This also serves as a natural unique constraint.

### Q17: DISTINCT?
**30s:** Removes duplicate rows from the result set. Operates on the full selected row. Don't use it as a band-aid — check if your JOIN is causing duplicates instead.

### Q18: DELETE vs TRUNCATE?
**30s:** DELETE removes rows one at a time (can be rolled back, fires triggers). TRUNCATE removes all rows at once (faster, resets sequences, minimal logging). In PostgreSQL both are transactional, but TRUNCATE is faster for large tables.

### Q19: Logical order of execution?
**30s:** FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT/OFFSET.

### Q20: Natural key vs surrogate key?
**30s:** A natural key is a real-world identifier (email, SSN, country_code). A surrogate key is an artificial ID (SERIAL/IDENTITY) with no business meaning. Surrogate keys are immutable and don't leak business data; natural keys are meaningful but may change.

---

## Score yourself

| Score | Meaning |
|-------|---------|
| 18–20 | Strong fundamentals |
| 14–17 | Solid, review gaps |
| 10–13 | Needs study on weak areas |
| <10 | Re-read chapters 01–07 before continuing