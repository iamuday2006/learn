# 00. DBMS Fundamentals

> Covers timestamps: 00:00:00 – Introduction, 00:01:35 – What is DBMS?

## 1. What is Data?

**Data** is raw, unorganized facts, numbers, text, or observations that have no meaning on their own (e.g., 25, "John", "orders").

**Information** is processed, organized, structured, or contextualized data that is meaningful and useful (e.g., "John is 25 years old and placed an order today").

**Knowledge** is derived by interpreting information to support decisions.

`	ext
Data → Processing → Information → Interpretation → Knowledge
`

## 2. What is a Database?

A **Database** is an organized collection of related data that is stored, managed, and accessed electronically. It represents some aspect of the real world (mini-world) and is designed for a specific purpose.

**Example**: A university database stores students, courses, instructors, enrollments.

## 3. What is DBMS?

**DBMS (Database Management System)** is software that allows users to create, define, store, retrieve, update, delete, and manage data in a database efficiently, securely, and consistently.

It acts as an interface between users/applications and the underlying data.

**Examples**: PostgreSQL, MySQL, Oracle, SQL Server, SQLite.

## 4. DBMS vs Database

| Aspect | Database | DBMS |
|---|---|---|
| Definition | Organized collection of data | Software to manage that data |
| Type | Data | Software/System |
| Examples | Student records, product catalog | PostgreSQL, MySQL, Oracle |
| Creation | Stored as files/tables | Used to create/manage databases |
| Analogy | A filing cabinet (data) | The filing system + librarian (software) |

## 5. DBMS vs RDBMS

| Aspect | DBMS | RDBMS (Relational DBMS) |
|---|---|---|
| Data Model | Hierarchical, Network, File-based, etc. (varied) | Relational (tables with rows/columns, relations) |
| Relationships | Handled manually or via links | Handled via Foreign Keys & Relations |
| Normalization | Not enforced | Supported (1NF–5NF) |
| SQL Support | May or may not support SQL | Primarily SQL-based |
| Redundancy | Higher | Lower (with normalization) |
| Integrity | Limited | Strong (Entity/Referential/Domain) |
| Examples | File-based systems, dBase (older) | PostgreSQL, MySQL, SQL Server, Oracle |

> **Note**: Modern "DBMS" is often used to mean RDBMS in general conversation. Technically RDBMS is a type of DBMS.

## 6. File System vs DBMS

| Aspect | File System | DBMS |
|---|---|---|
| Data Storage | Data in separate files | Data in a centralized, structured database |
| Data Redundancy | High (duplication across files) | Controlled (reduced via normalization) |
| Data Consistency | Hard to maintain | Enforced via constraints, ACID |
| Data Access | Manual/programmatic per file | Query language (SQL) + abstractions |
| Security | File-level permissions | Fine-grained (user/role/table/row-level) |
| Concurrency | Difficult, risk of data loss | Controlled (locking, MVCC, transactions) |
| Data Integrity | Weak/Manual | Strong (constraints, keys) |
| Scalability/Sharing | Limited (multiple users cause issues) | Designed for multi-user access |
| Backup/Recovery | Manual, error-prone | Built-in recovery mechanisms (logs, WAL) |
| **Problem Solved** | Simple storage | Data sharing, consistency, integrity, security, concurrency |

**Why DBMS exists**: File systems lead to data redundancy, inconsistency, difficulty in access, isolation, integrity issues, atomicity problems, and security concerns — especially in multi-user environments.

## 7. Why Databases Exist

Databases exist to solve: **how to store, organize, retrieve, share, and protect data reliably while ensuring correctness when multiple users/processes access it simultaneously**.

**Core Problems Solved**:
1. **Data redundancy & inconsistency** – Avoid duplication, keep consistent
2. **Data isolation** – Hide complexity, provide unified view
3. **Data integrity** – Enforce rules (constraints, keys)
4. **Atomicity** – All-or-nothing operations (critical: payments, transfers)
5. **Concurrent access** – Multiple users without corrupting data
6. **Security** – Controlled access (auth, roles, privileges)
7. **Data recovery** – Survive crashes/failures
8. **Data independence** – Change storage/schema without breaking apps

## 8. Advantages & Disadvantages of DBMS

### Advantages
- **Data sharing**: Multiple users/apps access same data
- **Data consistency & integrity**: Constraints, ACID
- **Reduced redundancy**: Normalization
- **Data abstraction**: Hide physical details
- **Security**: Access control, authorization
- **Backup & recovery**: Transaction logs, WAL, checkpoints
- **Concurrency control**: Safe multi-user access
- **Data independence**: Logical/physical separation
- **Scalability**: Supports growth (read replicas, partitioning, etc.)

### Disadvantages
- **Cost**: Software, hardware, setup, maintenance
- **Complexity**: Requires design, tuning, admin expertise
- **Performance overhead**: Abstractions, ACID, logging (trade-off for correctness)
- **Size**: Needs storage + memory (buffer pool)
- **Single point of failure risk** (centralized DB) — mitigated via replication/clustering/HA
- **Learning curve**: Schema design, indexing, transactions, tuning

## 9. Database Users & DBA

### Database Users
| User Type | Role | Example |
|---|---|---|
| **Naive/End Users** | Use apps, no DB knowledge | Customer using ecom app |
| **Application Programmers** | Write apps that interact with DB (via SQL/ORMs) | Backend engineers |
| **Sophisticated Users** | Write complex queries directly | Analysts, Data Analysts |
| **Specialized Users** | Use DB for specific domain (CAD, GIS) | Domain experts |

### DBA (Database Administrator)

**DBA** is responsible for overall management, security, performance, and availability of the database.

**Responsibilities**:
- **Database design & schema**: Logical/physical design
- **Installation & configuration**: Setup, tuning params
- **Security & authorization**: Users, roles, privileges, auditing
- **Backup & recovery**: Strategies, disaster recovery, PITR
- **Performance tuning**: Indexes, EXPLAIN, slow query optimization
- **Concurrency control & transactions**: Ensure correctness
- **Maintenance**: VACUUM (Postgres), stats updates, partitioning, archiving
- **High availability & replication**: Failover, read replicas, clustering
- **Capacity planning**: Storage, growth, scaling

## 10. Schema, Instance, Metadata

| Term | What | Static/Dynamic | Example |
|---|---|---|---|
| **Schema** | Logical structure/blueprint of DB (tables, columns, types, PK/FK, constraints) | **Static** (rarely changes, design-time) | CREATE TABLE users(id INT PK, email TEXT UNIQUE) |
| **Instance** | Actual data stored at a particular moment (state of DB) | **Dynamic** (changes constantly via DML) | 50,000 user rows right now |
| **Metadata** | "Data about data" — describes schema, tables, columns, indexes, constraints, storage | Stored in **data dictionary/catalog** | Table names, column types, PKs, FK relations |

**Analogy**: Schema = Class definition. Instance = Objects/records at runtime.

## 11. Data Abstraction

DBMS hides complexity of how data is stored/managed, exposing only what's needed. 3 levels (ANSI/SPARC):

| Level | View | What it hides | Who uses |
|---|---|---|---|
| **Physical (Internal)** | Lowest — how data stored on disk (files, blocks, indices, B-trees) | Storage details | DBA, Storage Engine |
| **Logical (Conceptual)** | Community view — entities, attributes, relationships, constraints | Physical storage complexity | DB Designers, Architects |
| **View (External)** | Highest — subset for specific users/apps | Rest of DB (security, abstraction) | End users, Applications |

`	ext
External Views (App1, App2)
        ↓
Logical/Conceptual Schema (entities/relations)
        ↓
Physical/Internal Schema (files, blocks, storage)
`

**Purpose**: Simplicity, security (views restrict access), maintainability.

## 12. Data Independence

**Data Independence** = Ability to change schema at one level without affecting schema at higher levels. Critical for maintainability (apps don't break when storage changes).

### Logical Data Independence
- Change **logical schema** (add/remove columns, tables, split/merge entities) **without changing external views/apps**.
- Easier said than done in practice (can break views), but goal.
- **Focus**: Conceptual ↔ External
- **Example**: Add phone_number column to users table — existing queries/views that don't use it still work.

### Physical Data Independence
- Change **physical storage** (disk layout, indexing strategy, file organization, move to SSD, partitioning) **without changing logical schema or apps**.
- **Much stronger in practice** (thanks to query optimizer, storage engines).
- **Focus**: Internal ↔ Conceptual
- **Example**: Switch from heap to different storage, add/remove indexes, change page size — SQL queries unchanged.

| Aspect | Logical Data Independence | Physical Data Independence |
|---|---|---|
| Level changed | Logical (conceptual) | Physical (internal/storage) |
| Affects higher? | External/views/apps (minimized) | No effect on logical/external |
| Difficulty | Harder | Easier (well-achieved) |
| Example | Schema evolution (normalize/denorm, add columns) | Storage tuning, indexing, file reorg |

## Key Takeaways (Interview)

- **DBMS exists** to solve redundancy, inconsistency, concurrency, integrity, atomicity, security, recovery.
- **Schema vs Instance**: Blueprint vs Current state.
- **3-level abstraction** + **Data Independence** = decouples apps from storage/structure.
- **DBA** owns availability, security, performance, backup/recovery.

## Interview Q&A (Quick)

**Q1. What is DBMS? Why do we need it over File System?**
- **Short**: DBMS is software to manage databases with controlled access, consistency, integrity, concurrency, recovery. File systems suffer redundancy, inconsistency, lack of multi-user safety, weak integrity/security.
- **Deep**: Explains ACID, data abstraction, independence, centralized control.

**Q2. Difference between Schema and Instance?**
- Schema = static structure (design). Instance = dynamic data at a point in time.

**Q3. Logical vs Physical Data Independence?**
- Logical: change conceptual schema without breaking apps/views. Physical: change storage without affecting logical/external.
