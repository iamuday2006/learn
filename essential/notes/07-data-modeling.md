## 7. Data Modeling

**Data modeling** defines entities, attributes, relationships, keys, and
constraints so data is reliable and useful.

- **Conceptual model:** major business entities and relationships.
- **Logical model:** attributes, keys, relationships, and normalization,
  independent of a specific database.
- **Physical model:** actual tables, data types, partitions, indexes, and
  storage choices.

### OLTP modeling

Use normalized tables to reduce update anomalies:

- **1NF:** atomic values and no repeating groups.
- **2NF:** 1NF plus every non-key attribute depends on the whole key.
- **3NF:** 2NF plus non-key attributes do not depend on other non-key
  attributes.

An e-commerce OLTP design can contain `customers`, `orders`, `order_items`,
`products`, and `payments`. `orders.customer_id` references
`customers.customer_id`; `order_items.order_id` and `product_id` reference
their parent tables. Constraints protect valid relationships.

### Dimensional modeling

Dimensional models are designed for analytics:

- **Fact table:** measurable business events, foreign keys, and measures.
- **Dimension table:** descriptive context such as customer, product, date,
  store, or employee.
- **Measure:** numeric value such as quantity, revenue, or discount.
- **Grain:** exactly what one fact row represents.

Always declare grain before choosing columns. For example:

- `fact_orders`: one row per order.
- `fact_order_items`: one row per product line within an order.

Mixing these grains can double-count revenue. Measures may be:

- **Additive:** can sum across all dimensions, e.g. order amount.
- **Semi-additive:** can sum across some dimensions, not time, e.g. account
  balance.
- **Non-additive:** ratios or percentages that must be recalculated.

### Star and snowflake schemas

```text
dim_customer
      |
dim_product - fact_sales - dim_date
      |
  dim_store
```

A **star schema** has a central fact and denormalized dimensions. It is simple
and fast for BI, at the cost of some redundancy. A **snowflake schema**
normalizes dimensions into additional tables, reducing duplication but adding
joins and complexity. Analytics commonly favors stars for usability and speed.


