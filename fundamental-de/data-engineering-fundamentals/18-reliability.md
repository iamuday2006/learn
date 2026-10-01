# 18 — Reliability & Production Engineering

A data platform is reliable when it can keep processing and produce trustworthy results even when systems fail.

## Key concepts
- Fault tolerance
- High availability
- Scalability
- Reliability
- Idempotency
- Retry
- Dead-letter queues
- Checkpointing
- Recovery
- Failure handling
- Observability
- Monitoring
- Alerting

## Data engineer perspective
Pipelines must not only run; they must also recover predictably, detect issues early, and protect data correctness.

## Must Know
- Idempotency and retries
- Recovery and checkpointing
- Monitoring and alerting

## Good to Know
- Fault tolerance vs high availability
- Observability practices

## Advanced
- Self-healing pipelines
- Chaos testing

## Interview Questions
1. What is the difference between reliability and availability?
2. Why is idempotency important in distributed pipelines?
3. What should happen when a downstream system fails?
4. Why are checkpointing and dead-letter queues useful?
5. How do you know a pipeline is healthy in production?
