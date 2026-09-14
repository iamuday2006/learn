# Easy Interview Questions

**20 questions. Level 1–2. Target: 5 minutes each.**

---

## Fundamentals

### Q1. What is a database?
A organized collection of data, structured in tables with rows and columns, managed by a DBMS.

### Q2. What is the difference between a DBMS and an RDBMS?
A DBMS manages any data storage system. An RDBMS specifically stores data in **related tables** with keys and relationships, enforcing integrity via SQL.

### Q3. What is a primary key?
A column (or set of columns) that uniquely identifies each row. Implicitly NOT NULL. Only one per table.

### Q4. What is a foreign key?
A column that references a primary key in another table, enforcing referential integrity.

### Q5. What is the difference between DELETE and TRUNCATE?
DELETE removes rows one at a time (can be rolled back, fires triggers). TRUNCATE removes all rows at once (faster, resets sequences, minimal logging). Both are transactional in PostgreSQL.

---

## SELECT, WHERE, ORDER BY

### Q6. Write a query to find all employees in the 'Data' department with salary > 80000.
```sql
SELECT * FROM employees WHERE department = 'Data' AND salary > 80000;
```

### Q7. What does SELECT DISTINCT do?
Removes duplicate rows from the result set. Operates on the full selected row.

### Q8. What is the difference between WHERE and HAVING?
WHERE filters individual rows before grouping. HAVING filters groups after aggregation.

---

## NULL

### Q9. What does NULL represent?
Unknown, missing, or not applicable data. It is not zero, not an empty string.

### Q10. What does `NULL = NULL` return?
NULL (unknown). Always use IS NULL / IS NOT NULL.

---

## Joins

### Q11. What is the difference between INNER JOIN and LEFT JOIN?
INNER JOIN returns only matched rows. LEFT JOIN returns all left rows plus matches; unmatched right-side columns are NULL.

### Q12. What is a self join?
A table joined to itself, typically using aliases. Used for hierarchies (managers/employees) or row-to-row comparisons.

---

## Aggregation

### Q13. What is the difference between COUNT(*) and COUNT(column)?
COUNT(*) counts all rows. COUNT(column) counts only non-NULL values of that column.

### Q14. Write a query to count employees per department.
```sql
SELECT department, COUNT(*) FROM employees GROUP BY department;
```

### Q15. Write a query to find departments with more than 3 employees.
```sql
SELECT department, COUNT(*) FROM employees GROUP BY department HAVING COUNT(*) > 3;
```

---

## Basics

### Q16. What is an aggregate function?
A function that collapses multiple rows into one value: COUNT, SUM, AVG, MIN, MAX.

### Q17. What does ORDER BY do?
Sorts the result set. DESC for descending, ASC for ascending (default).

### Q18. What does LIMIT do?
Restricts the number of rows returned. `LIMIT 10` returns at most 10 rows.

### Q19. What is the difference between UNION and UNION ALL?
UNION removes duplicates. UNION ALL keeps all rows (faster).

### Q20. Write a query to find the maximum salary.
```sql
SELECT MAX(salary) FROM employees;
```