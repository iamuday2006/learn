# Kafka Hands-On Lab — Weather Pipeline

Real-time pipeline from TODO.md §37, runnable on one machine:

```text
Weather API / synthetic  →  Python producer  →  Kafka (KRaft)  →  Python consumer group
```

Every exercise maps to a notes file — do the experiment, then reread the section and explain out loud what you saw.

## Setup

```bash
cd lab
pip install -r requirements.txt

# 1. Start Kafka (KRaft — no ZooKeeper)
docker compose up -d
docker compose logs kafka | tail -5      # wait until you see "started (kafka.server.KafkaRaftServer)"

# 2. Create the topic (4 partitions — matches the examples in the notes)
./k.sh kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic weather-events --partitions 4 --replication-factor 1

# 3. Run the pipeline (two terminals)
python weather-pipeline/producer.py
python weather-pipeline/consumer.py
```

## Exercises → what they teach

| # | Do this | Concept | Notes |
|---|---|---|---|
| 1 | Run producer + consumer, watch acks print partition+offset | producer flow, keying, per-city partition stickiness | `03` §1–3, `02` §2 |
| 2 | `./k.sh kafka-topics.sh --describe --topic weather-events` | partitions/leaders/ISR | `02` §4 |
| 3 | `./k.sh kafka-consumer-groups.sh --describe --group weather-analytics` | lag per partition | `04` §6 |
| 4 | Ctrl-C the consumer mid-stream, restart | **at-least-once reprocessing** + the consumer's own DUPLICATE dedupe log | `04` §4, `05` §4 |
| 5 | `SLOW_MS=15000 python weather-pipeline/consumer.py` (two instances, then stop one) | rebalance flow | `04` §3 |
| 6 | Stop producer, note last offsets, restart later | resume from committed offsets, `auto.offset.reset` only for new groups | `02` §3 |
| 7 | `./k.sh kafka-consumer-groups.sh --reset-offsets --to-earliest --topic weather-events --execute` (group must be inactive — stop consumers, wait ~45s) | **replay** — Kafka's superpower vs queues | `06` §2, `01` §5 |
| 8 | Create `user-state` compacted topic (script in `06` §8), write key updates | compaction | `06` §3 |
| 9 | Second terminal: `GROUP_ID=weather-dashboard python consumer.py` | independent consumer groups = fan-out | `04` §2 |
| 10 | Run 2 consumers in one group; then run 5 | partition assignment math; extras idle | `04` §2, §7 |

## Failure experiments (chaos day)

- **Kill the container mid-produce** (`docker compose stop kafka`): producer callbacks show errors → restart → note which sends were lost/duplicated (RF=1 lab!). Then explain what RF=3 + `min.insync.replicas=2` would have changed. → `05` §1–3
- **Rebalance storm**: `SLOW_MS=15000` + low `max_poll_interval_ms` in consumer.py → constant rebalancing logs. Diagnose like the scenario in `04` §3.
- **Lag spike**: pause the consumer for 2 minutes, then watch lag and catch-up. → `04` §6

## CLI you should have muscle memory for

`k.sh` runs any Kafka CLI script inside the container (and sidesteps a Git-Bash
path quirk on Windows):

```bash
./k.sh kafka-topics.sh --bootstrap-server localhost:9092 --list
./k.sh kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic weather-events
./k.sh kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic weather-events --from-beginning --property print.key=true --property print.partition=true
./k.sh kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group weather-analytics
```

Notes:
- On Windows Git Bash, run the Python scripts as `python -u consumer.py` so
  output isn't buffered by pipes.
- After killing a consumer, the group holds its membership until
  `session.timeout.ms` expires (~45s here) — `--reset-offsets` fails with
  "group is not inactive" until then. That IS the liveness mechanism from
  notes/04 working in front of you.

## Teardown

```bash
docker compose down          # keeps nothing (no volume) — clean slate each run
```
