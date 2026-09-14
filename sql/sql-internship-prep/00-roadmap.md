# 00 — Roadmap: 14-Day Study Plan

**Goal:** SQL interview readiness for Data Engineering / AI Data Engineering internships.

**How to study each day (≈90–120 min):**
1. Read the day's chapters (30–40 min)
2. Write the SQL examples yourself, from memory (20 min)
3. Solve 2–3 questions from the chapter/problem sets (20 min)
4. Do a spoken "explain it back" pass (10 min)
5. Mark the chapter **Checklist** honestly

**Golden rule:** never just read a query — predict the output, then run `EXPLAIN` thinking in your head.

---

## Priority Map

```text
🔥 MOST LIKELY ASKED:
Join, Group By, Having, Window Functions, CTE, Subqueries,
NULL, Aggregations, Distinct, ORDER BY/LIMIT, COUNT variants,
Second-highest salary, Deduplication, Latest record per group

⭐ HIGH VALUE:
Indexes, EXPLAIN ANALYZE, Transactions, ACID, PostgreSQL vs MySQL,
Idempotency, Index basics, Pagination, Upsert (ON CONFLICT)

🟡 GOOD TO KNOW:
MVCC, Connection pooling, Isolation levels, Serializables,
Gaps & overlaps, Retention

⚪ BONUS:
Advanced PG internals, VACUUM tuning, replication, DBA topics
```

---

## Week 1 — SQL Core (Days 1–7)

### Day 1 — Database Basics
- Read: `01-database-and-sql-fundamentals.md`, `02-select-where-order-limit.md`
- Do: Interview bank `interview/easy.md` questions 1–10
- Spoken test: "What is the difference between a DBMS and an RDBMS?"

### Day 2 — NULL + Aggregation
- Read: `03-null-and-three-valued-logic.md`, `05-aggregations-groupby-having.md`
- Do: NULL tricky questions, COUNT/COUNT(*)/COUNT(DISTINCT)
- Key trap to master: three-valued logic, `NOT IN` with NULL

### Day 3 — Joins
- Read: `06-joins.md`
- Do: all join examples; answer "Why can a LEFT JOIN become an INNER JOIN?"
- Spoken test: walk through a LEFT JOIN NULL behavior with a 3-row example

### Day 4 — Subqueries + CTE
- Read: `07-subqueries-exists-in.md`, `11-cte.md`
- Do: correlated subquery vs JOIN; recursive CTE basics
- Key trap: `NOT IN` vs `NOT EXISTS` with NULLs

### Day 5 — Window Functions
- Read: `12-window-functions.md`
- Do: all 15 "must solve" problems (window section)
- Spoken test: ROW_NUMBER vs RANK vs DENSE_RANK with duplicates

### Day 6 — Interview Patterns
- Read: `14`–`19-*.md`
- Do: 2 problems per pattern from `32-interview-question-patterns.md`
- Spoken test: "How do you find the latest order per customer?"

### Day 7 — Transactions + Indexes + Optimization
- Read: `20-transactions-acid.md`, `21-isolation-and-concurrency.md`, `22-indexes.md`
- Do: `23-query-optimization.md`, `24-explain-analyze-basics.md`
- Spoken test: "Why don't we index every column?"

---

## Week 2 — PostgreSQL + DE + Mocks (Days 8–14)

### Day 8 — PostgreSQL + MySQL
- Read: `25-postgresql-for-interviews.md`, `26-postgresql-vs-mysql.md`
- Spoken test: "What's the difference between PostgreSQL and MySQL?"

### Day 9 — PostgreSQL features
- Read: `27-idempotency.md`, `28-connection-pooling.md`, `29-pagination.md`, `30-upsert.md`
- Do: ON CONFLICT vs ON DUPLICATE KEY UPDATE

### Day 10 — Data Engineering SQL
- Read: `31-sql-for-data-engineering.md`
- Do: `datasets/data_engineering.sql` problems + `34-scenario-based-questions.md`

### Day 11 — Coding Rounds
- Do: `coding-rounds/round-1.md` through `round-3.md` (timed, 20 min each)
- Review answers against `interview/answer-key.md`

### Day 12 — Mock Interviews 1–3
- Read: `36-mock-interview-1.md` (Fundamentals 20Q)
- Do: `37-mock-interview-2.md` (SQL Coding 10Q)
- Do: `38-mock-interview-3.md` (Data Engineering SQL 15Q)
- Score yourself honestly

### Day 13 — Mock Interviews 4–6
- Do: `interview/mocks/mock-4-postgresql.md` (15Q)
- Do: `interview/mocks/mock-5-concepts.md` (20Q)
- Do: `interview/mocks/mock-6-final.md` (combined final)
- Use follow-up chains from `35-postgresql-interview.md`

### Day 14 — Revision
- Read: `39-final-revision.md` (1-day / 1-hour / 10-minute sections)
- Memorize: `40-sql-cheatsheet.md`
- Do: `interview/internship-killer.md` traps
- Spoken pass: every 🔥 topic name → one-sentence definition

---

## Daily Habit Checklist

- [ ] Wrote the SQL myself (typing, not copying)
- [ ] Predicted output before trusting examples
- [ ] Explained a concept out loud (no notes)
- [ ] Solved or attempted at least 2 new questions
- [ ] Marked chapter checklists honestly

## If You Have Less Than 14 Days

- **10 days:** skip Day 8 (skim only), compress mocks (Day 12–13 → single pass)
- **7 days:** Days 1–7 only, but do `39-final-revision.md` first
- **3 days:** `20-*.md` (1) → `transaction/`+concurrency+indexes (2) → mocks + cheatsheet (3)