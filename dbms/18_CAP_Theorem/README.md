# 18. CAP Theorem

> Covers: 10:55:30 – CAP Theorem. Consistency/Availability/Partition Tolerance, network partition examples, CP vs AP, nuance (not "pick any two").

## 1. What is CAP Theorem?

**CAP Theorem** (Brewer's Theorem, 2000, proved later) states that in a **distributed system** facing a **network partition (P)**, you can choose **at most two** of:

- **C – Consistency**
- **A – Availability**
- **P – Partition Tolerance**

**Key nuance**: In **normal (no partition)** operation, you can have **CA**. In the presence of **network partitions** (which are inevitable in distributed systems), you must choose **CP** or **AP**.

## 2. Definitions

| Term | Meaning | Explanation |
|---|---|---|
| **Consistency (C)** | **Strong Consistency** (Linearizability) | All nodes see **same data at same time** after write. Any read returns most recent write or error. |
| **Availability (A)** | **Always Available** | Every request gets a **non-error response** (success), without guarantee it's the **latest**. |
| **Partition Tolerance (P)** | **Tolerates Network Partitions** | System continues to operate despite **communication break** between nodes (network split). |

**Network Partition**: Nodes can't communicate but both still up (e.g. link failure, switch down). Common in distributed/cloud.

## 3. CP vs AP vs CA

| Choice | What it means | Behavior on Partition | Example Systems |
|---|---|---|---|
| **CA** | Consistent + Available, **no partition tolerance** | **Not realistic** for distributed (partitions happen). Works in **single-node**. | Traditional RDBMS on single server |
| **CP** | Consistent + Partition Tolerant, **sacrifice Availability** | **May refuse requests** to maintain consistency (wait/block or return error) until partition heals. | **MongoDB (majority)**, **HBase**, **Cassandra in some configs**, **Zookeeper**, **etcd** |
| **AP** | Available + Partition Tolerant, **sacrifice Consistency** | **Always respond** (available) but may return **stale** (inconsistent) data during partition. | **Cassandra (default tunable)**, **CouchDB**, **DynamoDB**, **Riak** |

**Reality**: **P is mandatory** for any real distributed system. So effectively choose **CP or AP** during partitions.

## 4. Example: Network Partition Scenario

Imagine 2 data centers, connected. Write happens in DC1.

**Network partition occurs** (link down). DC2 can't see DC1.

- **Choose CP (Consistency)**: DC2 **rejects reads/writes** or blocks until healed → **unavailable** but data remains **consistent** (no divergence).
- **Choose AP (Availability)**: DC2 **still serves reads/writes** from its local copy → **available** but may serve **stale** data; when link heals, need **conflict resolution** (eventual consistency).

## 5. CAP Nuance (Important)

- **"Pick any two" is misleading**. In practice, **partition tolerance is required**. The real trade-off is **C vs A during P**.
- **Consistency here = Linearizability (strong)**, not just transactional ACID in single-node sense.
- **Availability** = **every request receives response** (no timeout/error) – not "99.9% uptime" marketing.
- **Eventual Consistency** is common in AP systems (converge later).
- **Tunable Consistency**: Many systems let you choose (e.g. Cassandra QUORUM, ONE, ALL – trade C vs A).
- **No global choice**: Can vary per operation/consistency level.

## 6. Real-World Mapping

| Database | CAP Classification (tendency) | Notes |
|---|---|---|
| **PostgreSQL (single node)** | **CA** | No real partition tolerance alone |
| **PostgreSQL (streaming + failover)** | **CP/AP depends** | Complex HA can behave differently |
| **MySQL (single node)** | **CA** | Single-node → no P |
| **MongoDB (replica set, majority)** | **CP-leaning** | Prefers consistency on partitions (can become unavailable) |
| **Cassandra** | **AP-leaning (tunable)** | Default eventual; can be tuned to quorum (closer to CP) |
| **CouchDB** | **AP** | Master-master, eventual consistency |
| **DynamoDB** | **AP-tunable** | Offers strongly consistent reads (costs availability/latency) |
| **HBase** | **CP** | Strong consistency, may sacrifice availability |
| **Redis (single node)** | **CA** | In-memory, single-node |
| **Zookeeper/etcd** | **CP** | Consensus-based (strong consistency, quorum) |

> **Note**: Classifications are simplified. Modern systems are flexible.

## 7. PACELC Extension (Optional but Nice)

**PACELC**: "If **P**artition, else **E**lse **L**atency vs **C**onsistency". Extends CAP: when **no partition**, trade-off between **Latency** and **Consistency**.

- **PA/EL**: Prefer Availability+Latency
- **PC/EC**: Prefer Consistency over Latency

(Cassandra = PA/EL leaning; MongoDB = PC/EC leaning) – good to know conceptually.

## 8. Examples in Context

**Banking App (Transfer)**: Better **CP** – refuse/hold during partition to avoid double-spend/incorrect balance (consistency > availability).

**Social Media Feed/Comments/Likes**: Better **AP** – show something (even slightly stale) to keep app usable (availability > immediate perfect consistency). Eventual convergence fine.

**E-commerce Inventory**: Often **CP** for "add to cart/checkout" (avoid overselling). Can be **AP** for "product views/counts" (stale count acceptable).

## Key Takeaways (Interview)

- **CAP**: In distributed + partition → choose C or A (max 2). **P is unavoidable**.
- **CP**: Consistent, may be unavailable during partition. **AP**: Available, may be inconsistent (stale).
- **"Pick any two" oversimplifies** – focus on **C vs A under P**.
- **Tunable systems exist** (Cassandra quorum levels).
- **Single-node DBs = CA** (no real P).
- Choose by use case: **Finance → CP**. **Social/Feeds → AP** often acceptable.

## Interview Qs

**Q1. Explain CAP Theorem with example.**
- In distributed system with network partition (P), choose Consistency (C) or Availability (A). CP: may refuse requests to stay consistent (e.g. banking). AP: always respond but stale (e.g. social feed).

**Q2. Why is "pick any two" misleading?**
- Partitions are inevitable in real distributed systems → P is required. Real trade-off is **C vs A during partition**, not choosing to drop P entirely.

**Q3. CP vs AP systems – difference with examples?**
- CP: consistent, may be unavailable (MongoDB majority, HBase). AP: available, eventually consistent (Cassandra, CouchDB).

**Q4. Give real use case for CP and AP.**
- CP: Bank transfer (correctness critical). AP: Instagram likes/feed views (availability + eventual consistency acceptable).

**Q5. What does Partition Tolerance mean?**
- System continues functioning despite nodes unable to communicate (network split).

**Q6. Single-node RDBMS – CAP?**
- Effectively **CA** (no network partition across nodes). CAP applies to **distributed** systems.
