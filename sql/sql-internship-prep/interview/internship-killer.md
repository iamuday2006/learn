# Internship Killer Questions 🔥

**15 questions. Level 5. Looks simple, contains traps.**

These are the questions where candidates confidently give wrong answers. Read each, think carefully, then check the answer.

---

## Q1: What does `SELECT COUNT(*) FROM orders WHERE status = 'cancelled'` return when all orders are delivered?
**Trap answer:** 0
**Correct:** 0 rows match → COUNT(*) returns 0. ✓ (This one is actually straightforward — the trap is when people say NULL.)

---

## Q2: What does `NULL IN (1, 2, 3)` return?
**Trap answer:** TRUE or FALSE
**Correct:** NULL. `NULL = 1 OR NULL = 2 OR NULL = 3` → NULL.

---

## Q3: What does `1 NOT IN (1, 2, NULL)` return?
**Trap answer:** FALSE (because 1 is in the list)
**Correct:** FALSE. `1 <> 1 AND 1 <> 2 AND 1 <> NULL` → FALSE AND TRUE AND NULL → FALSE. ✓

---

## Q4: What does `4 NOT IN (1, 2, NULL)` return?
**Trap answer:** TRUE (4 isn't in the list!)
**Correct:** NULL. `4 <> 1 AND 4 <> 2 AND 4 <> NULL` → TRUE AND TRUE AND NULL → NULL → not TRUE. **NOT IN with any NULL in the list returns NULL, not TRUE.**

---

## Q5: Can you use an alias defined in SELECT inside WHERE?
**Trap answer:** Yes
**Correct:** No (in PostgreSQL). The WHERE clause executes **before** SELECT. You CAN use aliases in ORDER BY (post-SELECT).

---

## Q6: Two employees have the same salary (100). What does DENSE_RANK give them?
**Trap answer:** 1 and 2
**Correct:** Both get rank 1. The next distinct salary gets rank 2.

---

## Q7: What is the default frame for `SUM(x) OVER (ORDER BY t)`?
**Trap answer:** UNBOUNDED PRECEDING TO UNBOUNDED FOLLOWING (whole partition)
**Correct:** `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. This includes all **peer rows** (ties). For running totals, use `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.

---

## Q8: Does a LEFT JOIN always return all left-side rows?
**Trap answer:** Yes, always
**Correct:** Only if the ON clause doesn't filter them. If you put a WHERE condition on the left-side column (e.g., `WHERE a.id IS NOT NULL`), it can filter them out.

---

## Q9: What does `SELECT * FROM t LIMIT 0` return?
**Trap answer:** Error
**Correct:** An empty result set (zero rows). No error.

---

## Q10: Can you INSERT into a table and RETURNING the generated ID in one statement?
**Trap answer:** No, you need two queries
**Correct:** Yes! `INSERT INTO t (col) VALUES (x) RETURNING id;` — standard PostgreSQL.

---

## Q11: `DELETE FROM t WHERE id = 1; DELETE FROM t WHERE id = 1;` — what happens on the second DELETE?
**Trap answer:** Error
**Correct:** 0 rows affected (idempotent delete — no error, just nothing changes). The second DELETE succeeds but deletes nothing.

---

## Q12: What is the result of `SELECT COALESCE(NULL, NULL, NULL)`?
**Trap answer:** Error or empty string
**Correct:** NULL. All arguments are NULL → return value is NULL.

---

## Q13: `UNIQUE` constraint on a column — how many NULLs does PostgreSQL allow?
**Trap answer:** One NULL (like MySQL)
**Correct:** Unlimited. PostgreSQL treats NULLs as distinct for UNIQUE constraints. Multiple NULLs are allowed.

---

## Q14: What does `COUNT(DISTINCT NULL)` return?
**Trap answer:** 0
**Correct:** 0. COUNT(DISTINCT col) counts distinct non-NULL values. NULL is ignored.

---

## Q15: Can a column be both a PRIMARY KEY and a FOREIGN KEY?
**Trap answer:** No, they're mutually exclusive
**Correct:** Yes — in a 1:1 relationship table, the column can be both PK and FK referencing the parent table's PK.

---

## Key trap summary

| Trap | Rule |
|------|------|
| NOT IN + NULL | Always NULL (use NOT EXISTS) |
| Alias in WHERE | Not allowed (WHERE runs before SELECT) |
| NULL = NULL | NULL, not TRUE |
| COUNT(*) vs COUNT(col) | All rows vs non-NULL rows |
| LEFT JOIN + WHERE right table | Becomes INNER |
| Frame default | RANGE, not ROWS |
| PostgreSQL UNIQUE + NULL | Multiple NULLs allowed |
| DELETE twice | 0 rows second time, no error |