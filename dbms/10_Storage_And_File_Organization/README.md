# 10. Storage & File Organization

> Covers pages/blocks, records/rows, heap, disk I/O, buffer pool/cache, sequential vs random I/O. Explains DB performance is often I/O-bound.

## 1. Why Storage Matters

Databases store large data on **disk (HDD/SSD)**; memory (RAM) is faster but smaller/volatile. **Disk I/O is the bottleneck** in most DB workloads. Goal: minimize I/O, maximize memory hits (buffer pool).

## 2. Pages, Blocks, Records

| Term | Definition | Typical Size |
|---|---|---|
| **Block (Disk Block)** | Smallest unit OS reads/writes from disk | 4KB–8KB (common) |
| **Page (DB Page)** | Smallest unit DBMS reads/writes | Usually **same as block** (4KB/8KB/16KB). Postgres default 8KB |
| **Record/Row** | Single tuple in table | Varies (fixed/variable length) |
| **Slot** | Position of record inside page | Fixed or tracked via directory |

**Key**: DB reads/writes **entire pages/blocks** (not single rows) to amortize I/O cost.

## 3. File Organization: Heap Storage

Tables stored as **files** of pages. Simplest: **Heap (Unordered Heap File)**.

- **Heap** = collection of pages with **no particular order** of rows.
- Rows inserted at free space (usually end or first free slot).
- **No clustering** by key by default (Postgres heap).
- **Pros**: Fast inserts (append), simple.
- **Cons**: Lookups require scanning (unless indexed). Updates/deletes create free space (fragmentation).

**Alternatives** (conceptual): Sorted files, Hashed files, Clustered B-tree (index-organized tables). Most OLTP use Heap + Indexes.

## 4. Buffer Pool (Buffer Cache)

**Buffer Pool** = In-memory cache of **disk pages** in RAM. Managed by **Buffer Manager**.

**Why**: Accessing RAM ~1000x faster than disk. Cache hits avoid I/O.

**Workflow**:
1. Request page P
2. If in **Buffer Pool (Hit)** → return from memory
3. If not (**Miss**) → read P from disk → put in free frame → return. If full, **evict** some page (replacement policy: LRU/Clock)

**Dirty Page**: Modified in memory but not yet written to disk. Must be flushed eventually (WAL + checkpoints ensure durability).

**Pin/Unpin**: Prevent eviction while being used.

## 5. Disk I/O: Sequential vs Random

| Aspect | **Sequential I/O** | **Random I/O** |
|---|---|---|
| **Access Pattern** | Read pages in **contiguous** order | Read pages in **scattered/random** order |
| **Speed (HDD)** | **Much faster** (head moves less, seeks minimized) | Slower (many seeks) |
| **Speed (SSD)** | Faster but gap smaller vs HDD | Faster than HDD random, still more overhead |
| **Cost** | Cheaper per page | More expensive |
| **Examples** | Full table scan (seq), large range scan, ETL scans, index leaf scan in order | Index lookups hitting different pages, many single-row lookups |
| **Optimization** | Prefetch, read-ahead | Buffer pool, clustering, covering indexes, read-ahead less helpful |

**Key Insight**: **DB performance is I/O-bound**. Prefer **sequential I/O** when reading large data; minimize random I/O for point lookups at scale.

## 6. I/O Cost Implications

- **Full Table Scan**: Often large # pages but **sequential** → can be efficient if need high % of rows (low selectivity bad but I/O pattern sequential).
- **Index Scan (point lookups)**: Few rows but may cause **random I/O** (jump between index pages + heap pages) – costly if many lookups.
- **Range Scan via B-Tree**: Index traversal + then **leafs in order + heap pages possibly scattered** (less sequential than full scan).
- **Covering Index**: Avoids heap fetches → reduces random I/O.

## 7. Storage Structures Summary

| Structure | Ordered? | Best For |
|---|---|---|
| **Heap File** | No | Fast inserts, OLTP mixed workloads + indexes |
| **Sorted File** | Yes (by key) | Range queries, few updates (maintain order costly) |
| **Index-Organized (Clustered)** | Ordered by cluster key | Range scans by key, PK lookups |
| **Hash File** | No order, hash buckets | Equality lookups only |

## 8. Practical Implications

- **Page size trade-off**: Larger pages = fewer I/O (more data/read) but internal fragmentation, longer transfers. Smaller = more I/O but less wasted.
- **Buffer pool size**: Bigger → higher hit rate, less disk I/O (critical).
- **Clustering**: Physically ordering heap by index key improves range scans (reduces random I/O) – CLUSTER in Postgres (one-time).
- **SSD shift**: Random I/O faster on SSD vs HDD, but **sequential still preferred** and I/O remains cost center vs RAM.

## Key Takeaways (Interview)

- **Pages/Blocks**: DB reads in page units (4KB/8KB). I/O is per-page.
- **Heap = unordered**; fast inserts, needs indexes for lookups.
- **Buffer Pool** = RAM cache → avoids disk I/O (hit rate critical).
- **Sequential I/O faster than Random I/O** (especially HDD). SSD narrows gap.
- **DB performance often I/O-bound**, not CPU-bound.
- **Trade-off**: Indexes reduce logical scans but can create random I/O.

## Interview Qs

**Q1. Why is database performance often I/O-bound?**
- Data larger than RAM, disk reads/writes much slower than CPU/RAM. Page-based access + random access dominates cost.

**Q2. What is Buffer Pool? Why important?**
- In-memory page cache. Reduces disk I/O, improves throughput (cache hits). Managed by Buffer Manager with eviction.

**Q3. Sequential vs Random I/O – difference & impact?**
- Sequential = contiguous pages (faster, e.g. full scan). Random = scattered (slower, e.g. many point lookups via index). Impacts scan strategy choice.

**Q4. Page vs Block?**
- Block = OS disk unit. Page = DBMS I/O unit (usually same size). DB reads/writes pages.

**Q5. Heap storage – pros/cons?**
- Unordered pages. Pros: fast inserts (append). Cons: no order → may need full scan without index.
