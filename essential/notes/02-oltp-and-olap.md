## 2. OLTP and OLAP

### OLTP

OLTP (Online Transaction Processing) supports day-to-day business operations:
placing orders, updating account balances, or registering users. It has many
concurrent users, short selective queries, frequent inserts/updates/deletes,
and strong transactional consistency.

**ACID**:

- **Atomicity:** a transaction succeeds completely or has no effect.
- **Consistency:** constraints and business rules remain valid.
- **Isolation:** concurrent transactions do not incorrectly interfere.
- **Durability:** committed data survives failures.

### OLAP

OLAP (Online Analytical Processing) supports reporting, dashboards, trend
analysis, and machine learning. It is read-heavy, scans large historical
datasets, and performs joins and aggregations.

| Concern | OLTP | OLAP |
|---|---|---|
| Goal | Run the business | Analyze the business |
| Data | Current operational state | Historical, integrated data |
| Queries | Short and selective | Long scans and aggregations |
| Writes | Frequent | Batch or controlled loads |
| Schema | Usually normalized | Often dimensional/denormalized |
| Optimization | Fast transactions | Fast analytical scans |
| Examples | PostgreSQL, MySQL | Snowflake, BigQuery, Redshift |

Do not run large reports directly on a production OLTP database: scans compete
with customer transactions, operational schemas are not analytics-friendly,
and long-running queries can affect availability.


