#!/usr/bin/env bash
set -e

# Stop without removing the container or its files.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
docker compose -f "$script_dir/docker-compose.yml" stop
echo "Container stopped. Files remain in this container until it is removed or recreated."
echo "Run start.sh to start it again."
