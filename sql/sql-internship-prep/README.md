# SQL Internship Interview Preparation

A focused, structured preparation system to **clear SQL interview rounds for Data Engineering / AI Data Engineering internships and entry-level roles**.

This is NOT a textbook. It is an **interview preparation system** built around a target progression:

```text
SQL coding question
        ↓
"Explain your query"
        ↓
"Can you optimize it?"
        ↓
"What happens internally?"
        ↓
"How would this work with millions of rows?"
        ↓
"Why PostgreSQL?"
```

## Priority Legend

Used throughout every chapter.

| Mark   | Meaning       | Definition                                      |
|--------|---------------|--------------------------------------------------|
| 🔥     | MUST KNOW     | Asked in almost every intern SQL interview       |
| ⭐     | HIGH VALUE    | Likely to come up; strong answer impresses       |
| 🟡     | GOOD TO KNOW  | Common in follow-ups; know the idea              |
| ⚪     | BONUS         | Rare at internship level; know it only if time   |

## How to Use This System

1. Follow the **14-day roadmap** in `00-roadmap.md`.
2. Each chapter follows the same pipeline:

   ```text
   Concept → Simple example → SQL practice → Interview question →
   Tricky question → Follow-up question → Real-world scenario
   ```

3. End each chapter by working through its **Checklist**.
4. Drill with the **interview banks** (`interview/`), **coding rounds** (`coding-rounds/`), and **mock interviews** (`interview/mocks/`).
5. Review `39-final-revision.md` and `40-sql-cheatsheet.md` right before interviews.

## Folder Map

```text
sql-internship-prep/
├── README.md
├── 00-roadmap.md              ← 14-day study plan
├── 01-40 *.md                 ← 40 chapters
├── datasets/                  ← 6 PostgreSQL datasets
│   ├── ecommerce.sql
│   ├── banking.sql
│   ├── telecom.sql
│   ├── employee.sql
│   ├── food_delivery.sql
│   └── data_engineering.sql
├── interview/
│   ├── easy.md
│   ├── medium.md
│   ├── hard.md
│   ├── internship-killer.md
│   ├── answer-key.md
│   └── mocks/                 ← Mock interviews 4-6
├── coding-rounds/
│   ├── round-1.md  ... round-5.md
└── (chapters 36-38 contain mock interviews 1-3)
```

## Chapter List

- `00-roadmap.md` — How to study
- `01` Database & SQL fundamentals
- `02` SELECT / WHERE / ORDER BY / LIMIT
- `03` NULL & three-valued logic
- `04` Keys & constraints
- `05` Aggregations, GROUP BY, HAVING
- `06` Joins
- `07` Subqueries, EXISTS, IN
- `08` CASE expressions
- `09` Date & time
- `10` String functions
- `11` CTEs
- `12` Window functions
- `13` Set operations
- `14-19` Interview patterns (dedup, top-N, latest record, running totals, gaps & islands, real-world patterns)
- `20` Transactions & ACID
- `21` Isolation & concurrency
- `22` Indexes
- `23` Query optimization
- `24` EXPLAIN ANALYZE basics
- `25` PostgreSQL for interviews
- `26` PostgreSQL vs MySQL
- `27` Idempotency
- `28` Connection pooling
- `29` Pagination
- `30` UPSERT
- `31` SQL for Data Engineering
- `32` Interview question patterns
- `33` SQL coding round guide
- `34` Scenario-based questions
- `35` PostgreSQL interview
- `36-38` Mock interviews 1-3 (+ mocks 4-6 in `interview/mocks/`)
- `39` Final revision
- `40` SQL cheat sheet

## Primary vs Bonus

- **Primary database:** PostgreSQL. Every query example is PostgreSQL-compatible unless stated.
- **MySQL:** Covered where interviewers compare the two (`26-postgresql-vs-mysql.md`).
- **DBA-level internals (VACUUM internals, replication wire protocols, SSRS/SSIS/Azure):** deliberately skipped or marked ⚪ BONUS. This system exists to clear an internship interview, not to build a DBA.

## Practice Datasets

All datasets are PostgreSQL-compatible (create tables + insert data + relationships). Load any dataset into a scratch database to test the queries in the chapters:

```sql
psql -d practice -f datasets/ecommerce.sql
```

## Final Test

> If an interviewer gives you an unfamiliar SQL problem, you should be able to **reason through it** instead of depending on memorized solutions.

Every chapter is built toward that one sentence.