# 26 — PostgreSQL vs MySQL ⭐

**Priority: ⭐ HIGH VALUE** — every interviewer asks this; answer the tradeoffs, not the fanboy war.

---

## Core comparison

| Topic | PostgreSQL | MySQL (InnoDB) |
|-------|-----------|----------------|
| **Philosophy** | Standard SQL correctness, extensibility | Speed for simple OLTP, simplicity |
| **NULL in UNIQUE** | Multiple NULLs allowed (distinct) | Usually one NULL allowed |
| **Window functions** | Full support (PG 8.4+) | Full support (MySQL 8.0+) |
| **CTEs** | Full support + RECURSIVE (PG 8.4+) | Full support (MySQL 8.0+) |
| **JSON** | JSONB (binary, indexable, fast) | JSON (text, in-place updates, limited indexing) |
| **SERIAL / IDENTITY** | Both | `AUTO_INCREMENT` only |
| **UPDATE RETURNING** | ✅ `UPDATE ... RETURNING *` | ❌ (need two queries) |
| **ON CONFLICT UPSERT** | `INSERT ... ON CONFLICT DO UPDATE` | `INSERT ... ON DUPLICATE KEY UPDATE` |
| **Transactional DDL** | ✅ (part of transaction) | ❌ DDL auto-commits |
| **Data types** | INT, BIGINT, NUMERIC, JSONB, ARRAY, UUID, TIMESTAMPTZ, etc. | INT, VARCHAR, DATETIME (no tz), JSON, simpler set |
| **Indexes** | B-tree, GIN, GiST, BRIN, SP-GiST | B-tree, Hash, GIN (MySQL 8) |
| **CHECK constraints** | ✅ | ✅ (MySQL 8.0.16+) |
| **Default isolation** | READ COMMITTED | REPEATABLE READ (InnoDB) |
| **MVCC** | Yes (no gap locks) | Yes (InnoDB uses gap locks) |
| **Extensions ecosystem** | Large (TimescaleDB, PostGIS, pg_trgm, ...) | Plugin ecosystem is growing but smaller |

---

## When PostgreSQL is better

- Complex queries, many joins, window functions-heavy analytics.
- Schema flexibility: JSONB, arrays, expression indexes, custom types.
- Data integrity: richer constraints, transactional DDL.
- Compliance/audit: `UPDATE ... RETURNING`, robust serialization, extensions like `pg_audit`.
- **Time series** (TimescaleDB), **geo** (PostGIS), **full text** (`tsvector` + `pg_trgm`).

---

## When MySQL might be better

- Simple, high-throughput OLTP with minimal joins.
- Known, simple schema (especially read-heavy CMS, e-commerce where InnoDB works well).
- Ecosystem familiarity for the team.
- MySQL's replication is widely known and battle-tested for simple topologies.

---

## When is PostgreSQL *not* always better?

**Never say "PostgreSQL is always better."** Instead: "PostgreSQL is the right default for a new data-heavy project, but MySQL (InnoDB) is a proven choice for simple OLTP where team expertise and speed are priorities."

---

## When is MySQL faster?

For **trivial single-row lookups with minimal joins** on simple schemas, MySQL/InnoDB can be marginally faster due to lower overhead. For **complex analytical workloads**, PostgreSQL usually wins because its optimizer is more capable.

---

## Interview variation (2 minutes on the right answer)

**Q:** "Why PostgreSQL and not MySQL?"  
**30-second answer:** "PostgreSQL gives us richer data types (JSONB, arrays), window functions with more capabilities, transactional DDL, and the best extension ecosystem for data engineering. MySQL is great for simple OLTP, but for our analytical workloads PostgreSQL's optimizer, CTEs, and update-returning are a big win."

**Then wait.** They'll usually ask a follow-up rather than you elaborating.

---

## MySQL gotchas for PG people

```sql
-- MySQL: LIMIT syntax different for pagination
-- MySQL doesn't support LIMIT in all subqueries (older versions)
-- MySQL uses backtick or nothing for identifiers; PG uses double-quote
-- MySQL DATE_FORMAT vs PostgreSQL TO_CHAR / DATE_TRUNC
-- MySQL doesn't have 'EXCEPT' until 8.0.31
```

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Null handling diff?" / "UPDATE RETURNING?" / "When to choose MySQL?" / "Is PG always better?"