# 05. Normalization

> Covers: 05:33:43 – Normalization. Includes bad→why→decomposition→improved, anomalies, FDs, 1NF–5NF, Normalization vs Denormalization.

## 1. Why Normalization Exists

**Normalization** is the process of organizing data to reduce **redundancy** and improve **data integrity** by decomposing large tables into smaller, well-structured relations.

**Problems without normalization**:
- **Data Redundancy**: Same data stored repeatedly (wasteful, inconsistent)
- **Anomalies**: Insert/Update/Delete anomalies
- **Data Inconsistency**: Updates can leave partial/contradictory data

**Goal**: Minimize redundancy, maximize consistency, preserve information (lossless decomposition).

## 2. Functional Dependency (FD)

A **Functional Dependency** (A → B) means: if two tuples have same value for A, they must have same value for B. (Attribute B is functionally dependent on A).

- **Example**: StudentID → StudentName, DOB (given StudentID, name/DOB determined)
- **Trivial FD**: B ⊆ A → A → B (e.g. {id,name} → name)
- **Non-trivial**: B ⊈ A

**Prime Attribute**: Part of some candidate key. **Non-prime**: Not part of any candidate key.

## 3. Data Anomalies

| Anomaly | What Happens | Example (Unnormalized) |
|---|---|---|
| **Insert Anomaly** | Can't insert data because of missing unrelated info | Can't add a new course unless some student enrolled (or vice versa) |
| **Update Anomaly** | Updating same data in multiple places → risk of inconsistency | Dept head stored in 5 rows; update 4 only → inconsistent |
| **Delete Anomaly** | Deleting one record accidentally loses unrelated important data | Delete last student of a course → lose course details |

## 4. Normal Forms (1NF → 5NF)

We go step by step: **Problem → Bad Table → Why Problematic → Decomposition → Improved Schema**.

### 4.1 1NF (First Normal Form)

**Rule**: Relation must have **atomic (indivisible)** values. No repeating groups, no multivalued attributes.

**Violation**: Multiple phone numbers in one cell, comma-separated values, arrays.

**Example – Bad (Not in 1NF)**

| StudentID | Name | PhoneNumbers |
|---|---|---|
| S101 | Alice | 98765, 87654 |

**Why problematic**: Hard to query/filter by phone, redundancy, anomalies.

**Decomposition → 1NF**

| StudentID | Name |
|---|---|
| S101 | Alice |

| StudentID | Phone |
|---|---|
| S101 | 98765 |
| S101 | 87654 |

**Improved**: Atomic values. Now queryable, no repeating groups.

### 4.2 2NF (Second Normal Form)

**Rules**:
1. Must be in **1NF**
2. Must have **no Partial Dependency**: Every non-prime attribute must be **fully functionally dependent** on **entire** candidate key (not just part of composite key).

**Partial Dependency**: Non-prime attribute depends on **subset** of composite candidate key.

**Example – Bad (1NF but not 2NF)**

Table: Enrollment(StudentID, CourseID, StudentName, CourseName)

**Candidate Key**: (StudentID, CourseID) – composite

**FDs**:
- (StudentID, CourseID) → Grade (full)
- StudentID → StudentName (partial – depends on part)
- CourseID → CourseName (partial)

**Why**: Redundant (StudentName repeated for every course of student). Insert/update/delete anomalies.

**Decomposition → 2NF**
Split by partial dependencies:

1. Student(StudentID PK, StudentName)
2. Course(CourseID PK, CourseName)
3. Enrollment(StudentID FK, CourseID FK, Grade) → PK (StudentID,CourseID)

**Improved**: No partial dependencies. Redundancy reduced.

### 4.3 3NF (Third Normal Form) – Codd’s Definition

**Rules**:
1. Must be in **2NF**
2. Must have **no Transitive Dependency**: Non-prime attribute must **not** depend on another non-prime attribute (must depend only on candidate keys).

**Transitive Dependency**: A → B (non-prime), B → C (non-prime) ⇒ A → C transitively (C depends on A via B).

**Example – Bad (2NF but not 3NF)**

Table: Employee(EmpID, EmpName, DeptID, DeptName, DeptLocation)

**PK**: EmpID

**FDs**:
- EmpID → EmpName, DeptID (full on PK)
- DeptID → DeptName, DeptLocation (DeptID is non-prime, determines other non-prime)
- So EmpID → DeptName transitively (via DeptID)

**Why**: DeptName/Location repeated per employee in dept. If dept moves, update many rows (anomaly).

**Decomposition → 3NF**

1. Employee(EmpID PK, EmpName, DeptID FK)
2. Department(DeptID PK, DeptName, DeptLocation)

**Improved**: Dept info stored once. 3NF removes transitive dependencies.

**3NF Note (Common)**: "Every non-key attribute must depend only on the key, the whole key, and nothing but the key."

### 4.4 BCNF (Boyce–Codd Normal Form)

**Stronger than 3NF**. Deals with cases where there are **multiple candidate keys** or a **non-prime attribute determines a prime attribute**.

**Rule (Simplified)**: For every non-trivial FD X → A, **X must be a Super Key**.

**When needed**: 3NF is usually sufficient, BCNF removes remaining anomalies when determinants are not super keys.

**Example (Conceptual)**: If a table has overlapping candidate keys and a dependency where determinant isn't super key → BCNF violation even if 3NF.

**General**: BCNF ensures **no redundancy due to FDs where left side not super key**.

### 4.5 4NF (Fourth Normal Form)

**Rule**: Must be in **BCNF** and have **no Multi-Valued Dependencies (MVDs)** except trivial.

**MVD**: One attribute determines a **set of values** independently of others (multivalued independently).

**Example**: Course(CourseID, Instructor, Textbook) – one course has many instructors AND many textbooks, independent sets → MVDs. Storing combos creates redundancy.

**Decomposition**: Split into Course_Instructor(CourseID, Instructor) and Course_Textbook(CourseID, Textbook).

### 4.6 5NF (Fifth Normal Form) / PJNF

**Rule**: Must be in **4NF** and cannot be further decomposed into smaller relations **without loss of information** (lossless join decomposition). Deals with **join dependencies** across 3+ relations.

**Purpose**: Eliminate redundancy from complex multi-way relationships.

**Note**: Rarely needed in practice unless highly complex ternary+ relationships.

## 5. Normal Forms Summary

| NF | Key Requirement | Removes |
|---|---|---|
| **1NF** | Atomic values, no repeating groups | Multivalued/repeating groups |
| **2NF** | 1NF + No Partial Dependencies | Redundancy from composite key parts |
| **3NF** | 2NF + No Transitive Dependencies | Redundancy via non-prime→non-prime |
| **BCNF** | 3NF + Every determinant is Super Key | Stronger FD anomalies (overlapping CKs) |
| **4NF** | BCNF + No Multi-Valued Dependencies | Independent multivalued sets |
| **5NF** | 4NF + No Join Dependencies (lossless, irreducible) | Complex join-based redundancy |

**Practical takeaway**: Most OLTP designs aim for **3NF** (or BCNF). Higher NFs rare unless specific cases.

## 6. Normalization vs Denormalization

| Aspect | Normalization | Denormalization |
|---|---|---|
| **Purpose** | Reduce redundancy, improve integrity | Improve **read performance** (fewer joins) |
| **Approach** | Split tables (decompose) | Combine tables (merge, add redundant columns) |
| **Redundancy** | Minimized | Introduced intentionally |
| **Write Performance** | Better (smaller, less duplicated updates) | Slower (updates must touch redundant copies) |
| **Read Performance** | Slower in complex queries (more JOINs) | Faster (fewer/avoided joins) |
| **Data Integrity** | Higher (less inconsistency risk) | Lower risk if not maintained carefully |
| **Use Case** | OLTP (transactions, writes, correctness) | OLAP, Reporting, Read-heavy, Analytics, Dashboards, High-scale read workloads |
| **Anomalies** | Minimized | Can reintroduce |

### When to Denormalize (Production Reality)

Denormalization is a **deliberate trade-off** for performance:

- **Read-heavy workloads** (dashboards, reports, aggregations)
- **Avoid expensive joins** at scale (millions/billions of rows)
- **Latency-sensitive reads** (real-time analytics)
- **Data warehousing/OLAP** (Snowflake/BigQuery/Redshift often denormalized or use star/snowflake + columnar)
- **Caching/pre-computed tables/materialized views** (hybrid)
- **Geographic/distributed scaling** where cross-shard joins expensive

**Important**: Denormalize carefully. Maintain consistency via app logic, triggers, or ETL/materialized views. **Normalize first, denormalize only when measured bottleneck.**

## 7. Example: Bad → 3NF End-to-End

**Unnormalized Invoice-like**

| InvoiceNo | CustName | CustAddr | ItemID | ItemName | Qty | Price | DeptName |
|---|---|---|---|---|---|---|---|

Issues: repeating items (multivalued), CustAddr repeated per item, DeptName repeated.

**1NF**: Separate repeating groups (invoice items) → atomic.

**2NF** (remove partial): Split Customer, Item, Invoice, InvoiceItem. Remove partial deps on composite keys.

**3NF** (remove transitive): Move DeptName to Department if DeptID exists, etc. End with normalized relations.

Result: less redundancy, no anomalies, proper FKs.

## Key Takeaways (Interview)

- **Normalization = reduce redundancy + improve integrity**. Sacrifices some read speed for correctness.
- **3NF is sweet spot** for OLTP. Aim 3NF/BCNF in transactional systems.
- **Denormalization = intentional redundancy for read performance** (common in DW/analytics).
- **Anomalies** prove why normalization matters (insert/update/delete).
- **FDs drive normal forms** (partial/transitive/MVD/join deps).
- **Lossless decomposition** is key when splitting.

## Interview Qs

**Q1. What is Normalization? Why use it?**
- Process reducing redundancy via decomposition. Prevents anomalies, improves consistency/integrity.

**Q2. Explain 1NF, 2NF, 3NF simply?**
- 1NF: atomic values. 2NF: 1NF + no partial (depends on whole composite key). 3NF: 2NF + no transitive (non-prime→non-prime).

**Q3. Update/Insert/Delete anomalies with example?**
- Update: change same data in many rows → inconsistent. Insert: can’t add entity without related. Delete: remove related → lose data.

**Q4. Normalization vs Denormalization – when to denormalize?**
- Normalize for OLTP (writes/correctness). Denormalize for read-heavy (OLAP, reports, dashboards) when joins are bottleneck, accept redundancy + manage consistency.

**Q5. What is Transitive Dependency? Example?**
- A→B, B→C ⇒ A→C. EmpID→DeptID, DeptID→DeptName ⇒ EmpID→DeptName transitively.

**Q6. BCNF vs 3NF?**
- BCNF stronger: every determinant must be super key. Handles cases with multiple candidate keys.
