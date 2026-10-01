# 10 — Data Orchestration

Orchestration coordinates workflows so tasks run in the right order with retries, monitoring, and dependencies.

## What is orchestration?
It is the scheduling and coordination layer for data jobs.

## Why it is needed
Modern pipelines include multiple stages and dependencies. Without orchestration, failures and retries become difficult to manage.

## DAG
A directed acyclic graph shows dependency flow between tasks.

## Task dependencies
Tasks wait for upstream tasks to finish successfully.

## Scheduling
Jobs can run by time, trigger event, or external conditions.

## Retries
Automatic retry of failed tasks reduces operational fragility.

## Sensors
Monitor conditions such as a new file arriving or a table being refreshed.

## Backfills
Historical re-runs of data jobs.

## Monitoring
Track job status, retries, durations, and failures.

## Tools conceptually
- Airflow: workflow orchestration
- Dagster: asset-based orchestration
- Prefect: modern workflow orchestration

## Must Know
- DAGs and dependencies
- Scheduling and retries
- Backfills and monitoring

## Good to Know
- Sensors and triggers
- Airflow/Dagster/Prefect philosophy

## Advanced
- Dynamic orchestration
- SLA-aware workflows

## Interview Questions
1. Why do data pipelines need orchestration?
2. What is a DAG in workflow terms?
3. How do dependencies reduce risk in pipelines?
4. What happens when a task fails in a DAG?
5. Why are retries and monitoring essential for production pipelines?
