# Kafka Interview Preparation --- Internship / Entry-Level Data Engineering

## Goal

Prepare for a **Data Engineering internship / entry-level interview**
where Apache Kafka may be tested in:

-   Kafka fundamentals
-   Producer / Consumer architecture
-   Topics, partitions and offsets
-   Consumer groups
-   Replication and fault tolerance
-   Delivery semantics
-   Performance and scaling
-   Rebalancing
-   Retention and log architecture
-   Schema management
-   Kafka Connect
-   Kafka Streams
-   Real-world pipeline design
-   Troubleshooting and scenario questions

### Primary book

**Kafka: The Definitive Guide --- Real-Time Data and Stream Processing
at Scale**\
Neha Narkhede, Gwen Shapira, Todd Palino

Use the book as the **primary technical source**. Convert its concepts
into interview-focused notes instead of simply copying chapters.

------------------------------------------------------------------------

# 0. What's In This Workspace (Built Materials + Progress)

## Materials

``` text
notes/                         ← interview-focused notes (from the book)
  README.md                      index + reading order
  01-fundamentals.md             P0  what/why Kafka, architecture, vs queue/DB
  02-topics-partitions-offsets.md P0  partitions, keys, ordering, offsets
  03-producers.md                P0  acks, retries, idempotence, batching
  04-consumers.md                P0  groups, rebalancing, commits, lag
  05-reliability.md              P0  replication, ISR, delivery semantics
  06-storage-retention-compaction.md P1  segments, retention, compaction, page cache
  07-ecosystem.md                P1  Connect, Streams, schemas, security, KRaft
  08-pipelines-scenarios-monitoring.md P0/P1 designs, scenario bank, troubleshooting
  09-interview-drills.md         explanation template, 40 rapid-fire, CLI, flashcards
  10-checklist.md                final readiness checklist

lab/                           ← hands-on weather pipeline (verified working)
  docker-compose.yml             single-broker Kafka in KRaft mode (no ZooKeeper)
  k.sh                           helper to run Kafka CLI inside the container
  README.md                      10 exercises + failure experiments
  weather-pipeline/producer.py   keyed producer (confluent-kafka, idempotent)
  weather-pipeline/consumer.py   consumer group, manual commits, at-least-once
```

## Progress tracker

- [x] P0 notes written (01–05) — read one per sitting, answer Q&A out loud
- [x] P1 notes written (06–08)
- [x] Drills + checklist written (09–10)
- [x] Lab built and end-to-end verified (producer → topic → consumer → commit)
- [ ] Work through the 7-Day Sprint below, ticking boxes as you go
- [ ] Final checklist (notes/10-checklist.md) fully ticked
- [ ] Day-7 mock interview completed out loud

------------------------------------------------------------------------

# 1. How To Use This File

For every topic, learn in this order:

1.  What is it?
2.  Why do we need it?
3.  How does it work?
4.  Important terminology
5.  Simple example
6.  Real Data Engineering use case
7.  Important configurations
8.  Failure cases
9.  Performance/scaling considerations
10. Interview questions
11. Scenario-based questions
12. Hands-on task

The goal is **understanding + explanation ability**, not memorization.

------------------------------------------------------------------------

# 2. Priority System

## P0 --- Must Know

Master these before moving forward:

-   What is Kafka?
-   Event streaming
-   Topic
-   Partition
-   Offset
-   Producer
-   Consumer
-   Broker
-   Consumer group
-   Leader / follower
-   Replication
-   ISR
-   Retention
-   `acks`
-   Consumer offsets
-   Rebalancing
-   Ordering
-   Delivery semantics
-   At-most-once
-   At-least-once
-   Exactly-once concept
-   Producer retries
-   Idempotent producer
-   Partitioning / keys
-   Consumer scaling
-   Kafka vs traditional queues
-   Basic Kafka architecture

## P1 --- Strong Interview Knowledge

-   Log segments
-   Page cache
-   Replication protocol
-   `min.insync.replicas`
-   `acks=all`
-   Producer batching
-   Compression
-   Consumer polling
-   `max.poll.interval.ms`
-   `max.poll.records`
-   Offset commits
-   Consumer lag
-   Retention by time/size
-   Cleanup policies
-   Log compaction
-   Schema evolution
-   Kafka Connect
-   Source connectors
-   Sink connectors
-   Kafka Streams basics

## P2 --- Advanced

Study after P0/P1:

-   Transactions
-   Exactly-once semantics
-   KRaft
-   Controller quorum
-   Advanced replication behavior
-   Log compaction internals
-   Kafka Streams state stores
-   Windowing
-   Stream joins
-   Advanced performance tuning
-   Tiered storage
-   Advanced security
-   Multi-cluster architecture

Do not spend most of your interview preparation time on P2 before P0/P1.

------------------------------------------------------------------------

# 3. Kafka Mental Model

Before learning individual APIs, understand this:

``` text
                PRODUCER
                    |
                    | records
                    v
              +-----------+
              |   TOPIC   |
              +-----------+
               /    |    \
              /     |     \
             v      v      v
           P0      P1      P2
           |       |       |
           v       v       v
        Broker   Broker   Broker
           |
           v
     CONSUMER GROUP
       /        \
      v          v
 Consumer 1   Consumer 2
```

Think of Kafka as a **distributed append-only event log**.

A producer writes records.

Kafka stores records in partitions.

Consumers read records at their own pace.

------------------------------------------------------------------------

# 4. Chapter 1 --- Introduction to Kafka

## Learn

-   What Kafka is
-   Event streaming
-   Event vs message
-   Producers
-   Consumers
-   Topics
-   Brokers
-   Partitions
-   Distributed systems
-   Why Kafka is useful for Data Engineering

## Questions

1.  What is Apache Kafka?
2.  Why was Kafka created?
3.  What problem does Kafka solve?
4.  Kafka vs traditional message queue?
5.  Kafka vs database?
6.  Is Kafka a database?
7.  Is Kafka a queue?
8.  Is Kafka a streaming platform?
9.  Why is Kafka horizontally scalable?
10. Where is Kafka used in real companies?

## Scenario

> An e-commerce company receives 50,000 order events per minute.
> Payment, inventory, notification and analytics systems all need those
> events.

Explain how Kafka could sit between these systems.

------------------------------------------------------------------------

# 5. Chapter 2 --- Kafka Architecture

Understand:

-   Kafka cluster
-   Broker
-   Topic
-   Partition
-   Replica
-   Leader
-   Follower
-   Controller
-   Consumer
-   Consumer group

Basic architecture:

``` text
                  Kafka Cluster
        +-----------------------------+
        |                             |
        | Broker 1        Broker 2    |
        |   |               |         |
        |   |               |         |
        | Topic A          Topic A    |
        |   |               |         |
        | P0 leader        P1 leader  |
        | P1 replica       P0 replica |
        |                             |
        +-----------------------------+
```

## Questions

-   What is a Kafka broker?
-   Can one Kafka cluster have multiple brokers?
-   What is a topic?
-   What is a partition?
-   What is a replica?
-   What is a leader?
-   What is a follower?
-   What does the controller do?
-   Why does Kafka need multiple brokers?

------------------------------------------------------------------------

# 6. Topics

A topic is a logical stream of records.

Example:

``` text
orders
payments
users
click-events
weather-events
```

A topic can contain multiple partitions.

``` text
orders
 ├── partition-0
 ├── partition-1
 ├── partition-2
 └── partition-3
```

## Learn

-   Topic creation
-   Partition count
-   Replication factor
-   Retention
-   Cleanup policy
-   Ordering

## Questions

1.  What is a Kafka topic?
2.  Does Kafka delete a message after consumption?
3.  Can multiple consumers read the same topic?
4.  Can multiple consumer groups read the same topic?
5.  How does retention work?
6.  Can partition count be increased?
7.  What happens when partition count changes?

------------------------------------------------------------------------

# 7. Partitions

This is one of the most important Kafka topics.

A partition is an **ordered append-only log**.

``` text
Partition 0

offset
  0   order-A
  1   order-B
  2   order-C
  3   order-D
  4   order-E
```

## Critical Rule

Kafka ordering is guaranteed **within a partition**.

Kafka does not provide one global ordering across multiple partitions.

## Why partitions?

Partitions provide:

-   Parallelism
-   Scalability
-   Distribution
-   Ordering boundaries

## Partition Key

Example:

``` text
customer_id = 101
```

If customer 101's events must remain ordered, use:

``` text
key = customer_id
```

Conceptually:

``` text
customer 101
    |
    v
same partition
    |
    +--> event 1
    +--> event 2
    +--> event 3
```

## Questions

1.  Why does Kafka use partitions?
2.  What determines the partition?
3.  What happens when no key is provided?
4.  Is ordering global?
5.  How do you guarantee ordering for one customer?
6.  Can a partition be moved between brokers?
7.  What happens if there are more consumers than partitions?

------------------------------------------------------------------------

# 8. Offsets

Each record inside a partition has an offset.

``` text
Partition 0

0 -> A
1 -> B
2 -> C
3 -> D
4 -> E
```

Important:

**Offset is scoped to a partition.**

It is not a globally unique Kafka position.

## Understand

-   Offset
-   Current consumer position
-   Committed offset
-   Consumer offset storage
-   Offset reset

## Questions

1.  What is an offset?
2.  Is an offset globally unique?
3.  Can two partitions have offset 100?
4.  What happens after a consumer crashes?
5.  How does a consumer resume processing?
6.  What does `auto.offset.reset` control?

------------------------------------------------------------------------

# 9. Producers

Producer flow:

``` text
Application
    |
    v
Kafka Producer
    |
    +--> Serialization
    |
    +--> Partition selection
    |
    +--> Batch
    |
    +--> Compression
    |
    v
Kafka Broker
```

## Learn

-   Producer API
-   Serialization
-   Partition selection
-   Batching
-   Compression
-   Acknowledgements
-   Retries
-   Idempotence

## Important settings

Understand conceptually:

``` text
acks
retries
enable.idempotence
batch.size
linger.ms
compression.type
max.in.flight.requests.per.connection
```

Do not memorize values without knowing what they change.

------------------------------------------------------------------------

# 10. Acknowledgements

Understand:

``` text
acks=0
acks=1
acks=all
```

Compare:

  -----------------------------------------------------------------------
  Setting                 Basic behavior          Main trade-off
  ----------------------- ----------------------- -----------------------
  `acks=0`                Producer does not wait  Lower latency, weaker
                          for broker              delivery assurance
                          acknowledgement         

  `acks=1`                Leader acknowledges     Better than 0, but
                                                  leader failure can
                                                  matter before
                                                  replication

  `acks=all`              Acknowledgement depends Stronger durability,
                          on in-sync replicas     potentially more
                                                  latency
  -----------------------------------------------------------------------

## Interview Question

> Why is `acks=all` generally safer than `acks=1`?

Explain the interaction between:

``` text
leader
followers
ISR
replication
min.insync.replicas
```

------------------------------------------------------------------------

# 11. Producer Retries

Scenario:

``` text
Producer
   |
   | send record
   v
Broker
   |
   | record accepted
   |
   X acknowledgement lost
   |
Producer thinks request failed
   |
   v
Retry
```

Potential result:

``` text
duplicate record
```

This leads to the next topic.

------------------------------------------------------------------------

# 12. Idempotent Producer

Understand:

-   Why retries can create duplicates
-   Producer ID
-   Sequence numbers
-   Duplicate prevention
-   Relationship with delivery guarantees

## Scenario

> Kafka accepted a payment event, but the producer did not receive the
> acknowledgement because of a network failure. The producer retries.

Explain:

1.  What can go wrong?
2.  Why can duplicate events occur?
3.  How does idempotence help?

------------------------------------------------------------------------

# 13. Consumers

Consumer flow:

``` text
Kafka
  |
  v
Consumer
  |
  +--> poll()
  |
  +--> deserialize
  |
  +--> process
  |
  +--> commit offset
```

## Learn

-   Consumer API
-   Polling
-   Deserialization
-   Processing
-   Offset commits
-   Consumer position
-   Consumer lag

Important settings:

``` text
group.id
auto.offset.reset
enable.auto.commit
max.poll.records
max.poll.interval.ms
session.timeout.ms
heartbeat.interval.ms
```

------------------------------------------------------------------------

# 14. Consumer Groups

This is a **P0 interview topic**.

Example:

``` text
Topic
 ├── P0
 ├── P1
 ├── P2
 └── P3

Consumer Group A
 ├── Consumer 1
 ├── Consumer 2
 └── Consumer 3
```

Within one consumer group:

**One partition is assigned to at most one consumer at a time.**

Multiple consumer groups can independently consume the same topic.

``` text
                 orders
                    |
        +-----------+-----------+
        |                       |
        v                       v
 Analytics Group          Notification Group
   C1   C2                  C1   C2
```

## Questions

1.  What is a consumer group?
2.  Why use consumer groups?
3.  Can two consumers in the same group read one partition
    simultaneously?
4.  What happens when consumers \> partitions?
5.  What happens when partitions \> consumers?
6.  What happens when a consumer dies?
7.  Can multiple groups consume the same topic?

------------------------------------------------------------------------

# 15. Consumer Rebalancing

Rebalancing happens when partition ownership within a consumer group
needs to change.

Possible triggers:

-   Consumer joins
-   Consumer leaves
-   Consumer crashes
-   Partition assignment changes
-   Group membership changes

Concept:

``` text
Consumer failure
       |
       v
Group detects change
       |
       v
Rebalance
       |
       v
Partitions reassigned
```

## Important concepts

-   Group coordinator
-   Partition assignment
-   Heartbeats
-   Session timeout
-   Poll interval
-   Cooperative rebalancing

## Scenario

> A consumer takes 10 minutes to process one batch. The group keeps
> rebalancing.

What configuration and application behavior would you investigate?

------------------------------------------------------------------------

# 16. Consumer Offset Commit

Two broad approaches:

``` text
Auto commit
Manual commit
```

Understand the trade-offs.

## Important Question

Suppose:

``` text
record received
   |
   v
processing
   |
   X application crashes
   |
offset was already committed
```

What happens?

Now reverse it:

``` text
record received
   |
   v
processing succeeds
   |
   X application crashes
   |
offset not committed
```

What happens?

Use these scenarios to understand delivery semantics.

------------------------------------------------------------------------

# 17. Delivery Semantics

Know these three terms:

## At-most-once

A record may be lost, but normally is not processed more than once.

``` text
commit
  |
  v
process
```

## At-least-once

A record may be processed more than once, but the system aims not to
lose it.

``` text
process
  |
  v
commit
```

Potential duplicate:

``` text
process succeeds
      |
      X crash before commit
      |
      v
record processed again
```

## Exactly-once

The goal is that the externally visible processing effect occurs exactly
once under the supported transactional design.

Do not casually say:

> "Kafka automatically guarantees exactly once."

Explain the producer, transactions and downstream system together.

------------------------------------------------------------------------

# 18. Replication

Replication provides fault tolerance.

Example:

``` text
Partition 0

Broker 1
  Leader
    |
    +------> Broker 2
    |        Follower
    |
    +------> Broker 3
             Follower
```

## Learn

-   Replication factor
-   Leader
-   Followers
-   ISR
-   Leader election
-   Fault tolerance
-   `min.insync.replicas`
-   `acks=all`

## Scenario

> Broker 1 contains the leader for Partition 0 and suddenly fails.

Explain:

1.  What happens to the leader?
2.  What happens to followers?
3.  How is a new leader selected?
4.  What happens to producers?
5.  What happens to consumers?

------------------------------------------------------------------------

# 19. ISR --- In-Sync Replicas

ISR means:

**In-Sync Replicas**

Understand:

-   Which replicas are considered in sync
-   Why ISR matters
-   Relationship with `acks=all`
-   Relationship with `min.insync.replicas`

Mental model:

``` text
Partition P0

Leader
 |
 +-- Replica A  <- ISR
 |
 +-- Replica B  <- ISR
 |
 +-- Replica C  <- not currently ISR
```

## Interview Question

> What happens if `acks=all` is used and the number of available in-sync
> replicas falls below `min.insync.replicas`?

Be able to explain the availability vs durability trade-off.

------------------------------------------------------------------------

# 20. Retention

Kafka does not normally remove records simply because a consumer has
read them.

Retention is controlled by policies such as:

-   Time
-   Size

Example:

``` text
Topic
 |
 +-- old segment
 +-- old segment
 +-- recent segment
```

Older log segments can eventually be deleted according to retention
rules.

## Questions

1.  Does Kafka delete a message after consumption?
2.  What is retention?
3.  Can consumers reread old data?
4.  What happens if a consumer is offline for a long time?
5.  What is retention by size?
6.  What is retention by time?

------------------------------------------------------------------------

# 21. Log Segments

A partition is not one infinitely growing physical file.

Kafka stores partition data using log segments.

Conceptually:

``` text
Partition 0
 |
 +-- segment-000000000
 +-- segment-000001234
 +-- segment-000002456
```

Understand why segments are useful for:

-   Retention
-   Deletion
-   Compaction
-   File management

------------------------------------------------------------------------

# 22. Log Compaction

Compaction is different from normal retention.

Example:

``` text
key=A value=1
key=B value=2
key=A value=3
key=A value=4
```

After compaction, older values for the same key can be removed while
retaining the latest value according to Kafka's compaction semantics.

Common use case:

``` text
customer_id -> latest customer state
```

## Questions

1.  What is log compaction?
2.  Retention vs compaction?
3.  When would you use compaction?
4.  Is compaction the same as deleting all old records?
5.  What kind of data is suitable for compacted topics?

------------------------------------------------------------------------

# 23. Consumer Lag

Consumer lag is a very important real-world Data Engineering concept.

Conceptually:

``` text
Latest available offset
        -
Consumer processed/committed position
        =
Lag
```

Example:

``` text
Latest offset = 10000
Consumer position = 8500

Lag ≈ 1500 records
```

## Causes

-   Slow consumer
-   Insufficient consumers
-   Slow downstream database
-   Expensive processing
-   Network bottleneck
-   Broker performance issue
-   Large batches
-   Rebalancing

## Interview Scenario

> Your Kafka consumer lag suddenly increases from 100 to 1,000,000.

Explain how you would investigate.

Think:

``` text
Producer rate
      ↓
Kafka throughput
      ↓
Consumer count
      ↓
Consumer processing time
      ↓
Downstream system
      ↓
Errors/retries
      ↓
Partition distribution
```

------------------------------------------------------------------------

# 24. Scaling Kafka Consumers

Suppose:

``` text
Topic = 8 partitions
Consumer group = 3 consumers
```

The consumers can process partitions in parallel.

If:

``` text
8 partitions
10 consumers
```

some consumers will have no partition assigned.

Key interview principle:

**Maximum active consumer parallelism within one consumer group is
bounded by the number of partitions.**

------------------------------------------------------------------------

# 25. Ordering vs Parallelism

Important trade-off:

``` text
More partitions
     ↓
More parallelism
     ↓
Potentially harder global ordering
```

If strict global ordering is required, partitioning strategy becomes
critical.

## Scenario

> A financial application requires all events for an account to be
> processed in order, but different accounts can be processed in
> parallel.

Possible design:

``` text
partition key = account_id
```

Then:

``` text
Account A -> Partition 1
Account B -> Partition 3
Account C -> Partition 0
```

Events for one account remain ordered while accounts can be processed
concurrently.

------------------------------------------------------------------------

# 26. Kafka Connect

Kafka Connect is used to move data between Kafka and external systems.

``` text
Database
   |
   v
Source Connector
   |
   v
Kafka
   |
   v
Sink Connector
   |
   v
Warehouse / Search / Storage
```

## Learn

-   Kafka Connect
-   Worker
-   Connector
-   Task
-   Source connector
-   Sink connector
-   Distributed mode
-   Standalone mode
-   Connect configuration

## Questions

1.  What is Kafka Connect?
2.  Source vs sink connector?
3.  Why not write a custom Python consumer for every destination?
4.  What is a Connect worker?
5.  What is a task?
6.  How does Connect scale?

------------------------------------------------------------------------

# 27. Kafka Streams

Kafka Streams is a library for building stream-processing applications.

Conceptually:

``` text
Kafka Topic
    |
    v
Kafka Streams Application
    |
    +--> filter
    +--> map
    +--> aggregate
    +--> join
    +--> window
    |
    v
Kafka Topic
```

Learn the basics:

-   KStream
-   KTable
-   Stateless transformations
-   Stateful transformations
-   Aggregations
-   Joins
-   Windowing
-   State stores

For an internship interview, understand the architecture and use cases
before going deep into APIs.

------------------------------------------------------------------------

# 28. Schema and Serialization

Understand:

-   Serialization
-   Deserialization
-   JSON
-   Avro
-   Protobuf
-   Schema evolution
-   Compatibility

Example:

``` text
Producer
   |
serialize
   |
   v
Kafka
   |
deserialize
   |
   v
Consumer
```

## Questions

1.  Why serialize data?
2.  JSON vs Avro?
3.  What is schema evolution?
4.  Why is schema compatibility important?
5.  What happens when a producer adds a new field?

------------------------------------------------------------------------

# 29. Kafka Security --- Interview Basics

Know the purpose of:

-   Authentication
-   Authorization
-   Encryption
-   TLS
-   SASL
-   ACLs

Mental model:

``` text
Who are you?
     |
Authentication
     |
What can you access?
     |
Authorization
     |
Is communication protected?
     |
Encryption / TLS
```

Do not go deep into security configuration until the core architecture
is strong.

------------------------------------------------------------------------

# 30. KRaft --- Modern Kafka Architecture

Understand at a high level:

-   KRaft
-   Controller
-   Controller quorum
-   Metadata management
-   Difference from older ZooKeeper-based Kafka deployments

Interview question:

> Why did Kafka move away from ZooKeeper toward KRaft?

Focus on the architectural reason and operational simplification rather
than memorizing implementation details.

------------------------------------------------------------------------

# 31. Kafka vs Traditional Message Queue

Be able to compare:

  -------------------------------------------------------------------------
  Concept                 Kafka                   Traditional queue
  ----------------------- ----------------------- -------------------------
  Data model              Distributed log         Usually queue/message
                                                  model

  Consumption             Consumers track         Often message
                          position                acknowledgement/removal
                                                  model

  Replay                  Strong replay           Depends on system
                          capability              

  Partition-based         Yes                     Depends on system
  parallelism                                     

  Retention               Configurable            Depends on system

  Multiple independent    Consumer groups         Depends on system
  consumers                                       
  -------------------------------------------------------------------------

Do not say one system is universally better.

Explain the workload requirements.

------------------------------------------------------------------------

# 32. Kafka vs Database

Kafka:

-   Event transport
-   Event log
-   Streaming
-   Replay
-   High-throughput event pipelines

Database:

-   Persistent application state
-   Queries
-   Transactions
-   Data modeling
-   Constraints

Real architecture can use both:

``` text
Application
    |
    +------> PostgreSQL
    |
    +------> Kafka
              |
       +------+------+
       |             |
       v             v
   Analytics      Notifications
```

------------------------------------------------------------------------

# 33. Real Data Engineering Architecture

You should be able to design this:

``` text
                 Applications
                      |
                      v
                  Kafka
                      |
          +-----------+-----------+
          |                       |
          v                       v
   Stream Processing        Kafka Connect
          |                       |
          v                       v
       Storage              Data Warehouse
          |                       |
          +-----------+-----------+
                      |
                      v
                  Analytics
```

Example stack:

``` text
PostgreSQL
    |
    v
Debezium / CDC
    |
    v
Kafka
    |
    +--> PySpark / Databricks
    |
    +--> Snowflake
    |
    +--> Elasticsearch
```

Be prepared to explain why each component exists.

------------------------------------------------------------------------

# 34. Kafka Interview Scenario Bank

## Scenario 1 --- Duplicate Events

> Payment events appear twice downstream.

Investigate:

-   Producer retries
-   Idempotence
-   Consumer retries
-   Offset commit timing
-   Downstream idempotency

------------------------------------------------------------------------

## Scenario 2 --- Consumer Lag

> Lag continuously increases.

Investigate:

-   Producer throughput
-   Consumer throughput
-   Number of partitions
-   Number of consumers
-   Processing time
-   Downstream database latency
-   Errors/retries
-   Rebalances

------------------------------------------------------------------------

## Scenario 3 --- Ordering

> Customer events must be processed in order.

Ask:

-   What defines the ordering key?
-   Which events belong together?
-   Can those events use the same partition?
-   Can global ordering be avoided?

------------------------------------------------------------------------

## Scenario 4 --- Consumer Crash

> Consumer crashes after processing a record but before committing the
> offset.

Expected concept:

``` text
record processed
       |
       X crash
       |
offset not committed
       |
       v
record may be processed again
```

Connect this to **at-least-once delivery**.

------------------------------------------------------------------------

## Scenario 5 --- Broker Failure

> Leader broker fails.

Explain:

``` text
Leader failure
      |
      v
ISR replicas
      |
      v
Leader election
      |
      v
Producer/consumer reconnect
```

------------------------------------------------------------------------

## Scenario 6 --- More Consumers Than Partitions

> Topic has 4 partitions and consumer group has 8 consumers.

What happens?

Expected concept:

``` text
4 partitions
8 consumers

Only up to 4 consumers
can actively own partitions
at a time.
```

------------------------------------------------------------------------

## Scenario 7 --- Millions of Events

> Your company receives millions of events per minute.

Discuss:

-   Partitioning
-   Broker count
-   Replication
-   Producer batching
-   Compression
-   Consumer parallelism
-   Consumer lag
-   Monitoring
-   Retention
-   Downstream throughput

------------------------------------------------------------------------

## Scenario 8 --- Slow Consumer

> One consumer takes too long to process records.

Investigate:

-   `max.poll.interval.ms`
-   `max.poll.records`
-   Processing time
-   Batch size
-   Downstream latency
-   Consumer group rebalancing

------------------------------------------------------------------------

# 35. Troubleshooting Framework

When given a Kafka production problem, do not randomly change
configurations.

Use:

``` text
1. Define the symptom
        ↓
2. Check producer rate
        ↓
3. Check broker health
        ↓
4. Check partition distribution
        ↓
5. Check consumer lag
        ↓
6. Check consumer errors
        ↓
7. Check processing latency
        ↓
8. Check downstream system
        ↓
9. Check rebalances
        ↓
10. Change one thing and measure
```

------------------------------------------------------------------------

# 36. Monitoring Concepts

Know what you would monitor:

### Producer

-   Throughput
-   Error rate
-   Request latency
-   Retry rate
-   Batch behavior

### Broker

-   CPU
-   Memory
-   Disk
-   Network
-   Request latency
-   Under-replicated partitions

### Consumer

-   Lag
-   Processing latency
-   Poll behavior
-   Rebalances
-   Errors

### Cluster

-   Partition health
-   ISR
-   Replication
-   Broker availability

------------------------------------------------------------------------

# 37. Hands-On Lab

Do not only read Kafka.

Build a small pipeline.

## Project

### Real-Time Weather Pipeline

``` text
Weather API
    |
    v
Python Producer
    |
    v
Kafka
    |
    v
PySpark Consumer
    |
    v
PostgreSQL
```

Create:

``` text
weather-events
```

Suggested event:

``` json
{
  "city": "Siliguri",
  "temperature": 28.4,
  "humidity": 72,
  "timestamp": "2026-09-16T12:00:00"
}
```

Practice:

-   Producer
-   Topic
-   Partitions
-   Key
-   Consumer
-   Consumer group
-   Offset
-   Manual commit
-   Consumer lag
-   Failure/restart
-   Duplicate handling

------------------------------------------------------------------------

# 38. Kafka CLI Commands To Know

Understand what these commands do.

``` bash
kafka-topics.sh
```

``` bash
kafka-console-producer.sh
```

``` bash
kafka-console-consumer.sh
```

``` bash
kafka-consumer-groups.sh
```

Examples of concepts to practice:

``` bash
--create
--list
--describe
--bootstrap-server
--topic
--partitions
--replication-factor
--group
--from-beginning
```

Do not memorize command syntax alone. Know what each operation changes
or displays.

------------------------------------------------------------------------

# 39. Interview Explanation Template

For any Kafka question, answer using:

``` text
Definition
    ↓
Why
    ↓
How it works
    ↓
Example
    ↓
Trade-off
    ↓
Real-world use case
```

Example:

> What is a partition?

Weak answer:

> Partition stores Kafka messages.

Strong answer structure:

``` text
A partition is an ordered append-only log inside a Kafka topic.

Kafka divides a topic into partitions to distribute data across brokers
and enable parallel processing.

Each record gets an offset within the partition.

Ordering is guaranteed within that partition.

A partition key can be used to keep related events together.

Partitions therefore provide both scalability and an ordering boundary.
```

------------------------------------------------------------------------

# 40. Rapid-Fire Questions

Answer these without notes:

1.  What is Kafka?
2.  What is a broker?
3.  What is a topic?
4.  What is a partition?
5.  What is an offset?
6.  What is a consumer group?
7.  What is replication?
8.  What is ISR?
9.  What is a leader?
10. What is a follower?
11. What is `acks=all`?
12. What is `min.insync.replicas`?
13. Why do producers retry?
14. What is idempotence?
15. What is consumer lag?
16. Why does rebalancing happen?
17. What is at-least-once delivery?
18. What is at-most-once delivery?
19. What is exactly-once processing?
20. Does Kafka delete messages after consumption?
21. What is retention?
22. What is compaction?
23. What is Kafka Connect?
24. What is a source connector?
25. What is a sink connector?
26. What is Kafka Streams?
27. KStream vs KTable?
28. Why use a partition key?
29. What happens when a broker dies?
30. What happens when a consumer dies?
31. What happens when consumers \> partitions?
32. What causes consumer lag?
33. How would you reduce consumer lag?
34. How would you preserve ordering?
35. Kafka vs RabbitMQ?
36. Kafka vs PostgreSQL?
37. Kafka vs Redis Streams?
38. Why is Kafka suitable for event-driven architecture?
39. What is KRaft?
40. Why does Kafka need replication?

------------------------------------------------------------------------

# 41. Interview Coding / Practical Questions

Be prepared to explain or implement:

### Producer

-   Send a record
-   Send with a key
-   Send to a specific partition
-   Handle producer errors

### Consumer

-   Subscribe to topic
-   Poll records
-   Process records
-   Commit offsets
-   Handle errors
-   Restart safely

### Data Engineering

-   Kafka → PySpark
-   Kafka → PostgreSQL
-   PostgreSQL CDC → Kafka
-   Kafka → Snowflake
-   Kafka → Databricks

------------------------------------------------------------------------

# 42. System Design Questions

Practice designing:

### A. Order Event Pipeline

``` text
Order Service
     |
     v
Kafka
     |
     +--> Payment
     +--> Inventory
     +--> Notification
     +--> Analytics
```

Questions:

-   Partition key?
-   Number of partitions?
-   Replication?
-   Consumer groups?
-   Ordering?
-   Retry strategy?
-   Duplicate handling?

------------------------------------------------------------------------

### B. Real-Time Analytics

``` text
Applications
     |
     v
Kafka
     |
     v
Stream Processing
     |
     v
Warehouse
     |
     v
Dashboard
```

Discuss:

-   Latency
-   Throughput
-   Fault tolerance
-   Replay
-   Schema
-   Monitoring

------------------------------------------------------------------------

### C. CDC Pipeline

``` text
PostgreSQL
     |
     v
CDC
     |
     v
Kafka
     |
     v
Databricks / Spark
     |
     v
Snowflake
```

Be able to explain:

-   Why CDC?
-   Why Kafka?
-   Why Spark?
-   Why warehouse?
-   How to handle duplicates?
-   How to handle schema changes?

------------------------------------------------------------------------

# 43. Book Reading Strategy

Use **Kafka: The Definitive Guide** as the deep-learning reference.

Do NOT try to memorize every paragraph.

For every chapter:

``` text
READ
  ↓
UNDERSTAND
  ↓
MAKE 1-PAGE NOTES
  ↓
ANSWER QUESTIONS WITHOUT BOOK
  ↓
BUILD / TEST SOMETHING
  ↓
EXPLAIN OUT LOUD
```

### When reading the book, extract:

-   Architecture concepts
-   Internal mechanisms
-   Important terminology
-   Failure behavior
-   Configuration concepts
-   Trade-offs
-   Real-world examples
-   Interview-worthy questions

### Skip/deprioritize initially:

-   Rare operational edge cases
-   Deep implementation details
-   Configuration values you cannot yet connect to a problem
-   Advanced internals that are unlikely to matter for an internship
    interview

Return to them after P0/P1 mastery.

------------------------------------------------------------------------

# 44. 7-Day Kafka Interview Sprint

## Day 1 --- Fundamentals

Study:

-   Kafka
-   Event streaming
-   Broker
-   Topic
-   Partition
-   Offset

Practice:

-   Draw Kafka architecture from memory.
-   Explain Kafka in 60 seconds.

------------------------------------------------------------------------

## Day 2 --- Producers

Study:

-   Producer
-   Serialization
-   Partitioning
-   Keys
-   Batching
-   Compression
-   `acks`
-   Retries
-   Idempotence

Practice:

-   Explain duplicate records.
-   Explain `acks=0`, `1`, `all`.

------------------------------------------------------------------------

## Day 3 --- Consumers

Study:

-   Consumer
-   Poll
-   Offset
-   Commit
-   Consumer group
-   Consumer lag

Practice:

-   Explain what happens after consumer crash.
-   Explain consumers \> partitions.

------------------------------------------------------------------------

## Day 4 --- Reliability

Study:

-   Replication
-   Leader
-   Follower
-   ISR
-   `min.insync.replicas`
-   Rebalancing
-   Delivery semantics

Practice:

-   Broker failure scenario.
-   Duplicate processing scenario.
-   Consumer rebalance scenario.

------------------------------------------------------------------------

## Day 5 --- Storage + Ecosystem

Study:

-   Retention
-   Log segments
-   Compaction
-   Schema
-   Kafka Connect
-   Kafka Streams
-   KRaft

Practice:

-   Explain Kafka Connect architecture.
-   Explain retention vs compaction.

------------------------------------------------------------------------

## Day 6 --- Data Engineering Architecture

Design:

1.  PostgreSQL → Kafka
2.  Kafka → PySpark
3.  Kafka → Snowflake
4.  Kafka → Databricks
5.  Kafka → PostgreSQL

For each architecture explain:

``` text
Why?
How?
Failure?
Scaling?
Ordering?
Duplicates?
Monitoring?
```

------------------------------------------------------------------------

## Day 7 --- Mock Interview

### Round 1 --- Fundamentals

Answer 20 rapid-fire questions.

### Round 2 --- Scenarios

Solve 5 production scenarios.

### Round 3 --- System Design

Design one real-time pipeline.

### Round 4 --- Project Discussion

Explain your Kafka project:

``` text
Problem
    ↓
Architecture
    ↓
Kafka role
    ↓
Partition strategy
    ↓
Consumer strategy
    ↓
Failure handling
    ↓
Monitoring
    ↓
Result
```

------------------------------------------------------------------------

# 45. Final Internship Readiness Checklist

## Kafka Fundamentals

-   [ ] I can explain Kafka in 60 seconds.
-   [ ] I can draw Kafka architecture.
-   [ ] I understand brokers.
-   [ ] I understand topics.
-   [ ] I understand partitions.
-   [ ] I understand offsets.

## Producers

-   [ ] I understand partition keys.
-   [ ] I understand batching.
-   [ ] I understand `acks`.
-   [ ] I understand retries.
-   [ ] I understand idempotence.

## Consumers

-   [ ] I understand polling.
-   [ ] I understand consumer groups.
-   [ ] I understand commits.
-   [ ] I understand lag.
-   [ ] I understand rebalancing.

## Reliability

-   [ ] I understand replication.
-   [ ] I understand leader/follower.
-   [ ] I understand ISR.
-   [ ] I understand `min.insync.replicas`.
-   [ ] I understand delivery semantics.

## Ecosystem

-   [ ] I understand retention.
-   [ ] I understand compaction.
-   [ ] I understand Kafka Connect.
-   [ ] I understand Kafka Streams basics.
-   [ ] I understand schema evolution.
-   [ ] I understand KRaft at a high level.

## Data Engineering

-   [ ] I can design PostgreSQL → Kafka.
-   [ ] I can design Kafka → Spark.
-   [ ] I can design Kafka → Snowflake.
-   [ ] I can explain CDC.
-   [ ] I can troubleshoot consumer lag.
-   [ ] I can discuss duplicates.
-   [ ] I can discuss ordering.
-   [ ] I can discuss scaling.

------------------------------------------------------------------------

# 46. Final Rule

For an internship interview, do not try to become a Kafka administrator
first.

Become someone who can confidently answer:

> **What problem does Kafka solve, how does its architecture solve it,
> what happens when something fails, and how would I use it in a real
> Data Engineering pipeline?**

Master:

``` text
Kafka
  ↓
Topics
  ↓
Partitions
  ↓
Offsets
  ↓
Producers
  ↓
Consumers
  ↓
Consumer Groups
  ↓
Replication / ISR
  ↓
Delivery Semantics
  ↓
Lag / Rebalancing
  ↓
Connect / Streams
  ↓
Real Pipeline Design
```

That is the core interview path.
