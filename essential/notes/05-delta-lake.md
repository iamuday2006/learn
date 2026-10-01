## 5. Delta Lake

A Delta table is primarily **Parquet data files plus a transaction log**:

```text
table/
  part-*.parquet
  _delta_log/
```

Parquet stores the columnar data. `_delta_log` records commits, file additions
and removals, schemas, and table versions. Readers use the log to construct a
consistent snapshot instead of guessing which files belong to a transaction.

Delta provides:

- **ACID transactions:** readers see consistent states and writes commit
  atomically.
- **Updates/deletes/MERGE:** reliable row-level changes on object storage.
- **Schema enforcement:** rejects incompatible incoming data.
- **Schema evolution:** allows approved structural changes such as new columns.
- **Time travel:** reads an earlier table version for audit, debugging, or
  recovery.

`OPTIMIZE` compacts many small files into larger files. **Data skipping** uses
file statistics to avoid reading files that cannot match a filter. **Z-Ordering**
co-locates related values to improve skipping for commonly filtered columns.
`VACUUM` removes obsolete files after a retention period; aggressive cleanup
can break time travel, so retention must be managed carefully.

Delta is more than Parquet: Parquet alone does not provide a transaction log,
atomic multi-file commits, table history, or reliable concurrent updates.


