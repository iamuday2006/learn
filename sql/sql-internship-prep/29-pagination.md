# 29 — Pagination ⭐

**Priority: ⭐ HIGH VALUE** — basic LIMIT/OFFSET plus the efficient alternative.

---

## LIMIT / OFFSET — the simple approach

```sql
-- Page 1, 10 per page
SELECT * FROM orders
ORDER BY order_id
LIMIT 10 OFFSET 0;

-- Page 2
SELECT * FROM orders
ORDER BY order_id
LIMIT 10 OFFSET 10;
```

### Why OFFSET becomes inefficient

OFFSET must scan and discard all preceding rows. At `OFFSET 100000`, PostgreSQL reads 100000 rows → discards them → returns 10. That's O(n) work for page n.

---

## Keyset (cursor) pagination — the efficient alternative

Instead of "skip N rows", remember **where you left off**:

```sql
-- First page
SELECT * FROM orders
ORDER BY order_id
LIMIT 10;

-- Next page: take the last order_id from previous page (say 35)
SELECT * FROM orders
WHERE order_id > 35
ORDER BY order_id
LIMIT 10;
```

This is **O(log n)** — the index jumps to the right spot. Works when ordering by a **unique, indexed column**.

**Generalized (tie-breaking with composite sort):**
```sql
-- If ordering by (order_date, order_id) to handle ties:
SELECT * FROM orders
WHERE (order_date, order_id) > ('2023-01-01', 12)
ORDER BY order_date, order_id
LIMIT 10;
```

---

## Simple Example

```sql
-- OFFSET: slow after 100k rows
SELECT * FROM events ORDER BY event_id LIMIT 50 OFFSET 150;

-- Keyset: fast at any offset
SELECT * FROM events
WHERE event_id > 150   -- from previous page's last event_id
ORDER BY event_id
LIMIT 50;
```

---

## Interview Question (Level 3)

**Q:** When would you prefer OFFSET over keyset?

**A:** When the page number is random (user jumps to page 50 of 100) and the dataset is small. Keyset requires sequential access (page 1 → page 2) — it doesn't support "jump to page N". For small datasets (<100k), OFFSET is fine.

---

## Tricky Question (Level 5)

**Q:** What if I use `OFFSET 100000 LIMIT 10` and there's a `WHERE` clause? Does PostgreSQL still scan the preceding rows?

**A:** It scans preceding **filtered** rows. If the WHERE is well-indexed, the index handles the ordering/filtering; OFFSET still skips 100k filtered rows. Keyset is still better for large offsets. The planner can sometimes skip via index scan, but OFFSET is still logically doing the work.

---

## PostgreSQL note: `LIMIT` without `ORDER BY` is nondeterministic

```sql
SELECT * FROM events LIMIT 5;  -- which 5? The planner may give the same 5 each time
                               -- (heap order), but it's not guaranteed.
```
**Always** include ORDER BY when paginating.

---

## MySQL note

MySQL supports `LIMIT n OFFSET m` and `LIMIT m, n` (reversed). Keyset works the same way in MySQL.

---

## Real-world scenario

Your dashboard UI shows 50 rows at a time and users scroll forever. Design:
- Default: LIMIT 50 OFFSET 0 (first load fast).
- Infinite scroll: track last `id` and use keyset pagination.
- Don't expose page numbers in the URL for huge datasets.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "OFFSET performance?" / "Keyset limitations?" / "Tie-breaking?" / "What if rows are deleted between pages?"