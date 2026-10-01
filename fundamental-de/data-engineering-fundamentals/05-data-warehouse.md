# 05 — Data Warehouse

A data warehouse is a centralized analytics store designed for SQL-based reporting and BI.

## What is it?
It stores structured, cleaned data for analysis rather than raw transactional data.

## Why organizations use warehouses
- standardize metrics
- improve query performance
- support BI dashboards and reporting

## OLAP
Data warehouses are designed for OLAP: analytical queries over large data sets.

## Fact tables
Fact tables contain business events and measurable metrics.

### Example
orders, sales, product views, payments

## Dimension tables
Dimensions describe context around the facts.

### Example
customer, date, product, store

## Star schema
A central fact table linked to multiple dimensions.

## Snowflake schema
Normalized dimensions with more joins.

## Slowly Changing Dimensions (SCD)
Handle changes in dimension data over time.

### Example
Customer address changes from one year to the next.

## Surrogate keys
Artificial keys used to identify dimensions independent of natural business keys.

## Grain
The level of detail represented by a single row in a fact table.

## Data marts
Smaller, domain-specific slices of warehouse data.

## Business example
Customer -> Orders -> Products -> Revenue

- Customer dimension: customer_id, region, segment
- Orders fact: order_id, customer_id, product_id, revenue
- Product dimension: product_id, category, price

## Must Know
- Fact vs dimension
- Star schema and warehouse purpose
- Grain and SCD
- OLAP fundamentals

## Good to Know
- Snowflake schema
- Surrogate keys
- Data marts

## Advanced
- Conformed dimensions
- Semantic layers

## Interview Questions
1. What is the purpose of a data warehouse?
2. What is a fact table and how is it different from a dimension table?
3. Why is star schema easier to query than highly normalized schemas?
4. What is grain and why does it matter?
5. How do you handle customer changes in an SCD table?
