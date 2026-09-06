# PySpark Internship Preparation
> Your single, complete PySpark study guide — from beginner to Data Engineer internship interview readiness.
>
> **Primary source:** *Spark: The Definitive Guide* by Bill Chambers & Matei Zaharia (O'Reilly, 2018).
>
> **How to use this document:** Work through it top-to-bottom. Each section builds on the previous. Section 0 (Roadmap) tells you *why* each stage matters and what to study at each step. The last section is a progress tracker — tick boxes as you go.
---
## 0. The Journey
```text
Python/SQL Foundation
        ↓
Spark Fundamentals
        ↓
PySpark DataFrame API
        ↓
Spark Execution Model
        ↓
Spark Architecture
        ↓
Transformations & Actions
        ↓
Partitions & Parallelism
        ↓
Joins & Aggregations
        ↓
Shuffles
        ↓
Caching & Persistence
        ↓
Performance Optimization
        ↓
Spark SQL
        ↓
Structured Streaming
        ↓
Real Data Engineering Projects
        ↓
Interview Preparation
```
This is the **progressive curriculum** this entire document follows. Each chapter of this guide maps to one or more stages. Do not jump ahead — the stages are ordered so that hard concepts (shuffles, partitioning, optimization) only appear after you've built the foundation.
| Stage | Chapter in this guide | Objective |
|-------|----------------------|-----------|
| Python/SQL Foundation | (pre-requisite, see below) | Comfortable writing Python, basic SQL SELECT/GROUP BY/JOIN |
| Spark Fundamentals | Ch 1 | What Spark is, why it exists, core abstractions |
| PySpark DataFrame API | Ch 5 | Write everyday column/row transformations |
| Spark Execution Model | Ch 3 | Lazy evaluation, plans, Catalyst, Tungsten |
| Spark Architecture | Ch 2 | Driver, executors, cluster manager, DAG, stages, tasks |
| Transformations & Actions | Ch 3 & 4 | Narrow vs wide, lazy vs eager |
| Partitions & Parallelism | Ch 8 | repartition, coalesce, parallelism |
| Joins & Aggregations | Ch 6 & 7 | groupBy, join types, join strategies |
| Shuffles | Ch 8 | Where shuffles happen, why they're expensive |
| Caching & Persistence | Ch 9 | cache/persist/StorageLevel |
| Performance Optimization | Ch 11 | AQE, broadcast, skew, small files, checklist |
| Spark SQL | Ch 10 | temp views, EXPLAIN, SQL↔DataFrame interop |
| Structured Streaming | Ch 13 | internship-level streaming concepts |
| Real Data Engineering | Ch 14 | where Spark sits in a modern pipeline |
| Internship Projects | Ch 15 | 3 hands-on projects |
| Practice | Ch 16 | 60 realistic problems |
| Interview Preparation | Ch 17–21 | questions, answer frameworks, cheat sheet |
---
### Pre-Requisite: Python & SQL Foundation
- **Python:** variables, lists, dicts, loops, functions, list comprehensions, basic file I/O, `datetime`, basic `pandas` (DataFrame mental model helps).
- **SQL:** `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `JOIN` (inner/left), `ORDER BY`, `LIMIT`, aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).
- **Interview importance:** `MUST KNOW` — Spark's DataFrame API maps almost 1:1 onto SQL, and interviews assume you can write SQL.
**Practice requirement:** Solve 10–20 easy SQL problems on any platform (LeetCode/HackerRank) and write 5 small Python scripts manipulating lists/dicts.
---
