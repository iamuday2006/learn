# Normalization Cheat Sheet

**Goal**: reduce redundancy, integrity, avoid anomalies (Insert/Update/Delete)

**FD**: A→B same A => same B. Partial (subset of composite), Transitive (non-prime→non-prime via non-prime)

**1NF**: atomic, no repeating groups
**2NF**: 1NF + no partial deps
**3NF**: 2NF + no transitive deps
**BCNF**: every determinant = super key
**4NF**: BCNF + no MVDs
**5NF**: 4NF + no join deps (lossless)

**Normalize**: OLTP (correctness). **Denormalize**: OLAP/read-heavy (perf), trade redundancy for fewer joins.
