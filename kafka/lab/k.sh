#!/usr/bin/env bash
# Helper: run Kafka CLI scripts inside the lab container without path-mangling
# (Git Bash on Windows converts leading /opt/... paths; going through this
# script avoids that). Works the same on macOS/Linux.
#
# Usage:  ./k.sh kafka-topics.sh --bootstrap-server localhost:9092 --list
set -euo pipefail
# Stop Git Bash (MSYS) from rewriting /opt/... into C:/Program Files/Git/opt/...
export MSYS_NO_PATHCONV=1
exec docker exec kafka-lab /opt/kafka/bin/"$@"
