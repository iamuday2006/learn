# 02 — Data Sources

Data sources are where the data originates. The source tells you about format, volume, update frequency, and extraction strategy.

## Relational databases
### What it is
Systems like PostgreSQL, MySQL, and SQL Server storing structured data in tables.

### Typical format
Rows and columns with a schema.

### Extraction
- SQL queries
- CDC tools
- database replication

### Problems
- schema changes
- high write load
- locking or contention

### Example
A retail app stores customers and orders in PostgreSQL; reporting pulls from those tables.

## APIs
### What it is
HTTP-based interfaces that expose data.

### Format
Usually JSON.

### Extraction
- polling endpoints
- pagination
- webhooks
- scheduled jobs

### Problems
- rate limits
- auth tokens
- API outages
- schema drift

### Example
A SaaS app exposes product and billing data through an API.

## Files
### What it is
CSV, JSON, XML, and text files stored locally or in object storage.

### Extraction
- file transfer
- scheduled reads
- object storage scanning

### Problems
- malformed rows
- large file size
- encoding issues

### Example
A partner sends daily CSV files of orders.

## CSV
Simple, common, easy to export/import. Weak for nested data and schema evolution.

## JSON
Flexible and widely used for APIs and event payloads. Nested and harder to query directly.

## Logs
- machine-generated records
- often plain text or JSON
- high volume and noisy

### Example
Web servers produce access logs and error logs.

## Application events
Discrete actions such as clicks, purchases, or user sessions.

### Why important
Events are essential for analytics, monitoring, and real-time systems.

## SaaS applications
CRMs and support platforms often expose data through APIs and connectors.

## IoT / event sources
Sensors and devices generate continuous data streams, often with timestamps and device IDs.

## Message brokers
Systems like Kafka, RabbitMQ, and Pub/Sub collect and distribute events.

### Why important
They decouple producers and consumers and support streaming architectures.

## Must Know
- Relational databases, APIs, files, logs, events
- Message brokers are important for streaming
- Source type affects ingestion method

## Good to Know
- SaaS and IoT patterns
- Event-driven capture

## Advanced
- Connector architecture
- Schema drift management

## Interview Questions
1. What is the difference between a database source and an API source?
2. Why is JSON harder to query than a normalized table?
3. When would you choose Kafka over polling an API?
4. What are common problems with SaaS extraction?
5. How do logs differ from application events?
