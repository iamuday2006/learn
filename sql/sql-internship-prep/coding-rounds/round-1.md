# Coding Round 1: Easy

**10 questions, 20 minutes. Schema and data in `datasets/employee.sql`.**

---

## Schema (from datasets/employee.sql)

```sql
-- departments: department_id, department_name, location
-- employees: employee_id, name, department_id (FK), manager_id (FK), job_title, hire_date, salary
-- salaries: salary_id, employee_id (FK), salary, effective_from, effective_to
```

---

## Problems

### P1: Select all employees, ordered by salary descending.
```sql
SELECT * FROM employees ORDER BY salary DESC;
```

### P2: Find employees hired after 2022-01-01.
```sql
SELECT * FROM employees WHERE hire_date > '2022-01-01';
```

### P3: Count employees per department.
```sql
SELECT department_id, COUNT(*) AS cnt FROM employees GROUP BY department_id;
```

### P4: Find departments with no employees (use the departments table).
```sql
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

### P5: Find the highest salary in the company.
```sql
SELECT MAX(salary) FROM employees;
```

### P6: List all distinct job titles.
```sql
SELECT DISTINCT job_title FROM employees;
```

### P7: Find employees whose name starts with 'S'.
```sql
SELECT * FROM employees WHERE name LIKE 'S%';
```

### P8: Find departments with more than 2 employees.
```sql
SELECT department_id, COUNT(*) FROM employees GROUP BY department_id HAVING COUNT(*) > 2;
```

### P9: Find the employee with the highest salary.
```sql
SELECT * FROM employees ORDER BY salary DESC LIMIT 1;
```

### P10: Find the total salary paid by each department.
```sql
SELECT department_id, SUM(salary) AS total FROM employees GROUP BY department_id;
```