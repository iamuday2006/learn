## 9. File Formats and Partitioning

| Format | Best use | Main trade-off |
|---|---|---|
| CSV | Simple exchange and ingestion | No types, weak schema, large scans |
| JSON | APIs and nested events | Flexible but verbose and slower to scan |
| Parquet | Analytical storage | Columnar and efficient, less convenient to edit manually |
| Avro | Streaming and schema-based messages | Row-oriented; needs schema management |

**Parquet** is columnar, typed, compressed, and supports predicate pushdown:
the engine can read only required columns and files. This is why it is usually
better than CSV for analytics.

**Partitioning** places data in separate directories or table partitions based
on a column, commonly date:

```text
sales/year=2026/month=01/
sales/year=2026/month=02/
```

When a query filters on the partition column, **partition pruning** avoids
unneeded partitions. Good partition columns have low-to-moderate cardinality
and are frequently filtered, such as event date. Avoid high-cardinality
columns such as `customer_id`; they create too many directories.

Too many partitions and frequent tiny writes cause the **small-file problem**,
which increases metadata and scheduling overhead. Too few partitions cause
large scans. Use sensible partitioning and compaction.


