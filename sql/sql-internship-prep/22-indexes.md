# 22 — Indexes ⭐

**Priority: ⭐ HIGH VALUE** — index questions are near-guaranteed for Data Engineering roles.

---

## Concept

An **index** is a data structure (default **B-tree** in PostgreSQL) that lets the DB find rows *without scanning the whole table*. Like the index of a book.

- **B-tree** — sorted tree; supports `=`, `<`, `>`, `BETWEEN`, `ORDER BY`, prefix `LIKE` on text (with `text_pattern_ops`), and `IN`.
- **Index Scan** — uses index to locate rows, then fetches pages from the heap (table).
- **Bitmap Scan** — for "many matches": builds a bitmap in memory, then reads heap pages once. Good for `WHERE` selecting a large fraction.
- **Seq Scan** — reads the whole table. Not necessarily bad — for small tables or low selectivity, it's the cheapest.
- **Unique index** — enforces uniqueness (every PK/UNIQUE constraint creates one).
- **Composite index** — multiple columns; *column order matters* (leftmost prefix rule).
- **Partial index** — `WHERE` clause limits indexed rows (e.g., index only active rows).

---

## Simple Example

```sql
CREATE INDEX idx_orders_customer ON orders (customer_id);
SELECT * FROM orders WHERE customer_id = 5;   -- index scan now
```

Composite index — notice the order:
```sql
CREATE INDEX idx_orders_ct_o ON orders (customer_id, order_date);
-- helps: customer_id = ?
-- helps: customer_id = ? AND order_date >= ?
-- helps: order_date sorted within one customer
-- does NOT help: order_date alone (leftmost prefix)
```

Selectivity — if a column has few distinct values (e.g., `is_active` booleans), an index won't help much; the planner picks Seq Scan. A **partial index** helps:
```sql
CREATE INDEX idx_active_users ON users (user_id) WHERE is_active;
```

---

## Interview Question (Level 3)

**Q:** Why shouldn't we index every column?

**A:**
1. **Write overhead** — every INSERT/UPDATE/DELETE also updates all indexes → slower writes.
2. **Storage** — indexes take disk space, can exceed table size.
3. **Maintenance** — VACUUM/ANALYZE must process them, boosting/cache pressure.
4. **Planner confusion** — optimizer could pick a bad index (low selectivity), and planning grows.

---

## Tricky Question (Level 5)

**Q:** Why might PostgreSQL **ignore** an index?

**A:** When using it isn't cheaper:
- Low **selectivity** (returns most rows) → full table scan is faster.
- Function applied to column: `WHERE lower(email) = 'x'` can't use a plain index (needs **expression index**): `CREATE INDEX ON users (lower(email))`.
- Column type mismatch — index on int vs `WHERE id::text = ...`.
- Statistics are stale (`ANALYZE` needed).
- `LIKE '%foo'` (leading wildcard) can't use B-tree.

---

## Interview Follow-Up Chain

**Q:** What happens to indexes when data is inserted or updated?

**A:** Index entries are maintained transactionally:
- INSERT → add entries.
- UPDATE → delete old + add new entries (row versioning in MVCC).
- DELETE → entries stay until VACUUM cleans the dead rows; hence the need to `VACUUM` regularly.

**Q:** How do you debug a slow query using an index?

**A:** `EXPLAIN` to see Seq Scan vs Index Scan; if Seq Scan on big table, add index on the filtered column; check it's used with a composite index matching the WHERE columns; run `ANALYZE`.

**Q:** Primary key vs index?

**A:** In PostgreSQL, the PK already **is** an index (unique B-tree). So adding a duplicate index on the PK column is redundant.

---

## Real-world scenario

`orders` has 10M rows. Query: "all orders for customer_id = 421 in the last month" plus join to order_items.

```sql
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);
CREATE INDEX idx_order_items_order ON order_items (order_id);

SELECT o.order_id, oi.quantity
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = 421
  AND o.order_date >= NOW() - INTERVAL '30 days';
```
Explain: composite index covers the filter + sort; the order_items index makes the join fast (prevent per-row seq scans).

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Why not index everything?" / "When is an index ignored?" / "Composite order?" / "Expression index?" / "Indexes and writes?"