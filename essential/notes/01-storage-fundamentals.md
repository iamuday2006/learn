## 1. Storage Fundamentals

**Data storage** is the durable recording of data so it can be retrieved,
processed, shared, and recovered later. Persistent storage is needed because
memory is temporary and business data must survive process or machine failures.

| Type | Meaning | Examples |
|---|---|---|
| Structured | Fixed rows, columns, and types | PostgreSQL tables, CSV |
| Semi-structured | Flexible or nested structure with tags/keys | JSON, XML, Avro |
| Unstructured | No regular tabular structure | Images, audio, documents, logs |

**File storage** is inexpensive and flexible, but the application must manage
formats, consistency, and querying. **Database storage** provides indexes,
constraints, transactions, and query execution, but is usually more expensive
and structured.

**Row-oriented storage** keeps complete records together and is good for OLTP
point lookups and writes. **Column-oriented storage** keeps values from one
column together and is good for analytics because queries often read only a few
columns; compression is also more effective.


