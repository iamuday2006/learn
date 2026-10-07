# Beginner Questions (50)

Template applied to key ones. Short answers provided for all major concepts.

## 1. What is DBMS?
**Short Answer:** DBMS is software to create, store, manage, retrieve data securely with multi-user access. It solves redundancy, inconsistency, concurrency, integrity, security, recovery.

**Deep Explanation:** Acts as interface between apps and data; provides abstraction (3-level), data independence, ACID, constraints.
**Example:** PostgreSQL/MySQL manage university/student data.
**Follow-up:** DBMS vs RDBMS?
**Common Mistake:** Confusing DBMS with database.
**DE Perspective:** Understanding sources (OLTP) is key.

## 2. Database vs DBMS
**Short:** Database = organized data collection. DBMS = software managing it.

## 3. DBMS vs RDBMS
**Short:** DBMS varied models; RDBMS relational (tables+FKs), supports SQL, normalization, stronger integrity.

## 4. File System vs DBMS
**Short:** File system causes redundancy/inconsistency/concurrency issues; DBMS centralizes with constraints, ACID, security.

## 5. Why DBMS over File System?
**Short:** Multi-user safety, data consistency/integrity, atomicity, recovery, abstraction, access control.

## 6. What is RDBMS?
**Short:** Relational DBMS stores data as relations (tables) with keys/constraints, uses SQL.

## 7. Schema vs Instance
**Short:** Schema = static blueprint (structure). Instance = dynamic data at a point in time.

## 8. Data Abstraction (3 levels)
**Short:** External (views), Conceptual/Logical (entities), Internal/Physical (storage). Hides complexity.

## 9. Logical vs Physical Data Independence
**Short:** Logical: change conceptual without breaking apps. Physical: change storage without affecting logical/external.

## 10. What is Data Redundancy?
**Short:** Same data repeated in multiple places; causes inconsistency. Normalization reduces it.

## 11. Data Integrity
**Short:** Accuracy/consistency via PK/FK/UNIQUE/CHECK/domain constraints.

## 12. Entity & Attribute
**Short:** Entity = real-world object. Attribute = property of entity.

## 13. Tuple & Attribute (Relational)
**Short:** Tuple = row. Attribute = column.

## 14. Relation, Domain
**Short:** Relation = table. Domain = valid set of values for attribute.

## 15. Primary Key
**Short:** Uniquely identifies row, NOT NULL, one per table.

## 16. Foreign Key
**Short:** References PK of another table; enforces referential integrity.

## 17. Candidate Key vs Primary Key
**Short:** Candidate = minimal unique. PK = chosen candidate.

## 18. Super Key
**Short:** Any set uniquely identifying tuple (may include extras).

## 19. Composite Key
**Short:** Key made of multiple attributes (e.g. (sid,cid)).

## 20. Entity Integrity
**Short:** PK cannot be NULL.

## 21. Referential Integrity
**Short:** FK must match existing PK or be NULL if allowed.

## 22. ER Model
**Short:** Conceptual model showing entities, attributes, relationships (design before relational).

## 23. Strong vs Weak Entity
**Short:** Strong has PK, independent. Weak needs strong via identifying relationship + partial key.

## 24. Cardinality (1:1,1:M,M:N)
**Short:** Max mapping: 1:1, 1:M, M:N.

## 25. Participation (Total/Partial)
**Short:** Total = must participate (double line). Partial = may (single line).

## 26. Generalization vs Specialization
**Short:** Generalization = bottom-up (merge). Specialization = top-down (split).

## 27. What is Normalization?
**Short:** Decompose to reduce redundancy, improve integrity, avoid anomalies.

## 28. 1NF, 2NF, 3NF (simple)
**Short:** 1NF atomic. 2NF no partial on composite key. 3NF no transitive (non-prime→non-prime).

## 29. Update/Insert/Delete Anomalies
**Short:** Update inconsistency, can't insert without related, delete loses unrelated data.

## 30. What is a Transaction?
**Short:** Logical unit of work – all-or-nothing (COMMIT/ROLLBACK).

## 31. ACID Properties
**Short:** Atomicity, Consistency, Isolation, Durability.

## 32. COMMIT vs ROLLBACK
**Short:** COMMIT makes permanent. ROLLBACK undoes.

## 33. What is SQL?
**Short:** Structured Query Language to query/manipulate relational data.

## 34. DDL/DML/DCL/TCL (brief)
**Short:** DDL schema, DML data, DCL privileges, TCL transactions.

## 35. SELECT, WHERE, GROUP BY, HAVING
**Short:** WHERE filters rows pre-group; HAVING filters groups post-group.

## 36. INNER vs LEFT JOIN
**Short:** INNER matched only. LEFT all left + matched (NULL if none).

## 37. SELF JOIN
**Short:** Table joined to itself (hierarchies).

## 38. Subquery vs CTE
**Short:** CTE named/reusable/readable; subquery nested. Often similar.

## 39. DISTINCT
**Short:** Removes duplicate rows.

## 40. NULL vs Empty
**Short:** NULL unknown/missing (use IS NULL). Empty string is known value.

## 41. What is an Index?
**Short:** Data structure to speed lookups; trades speed for write cost/space.

## 42. Why indexes slow writes?
**Short:** Must update table + all affected indexes on DML.

## 43. Clustered vs Non-Clustered Index (basic)
**Short:** Clustered reorders data (1 per table, leaf=data). Non-clustered separate (many, points to data).

## 44. What is a View?
**Short:** Virtual table from query; simplifies/security.

## 45. Primary vs Unique Key
**Short:** PK NOT NULL, 1 per table. UNIQUE allows NULL (usually 1 in practice, varies), multiple allowed.

## 46. WHERE vs HAVING
**Short:** Row filter before grouping vs group filter after.

## 47. What is Constraint?
**Short:** Rule enforcing data integrity (PK/FK/UNIQUE/CHECK/NOT NULL).

## 48. TRUNCATE vs DELETE
**Short:** TRUNCATE faster, removes all (DDL-like), can't rollback in some cases? DELETE row-wise, can filter, rollbackable in txn.

## 49. What is Data Type?
**Short:** Defines kind of data (INT, TEXT, DATE) for validation/storage.

## 50. Why use Transactions?
**Short:** Ensure ACID – all-or-nothing, consistent, isolated, durable for critical ops.
