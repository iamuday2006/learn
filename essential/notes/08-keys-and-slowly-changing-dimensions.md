## 8. Keys and Slowly Changing Dimensions

- **Primary key:** uniquely identifies a row.
- **Foreign key:** references a key in another table.
- **Natural/business key:** meaningful source identifier, such as an email or
  source customer number.
- **Surrogate key:** warehouse-generated identifier, such as `customer_sk =
  1001`.
- **Composite key:** key made from multiple columns.

Surrogate keys are stable when business keys change and allow multiple
historical versions of one business entity.

A **Slowly Changing Dimension (SCD)** tracks changes to descriptive attributes.

- **Type 1:** overwrite the old value. Simple and useful when history is not
  required, but previous values are lost.
- **Type 2:** create a new version and retain history. Typical columns are
  `customer_sk`, `customer_id`, `effective_start_date`,
  `effective_end_date`, and `current_flag`.
- **Type 3:** keep limited history in extra columns, such as `current_city` and
  `previous_city`; it is useful only when a small amount of history is needed.

Type 2 example:

```text
customer_sk | customer_id | city    | start_date | end_date   | current
------------+-------------+---------+------------+------------+--------
101         | C7          | Kolkata | 2025-01-01 | 2026-04-01 | false
102         | C7          | Delhi   | 2026-04-01 | NULL       | true
```

When the city changes, expire the current row and insert a new surrogate-key
row. Facts join to the correct historical surrogate key so past reports use
the address that was valid at the event time.


