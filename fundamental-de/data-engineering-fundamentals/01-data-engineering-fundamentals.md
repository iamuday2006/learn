# 01 — Data Engineering Fundamentals

## What is Data Engineering?
Data engineering is the practice of building and maintaining systems that move, store, process, and serve data reliably for analytics, machine learning, and operational use cases.

## Role of a Data Engineer
A data engineer:
- collects data from different sources
- moves data to storage
- transforms it into usable forms
- builds pipelines and jobs
- ensures quality and monitoring
- supports analytics and ML

## Data Engineer vs Data Analyst
| Role | Focus |
|---|---|
| Data Engineer | building reliable data systems |
| Data Analyst | exploring data and producing insights |

A data analyst asks, “What happened?” A data engineer makes sure the data exists, is trustworthy, and is ready to answer that question.

## Data Engineer vs Data Scientist
- Data scientist: builds models and experiments
- Data engineer: prepares reliable data for those models and dashboards

## Data lifecycle
Data usually moves through:
1. Creation
2. Capture
3. Ingestion
4. Storage
5. Processing
6. Serving / analysis
7. Archival or deletion

## Data engineering lifecycle
`Source -> Ingestion -> Storage -> Processing -> Serving`

## Batch vs streaming
### Batch
- data arrives in chunks
- good for daily or hourly reporting
- simpler and cheaper

### Streaming
- data arrives continuously
- good for alerts, fraud detection, and live dashboards
- more complex

## Structured / semi-structured / unstructured
- Structured: tables and fixed schemas
- Semi-structured: JSON, logs, XML
- Unstructured: text, images, video

## OLTP vs OLAP
| Type | Main purpose |
|---|---|
| OLTP | transaction processing |
| OLAP | analytics and reporting |

## Operational vs analytical workloads
- Operational workloads support business transactions
- Analytical workloads support reporting and decision-making

## Must Know
- Data lifecycle and engineering lifecycle
- Batch vs streaming
- OLTP vs OLAP
- Role of a data engineer

## Good to Know
- Analyst vs scientist vs engineer
- Structured vs semi-structured vs unstructured

## Advanced
- Data platform architecture patterns
- Real-time analytics systems

## Interview Questions
1. What is data engineering in one sentence?
2. Why is the lifecycle important?
3. When do you choose batch over streaming?
4. How is OLTP different from OLAP?
5. What problems does a data engineer solve that analysts do not?
