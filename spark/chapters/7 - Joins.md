# 7. Joins

**Objective:** Master join types, join strategies, and — critically — *why joins can become extremely expensive* and how to optimize them.

**Why it matters:** Joins are the #1 performance topic in Data Engineering interviews. Understanding broadcast vs sort-merge and data skew will set you apart.

**Book chapters to study:** Ch 8/9 of the book (joins), Ch 19 (join execution) and throughout Part IV.

**Interview importance:** `MUST KNOW`

---

## Concept: Join Types

### Simple Explanation
Joins combine rows from two DataFrames based on a key. The *type* controls which rows are kept.

### Code Example (all types)
```python
# Inner — only matching rows from both
result = orders.join(customers, "customer_id", "inner")

# Left outer — all left rows, matching right (nulls where no match)
result = orders.join(customers, "customer_id", "left")

# Right outer — all right rows, matching left
result = orders.join(customers, "customer_id", "right")

# Full outer — all rows from both
result = orders.join(customers, "customer_id", "full")

# Left semi — left rows that HAVE a match (no right columns returned)
result = customers.join(orders, "customer_id", "left_semi")

# Left anti — left rows that have NO match
result = customers.join(orders, "customer_id", "left_anti")

# Cross — cartesian product (dangerous!)
result = df1.crossJoin(df2)
```

### Table: what each join keeps

| Join type | Result |
|-----------|--------|
| inner | Only rows matching in both |
| left | All left rows (+ matched right) |
| right | All right rows (+ matched left) |
| full | All rows from both |
| left_semi | Left rows that have a match (only left columns) |
| left_anti | Left rows with no match |
| cross | Every left row × every right row |

### Real-World Examples
- **left_semi:** "Which customers placed at least one order?" (keep customer columns).
- **left_anti:** "Which new users have never placed an order?" (new users not in orders).
- **inner:** "Orders with a valid matching customer."

### Interview Explanation
"Join types control which rows survive: inner keeps matches, left/right/full outer keep respective sides, semi keeps left rows that have a match (left columns only), and anti keeps left rows with no match. Choosing the right join type is essential for correct ETL and analytics."

### Common Mistakes
- Using `left` when you mean `inner` (produces extra null rows).
- Using `crossJoin` accidentally (cartesian explosion).

### Interview Questions
1. (B) What's the difference between inner and left join?
2. (I) When would you use `left_semi` vs `inner`?
3. (I) What does `left_anti` do and when is it useful?

---

## Concept: Join Strategies

When Spark joins two large DataFrames, it must get matching keys onto the same partition — that means a **shuffle** unless it can broadcast. The choice of strategy lives in the physical plan and directly affects performance.

### Broadcast Hash Join
- **What:** The **small** table (below `spark.sql.autoBroadcastJoinThreshold`, default 10MB) is sent (broadcast) to every executor. Each executor builds a hash table in memory of the small table and joins it against its local slice of the large table. **No shuffle of the large table.**
- **When:** One table is small (< ~200MB recommended, default threshold 10MB).
- **Cost:** Cheap — one network broadcast, no data shuffle.

```python
from pyspark.sql.functions import broadcast
result = large_df.join(broadcast(small_df), "key")   # force broadcast
```

### Sort Merge Join
- **What:** Both tables are **shuffled** by join key, then each is **sorted**, and merged. The shuffle ensures same keys land on the same partition; sorting enables an efficient merge.
- **When:** Both tables are large (the default when neither can broadcast). Equi-joins only.
- **Cost:** Expensive — two shuffles (one per side) + sort.

```python
result = large1.join(large2, "key")   # likely sort-merge if both large
```

### Shuffle Hash Join
- **What:** Both tables shuffled by key; the **smaller** side builds a hash table per partition.
- **When:** Medium tables, memory available. Often disabled in favor of sort-merge (`spark.sql.join.preferSortMergeJoin=true` by default).
- **Cost:** Two shuffles, but no sort.

### Broadcast Nested Loop Join
- **What:** Naive nested-loop join; extremely expensive. Used when there's no equality condition (e.g. range join).
- **When:** Only when forced (e.g. `<=` join without sorting/bucketing). **Avoid.**
- **Cost:** Catastrophic at scale.

### Bucket Join
- **What:** Both tables pre-bucketed to the same number of buckets by the same key; matching buckets locate data on the same node → **no shuffle**. Requires writing with `bucketBy`/`saveAsTable`.

### Table: choosing a strategy

| Strategy | Large + Small | Large + Large | Cost | Requires eq key |
|----------|---------------|---------------|------|-----------------|
| Broadcast Hash | ✓ | ✗ | Low (no shuffle) | Yes |
| Sort Merge | — | ✓ | High (2 shuffles + sort) | Yes |
| Shuffle Hash | — | ✓ (memory) | Medium-High | Yes |
| Bucket | ✓ | ✓ | Low (no shuffle) | Yes |
| Broadcast NLJ | — | ✗ | Very high | No |

### Interview Explanation
> "Spark picks a join strategy in the physical plan. **Broadcast hash join** sends a small table to every executor and joins locally without shuffling the large table — best when one side is small. **Sort merge join** shuffles and sorts both large tables by key then merges — the default for large-large joins but it's expensive because of two shuffles. **Shuffle hash join** shuffles both and hashes the smaller side. **Broadcast nested loop** is a fallback for non-equi joins and is very costly. Pre-bucketing can eliminate the shuffle entirely."

### Common Mistakes
- Broadcasting a large table (driver/executor OOM).
- Forgetting default broadcast threshold is only 10MB (small!).
- Assuming all joins shuffle — broadcast avoids it.

---

## Concept: Broadcast Join Detailed

### When should I broadcast a table?
- When one side is **small** (< ~10MB default; up to ~200MB with tuning) — like dimension/lookup tables.
- When broadcasting avoids a huge shuffle cost that outweighs the broadcast.
- For frequently tiny lookup tables (country codes, category names, etc.).

### How to enable
```python
# Explicit hint
from pyspark.sql.functions import broadcast
large.join(broadcast(small), "key")

# Auto threshold
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", 200 * 1024 * 1024)  # 200MB
```

### Trade-offs
- **Pro:** No shuffle of the big table; huge speedup.
- **Con:** The small table must fit in executor memory (broadcast is replicated on every executor). Broadcasting a too-big table → memory pressure/OOM and slow broadcast time.

### Interview Explanation
> "I broadcast a table when one side of the join is genuinely small — typically a dimension or lookup table under a few hundred MB. The small table is copied to every executor, which then joins locally, avoiding a full shuffle of the large table. The trade-off is that the broadcast data is replicated onto every executor, so it must fit in memory; broadcasting an overly large table causes memory pressure or OOM. I can hint with `broadcast()` or tune `spark.sql.autoBroadcastJoinThreshold`."

### Common Mistakes
- Broadcasting without checking actual size.
- Forgetting default auto-broadcast threshold (10MB) is conservative.

---

## Concept: Why a join can become extremely expensive

The main reasons:
1. **Full shuffle** — large-large joins shuffle entire datasets over the network (2 shuffles for sort-merge).
2. **Data skew** — one/hot keys put enormous load on a single partition/task, so the job waits on one slow task (straggler).
3. **Too many/large partitions** — oversized shuffle writes/reads and spill to disk.
4. **Non-equi joins** — fall back to broadcast nested-loop (catastrophic).
5. **No filtering/pruning** — joining entire tables instead of pre-filtering.

### Interview Explanation
> "A join is expensive mainly because large-large joins require shuffling all data across the network so matching keys are co-located. This is amplified by data skew (a few hot keys concentrate work on a few over-loaded partitions), by sorting in sort-merge, by non-equi conditions that force nested-loop joins, and by not filtering or pruning columns before the join."

### Common Mistakes
- Joining full tables and only then filtering (filter first!).
- Ignoring skew until a prod job breaks.

---

## Concept: Data Skew in Joins

### Simple Explanation
When some join keys appear far more than others, the partitions holding those keys get far more data → a few tasks become the bottleneck.

### Why it matters
A skewed join can make a 2-minute job take 30+ minutes because one executor is swamped while others idle.

### Detection
- Spark UI: few tasks take much longer than others (uneven task durations).
- `df.groupBy("key").count().orderBy(desc("count"))` — check max vs avg.

### Mitigation
1. **AQE skew join** (Spark 3.x) — automatically splits skewed partitions.
2. **Salting** — add a random salt suffix to the skewed keys to spread them across partitions, and explode the small side accordingly.
3. **Separate skewed rows** — handle hot keys with broadcast, process the rest normally.
4. **Round-Robin/broadcast the small side**.

### Interview Explanation
> "Data skew happens when a few keys dominate. In a shuffled join, all rows for a hot key land on one partition, so one task does most of the work while others finish early — a classic straggler. I detect it via the Spark UI (uneven task durations) or by checking key cardinality. I fix it with AQE's automatic skew join, or manually by salting the skewed keys and exploding the small side, or by splitting out the hot keys and broadcasting their small counterpart."

### Common Mistakes
- Assuming more executors fix skew (it's about distribution, not raw resources).
- Salting only one side of the join.

---

**End of Chapter 7.** Tick "Joins", "Broadcast joins" in the tracker.

---

