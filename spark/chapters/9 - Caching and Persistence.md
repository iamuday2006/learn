# 9. Caching and Persistence

**Objective:** Know when caching *helps*, when it *hurts*, the storage levels, and cache eviction/recomputation.

**Why it matters:** Misuse of caching is a classic interview trap and a real performance blocker.

**Book chapters to study:** Ch 7 (and references to persistence in Part IV). `EXTERNAL KNOWLEDGE` for storage-level detail specifics.

**Interview importance:** `MUST KNOW`

---

## Concept: cache() & persist()

### Simple Explanation
`cache()`/`persist()` tells Spark to **store a DataFrame's computed data in memory** (and/or disk) so reuses don't recompute from scratch.

### Code Example
```python
from pyspark import StorageLevel

# Cache (default = MEMORY_AND_DISK)
df_clean = df.filter(...).withColumn(...).cache()
df_clean.count()          # action → materializes the cache NOW

# Reuse without recomputing
r1 = df_clean.groupBy("region").count()
r2 = df_clean.groupBy("product").count()

df_clean.unpersist()      # release when done

# Explicit storage level
df.persist(StorageLevel.MEMORY_AND_DISK)
df.persist(StorageLevel.MEMORY_ONLY)
df.persist(StorageLevel.DISK_ONLY)
df.persist(StorageLevel.MEMORY_ONLY_SER)
```

### Why It Exists
Spark datasets are immutable; without caching, every new action **replays the full lineage** (re-reads + recomputes). Caching stores the computed result so a reused DataFrame is fetched from memory/disk instead of recomputed.

### Interview Explanation
"`cache()` and `persist()` store a DataFrame's computed partitions so that subsequent actions reuse them instead of recomputing the lineage from scratch. `cache()` is a shorthand for `persist()` at the default storage level `MEMORY_AND_DISK`. You must trigger an action (like `count()`) to actually materialize the cache, and you call `unpersist()` when you're done."

### Common Mistakes
- Caching without measuring benefit (usually harmless but wastes memory).
- Not triggering an action after `cache()` → nothing cached.
- Never calling `unpersist()` → memory held.

---

## Concept: StorageLevel

### Simple Explanation
Configures *where* cached data lives: memory, disk, or both, and whether it's serialized.

### StorageLevel options (PySpark)

| StorageLevel | Stores in memory | Stores on disk | Serialized | Notes |
|--------------|------------------|----------------|------------|-------|
| `MEMORY_ONLY` | Yes | No | No | Fast, but loses partitions if out of memory |
| `MEMORY_AND_DISK` | Yes | Yes (overflow) | No | Default & safest |
| `MEMORY_ONLY_SER` | Yes | No | Yes | Less memory, more CPU |
| `MEMORY_AND_DISK_SER` | Yes | Yes | Yes | Balanced for big data |
| `DISK_ONLY` | No | Yes | — | Large data, memory-scarce |
| `OFF_HEAP` | Off-heap | — | Yes | Advanced, requires config |

### Interview Explanation
"Storage levels choose memory vs disk and serialization. `MEMORY_ONLY` keeps deserialized objects in memory (fast, but partitions are dropped if they don't fit). `MEMORY_AND_DISK` spills to disk when memory fills — the safe default that `cache()` uses. Serialized forms (`_SER`) use less memory at the cost of CPU. `DISK_ONLY` is for when data barely fits memory."

### Common Mistakes
- Using `MEMORY_ONLY` on large data (loses partitions → recompute).
- Forgetting serialized levels to save memory.

---

## Concept: When caching helps / hurts

### Helps when:
- A DataFrame is **reused across multiple actions/derived queries** (common: a cleaned base table used by many reports).
- The DataFrame is **expensive to compute** (complex joins/aggregations).
- **Iterative algorithms** reuse intermediate results.

### Hurts when:
- The DataFrame is used **only once** (cache adds overhead, no benefit).
- Data **doesn't fit in memory** anyway (spill/eviction, GC pressure).
- Recomputing the source is cheap and the cache just wastes memory.
- Storage causes excessive **garbage collection**.

### Interview Explanation
"Cache only DataFrames that are reused multiple times or are expensive to compute. Caching hurts when the data is used once — the overhead of materializing and storing outweighs any benefit — or when it doesn't fit in memory, causing eviction, spill, GC pressure, and then recomputation anyway."

### Common Mistakes
- Caching every intermediate step "just in case."
- Caching before knowing the reuse pattern.

---

## Concept: Cache Eviction

### Simple Explanation
If cached data doesn't fit in executor memory, Spark **evicts** (drops) some cached partitions — typically the least-recently-used.

### Technical Explanation
Unified memory: execution and storage share the executor's memory pool. If storage needs more space than available, Spark evicts cached partitions (for `MEMORY_AND_DISK`, evicted blocks spill to disk; for `MEMORY_ONLY`, they're dropped and will be recomputed via lineage). The Spark UI **Storage** tab shows "Fraction Cached" — if < 100%, eviction is happening.

### Interview Explanation
"Cache eviction happens when cached data exceeds the executor's storage memory. Spark drops the least-recently-used cached partitions; with `MEMORY_AND_DISK` they spill to disk, with `MEMORY_ONLY` they're lost and must be recomputed. The Storage tab's 'Fraction Cached' reveals eviction — you want 100%."

### Common Mistakes
- Ignoring a low "Fraction Cached" (means your cache isn't fully effective).

---

## Concept: Recomputing Lineage

### Simple Explanation
When a needed partition isn't cached (evicted or never cached), Spark **recomputes it from lineage** — replaying all its transformations.

### Technical Explanation
Because DataFrames/RDDs carry lineage, any un-cached partition can be regenerated by rerunning its transformations from the source. This is the fallback that guarantees correctness, but recomputation costs time and I/O — hence caching reused data.

### Interview Explanation
"Recomputing lineage is Spark's fallback for data that isn't cached: it replays the transformations from the source to regenerate the lost partition. It guarantees correctness but is costly, so caching is used to avoid repeated recomputation of expensive reused data."

---

**End of Chapter 9.** Tick "Caching" in the tracker.

---

