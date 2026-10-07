# 16. Partitioning

> Covers: 10:24:07 – Partitioning and Sharding. Range/List/Hash/Composite, partition pruning, benefits/limits.

## 1. What is Partitioning?

**Partitioning** is the **logical division** of a large table into smaller, more manageable **partitions** (subtables) **within the same database instance/server**. Physically stored separately but logically treated as **single table** from SQL view.

**Goal**: Improve **query performance, maintenance, data lifecycle management**.

**Note**: Partitioning ≠ Sharding (sharding splits across **different servers/instances**).

## 2. Why Partition?

- **Improved Query Performance**: **Partition Pruning** skips irrelevant partitions
- **Faster Maintenance**: Truncate/drop/archive entire partition easily (e.g. old months)
- **Better Indexing**: Smaller indexes per partition (faster)
- **Load Reduction**: Scans touch subset
- **Data Retention**: Purge old data by dropping partition (instant)
- **Parallelism**: Some DBs scan partitions in parallel

## 3. Partitioning vs Sharding (Key)

| Aspect | **Partitioning** | **Sharding** |
|---|---|---|
| **Location** | Same **database instance/server** | Across **multiple servers/instances** (shards) |
| **Scope** | Logical split, physical storage managed per partition | Horizontal distribution to different nodes |
| **Scale Type** | **Vertical/Manageability** + query perf (not horizontal node scale) | **Horizontal scaling** (add more nodes) |
| **Transparency** | Often transparent (single table view) | Apps may need to route by **shard key** |
| **Failure Impact** | Single instance failure affects all | Failure isolated to shard (if designed well) |
| **Complexity** | Moderate | Higher (routing, cross-shard) |

## 4. Partitioning Strategies

### 4.1 Range Partitioning
Split by **range of values** (dates, IDs).

- **Use**: Time-based data (orders by month/year), numeric ranges
- **Example**: orders_2025_01, orders_2025_02 by order_date
- **Good for**: Range queries (BETWEEN, < >)

`sql
-- Conceptual Postgres
CREATE TABLE orders (
  id BIGSERIAL, order_date DATE, amount DECIMAL
) PARTITION BY RANGE (order_date);
`

### 4.2 List Partitioning
Split by **discrete list of values** (categories, regions).

- **Use**: Known fixed sets (country, status)
- **Example**: Partition by country IN ('IN','US','UK')
- **Good for**: Filtering by exact category

`sql
PARTITION BY LIST (country);
`

### 4.3 Hash Partitioning
Split by **hash of key** → distributes rows **uniformly**.

- **Use**: Want even distribution, no natural range
- **Avoids hot partitions** if hash good
- **Not good for range queries** (hash breaks order)
- **Example**: Partition by hash(user_id) % N

`sql
PARTITION BY HASH (user_id);
`

### 4.4 Composite Partitioning (Subpartitioning)
Combine two strategies (e.g. **Range + Hash**, or **List + Range**).

- **Use**: Multi-level (e.g. partition by year range, subpartition by hash of user_id)
- **More flexible, more complex**

## 5. Partition Pruning

**Partition Pruning** = Optimizer **skips** partitions that **cannot** contain matching rows for a query.

**Benefit**: Dramatically reduces I/O (scans only relevant partitions).

**Example**:
`sql
SELECT * FROM orders WHERE order_date BETWEEN '2025-10-01' AND '2025-10-31';
`

If partitioned by month → only **Oct 2025 partition** scanned, others ignored.

**Works best when**: Query includes **partition key** in WHERE clause.

## 6. Partitioning Examples (Practical)

### Time-based (Range)
`	ext
orders_2024, orders_2025, orders_2026
`
Archive/drop orders_2024 after retention (instant vs DELETE).

### Geo-based (List)
Partition customers by region: APAC, EMEA, AMER.

### Load-balanced (Hash)
Hash user_id across 4 partitions for even spread.

## 7. Benefits vs Limitations

### Benefits
- **Faster queries** via pruning
- **Easier maintenance** (detach/attach, truncate/drop partition)
- **Bulk operations** efficient (archival)
- **Smaller indexes** per partition
- **Improved vacuum/cleanup** in some DBs
- **Better parallel query execution**

### Limitations
- **Single instance** still (no horizontal node scaling)
- **Partition key choice critical** (wrong key → poor pruning)
- **Cross-partition queries** still possible but can be slower
- **Constraint/application logic** awareness
- **Not all DBs support same features** (Postgres strong, MySQL varies)
- **Foreign keys** across partitions can be tricky
- **Over-partitioning** creates too many small objects (overhead)

## 8. When to Partition

**Good fit**:
- Large tables (>10–100M rows) growing fast
- **Time-series** (logs, events, orders by date)
- Need **easy archival** (drop old partitions)
- Queries naturally filter by **partition key**
- Reporting on recent ranges

**Poor fit**:
- Small tables
- Queries rarely filter by partition key
- Need to shard across multiple servers (use sharding)
- High cross-partition joins

## 9. PostgreSQL Partitioning Notes (Conceptual)

- Declarative partitioning (Postgres 10+) vs inheritance
- Supported: **RANGE, LIST, HASH**
- Can **attach/detach** partitions (DETACH CONCURRENTLY in modern)
- Indexes created on parent automatically propagate? Or create on partitions
- **Pruning** automatic when partition key in WHERE
- DEFAULT partition for unmatched values

## Key Takeaways (Interview)

- **Partitioning = split table within same server/instance** (logical single table).
- **Sharding = split across different servers/instances** (horizontal scaling).
- **Partition Pruning** is key benefit – skip irrelevant partitions.
- **Range** for time/numeric, **List** for categories, **Hash** for uniform distribution.
- Great for **large time-series + archival**. Not for node-level horizontal scale.

## Interview Qs

**Q1. What is Table Partitioning? Difference from Sharding?**
- Partitioning: divide table into partitions inside **same DB instance**. Sharding: distribute across **multiple DB servers/nodes** for horizontal scale.

**Q2. Explain Range/List/Hash Partitioning with examples.**
- Range: by date ranges (orders by month). List: by fixed values (country). Hash: by hash(user_id) for uniform distribution.

**Q3. What is Partition Pruning? Why important?**
- Optimizer skips non-matching partitions when WHERE uses partition key → fewer pages scanned, faster queries.

**Q4. When would you choose partitioning?**
- Very large table (time-series), need to archive old data quickly, queries filter by date/key (enables pruning), maintenance easier.

**Q5. Can you partition by multiple keys?**
- Yes, **composite/subpartitioning** (e.g. range by year, hash by user_id).
