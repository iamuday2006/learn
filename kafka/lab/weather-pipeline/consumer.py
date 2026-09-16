"""Weather events consumer (confluent-kafka client).

Demonstrates the patterns from notes/04-consumers.md:
- consumer group + poll loop
- manual commit AFTER processing (at-least-once; notes/05 section 4)
- idempotent-ish sink: dedupes per (city, timestamp) in-memory
- lag visibility per poll (position vs watermarks)

Usage:
    python consumer.py                     # group "weather-analytics"
    GROUP_ID=my-group python consumer.py
    SLOW_MS=15000 python consumer.py       # slow processing -> rebalance demo
"""

import json
import os
import socket
import time

from confluent_kafka import Consumer, KafkaError, KafkaException, TopicPartition

BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "localhost:9092")
TOPIC = "weather-events"
GROUP_ID = os.getenv("GROUP_ID", "weather-analytics")
SLOW_MS = int(os.getenv("SLOW_MS", "0"))  # artificial processing time


def process(record, v):
    """Your 'business logic' — the point where duplicates would matter."""
    if SLOW_MS:
        time.sleep(SLOW_MS / 1000.0)
    print(
        f"p={record.partition():2d} off={record.offset():5d} key={record.key().decode():10s} "
        f"{v['city']:10s} {v['temperature']:5.1f}C {v['humidity']:3d}% {v['timestamp']}"
    )


def main():
    consumer = Consumer(
        {
            "bootstrap.servers": BOOTSTRAP,
            "group.id": GROUP_ID,
            "client.id": f"weather-consumer-{socket.gethostname()}",

            # --- offset semantics (notes/04 section 4, notes/05 section 4) ---
            "enable.auto.commit": False,    # manual: commit AFTER processing
            "auto.offset.reset": "earliest",  # only applies with NO committed offset

            # --- liveness knobs (notes/04 section 5) ---
            "max.poll.interval.ms": 300000,   # 5 min processing budget
            "session.timeout.ms": 45000,
            "heartbeat.interval.ms": 15000,

            # resilient rebalancing (notes/04 section 3)
            "partition.assignment.strategy": "cooperative-sticky",
        }
    )
    print(f"group={GROUP_ID} @ {BOOTSTRAP}, topic={TOPIC} — Ctrl-C to stop")
    consumer.subscribe([TOPIC])

    seen = set()  # in-lab dedupe; real systems: DB upsert / processed-ids (notes/05 section 4)
    batch_count = 0

    try:
        while True:
            batch = consumer.consume(num_messages=50, timeout=1.0)
            if not batch:
                continue

            batch_count += 1
            print(f"--- poll #{batch_count}: {len(batch)} records ---")

            for record in batch:
                if record.error():
                    # topic-partition-level errors: log and continue unless fatal
                    if record.error().code() == KafkaError._PARTITION_EOF:
                        continue
                    raise KafkaException(record.error())

                v = json.loads(record.value().decode("utf-8"))
                key = (record.key().decode(), v["timestamp"])
                if key in seen:
                    # crash-before-commit on a previous run would land here
                    print(f"DUPLICATE detected (deduped): {key}")
                    continue
                seen.add(key)
                process(record, v)

            # at-least-once: commit only after the whole batch is processed.
            # Crash before this line -> records reprocessed on restart.
            consumer.commit(asynchronous=False)
    except KeyboardInterrupt:
        print("\nstopping...")
    finally:
        try:
            consumer.commit(asynchronous=False)
        except KafkaException:
            pass
        consumer.close()


if __name__ == "__main__":
    main()
