# DBMS 1-Page Cheat Sheet

**Core**: DBMS manages DB. RDBMS = relations+SQL+ACID. Schema=static, Instance=dynamic.

**Keys**: PK (unique,NOT NULL), FK (ref integrity), Candidate/Alt/Super, Composite.

**Normalization**: 1NF atomic, 2NF no partial (composite), 3NF no transitive, BCNF determinant=superkey, 4NF no MVD, 5NF lossless.

**ACID**: A all-or-none, C consistent, I isolated, D durable. WAL: log before data (redo/undo/checkpoints).

**Isolation**: RU dirty yes, RC no dirty, RR no NRR, Serializable no phantom.

**MVCC**: versioned snapshots, R/W don’t block (readers no locks).

**Index**: B-Tree (eq+range), Hash (eq). Clustered 1 (leaf=data), Non-clustered many (points). Trade-off: reads↑ writes↓.

**Joins**: NLJ small/indexed, Hash eq large, Merge sorted/range.

**SQL vs NoSQL**: SQL ACID+joins+normalized. NoSQL flexible+scale+BASE/tunable.

**OLTP vs OLAP**: OLTP row/normalized/txn. OLAP column/denorm/agg.

**Rep vs Clust**: Rep copies (HA+reads), Cluster coordinates nodes (HA/load).

**Part vs Shard**: Part same server (pruning/manage), Shard multiple servers (horizontal scale).

**CAP**: CP consistency (may unavailable on P), AP available (eventual). P unavoidable.

**Scale**: Vertical simple, Horizontal complex. Read→replicas+cache. Writes→shard. Pooling early.
