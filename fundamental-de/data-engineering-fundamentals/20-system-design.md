# 20 — Data Engineering System Design

System design is about choosing architectures that fit requirements, scale, cost, and reliability.

## Thought process
1. Understand requirements
2. Identify sources
3. Estimate data volume
4. Choose batch vs streaming
5. Design ingestion
6. Design storage
7. Design processing
8. Design data model
9. Add quality checks
10. Add orchestration
11. Add monitoring
12. Handle failures
13. Consider security
14. Consider cost
15. Explain trade-offs

## Example: 100 million transactions each day
- Source: payment systems, logs, APIs
- Ingestion: batch and streaming hybrid
- Storage: raw object storage + curated warehouse
- Processing: Spark or warehouse transforms
- Quality: row counts, schema validation, duplicate detection
- Reliability: idempotent jobs, retries, backfills, monitoring

## Best design is not the fanciest one
The best design is the one that meets the requirement with acceptable reliability, complexity, and cost.

## Must Know
- Requirements-to-architecture thinking
- Batch vs streaming trade-offs
- Storage and modeling decisions
- Monitoring, security, and cost

## Good to Know
- Estimating throughput and storage needs
- Designing for failure recovery

## Advanced
- Multi-region design
- Real-time + batch coexistence

## Interview Questions
1. How would you design a pipeline for 100 million daily transactions?
2. What requirements should drive a batch-vs-streaming decision?
3. How do you estimate storage and compute needs?
4. What checks do you perform when a pipeline is slow?
5. How do you explain trade-offs to stakeholders?
