# 13 — Set Operations ⭐

**Priority: ⭐ HIGH VALUE** — less frequent than joins, but clean answers impress.

---

## Concept

Set operations combine **whole result sets** (row-based), unlike joins (column-based). In PostgreSQL and standard SQL:

| Operator | Rows in result | Notes |
|----------|----------------|-------|
| `UNION` | distinct rows from both | deduplicates |
| `UNION ALL` | all rows from both | faster, keeps duplicates |
| `INTERSECT` | rows present in both | distinct |
| `EXCEPT` | rows in left but not right | distinct, NULL-sensitive |

Rules:
- Same number of columns, compatible types.
- Column names come from the first query.
- NULLs: two NULLs are treated as **equal** by set operations (unlike normal comparisons).

---

## Simple Example

```sql
-- All cities where we have customers OR riders
SELECT city FROM customers
UNION
SELECT city FROM restaurants
ORDER BY city;

-- Customers + riders with no dedup
SELECT name FROM customers
UNION ALL
SELECT name FROM riders;
```

---

## Interview Question (Level 3)

**Q:** UNION vs UNION ALL?

**A:** UNION removes duplicates (requires a sort/hash to find them, slower). UNION ALL keeps everything — use it when duplicates are impossible or harmless, or when you deliberately need every row (e.g., appending event logs of different types).

---

## Tricky Question (Level 5)

**Q:** This returns nothing. Why?

```sql
SELECT 1 WHERE NULL IS NULL
INTERSECT
SELECT 1;
```
**Play it back:** `NULL IS NULL` is TRUE so first side is `{1}`. `INTERSECT` yields `{1}`. (Correct — not nothing.)

Now the real trap:

```sql
SELECT 1
EXCEPT
SELECT NULL;
```
`EXCEPT` treats NULLs as equal under set semantics, so answer is `{1}`. But:

```sql
SELECT 1 WHERE FALSE
EXCEPT
SELECT 1;
```
Empty left side → empty result. Set semantics, not row-by-row.

**KEY NULL fact:** under set operations `NULL = NULL` is TRUE — the opposite of `WHERE` comparisons. Interviewers love this contrast.

---

## Interview Follow-Up Chain

**Q:** How do you find products that appear in **both** the order_items and a sale_items feed?

```sql
SELECT product_id FROM order_items
INTERSECT
SELECT product_id FROM sale_items;
```

**Q:** vs JOIN — when is EXCEPT/INTERSECT cleaner than a JOIN?  
**A:** When you compare **entire rows/keys across two full sets** and only care about presence on either side (e.g., compare a staging table snapshot to the live table to find changed rows — very much a Data Engineering pattern!).

**Q:** Rows in table A not in B — EXCEPT vs NOT EXISTS vs LEFT JOIN:  
**A:** All equivalent in result. EXCEPT is the most readable for whole rows; NOT EXISTS is usually the most efficient for keyed comparisons; LEFT JOIN + IS NULL is classic. The optimizer often translates between them.

---

## Real-World Scenario — ETL diff check (Data Engineering)

Compare two snapshots of the same table to find changed rows (INSERT/DELETE/UPDATE candidates):

```sql
-- Rows that disappeared since last load
SELECT event_id, event_name, event_ts
FROM yesterdays_snapshot
EXCEPT
SELECT event_id, event_name, event_ts
FROM todays_snapshot;
```
And `INTERSECT` for unchanged rows. This is a standard "**diff two datasets**" answer.

---

## MySQL note

`INTERSECT` and `EXCEPT` arrived in MySQL 8.0.31 (as `INTERSECT`) and MySQL 8.0.31+ (`EXCEPT`); older MySQL only had `UNION`/`UNION ALL`. PostgreSQL has had all four forever.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "UNION vs UNION ALL?" / "Set ops vs joins?" / "NULL handling in set ops?" / "EXCEPT for ETL diffing?"