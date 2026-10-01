# 07 — Data Processing

Processing turns raw data into a usable form.

## ETL transformations
Clean, validate, join, aggregate, and reshape data.

## Distributed processing
Large datasets are split across multiple workers and processed in parallel.

## MapReduce
- map: transform input
- reduce: aggregate intermediate results

## Apache Spark
Spark is a distributed processing engine widely used for big data tasks.

## PySpark
Python API for Spark.

## DataFrames
Structured tabular abstraction for working with data.

## Transformations
Examples: filter, select, join, aggregate, groupBy.

## Actions
Trigger execution and return results: show, count, collect, save.

## Lazy evaluation
Spark builds a plan and executes only when an action is called.

## DAG
A directed acyclic graph describes the sequence of operations.

## Partitioning
Data is split into partitions for parallelism.

## Shuffle
A wide data movement across partitions; expensive but necessary for some operations.

## Narrow vs wide transformations
- narrow: local to a partition or small group
- wide: depends on many partitions and causes shuffle

## Must Know
- Spark basics
- DataFrames and lazy evaluation
- DAG and partitioning
- Narrow vs wide transformations

## Good to Know
- MapReduce concept
- Actions vs transformations
- Shuffle cost

## Advanced
- Spark optimizer internals
- Adaptive query execution

## Interview Questions
1. Why is lazy evaluation useful in Spark?
2. What is a DAG and why does Spark use one?
3. What is the difference between a transformation and an action?
4. Why is shuffle expensive?
5. What is a wide transformation and why does it matter?
