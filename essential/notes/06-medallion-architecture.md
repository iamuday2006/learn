## 6. Medallion Architecture

```text
Sources -> Bronze -> Silver -> Gold -> BI / ML / Applications
```

- **Bronze:** raw or minimally changed data, with ingestion metadata. It
  preserves auditability and enables reprocessing when downstream logic changes.
- **Silver:** typed, cleaned, validated, deduplicated, standardized data;
  joins and reusable business transformations belong here.
- **Gold:** business-ready facts, dimensions, aggregates, KPIs, and data marts.
  It is optimized for consumption.

BI should not normally query Bronze because it contains duplicates, malformed
records, source-specific fields, and unstable semantics.


