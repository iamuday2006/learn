# 04 — Keys and Constraints ⭐

**Priority: ⭐ HIGH VALUE** — solid answer separates you from candidates who can only name a PK.

---

## Concept

**Keys** identify and relate rows. **Constraints** enforce rules at the database layer (so bad data is rejected regardless of which app wrote it).

### Key types

| Key | What it does | Notes |
|-----|--------------|-------|
| **Primary Key (PK)** | Uniquely identifies each row | One per table, implicitly NOT NULL |
| **Foreign Key (FK)** | References a PK (or unique) in another table | Enforces referential integrity |
| **Unique key** | No duplicate values | Multiple allowed; NULLs allowed (PG) |
| **Composite key** | PK or unique made of 2+ columns | e.g., (order_id, product_id) |
| **Candidate key** | Any column(s) that could be a PK | Every PK is a candidate key that was chosen |
| **Alternate key** | Candidate key NOT chosen as PK | e.g., email when id is PK |
| **Natural key** | Real-world identifier (email, SSN, passport) | Stable? For a person, arguably. Not always |
| **Surrogate key** | Artificial, no business meaning (SERIAL id) | Never changes, no business leakage |
| **Super key** | Any set of columns that uniquely identifies rows | Superset of a candidate key |

### Constraint types

| Constraint | Syntax | Meaning |
|-----------|--------|---------|
| PRIMARY KEY | `id INT PRIMARY KEY` | unique + not null |
| FOREIGN KEY | `customer_id INT REFERENCES customers(id)` | must exist in parent |
| UNIQUE | `email VARCHAR UNIQUE` | no duplicates |
| NOT NULL | `name VARCHAR NOT NULL` | required |
| CHECK | `CHECK (price >= 0)` | condition must hold |
| DEFAULT | `created_at TIMESTAMPTZ DEFAULT NOW()` | fallback value |

---

## Simple Example

```sql
CREATE TABLE countries (
    country_code CHAR(2) PRIMARY KEY,      -- natural, stable
    name         VARCHAR(50) NOT NULL
);

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,       -- surrogate
    email        VARCHAR(255) UNIQUE NOT NULL,
    country_code CHAR(2) REFERENCES countries(country_code),  -- FK
    age          INT CHECK (age BETWEEN 13 AND 120),
    created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

---

## SQL Practice

Dataset: `datasets/ecommerce.sql`

1. Try inserting an order with `customer_id = 9999` → FK error. Then explain why.
2. Try inserting a product with `price = -5` → CHECK error.
3. Inspect constraints via `\d orders`.
4. Delete a category that has products → what happens? (FK violation by default.)

---

## Interview Question (Level 3)

**Q:** What happens if I try to delete a row that's referenced by a foreign key?

**Answer:** By default the delete is **rejected** (RESTRICT/NO ACTION). Options:
- `ON DELETE CASCADE` → delete the child rows too.
- `ON DELETE SET NULL` → set child FK column to NULL.
- `ON DELETE RESTRICT` / `NO ACTION` → block the delete.

Interview follow-up is usually: "When would you use CASCADE?" → when child rows are meaningless without the parent (e.g., order_items when order is deleted).

---

## Tricky Question (Level 5)

**Q:** In PostgreSQL, can a column be both a PK **and** an FK? **A:** Yes — e.g., a 1:1 table where the child's PK also references the parent's PK:

```sql
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY REFERENCES users(user_id),
    bio     TEXT
);
```

---

## Interview Follow-Up Chain

**Q:** What's the difference between `RESTRICT` and `NO ACTION` in PostgreSQL?  
**A:** Semantically the same in PostgreSQL today; both reject the delete. (Some other DBs defer `NO ACTION` to end of statement/transaction — `RESTRICT` is immediate.)

**Q:** Why use a surrogate key over a natural key like email?  
**A:** Emails change, can be long, may expose PII, and are not guaranteed unique forever (account reuse). Surrogate keys are immutable, compact, and don't leak business meaning.

**Q:** When would a natural key be fine?  
**A:** When the value is truly stable and unique in the business domain — `country_code`, `isbn`, airport codes.

---

## Real-World Scenario

Orders + payments + order_items. Design the constraints so that:
- An order can't exist without a customer → FK NOT NULL.
- Order items must reference a real order and product → FKs, composite PK on (order_id, product_id).
- A payment can't be negative → CHECK.
- Deleting a customer keeps their orders for audit → do NOT cascade; use `ON DELETE RESTRICT` and mark customers inactive instead.

```sql
CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, product_id)
);
```

Composite PK is the correct modeling here; explain why to the interviewer.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Cascade vs restrict?" / "Surrogate vs natural key?" / "Composite PK?" / "Constraints at DB layer vs app layer?"