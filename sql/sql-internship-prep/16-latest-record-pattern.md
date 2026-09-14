# 16 — Latest Record Pattern 🔥

**Priority: 🔥 MUST KNOW** — "latest order per customer", "most recent price per product", "current state from a history table".

---

## How to recognize it

"Most recent / latest / current" + "per X" — e.g., latest order per customer, latest salary per employee, latest CDC version per record, current subscription status.

---

## Recommended SQL technique

**Rank-then-filter** with `ROW_NUMBER() OVER (PARTITION BY <id> ORDER BY <timestamp> DESC)`. If you only need the timestamp, `MAX(some_ts) GROUP BY id` is cheaper — but to fetch **other columns of the latest row**, use the window.

---

## Example — latest salary per employee

From `datasets/employee.sql` (salaries history table):

```sql
WITH ranked AS (
    SELECT employee_id, salary, effective_from,
           ROW_NUMBER() OVER (PARTITION BY employee_id
                              ORDER BY effective_from DESC) AS rn
    FROM salaries
)
SELECT employee_id, salary, effective_from
FROM ranked
WHERE rn = 1;
```

### Without a window — self join / MAX + join

```sql
SELECT s.employee_id, s.salary, s.effective_from
FROM salaries s
JOIN (SELECT employee_id, MAX(effective_from) AS latest
      FROM salaries GROUP BY employee_id) l
  ON l.employee_id = s.employee_id
 AND l.latest = s.effective_from;
```

When would you prefer this? When the interviewer asks for a **non-window** solution, or when the ordering column is genuinely unique per group.

---

## Common mistake

- Using `MAX(timestamp)` then filtering `WHERE ts = ...` without the join → returns only rows equal to the max; **duplicate timestamps** return extra rows.
- Forgetting a deterministic tiebreaker in `ROW_NUMBER ... ORDER BY ts DESC` when ts ties → arbitrary row kept. Add `, id DESC`.
- "Latest" ≠ "current": if the business meaning is "the version still in effect", you may mean `effective_to IS NULL` (current record) rather than max date. Ask clarifying questions!

---

## Interview variations

1. **Latest order per customer:**
```sql
WITH ranked AS (
    SELECT o.*, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders o
)
SELECT * FROM ranked WHERE rn = 1;
```

2. **Latest price per product** (price history) — same pattern.

3. **State at a point in time** ("what was the price on 2023-06-01") — the history pattern requires the record where `effective_from <= date` and next version starts after; this is the "**as-of join**":
```sql
SELECT ph.product_id, p.product_name, ph.price
FROM price_history ph
JOIN (
    SELECT product_id, MAX(effective_from) AS effective_from
    FROM price_history
    WHERE effective_from <= '2023-06-01'
    GROUP BY product_id
) latest ON latest.product_id = ph.product_id
        AND latest.effective_from = ph.effective_from;
```

4. **Latest event per session** 😄.

---

## Real-world scenario (Data Engineering)

A CDC-style `user_status_history` table: every change to a user's status appends a row. Build the **current state table** for a dashboard:

```sql
WITH current_state AS (
    SELECT user_id, status, changed_at,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY changed_at DESC) AS rn
    FROM user_status_history
)
SELECT user_id, status, changed_at
FROM current_state
WHERE rn = 1;
```

Bonus answer: for very large history tables, this can be replaced with an **incremental** approach — keep a `users_current` table updated only with new deltas (ties into chapter 31).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Latest vs current?" / "Duplicate timestamps?" / "Non-window version?" / "Point-in-time (as-of)?"