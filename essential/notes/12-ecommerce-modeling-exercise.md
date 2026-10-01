## 12. E-Commerce Modeling Exercise

Suggested Gold model:

- `dim_customer`: customer attributes and Type 2 history.
- `dim_product`: product category, brand, and price attributes.
- `dim_store`: store and location details.
- `dim_date`: calendar attributes such as month, quarter, and fiscal year.
- `fact_order_item`: one row per product in an order; quantity, unit price,
  discount, and net amount.
- `fact_payment`: one row per payment event if payment analysis is needed.

Define keys, grain, and relationships before writing transformations. Keep
source identifiers for traceability, but use surrogate dimension keys for
warehouse joins and historical versions.


