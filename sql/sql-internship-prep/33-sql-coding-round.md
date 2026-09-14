# 33 — SQL Coding Round Guide ⭐

**Priority: ⭐ HIGH VALUE** — a guide on how to approach timed SQL coding rounds.

---

## Structure of a typical coding round

1. **Given:** schema (CREATE TABLE statements) + sample data.
2. **Task:** write SQL to produce a specific output.
3. **Constraints:** 10–20 minutes per problem, 5–10 problems.
4. **Format:** either in a text editor or verbally.

---

## Approach for each problem

1. **Read the schema first** — understand relationships (FKs, PKs).
2. **Read the sample data** — mentally trace what the expected output looks like.
3. **Sketch the logic** in 1–2 sentences.
4. **Write SQL** — one CTE at a time if complex.
5. **Test against sample data** — mentally or with `EXPLAIN ANALYZE`.
6. **Handle edge cases** — NULLs, empty tables, ties.

---

## Difficulty ladder (round 5 → 10 problems each)

| Round | Level | Topics |
|-------|-------|--------|
| Round 1 | Easy | SELECT, WHERE, ORDER BY, LIMIT, DISTINCT |
| Round 2 | Easy/Medium | GROUP BY, HAVING, aggregates, JOIN basics |
| Round 3 | Medium | Multi-table JOINs, subqueries, NULL handling |
| Round 4 | Medium/Hard | Window functions, CTEs, date logic |
| Round 5 | Hard | Multi-step reasoning, optimization, edge cases |

---

## Common patterns and template SQL

**Find duplicates:**
```sql
SELECT col1, col2, COUNT(*)
FROM table
GROUP BY col1, col2
HAVING COUNT(*) > 1;
```

**Top N per group:**
```sql
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY value DESC) AS rn
    FROM table
)
SELECT * FROM ranked WHERE rn <= N;
```

**Anti-join (rows in A not in B):**
```sql
SELECT * FROM a
WHERE NOT EXISTS (SELECT 1 FROM b WHERE b.id = a.id);
```

**Missing values / gaps:**
```sql
SELECT generate_series(min_val, max_val) AS n
LEFT JOIN table ON table.id = generate_series.n
WHERE table.id IS NULL;
```

---

## Test cases to consider

| Edge case | What to check |
|-----------|---------------|
| Empty table | Does the query return empty, not error? |
| NULLs | NULL in join key, NULL in aggregate, NULL in filter |
| Ties | Same value in ranking — do you want RANK, DENSE_RANK, or ROW_NUMBER? |
| All rows filtered out | Does HAVING/WHERE produce zero groups? |
| Single row | Does the aggregate still work? |

---

## Speed tips

- **Write common patterns from memory** — don't re-derive every time.
- **CTE first, then SELECT** — more readable than nested subqueries.
- **Use aliases** (`o`, `c`, `oi`) to keep things short.
- **Don't over-optimize on first pass** — correctness first, speed second.
- **Keep talking** — explaining your thinking buys you time if you're stuck.

---

## Interviewer expectations

- You **ask clarifying questions** ("what if there are ties?" "does NULL count?").
- You **explain your approach** before writing SQL.
- You **handle NULLs** explicitly (it's a trap they set on purpose).
- You can **explain your query** after writing it.

---

## Real-world example

**Problem:** "Given `orders(order_id, customer_id, order_date, total_amount)`, find the first order date and total spend for each customer who has placed orders in at least two different months."

```sql
SELECT customer_id,
       MIN(order_date) AS first_order_date,
       SUM(total_amount) AS total_spend
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE_TRUNC('month', order_date)) >= 2
ORDER BY total_spend DESC;
```

**Trace through mentally** with the ecommerce dataset → verify it works.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "What if the input is 10M rows?" / "Can you optimize this?" / "What happens with NULLs?"