## 4. Data Lake, Warehouse, and Lakehouse

A **data lake** stores raw structured, semi-structured, and unstructured data
in low-cost object storage such as S3, ADLS, or GCS. Files may be CSV, JSON,
Parquet, logs, or images. It generally uses **schema-on-read**: data is
interpreted when it is consumed.

A lake is flexible and cheap, but a poorly governed lake can become a **data
swamp**: unknown schemas, duplicates, poor quality, unclear ownership, and
slow queries.

| Concern | Data lake | Data warehouse |
|---|---|---|
| Storage | Object storage/files | Managed analytical tables |
| Data | Raw and any format | Curated structured data |
| Schema | Usually on read | Usually on write |
| Cost | Lower storage cost | Higher but optimized query service |
| Users | Engineers, data scientists | Analysts, BI users |
| Strength | Flexibility and retention | Governance and predictable analytics |
| Risk | Quality and discoverability | Less flexible and costly for raw data |

Do not use only a lake when business users need governed, predictable metrics.
Do not use only a warehouse when you need cheap raw retention, unstructured
data, or flexible experimentation.

A **lakehouse** adds warehouse capabilities to open object storage: ACID
transactions, schema enforcement, governance, reliable updates, and SQL
analytics. It supports both BI and ML without copying all data into a
proprietary warehouse. Examples include Databricks with Delta Lake, and systems
using Apache Iceberg or Hudi.


