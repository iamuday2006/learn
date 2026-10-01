## 13. Scenario Playbook

**PostgreSQL with five years of sales:** extract with CDC or an incremental
timestamp, land raw data in object storage, validate and deduplicate in Silver,
load dimensional Gold tables into a warehouse, and expose sales marts to BI.
Avoid heavy reporting queries on PostgreSQL.

**Hourly JSON API:** land the original response in a date/hour path, record
request and batch metadata, parse and validate into Silver, deduplicate by the
API's event ID, retry transient failures, quarantine malformed records, and
make the target idempotent.

**Customer address history:** use SCD Type 2 with a surrogate key and effective
dates. Facts join to the dimension version valid when the event occurred.

**Millions of tiny Delta files:** identify the write pattern, compact files
with `OPTIMIZE`, reduce unnecessary partitions, batch writes, and use data
skipping/Z-Ordering where appropriate.

**Same day loaded twice:** detect by batch ID, source interval, row counts, or
duplicate business keys. Make the load idempotent with a deterministic batch
identifier and MERGE/overwrite of the exact partition.

**Dashboard takes ten minutes:** inspect the query plan, selected columns,
joins and filters, table grain, partition pruning, file sizes, clustering,
data volume, stale statistics, warehouse resources, and whether an aggregate
or data mart is appropriate.


