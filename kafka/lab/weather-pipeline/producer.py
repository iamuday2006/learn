"""Weather event producer (confluent-kafka client).

Sends weather events to the `weather-events` topic, keyed by city so all
events for one city land on the same partition (per-city ordering).

Maps to TODO.md section 37 (Hands-On Lab) and notes/03-producers.md.

Usage:
    python producer.py                       # synthetic events (no API key needed)
    OPENWEATHER_KEY=xxx python producer.py   # live data from OpenWeather
"""

import json
import os
import random
import socket
import time
from datetime import datetime, timezone

from confluent_kafka import Producer

BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "localhost:9092")
TOPIC = "weather-events"
CITIES = {
    "Siliguri": (26.7271, 88.3953),
    "Kolkata": (22.5726, 88.3639),
    "Delhi": (28.6139, 77.2090),
    "Mumbai": (19.0760, 72.8777),
    "Chennai": (13.0827, 80.2707),
}
INTERVAL = float(os.getenv("PRODUCE_INTERVAL", "1.0"))


def fetch_live(city, coords):
    """Fetch live weather if OPENWEATHER_KEY is set; otherwise None."""
    key = os.getenv("OPENWEATHER_KEY")
    if not key:
        return None
    try:
        import requests

        url = "https://api.openweathermap.org/data/2.5/weather"
        r = requests.get(
            url,
            params={"lat": coords[0], "lon": coords[1], "appid": key, "units": "metric"},
            timeout=5,
        )
        r.raise_for_status()
        d = r.json()
        return {
            "city": city,
            "temperature": d["main"]["temp"],
            "humidity": d["main"]["humidity"],
        }
    except Exception as e:  # noqa: BLE001 - lab code: fall back to synthetic
        print(f"[warn] live fetch failed for {city}: {e} -> synthetic")
        return None


def synthetic(city):
    return {
        "city": city,
        "temperature": round(random.uniform(15.0, 35.0), 1),
        "humidity": random.randint(40, 95),
    }


def delivery_report(err, msg):
    """Delivery callback — where send errors surface (notes/03 section 10)."""
    if err is not None:
        # Production: log, retry/dead-letter, or block. Never silently drop.
        print(f"[error] delivery failed: {err}")
    else:
        print(
            f"acked: partition={msg.partition()} offset={msg.offset()} "
            f"key={msg.key().decode()}"
        )


def main():
    # Producer config mirrors notes/03: durable + idempotent defaults.
    producer = Producer(
        {
            "bootstrap.servers": BOOTSTRAP,
            "client.id": f"weather-producer-{socket.gethostname()}",
            "enable.idempotence": True,  # PID + sequence: broker dedupes retries (notes/03 section 7)
            "acks": "all",               # wait for ISR (notes/03 section 5)
            "linger.ms": 50,             # small batching demo (notes/03 section 4)
            "compression.type": "lz4",   # savings reach replicas + disk too
            # retries are automatic; overall delivery budget = message.timeout.ms (default 5 min)
        }
    )
    print(f"producing to {TOPIC} @ {BOOTSTRAP} — Ctrl-C to stop")

    try:
        while True:
            city = random.choice(list(CITIES))
            event = fetch_live(city, CITIES[city]) or synthetic(city)
            event["timestamp"] = datetime.now(timezone.utc).isoformat()

            # key = city -> same partition -> per-city ordering (notes/02 section 2)
            producer.produce(
                TOPIC,
                key=city,
                value=json.dumps(event).encode("utf-8"),
                on_delivery=delivery_report,
            )
            producer.poll(0)  # serve delivery callbacks
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print("\nstopping...")
    finally:
        producer.flush(10)  # deliver buffered records before exit


if __name__ == "__main__":
    main()
