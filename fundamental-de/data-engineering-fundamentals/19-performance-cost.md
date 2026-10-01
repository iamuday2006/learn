# 19 — Performance & Cost

Good data engineering balances speed, cost, and reliability.

## Partitioning
Splits data by a key like date or region to reduce scan size.

## Indexing
Improves lookup speed for repeated access patterns.

## File sizes
Too many small files create overhead; very large files can be hard to manage.

## Compression
Reduces storage and I/O cost but adds CPU time.

## Columnar formats
Allow analytical systems to read only the needed columns.

## Predicate pushdown
Filter data as early as possible in the query plan.

## Partition pruning
Skip partitions that do not match query predicates.

## Query optimization
Reduce unnecessary reads and joins.

## Caching
Keep hot data in memory for repeated access.

## Parallelism
Run tasks at the same time to reduce completion time.

## Data skew
Uneven distribution of data causing bottlenecks.

## Shuffle
Redistributes data across partitions, often expensive.

## Small files problem
Creates scheduling and storage overhead.

## Must Know
- Partitioning, pruning, and skew
- Compression and columnar storage
- Small files and shuffle cost

## Good to Know
- Indexing and caching
- Predicate pushdown

## Advanced
- Cost-based optimizer tuning
- Storage tiering

## Interview Questions
1. What problem does partitioning solve?
2. Why is a small files problem harmful?
3. What is data skew and how does it affect a job?
4. Why is a columnar format faster for analytics?
5. What happens when you ignore query optimization in a large warehouse?
