# 01 — Database and SQL Fundamentals 🔥

**Priority: 🔥 MUST KNOW** for the first 10 minutes of any SQL interview.

---

## Concept: What is each thing?

| Term | Definition | Analogy |
|------|-----------|---------|
| **Database** | An organized collection of data stored electronically | A warehouse of files |
| **DBMS** | Software to create, manage, and query databases | The warehouse manager |
| **RDBMS** | A DBMS that stores data in **tables with relationships**, enforcing integrity | Warehouse with labeled shelves + rules |
| **Table** | Rows × columns of related data | A spreadsheet sheet |
| **Row (record / tuple)** | One instance of data in a table | One line of the sheet |
| **Column (attribute / field)** | A named property shared by all rows | One column of the sheet |
| **Schema** | The structure/layout of tables (columns, types, constraints) | The sheet's headers + validation |
| **Primary Key (PK)** | Column(s) uniquely identifying each row | Unique item ID |
| **Foreign Key (FK)** | Column referencing another table's PK | "Belongs to" pointer |
| **Unique constraint** | Column(s) must not repeat | Email uniqueness |
| **NOT NULL** | Column must hold a value | Compulsory field |
| **CHECK** | Column must satisfy a condition | `price >= 0` |
| **DEFAULT** | Fallback value when none supplied | `created_at = NOW()` |
| **Composite key** | PK/FK built from multiple columns | (order_id, product_id) |
| **Natural key** | A key that exists in the real world (SSN, email) | Real-world identifier |
| **Surrogate key** | An artificial key with no business meaning (auto-increment id) | Ticket number |

---

## DBMS vs RDBMS vs Database — the common mix-up

- **Database** = the data itself.
- **DBMS** = software that manages any data (flat files, hierarchical, relational, NoSQL).
- **RDBMS** = a DBMS based on the **relational model**: tables, keys, relationships, SQL.

> Interview answer: "An RDBMS is a type of DBMS that stores data in related tables and enforces integrity via keys, so data has structure and relationships rather than just a collection of files."

---

## Data Definition vs Data Manipulation

| Class | Purpose | Commands |
|-------|---------|----------|
| **DDL** (Data Definition Language) | Define/change structure | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` |
| **DML** (Data Manipulation Language) | Work with the data itself | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** (Data Control) | Permissions | `GRANT`, `REVOKE` |
| **TCL** (Transaction Control) | Manage transactions | `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> Note: In standard SQL, `SELECT` is also called DQL (Data Query Language), but `SELECT` is commonly classified under DML.

---

## Simple Example

```sql
CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,      -- surrogate key
    email         VARCHAR(100) UNIQUE,     -- natural key + unique constraint
    name          VARCHAR(100) NOT NULL,
    department    VARCHAR(50),
    salary        NUMERIC(10,2) CHECK (salary >= 0),
    hire_date     DATE DEFAULT CURRENT_DATE,
    manager_id    INT REFERENCES employees(employee_id)  -- FK to itself
);
```

```sql
INSERT INTO employees (email, name, department, salary)
VALUES ('ada@x.com', 'Ada', 'Data', 90000.00);
```

---

## SQL Practice

Load `datasets/employee.sql` and try:

1. Select all rows and columns from `employees`.
2. Select only `name`, `salary`.
3. Count rows: `SELECT COUNT(*) FROM employees;`
4. Insert a new employee, then delete them.

---

## Interview Question (Level 2)

**Q:** What is the difference between a primary key and a unique constraint?

**Answer:**
- A table has **only one** primary key; it may have **many** unique constraints.
- A PK is implicitly **NOT NULL**; a unique constraint **allows NULL** (in PostgreSQL, multiple NULLs allowed).
- A PK is the identity of the row and is used as the FK target; unique is for preventing duplicates.

---

## Tricky Question (Level 5 — looks simple, catches many)

**Q:** Consider this table:

```sql
CREATE TABLE t (
    a INT,
    b INT,
    UNIQUE (a, b)
);
```

Can you insert these rows? `(1, 2)`, `(1, NULL)`, `(1, NULL)`?

**Answer:** First two yes. The third **fails**. MySQL's behavior differs — but in **PostgreSQL**, `(1, NULL)` and `(1, NULL)` are considered **distinct** because `NULL <> NULL` is `NULL` (i.e., rows with NULL are treated as distinct). Wait — then why does the third fail?

**Correction:** In PostgreSQL, `UNIQUE (a, b)` treats NULLs as distinct, so `(1, NULL)` and `(1, NULL)` **both succeed**. In MySQL, the default `UNIQUE` index treats NULLs as equal under `UNIQUE`, so the second `(1, NULL)` fails. This difference is itself a great interview point.

**Interview answer:** "In PostgreSQL, NULLs are distinct, so multiple rows with NULL in the unique column are allowed. In MySQL, only one NULL is allowed per unique index (legacy behavior)."

---

## Real-World Scenario

You are asked to design a `users` table for a SaaS. Which columns get which constraint?

```sql
CREATE TABLE users (
    user_id   SERIAL PRIMARY KEY,          -- surrogate key
    email     VARCHAR(255) UNIQUE NOT NULL, -- natural key, no dupes, no null
    country   VARCHAR(2) NOT NULL,
    age       INT CHECK (age BETWEEN 13 AND 120),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_type VARCHAR(20) NOT NULL DEFAULT 'customer'
                 CHECK (user_type IN ('customer', 'admin', 'vendor'))
);
```

Explain each constraint choice to the interviewer.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups to prepare:** "What's a surrogate vs natural key?" / "Why use SERIAL / IDENTITY instead of manually incrementing?" / "What is a composite key used for?"