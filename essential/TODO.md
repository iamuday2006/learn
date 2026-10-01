# Data Engineering Storage & Modeling — Internship Notes

> **Goal:** Build internship-ready understanding of Data Warehouse, Data Lake, Lakehouse, Delta Lake, and Data Modeling.
>
> **Primary outcome:** Be able to explain *what it is, why it exists, when to use it, how it works, and how it appears in a real Data Engineering project.*

---

# 0. Study Rules

* [ ] Learn the concept before memorizing terminology
* [ ] For every topic answer:

  * [ ] What is it?
  * [ ] Why do we need it?
  * [ ] What problem does it solve?
  * [ ] Where is it used?
  * [ ] What are its limitations?
  * [ ] Give one real-world example
* [ ] Add diagrams wherever architecture is involved
* [ ] Add SQL examples for modeling concepts
* [ ] Add interview questions after every major chapter
* [ ] Add "How I would explain this in an interview" section
* [ ] Connect every concept to a real Data Engineering pipeline

---

# PART 1 — DATA STORAGE FUNDAMENTALS

## 1.1 What is Data Storage?

* [ ] Define data storage
* [ ] Why organizations need persistent storage
* [ ] Structured vs semi-structured vs unstructured data
* [ ] Examples of each
* [ ] File-based storage vs database storage
* [ ] Row-oriented vs column-oriented storage

### Examples to understand

```text
CSV
JSON
Parquet
PostgreSQL
MySQL
S3
Snowflake
Databricks
```

### Interview Questions

* [ ] What are the different types of data?
* [ ] Database vs file storage?
* [ ] Row-oriented vs column-oriented storage?
* [ ] Why is Parquet popular in Data Engineering?

---

# PART 2 — OLTP DATABASES

## 2.1 OLTP Fundamentals

* [ ] What is OLTP?
* [ ] Purpose of OLTP systems
* [ ] Characteristics of OLTP
* [ ] ACID properties
* [ ] Transactions
* [ ] Concurrent users
* [ ] Insert/update/delete workloads

### Examples

```text
PostgreSQL
MySQL
Oracle
SQL Server
```

## 2.2 OLTP Data Modeling

* [ ] Tables
* [ ] Primary keys
* [ ] Foreign keys
* [ ] Constraints
* [ ] Relationships
* [ ] Normalization
* [ ] 1NF
* [ ] 2NF
* [ ] 3NF
* [ ] Denormalization

## 2.3 Real Example

Design:

```text
customers
orders
order_items
products
payments
```

Explain:

* [ ] Relationships
* [ ] Primary keys
* [ ] Foreign keys
* [ ] Why the model is normalized

### Interview Questions

* [ ] OLTP vs OLAP?
* [ ] Why normalize OLTP databases?
* [ ] Why aren't OLTP databases usually used directly for analytics?
* [ ] What is a transaction?
* [ ] Explain ACID.

---

# PART 3 — OLAP

## 3.1 OLAP Fundamentals

* [ ] What is OLAP?
* [ ] Why OLAP exists
* [ ] Analytical workloads
* [ ] Aggregations
* [ ] Historical data
* [ ] Read-heavy workloads
* [ ] Large-scale analytical queries

## 3.2 OLTP vs OLAP

Create a comparison table:

```text
                 OLTP              OLAP
------------------------------------------------
Purpose
Workload
Data
Queries
Users
Transactions
Schema
Optimization
Examples
```

### Interview Questions

* [ ] OLTP vs OLAP?
* [ ] Why use a separate analytical system?
* [ ] Why are OLAP systems optimized for aggregation?

---

# PART 4 — DATA WAREHOUSE

## 4.1 Data Warehouse Fundamentals

* [ ] What is a Data Warehouse?
* [ ] Why organizations use Data Warehouses
* [ ] Historical data
* [ ] Analytical workloads
* [ ] Structured data
* [ ] Centralized analytical storage
* [ ] Reporting and BI

### Examples

* [ ] Snowflake
* [ ] Amazon Redshift
* [ ] Google BigQuery
* [ ] Azure Synapse

## 4.2 Data Warehouse Architecture

Understand:

```text
Operational Systems
       |
       v
    Ingestion
       |
       v
   Staging/Raw
       |
       v
 Data Warehouse
       |
       v
 BI / Analytics
```

Explain every layer.

## 4.3 Warehouse Characteristics

* [ ] Subject-oriented
* [ ] Integrated
* [ ] Time-variant
* [ ] Non-volatile
* [ ] Historical data
* [ ] Analytical optimization

## 4.4 Warehouse Loading

* [ ] Full load
* [ ] Incremental load
* [ ] Batch loading
* [ ] CDC concept
* [ ] Upsert
* [ ] MERGE
* [ ] Deduplication

### Interview Questions

* [ ] What is a Data Warehouse?
* [ ] Why not run analytics directly on PostgreSQL?
* [ ] Data Warehouse vs Database?
* [ ] What is a staging layer?
* [ ] Full load vs incremental load?
* [ ] What is CDC?

---

# PART 5 — DATA LAKE

## 5.1 Data Lake Fundamentals

* [ ] What is a Data Lake?
* [ ] Why Data Lakes were introduced
* [ ] Store raw data
* [ ] Structured data
* [ ] Semi-structured data
* [ ] Unstructured data
* [ ] Schema-on-read
* [ ] Low-cost object storage

### Examples

```text
Amazon S3
Azure Data Lake Storage
Google Cloud Storage
```

## 5.2 Data Lake Architecture

Understand:

```text
Applications
     |
     v
   Ingestion
     |
     v
+----------------+
|   Data Lake    |
|                |
| CSV            |
| JSON           |
| Parquet        |
| Logs           |
| Images         |
+----------------+
     |
     v
Processing
     |
     v
Analytics / ML
```

## 5.3 Data Lake Concepts

* [ ] Object storage
* [ ] Bucket
* [ ] Object
* [ ] Prefix
* [ ] Partitioning
* [ ] File formats
* [ ] Parquet
* [ ] JSON
* [ ] CSV
* [ ] Schema-on-read

### Interview Questions

* [ ] What is a Data Lake?
* [ ] Data Lake vs Data Warehouse?
* [ ] Why store raw data?
* [ ] What does schema-on-read mean?
* [ ] Why is Parquet preferred over CSV for analytical workloads?
* [ ] What problems can a traditional Data Lake have?

---

# PART 6 — DATA LAKE VS DATA WAREHOUSE

Create a detailed comparison.

```text
                 DATA LAKE       DATA WAREHOUSE
------------------------------------------------
Storage
Data types
Schema
Cost
Querying
Performance
Governance
Users
Use cases
Data quality
```

Understand:

* [ ] Schema-on-read vs schema-on-write
* [ ] Raw vs curated data
* [ ] Flexibility vs governance
* [ ] Object storage vs warehouse storage
* [ ] Analytics use cases

### Critical Question

* [ ] Why can't we simply use a Data Lake for everything?
* [ ] Why can't we simply use a Data Warehouse for everything?

---

# PART 7 — DATA LAKEHOUSE

## 7.1 Lakehouse Fundamentals

* [ ] What is a Data Lakehouse?
* [ ] Why Lakehouse architecture appeared
* [ ] Data Lake + Data Warehouse characteristics
* [ ] Open storage
* [ ] ACID transactions
* [ ] Schema enforcement
* [ ] Data governance
* [ ] Analytical workloads

## 7.2 Lakehouse Architecture

Understand:

```text
                 Applications
                      |
                      v
                 Data Sources
                      |
                      v
                 Object Storage
                      |
                      v
              +---------------+
              |   Lakehouse   |
              |               |
              | Bronze        |
              | Silver        |
              | Gold          |
              +---------------+
                      |
             +--------+--------+
             |                 |
           BI                ML
```

## 7.3 Examples

* [ ] Databricks Lakehouse
* [ ] Delta Lake
* [ ] Apache Iceberg
* [ ] Apache Hudi

### Interview Questions

* [ ] What is a Lakehouse?
* [ ] Data Lake vs Lakehouse?
* [ ] Why did Lakehouse architecture become popular?
* [ ] How does a Lakehouse provide warehouse-like capabilities on object storage?

---

# PART 8 — DELTA LAKE

## 8.1 Delta Lake Fundamentals

* [ ] What is Delta Lake?
* [ ] Why Delta Lake exists
* [ ] Delta table
* [ ] Parquet + transaction log
* [ ] `_delta_log`
* [ ] ACID transactions
* [ ] Schema enforcement
* [ ] Schema evolution
* [ ] Time travel

## 8.2 Delta Lake Architecture

Understand:

```text
Object Storage
     |
     +----------------------+
     |                      |
 Parquet files          _delta_log
     |                      |
     +----------+-----------+
                |
           Delta Table
```

Explain what each part does.

## 8.3 Delta Transactions

* [ ] Transaction log
* [ ] Commit
* [ ] Atomicity
* [ ] Concurrent writes
* [ ] Versioning
* [ ] Snapshot

## 8.4 Delta Operations

Understand:

* [ ] INSERT
* [ ] UPDATE
* [ ] DELETE
* [ ] MERGE
* [ ] UPSERT
* [ ] OPTIMIZE
* [ ] VACUUM
* [ ] Time Travel

## 8.5 Schema Management

* [ ] Schema enforcement
* [ ] Schema evolution
* [ ] Why schemas matter
* [ ] What happens when incoming data changes

## 8.6 Delta Performance

* [ ] Partitioning
* [ ] File sizes
* [ ] Small-file problem
* [ ] OPTIMIZE
* [ ] Data skipping
* [ ] Compaction
* [ ] Z-Ordering concept

### Interview Questions

* [ ] What is Delta Lake?
* [ ] Delta Lake vs Parquet?
* [ ] How does Delta provide ACID transactions?
* [ ] What is `_delta_log`?
* [ ] What is time travel?
* [ ] What is schema enforcement?
* [ ] Schema enforcement vs schema evolution?
* [ ] Why does the small-file problem happen?
* [ ] What does OPTIMIZE do?
* [ ] What does VACUUM do?
* [ ] What is MERGE used for?

---

# PART 9 — MEDALLION ARCHITECTURE

## 9.1 Bronze Layer

* [ ] Purpose
* [ ] Raw data
* [ ] Minimal transformation
* [ ] Auditability
* [ ] Reprocessing

## 9.2 Silver Layer

* [ ] Cleaning
* [ ] Validation
* [ ] Deduplication
* [ ] Standardization
* [ ] Business transformations
* [ ] Joining datasets

## 9.3 Gold Layer

* [ ] Business-ready data
* [ ] Aggregations
* [ ] KPIs
* [ ] BI consumption
* [ ] Data marts

### Architecture

```text
Raw Sources
    |
    v
+---------+
| Bronze  |
+---------+
    |
    v
+---------+
| Silver  |
+---------+
    |
    v
+---------+
|  Gold   |
+---------+
    |
    v
BI / ML / Applications
```

### Interview Questions

* [ ] What is Medallion Architecture?
* [ ] Why keep a Bronze layer?
* [ ] What transformations belong in Silver?
* [ ] Why shouldn't BI tools directly query Bronze?
* [ ] What belongs in Gold?

---

# PART 10 — DATA MODELING FUNDAMENTALS

## 10.1 What is Data Modeling?

* [ ] Definition
* [ ] Purpose
* [ ] Why data engineers need data modeling
* [ ] Entities
* [ ] Attributes
* [ ] Relationships
* [ ] Keys
* [ ] Constraints

## 10.2 Types of Data Models

* [ ] Conceptual model
* [ ] Logical model
* [ ] Physical model

Understand the difference.

---

# PART 11 — DIMENSIONAL MODELING

## 11.1 Dimensional Modeling

* [ ] What is dimensional modeling?
* [ ] Why it is used in analytics
* [ ] Fact tables
* [ ] Dimension tables
* [ ] Measures
* [ ] Attributes
* [ ] Grain

## 11.2 Fact Tables

Understand:

* [ ] What is a fact?
* [ ] Measures
* [ ] Foreign keys
* [ ] Transaction facts
* [ ] Periodic snapshot facts
* [ ] Accumulating snapshot facts

## 11.3 Dimension Tables

Understand:

* [ ] Customer dimension
* [ ] Product dimension
* [ ] Date dimension
* [ ] Location dimension
* [ ] Employee dimension

## 11.4 Grain

This is **mandatory**.

* [ ] What is grain?
* [ ] Why grain must be defined before designing a fact table
* [ ] Examples of different grains
* [ ] Problems caused by incorrect grain

Example:

```text
fact_orders
Grain = one row per order
```

vs

```text
fact_order_items
Grain = one row per product within an order
```

### Interview Questions

* [ ] What is a fact table?
* [ ] What is a dimension table?
* [ ] What is grain?
* [ ] Why is defining grain important?
* [ ] Fact vs dimension?
* [ ] Can a fact table contain text?
* [ ] What are additive, semi-additive and non-additive measures?

---

# PART 12 — STAR SCHEMA

## 12.1 Star Schema

Understand:

```text
              dim_customer
                   |
                   |
dim_product -- fact_sales -- dim_date
                   |
                   |
              dim_store
```

* [ ] Fact table in center
* [ ] Dimension tables around fact
* [ ] Relationships
* [ ] Advantages
* [ ] Disadvantages

## 12.2 Snowflake Schema

* [ ] What is Snowflake Schema?
* [ ] Why dimensions can be normalized
* [ ] Star vs Snowflake Schema

### Interview Questions

* [ ] What is Star Schema?
* [ ] Why is it called Star Schema?
* [ ] Star Schema vs Snowflake Schema?
* [ ] Why are dimensions often denormalized?

---

# PART 13 — KEYS

Understand deeply:

* [ ] Primary key
* [ ] Foreign key
* [ ] Natural key
* [ ] Surrogate key
* [ ] Composite key
* [ ] Business key

## Surrogate Keys

Understand:

```text
customer_id = 1001
```

instead of relying only on:

```text
email = user@example.com
```

### Interview Questions

* [ ] Natural key vs surrogate key?
* [ ] Why use surrogate keys in dimensional modeling?
* [ ] What happens if a business key changes?

---

# PART 14 — SLOWLY CHANGING DIMENSIONS

## 14.1 SCD Fundamentals

* [ ] What is an SCD?
* [ ] Why dimensions change
* [ ] Historical tracking

## 14.2 SCD Type 1

```text
Overwrite old value
```

Understand:

* [ ] Use case
* [ ] Advantages
* [ ] Limitations

## 14.3 SCD Type 2

```text
Keep historical versions
```

Understand:

* [ ] Surrogate key
* [ ] effective_start_date
* [ ] effective_end_date
* [ ] current_flag
* [ ] Versioning

Example:

```text
customer_id | city    | start_date | end_date   | current
------------------------------------------------------------
101         | Kolkata | 2025-01-01 | 2026-04-01 | false
102         | Delhi   | 2026-04-01 | NULL       | true
```

## 14.4 SCD Type 3

* [ ] Understand concept
* [ ] Know when it can be used
* [ ] Compare with Type 1 and Type 2

### Interview Questions

* [ ] What is SCD?
* [ ] SCD Type 1 vs Type 2?
* [ ] How would you implement SCD Type 2?
* [ ] Why do we need surrogate keys for SCD Type 2?

---

# PART 15 — DATA WAREHOUSE ARCHITECTURE

Build notes for:

```text
                  Sources
                     |
        +------------+------------+
        |            |            |
      APIs         OLTP         Files
        |            |            |
        +------------+------------+
                     |
                     v
                 Ingestion
                     |
                     v
                  Staging
                     |
                     v
             Data Warehouse
                     |
          +----------+----------+
          |                     |
      Data Marts             BI
```

Explain:

* [ ] Source systems
* [ ] Ingestion
* [ ] Staging
* [ ] Transformation
* [ ] Warehouse
* [ ] Data marts
* [ ] BI

---

# PART 16 — MODERN DATA ENGINEERING ARCHITECTURE

Build one complete architecture:

```text
                DATA SOURCES
                     |
        +------------+------------+
        |            |            |
       API          DB           Kafka
        |            |            |
        +------------+------------+
                     |
                     v
                 Ingestion
                     |
                     v
              Object Storage
                  (S3)
                     |
                     v
              +-------------+
              |   Bronze    |
              |    Delta    |
              +-------------+
                     |
                     v
              +-------------+
              |   Silver    |
              |    Delta    |
              +-------------+
                     |
                     v
              +-------------+
              |    Gold     |
              |    Delta    |
              +-------------+
                     |
            +--------+--------+
            |                 |
          BI/SQL             ML
```

Document:

* [ ] Why each layer exists
* [ ] Data format at each stage
* [ ] Transformation responsibilities
* [ ] Data quality responsibilities
* [ ] Storage technology
* [ ] Processing technology
* [ ] Consumption layer

---

# PART 17 — FILE FORMATS

## 17.1 CSV

* [ ] Structure
* [ ] Advantages
* [ ] Limitations
* [ ] Why it is common for ingestion

## 17.2 JSON

* [ ] Structure
* [ ] Nested data
* [ ] API use cases

## 17.3 Parquet

* [ ] Columnar format
* [ ] Compression
* [ ] Schema
* [ ] Predicate pushdown
* [ ] Analytical workloads

## 17.4 Avro

* [ ] Basic concept
* [ ] Schema
* [ ] Streaming use cases

### Interview Questions

* [ ] CSV vs Parquet?
* [ ] Why is Parquet faster for analytics?
* [ ] Why is Parquet smaller than CSV?
* [ ] Parquet vs Avro?

---

# PART 18 — PARTITIONING

## 18.1 Partitioning Fundamentals

* [ ] What is partitioning?
* [ ] Why partition data?
* [ ] Partition pruning
* [ ] Partition column
* [ ] Good partition columns
* [ ] Bad partition columns

Example:

```text
sales/
  year=2026/
    month=01/
    month=02/
    month=03/
```

## 18.2 Partition Problems

* [ ] Too many partitions
* [ ] Too few partitions
* [ ] Small files
* [ ] High-cardinality partition columns

### Interview Questions

* [ ] What is partitioning?
* [ ] Why partition by date?
* [ ] Why shouldn't you partition by customer_id?
* [ ] What is partition pruning?
* [ ] What is the small-file problem?

---

# PART 19 — DATA QUALITY

## 19.1 Essential Checks

* [ ] Null checks
* [ ] Duplicate checks
* [ ] Referential integrity
* [ ] Schema validation
* [ ] Data type validation
* [ ] Range validation
* [ ] Row count validation
* [ ] Freshness checks

## 19.2 Example

For:

```text
fact_orders
```

check:

```text
order_id IS NOT NULL
customer_id IS NOT NULL
amount >= 0
order_date IS NOT NULL
order_id is unique
customer_id exists in dim_customer
```

### Interview Questions

* [ ] How do you ensure data quality?
* [ ] What happens when a data-quality check fails?
* [ ] How would you detect duplicate records?
* [ ] How would you validate an ingestion pipeline?

---

# PART 20 — INCREMENTAL DATA PROCESSING

Understand:

* [ ] Full refresh
* [ ] Incremental processing
* [ ] Watermark
* [ ] Timestamp-based loading
* [ ] ID-based loading
* [ ] CDC
* [ ] Upsert
* [ ] MERGE

Example:

```text
Yesterday:
1,000,000 rows

Today:
+10,000 new rows
+500 updates
```

Explain how to process only the required data.

### Interview Questions

* [ ] Full load vs incremental load?
* [ ] Why is incremental processing important?
* [ ] What is a watermark?
* [ ] How would you handle late-arriving data?

---

# PART 21 — DATA MARTS

* [ ] What is a Data Mart?
* [ ] Department-specific analytics
* [ ] Sales Data Mart
* [ ] Finance Data Mart
* [ ] Marketing Data Mart
* [ ] Relationship between warehouse and marts

Architecture:

```text
              Data Warehouse
                     |
        +------------+------------+
        |            |            |
      Sales        Finance     Marketing
      Mart          Mart         Mart
```

---

# PART 22 — DATA LAKE vs LAKEHOUSE vs WAREHOUSE

Create a final comparison:

```text
                   DATA LAKE
                      |
                      |
                DATA LAKEHOUSE
                      |
                      |
                DATA WAREHOUSE
```

Compare:

* [ ] Storage
* [ ] Data types
* [ ] Schema
* [ ] Transactions
* [ ] Governance
* [ ] Performance
* [ ] Cost
* [ ] BI
* [ ] ML
* [ ] Data engineering use cases

Be able to explain:

> "When would I choose a Data Lake?"

> "When would I choose a Warehouse?"

> "When would I choose a Lakehouse?"

---

# PART 23 — TECHNOLOGY MAPPING

Create a table:

```text
Concept             Technologies
------------------------------------------------
OLTP                PostgreSQL / MySQL
Object Storage      S3 / GCS / ADLS
Data Warehouse      Snowflake / Redshift / BigQuery
Lakehouse           Databricks
Table Format        Delta / Iceberg / Hudi
Processing           Spark
Orchestration        Airflow
Transformation       dbt
Streaming            Kafka
BI                   Power BI / Tableau
```

For every technology:

* [ ] What problem does it solve?
* [ ] Where does it fit in architecture?
* [ ] What data does it store/process?
* [ ] When would I use it?

---

# PART 24 — REAL PROJECT MODELING EXERCISE

## Build an E-Commerce Model

Design:

```text
Customers
Products
Orders
Order Items
Payments
Stores
Dates
```

### Step 1

* [ ] Identify entities

### Step 2

* [ ] Define relationships

### Step 3

* [ ] Define primary keys

### Step 4

* [ ] Define foreign keys

### Step 5

* [ ] Define fact tables

### Step 6

* [ ] Define dimension tables

### Step 7

* [ ] Define grain

### Step 8

* [ ] Choose surrogate keys

### Step 9

* [ ] Handle customer history using SCD Type 2

### Step 10

* [ ] Design Gold layer

---

# PART 25 — INTERVIEW SCENARIOS

Answer these without notes.

## Scenario 1

> Your company has PostgreSQL containing transactional orders. Management wants 5 years of sales analytics.

* [ ] Design the architecture
* [ ] Explain OLTP vs OLAP
* [ ] Decide where data should be stored
* [ ] Explain ingestion
* [ ] Explain transformation
* [ ] Design warehouse tables

---

## Scenario 2

> An API produces JSON every hour.

* [ ] Where would you store raw data?
* [ ] What format would you choose?
* [ ] How would you process it?
* [ ] How would you handle failures?
* [ ] How would you prevent duplicates?

---

## Scenario 3

> Customer address changes every few months, but analysts need historical reporting.

* [ ] Which SCD strategy?
* [ ] Design the dimension
* [ ] Explain effective dates
* [ ] Explain surrogate keys

---

## Scenario 4

> Your Delta table has millions of tiny files.

* [ ] Explain the problem
* [ ] Explain why it happens
* [ ] Explain how you would address it

---

## Scenario 5

> A pipeline loaded the same day's data twice.

* [ ] What caused the problem?
* [ ] How would you detect it?
* [ ] How would you make the pipeline idempotent?

---

## Scenario 6

> A dashboard query takes 10 minutes.

* [ ] What would you investigate?
* [ ] Check data model
* [ ] Check query
* [ ] Check partitioning
* [ ] Check file format
* [ ] Check data volume
* [ ] Check warehouse configuration

---

# PART 26 — MUST-KNOW DEFINITIONS

Create short 2–3 line notes for:

* [ ] OLTP
* [ ] OLAP
* [ ] Data Warehouse
* [ ] Data Lake
* [ ] Lakehouse
* [ ] Delta Lake
* [ ] Data Mart
* [ ] Fact Table
* [ ] Dimension Table
* [ ] Grain
* [ ] Star Schema
* [ ] Snowflake Schema
* [ ] Surrogate Key
* [ ] Natural Key
* [ ] SCD
* [ ] SCD Type 1
* [ ] SCD Type 2
* [ ] Partitioning
* [ ] Partition Pruning
* [ ] Schema-on-Read
* [ ] Schema-on-Write
* [ ] Schema Evolution
* [ ] Schema Enforcement
* [ ] ACID
* [ ] Transaction Log
* [ ] Time Travel
* [ ] Incremental Load
* [ ] Full Load
* [ ] CDC
* [ ] Upsert
* [ ] MERGE
* [ ] Medallion Architecture
* [ ] Bronze
* [ ] Silver
* [ ] Gold
* [ ] Data Quality
* [ ] Idempotency
* [ ] Parquet
* [ ] Columnar Storage

---

# PART 27 — FINAL INTERVIEW CHEAT SHEET

Create a final section answering these in **30–60 seconds each**:

* [ ] What is a Data Warehouse?
* [ ] What is a Data Lake?
* [ ] Data Lake vs Data Warehouse?
* [ ] What is a Lakehouse?
* [ ] What is Delta Lake?
* [ ] Delta Lake vs Parquet?
* [ ] What is a fact table?
* [ ] What is a dimension table?
* [ ] What is grain?
* [ ] Star Schema vs Snowflake Schema?
* [ ] What is SCD Type 2?
* [ ] What is a surrogate key?
* [ ] What is partitioning?
* [ ] Why use Parquet?
* [ ] What is schema evolution?
* [ ] What is schema enforcement?
* [ ] What is Medallion Architecture?
* [ ] Bronze vs Silver vs Gold?
* [ ] Full load vs incremental load?
* [ ] What is CDC?
* [ ] What is idempotency?
* [ ] How would you design a simple data warehouse?
* [ ] How would you design a modern lakehouse?
* [ ] Why can't we simply put everything into one database?
* [ ] How would you handle historical data?
* [ ] How would you handle bad data?
* [ ] How would you optimize a large analytical dataset?

---

# PART 28 — FINAL PROJECT

Build one small end-to-end system demonstrating everything.

## Architecture

```text
                 API / PostgreSQL
                       |
                       v
                  Python ETL
                       |
                       v
                      S3
                       |
                       v
                Databricks / Spark
                       |
                       v
                +-------------+
                |   Bronze    |
                +-------------+
                       |
                       v
                +-------------+
                |   Silver    |
                +-------------+
                       |
                       v
                +-------------+
                |    Gold     |
                +-------------+
                       |
                       v
                 Data Warehouse
                       |
                       v
                    BI
```

Implement:

* [ ] Raw ingestion
* [ ] Bronze table
* [ ] Silver transformation
* [ ] Gold dimensional model
* [ ] Fact table
* [ ] Dimension tables
* [ ] SCD Type 2
* [ ] Incremental loading
* [ ] Data-quality checks
* [ ] Partitioning
* [ ] Parquet/Delta
* [ ] Git repository
* [ ] Architecture diagram
* [ ] README
* [ ] Interview explanation

---

# FINAL CHECKLIST — INTERNSHIP READY

## Fundamentals

* [ ] I can explain OLTP vs OLAP
* [ ] I can explain Data Lake vs Warehouse
* [ ] I can explain Lakehouse
* [ ] I understand Parquet
* [ ] I understand schema-on-read/write

## Data Warehouse

* [ ] I understand fact tables
* [ ] I understand dimension tables
* [ ] I can define grain
* [ ] I understand Star Schema
* [ ] I understand Snowflake Schema
* [ ] I understand SCD Type 1
* [ ] I understand SCD Type 2
* [ ] I understand surrogate keys

## Data Lake / Lakehouse

* [ ] I understand Bronze/Silver/Gold
* [ ] I understand Delta Lake
* [ ] I understand `_delta_log`
* [ ] I understand ACID transactions
* [ ] I understand schema enforcement
* [ ] I understand schema evolution
* [ ] I understand time travel
* [ ] I understand partitioning
* [ ] I understand small-file problems

## Pipeline Design

* [ ] I understand full vs incremental loads
* [ ] I understand CDC concept
* [ ] I understand idempotency
* [ ] I understand data quality
* [ ] I can design a simple pipeline

## Interview

* [ ] I can draw a warehouse architecture
* [ ] I can design a dimensional model
* [ ] I can explain my design decisions
* [ ] I can answer scenario-based questions
* [ ] I can explain every technology used in my project

---

# FINAL GOAL

At the end of these notes, I should be able to look at a requirement such as:

> "We receive transactional data from PostgreSQL and events from Kafka. We need historical analytics, reliable pipelines, and BI dashboards."

and independently explain:

```text
SOURCE
  ↓
INGESTION
  ↓
OBJECT STORAGE
  ↓
BRONZE
  ↓
SILVER
  ↓
GOLD
  ↓
DIMENSIONAL MODEL
  ↓
WAREHOUSE / LAKEHOUSE
  ↓
BI
```

and justify:

* [ ] Why each component exists
* [ ] What data belongs at each layer
* [ ] How data is modeled
* [ ] How history is maintained
* [ ] How incremental processing works
* [ ] How data quality is handled
* [ ] How the system can scale
* [ ] How the design changes for batch vs streaming
