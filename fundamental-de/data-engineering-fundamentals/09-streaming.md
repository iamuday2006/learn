# 09 — Streaming Data

Streaming handles events continuously rather than waiting for batch windows.

## Streaming vs batch
| Type | Latency | Typical use |
|---|---|---|
| Batch | slower | reporting | 
| Streaming | faster | alerts, live dashboards |

## Events
Discrete actions such as purchases, clicks, or sensor readings.

## Producers
Applications or systems that emit events.

## Consumers
Applications that read events and process them.

## Topics
Streams are often organized into categories called topics.

## Partitions
Topics are split into partitions for parallel processing.

## Consumer groups
Multiple consumers can share partitions while preserving load balancing.

## Offsets
Location markers for how far a consumer has read.

## Ordering
Often guaranteed within a partition, not across all partitions.

## At-least-once delivery
Messages can be processed more than once but are not lost.

## At-most-once delivery
Messages may be dropped, but not retried.

## Exactly-once concept
System ensures each event is effectively processed once, even with retries.

## Event time vs processing time
- Event time: when the event happens
- Processing time: when the system handles it

## Watermarks
Estimate how late events may still arrive.

## Windowing
Group events into time windows like 5-minute or hourly windows.

## Kafka-style example
A payment app emits transaction events to a payments topic; downstream consumers read and compute metrics.

## Must Know
- Producers, consumers, partitions, offsets
- At-least-once and exactly-once concepts
- Event time vs processing time
- Watermarks and windowing

## Good to Know
- Consumer groups
- Ordering guarantees

## Advanced
- Stateful streaming
- Event-time joins

## Interview Questions
1. What is the difference between batch and streaming?
2. Why do partitions matter in Kafka-like systems?
3. What does at-least-once delivery mean?
4. Why are watermarks needed?
5. What is the difference between event time and processing time?
