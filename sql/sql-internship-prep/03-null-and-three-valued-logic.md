# 03 — NULL and Three-Valued Logic 🔥

**Priority: 🔥 MUST KNOW** — NULL is a top-10 interview topic across every role.

---

## Concept

**NULL means unknown / missing / not applicable — not zero, not empty string, not ''.**

- `NULL = 0` → NULL (unknown)
- `NULL = NULL` → NULL (unknown) → always false in WHERE
- `NULL < 5` → NULL
- `NULL != 'foo'` → NULL

This is **three-valued logic**: every comparison can be TRUE, FALSE, or NULL (unknown).

| a | b | a AND b | a OR b | NOT a |
|---|---|---------|--------|-------|
| TRUE | NULL | NULL | TRUE | FALSE |
| FALSE | NULL | FALSE | NULL | TRUE |
| NULL | NULL | NULL | NULL | NULL |

**Summary:** FALSE dominates AND; TRUE dominates OR; NULL almost always yields NULL unless the other operand can determine the result.

---

## Simple Example

```sql
SELECT *
FROM orders
WHERE status = 'delivered';
```
Rows with `status IS NULL` are excluded — that is correct. But:

```sql
SELECT *
FROM orders
WHERE status <> 'delivered';
```
Also excludes NULLs — people often think this means "anything not delivered". **NULLs are lost.**

The correct way to include NULLs:
```sql
SELECT *
FROM orders
WHERE status <> 'delivered'
   OR status IS NULL;
```

---

## SQL Practice

Dataset: `datasets/ecommerce.sql` — `payments.amount` has NULL rows.

1. Count payments: `COUNT(*)` vs `COUNT(amount)` vs `COUNT(DISTINCT amount)`.
2. Find payments that are not 29.99 — see NULLs excluded.
3. Use `COALESCE(amount, 0)` to replace NULL.
4. Use `NULLIF(a, b)`.

### COUNT behavior — a classic trap

```sql
SELECT COUNT(*)         -- counts ALL rows
FROM payments;

SELECT COUNT(amount)    -- counts only NON-NULL amounts
FROM payments;

SELECT COUNT(DISTINCT amount)  -- distinct non-null values
FROM payments;
```

> If every row had `amount` NULL, `COUNT(*)` = N but `COUNT(amount)` = 0 and `AVG(amount)` = NULL.

---

## Interview Question (Level 3)

**Q:** What does this return?

```sql
SELECT AVG(amount), SUM(amount) / COUNT(amount) AS avg_manual
FROM payments;
```

**Answer:** identical — AVG ignores NULLs, SUM and COUNT also ignore NULLs, so the manual division matches. But if some rows are NULL, both skip them. `SUM(amount) / COUNT(*)` would differ.

---

## Tricky Question (Level 5 — internship killer)

**Q:** `SELECT COUNT(1) FROM payments;` — what does 1 mean?

**Answer:** `COUNT(1)` counts **rows**, same as `COUNT(*)`. The `1` is a constant per row, never NULL, so every row counts. It is NOT "the first column". (Optimizers treat `COUNT(1)` and `COUNT(*)` identically in PostgreSQL.)

**Follow-up:** does `COUNT(NULL)` count anything? → No, returns 0.

---

## COALESCE and NULLIF

```sql
SELECT COALESCE(NULL, NULL, 'fallback');  -- 'fallback'
SELECT NULLIF('a', 'a');                  -- NULL (differs from second arg)
SELECT NULLIF('a', 'b');                  -- 'a'
```

**Use `NULLIF` to avoid divide-by-zero:**

```sql
SELECT ROUND(total / NULLIF(quantity, 0), 2) FROM order_items;
```
If `quantity = 0`, `NULLIF` turns it into NULL → result is NULL instead of an error.

**Use `COALESCE` in LEFT JOINs** to fill missing values:
```sql
SELECT c.customer_id, COALESCE(p.amount, 0) AS paid
FROM customers c
LEFT JOIN payments p ON p.customer_id = c.customer_id;  -- schema sketch
```

---

## Interview Follow-Up Chain

**Q:** Why can't you use `WHERE amount = NULL`?  
**A:** Nothing equals NULL (unknown); you must use `IS NULL` / `IS NOT NULL`.

**Q:** What does `ORDER BY amount` do with NULLs in PostgreSQL?  
**A:** NULLs sort **last ascending, first descending** by default. You can control it: `ORDER BY amount NULLS FIRST` or `NULLS LAST`.

**Q:** And `UNIQUE` constraints with NULL?  
**A:** In PostgreSQL NULLs are not considered equal, so multiple `NULL`s allowed in a unique column (as covered in ch 01).

---

## Real-World Scenario

You load an ETL batch of `payments` and see `amount` NULLs. Which rows are suspect, and how do you flag them?

```sql
SELECT order_id,
       amount,
       CASE WHEN amount IS NULL THEN 'missing_amount'
            WHEN amount = 0 THEN 'zero_amount'
            ELSE 'ok' END AS flag
FROM payments;
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "NULL in aggregates?" / "COALESCE vs ISNULL vs NVL?" / "Sorting NULLs?" / "NOT IN with NULL?"