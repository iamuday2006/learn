# 32 — Interview Question Patterns 🔥

**Priority: 🔥 MUST KNOW** — a meta-chapter on how to **recognize and decompose** SQL interview questions.

---

## The 5-step framework

When you see a SQL problem:

1. **Understand the question** — rephrase it in your own words. What are the inputs? What's the expected output?
2. **Identify the pattern** — is it a join? aggregation? window? subquery? anti-join? ranking?
3. **Sketch the logic** — in English/pseudocode, then translate to SQL.
4. **Consider edge cases** — NULLs? empty tables? ties? duplicates?
5. **Optimize (if asked)** — can you make it faster/simpler?

---

## Pattern recognition cheat sheet

| Keyword in question | Likely pattern |
|---------------------|----------------|
| "per group", "for each X" | GROUP BY or PARTITION BY |
| "most recent", "latest", "current" | ROW_NUMBER ORDER BY ts DESC |
| "top N", "second highest" | OFFSET/LIMIT or RANK/DENSE_RANK |
| "consecutive", "streak", "gap" | Gaps & islands |
| "difference from previous" | LAG |
| "never", "not in", "missing" | Anti-join (LEFT JOIN IS NULL / NOT EXISTS) |
| "same as", "duplicate" | GROUP BY + HAVING COUNT > 1 |
| "cumulative", "running" | SUM() OVER (ORDER BY) |
| "percentile", "median" | PERCENTILE_CONT or ROW_NUMBER arithmetic |
| "conditional count/side-by-side" | FILTER or CASE in aggregate |
| "check if exists" | EXISTS |
| "ranking" | RANK/DENSE_RANK/ROW_NUMBER |

---

## Example decomposition

**Q:** "Find customers who placed more than 5 orders in the last 30 days, with their most recent order amount."

**Decomposition:**
- "per customer" → GROUP BY or PARTITION BY
- "more than 5 orders" → COUNT + HAVING
- "last 30 days" → WHERE order_date >= ...
- "most recent order amount" → ROW_NUMBER OR MAX within partition

**SQL:**
```sql
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(*) AS order_count,
           MAX(total_amount) AS latest_amount,
           ROW_NUMBER() OVER (PARTITION BY customer_id
                              ORDER BY order_date DESC) AS rn
    FROM orders
    WHERE order_date >= NOW() - INTERVAL '30 days'
    GROUP BY customer_id
)
SELECT customer_id, order_count, latest_amount
FROM customer_orders
WHERE order_count > 5 AND rn = 1;
```

---

## Common mistakes

1. **Diving into SQL before sketching the logic** — write pseudocode first.
2. **Ignoring NULLs** — ask yourself: "could this column be NULL?"
3. **Join multiplication** — joining to a non-unique column and getting duplicate rows. Add DISTINCT or aggregate before joining.
4. **Wrong window frame** — forgetting the frame clause causes unexpected results for running totals.
5. **Treating interviewers as execution engines** — explain your thought process *as you write*.

---

## How to think out loud (interview strategy)

Say:
- "Let me think about what this is asking..."
- "I think this needs a join between A and B on the customer key..."
- "I want the most recent row per customer, so I'll use ROW_NUMBER..."
- "Let me check edge cases: what if there are no orders? NULLs in the join column?"

This shows **structured thinking**, which interviewers value more than a perfect answer.

---

## Real-world DE scenarios

| Scenario | Key insight |
|----------|-------------|
| "Our pipeline loaded duplicate rows" | Dedup (ch 14) + ON CONFLICT (ch 30) |
| "We need to fill missing dates" | generate_series + LEFT JOIN (ch 18) |
| "Compare two snapshots" | EXCEPT/INTERSECT (ch 13) or LEFT JOIN IS NULL |
| "Find changed rows since last run" | Watermark-based WHERE on updated_at |

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "How do you approach a problem?" / "What if you're stuck?" / "Walk me through your thought process"