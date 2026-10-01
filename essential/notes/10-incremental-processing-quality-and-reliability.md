## 10. Incremental Processing, Quality, and Reliability

A **watermark** records the latest safely processed source position, commonly
an `updated_at` timestamp, monotonically increasing ID, or CDC offset. A robust
incremental pipeline should:

1. Read a bounded range, often with a small overlap for late arrivals.
2. Deduplicate using a business key and latest update timestamp.
3. Upsert or merge into the target.
4. Advance the watermark only after a successful commit.

Late-arriving data requires an overlap window, event-time processing, or a
reconciliation job. **Idempotency** means running the same input more than once
produces the same final result. Use deterministic keys, batch IDs, MERGE, and
atomic checkpoints to prevent duplicate loads.

Essential quality checks:

- required columns are not null;
- keys are unique where required;
- foreign keys exist in dimensions;
- data types and schemas are valid;
- numeric values are within range, such as `amount >= 0`;
- row counts are within expected bounds;
- data is fresh and arrives before its SLA;
- duplicates and unexpected deletes are detected.

On failure, quarantine bad records, alert the owner, preserve the failed batch,
and stop or isolate downstream publication. Never silently convert invalid data
into success.


