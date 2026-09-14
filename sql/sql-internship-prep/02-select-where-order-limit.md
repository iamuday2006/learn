# 02 — SELECT, WHERE, ORDER BY, LIMIT 🔥

**Priority: 🔥 MUST KNOW** — the building blocks of every query.

---

## Concept

The core statement is `SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ... LIMIT ... OFFSET ...`.

### Logical Query Processing Order

The **written** order and the **executed** order are different — a classic interview question:

```text
1. FROM           -- get the table(s)
2. WHERE          -- filter rows
3. GROUP BY       -- group rows
4. HAVING         -- filter groups
5. SELECT         -- compute selected columns
6. DISTINCT       -- remove duplicates
7. ORDER BY       -- sort
8. LIMIT / OFFSET -- slice
```

**Why it matters:**
- You cannot put an aggregate in `WHERE` because WHERE runs **before** grouping.
- You CAN alias a column and use it in `ORDER BY` (order runs after SELECT) but NOT in WHERE.
- `SELECT` can reference `WHERE` columns but not the other way.

```sql
SELECT  department, COUNT(*) AS cnt
FROM    employees
WHERE   hire_date >= '2022-01-01'      -- per-row filter first
GROUP BY department
HAVING  COUNT(*) > 1                    -- per-group filter second
ORDER BY cnt DESC;
```

---

## Simple Example

```sql
SELECT name, salary
FROM employees
WHERE department = 'Data'
ORDER BY salary DESC
LIMIT 3;
```

---

## SQL Practice

Dataset: `datasets/employee.sql`

1. Distinct departments.
2. Employees hired after 2021, ordered by hire date.
3. Top 5 highest salaries (with ties? see below).
4. Paginate with `LIMIT n OFFSET m`.

---

## Interview Question (Level 2)

**Q:** Why can `WHERE` use `salary > 100000` but not `COUNT(*) > 1`?

**Answer:** `WHERE` operates on **individual rows before grouping/aggregation** (step 2). Aggregates only exist after `GROUP BY`/aggregation (steps 3-4). That's exactly what `HAVING` is for — filtering on **group** results after aggregation.

---

## Tricky Question (Level 5)

**Q:** What does this return?

```sql
SELECT name, salary
FROM employees
WHERE department = 'Sales';
```
vs
```sql
SELECT name, salary
FROM employees
WHERE department IS NULL;
```

If there are rows with `department = NULL`, the second query returns them. But if you wrote:

```sql
WHERE department NOT IN ('Sales')
```

rows with `department = NULL` are **excluded** — because comparing `NULL` with `IN` yields unknown. This connects to three-valued logic (chapter 03). A common trap: people assume `NOT IN ('Sales')` means "everything except Sales" — but NULLs silently vanish.

---

## Interview Follow-Up Chain

**Q:** How do I get the 3 most recently hired employees?

```sql
SELECT name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 3;
```

**Q:** What if there are ties on hire_date?  
**A:** Then you're picking an arbitrary 3 of the ties. Use `RANK()`/`DENSE_RANK()` if ties matter (chapter 12, 15).

**Q:** How does this behave on millions of rows?  
**A:** With an index on `hire_date`, the sort is avoided and only 3 rows are read. Without an index, PostgreSQL sorts the whole table then takes 3.

---

## Real-World Scenario

You need to find "customers with more than 3 orders in the last 30 days" — a perfect mix of WHERE (date filter), GROUP BY + HAVING (count filter):

```sql
SELECT customer_id, COUNT(*) AS order_count
FROM   orders
WHERE  order_date >= NOW() - INTERVAL '30 days'
GROUP BY customer_id
HAVING COUNT(*) > 3;
```

---

## Keywords quick reference

| Keyword | Purpose | Note |
|---------|---------|------|
| `DISTINCT` | Remove duplicate rows | `SELECT DISTINCT city FROM customers` |
| `AND` / `OR` / `NOT` | Combine conditions | `AND` binds tighter than `OR` — use parens |
| `IN` | Value in a set | NULL trap (see chapter 07) |
| `BETWEEN` | Inclusive range | `BETWEEN 10 AND 20` → 10, 20 included |
| `LIKE` | Pattern match | `%` any chars, `_` one char |
| `ILIKE` | Case-insensitive LIKE (PostgreSQL) | MySQL uses `LIKE` (already case-insensitive by default for ASCII) |
| `IS NULL` / `IS NOT NULL` | NULL tests | Never use `= NULL` |

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Logical order of execution?" / "WHERE vs HAVING?" / "What happens with NULL in WHERE?"