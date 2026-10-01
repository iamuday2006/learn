## 14. Short Interview Answers

**What is a data warehouse?** A governed, centralized store of integrated
historical data optimized for analytical queries and BI. It separates reporting
workloads from operational systems and usually exposes curated dimensional
models.

**What is a data lake?** Low-cost object storage for raw data in many formats.
It provides flexibility and long-term retention, but needs cataloging,
governance, quality controls, and a processing layer.

**What is a lakehouse?** A lake architecture with warehouse capabilities such
as ACID transactions, schema management, governance, and SQL analytics on open
storage.

**What is Delta Lake?** A table format that combines Parquet files with a
transaction log to provide reliable updates, ACID commits, schema controls,
versioning, and time travel.

**What is grain?** The exact meaning of one fact row. It must be fixed before
designing the fact table because mixed grain causes incorrect joins and
double-counting.

**What is SCD Type 2?** A historical dimension technique that expires the old
row and inserts a new version with a surrogate key and effective dates.

**What is partitioning?** Organizing data by a frequently filtered,
moderate-cardinality column so queries can prune irrelevant data. It improves
scans only when the partition design matches access patterns.

**What is CDC?** A mechanism that captures inserts, updates, and deletes from a
source so downstream systems can process changes instead of repeatedly
reloading the entire source.

**What is idempotency?** A property where retrying the same input does not
change the final result beyond the first successful application.

**How do you handle bad data?** Validate at ingestion and transformation,
quarantine invalid records with reasons, alert the owner, preserve the input
for replay, and do not publish failed data as trusted data.


