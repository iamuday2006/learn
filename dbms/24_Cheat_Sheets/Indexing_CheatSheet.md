# Indexing Cheat Sheet

**B-Tree**: eq+range, balanced O(log n) (B+Tree common)
**Hash**: eq only, O(1)

**Clustered**: 1/table, leaf=data, reorders data. **Non-clustered**: many, leaf=pointer.

**Types**: Single, Composite (leftmost prefix), Unique, Partial (WHERE), Covering (index-only)

**Trade-off**: reads↑, writes↓, space↑
**When NOT**: small tables, write-heavy, low selectivity, rarely queried, too many
**Good**: high cardinality, filtered/joined/sorted
