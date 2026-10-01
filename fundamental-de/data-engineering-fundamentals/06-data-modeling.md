# 06 — Data Modeling

Data modeling is the process of defining how data should be represented and related.

## Conceptual model
High-level business view with entities and relationships.

## Logical model
More structured representation of entities and attributes.

## Physical model
Actual database or warehouse design: tables, keys, partitions, indexes.

## Normalization
Reduce redundancy by splitting data into related tables.

### Benefits
- data consistency
- less duplication

### Cost
- more joins

## Denormalization
Combine data to reduce joins and improve analytical performance.

## Primary key
Unique identifier for a row.

## Foreign key
Reference to a key in another table.

## Relationships
- one-to-one
- one-to-many
- many-to-many

## Cardinality
How many records are related between two tables.

## Fact vs dimension
- Facts are measurable events
- Dimensions provide descriptive context

## Grain
The exact level of detail for one row in a fact table.

## Star schema
A fact table with related dimension tables.

## Slowly Changing Dimensions
Track historical changes in dimension data.

## Good vs bad model
### Bad
One giant table with repeated customer and product details.

### Good
Separate customer, product, order, and date tables with clear keys and relationships.

## Must Know
- Primary and foreign keys
- Normalization vs denormalization
- Fact vs dimension
- Star schema and grain

## Good to Know
- Conceptual/logical/physical modeling
- Relationship types
- SCD patterns

## Advanced
- Data vault
- Hybrid enterprise models

## Interview Questions
1. What is the difference between conceptual and physical modeling?
2. When would you denormalize data intentionally?
3. Why is grain important in a fact table?
4. How does a foreign key help maintain integrity?
5. What is a bad modeling pattern and how would you fix it?
