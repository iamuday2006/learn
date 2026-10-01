# 11 — Data Quality

Data quality means data is fit for its intended purpose.

## Key dimensions
- Completeness
- Accuracy
- Consistency
- Validity
- Uniqueness
- Timeliness

## Common checks
- NULL checks
- Duplicate checks
- Referential integrity
- Range checks
- Schema validation
- Row count checks
- Freshness checks

## What happens when bad data enters production?
Broken dashboards, wrong alerts, wrong model features, and poor business decisions.

## Example
An order pipeline loads duplicate rows and missing order IDs, producing wrong revenue metrics.

## Must Know
- Completeness, accuracy, consistency, validity
- Duplicate and null checks
- Freshness checks

## Good to Know
- Referential integrity
- Schema validation

## Advanced
- Data contracts
- Automated anomaly detection

## Interview Questions
1. What does data quality mean in production systems?
2. Why is freshness important if the data is complete?
3. How do duplicate checks prevent bad analytics?
4. What happens when referential integrity breaks?
5. What would you do if a source schema suddenly changes?
