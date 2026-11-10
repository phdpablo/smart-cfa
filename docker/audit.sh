#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
command -v docker >/dev/null || { echo "Install Docker before running this script." >&2; exit 1; }
docker info >/dev/null
docker compose version >/dev/null
mkdir -p "$script_dir/../docs"
export AUDIT_UID="$(id -u)"
export AUDIT_GID="$(id -g)"
docker compose -f "$script_dir/docker-compose.yml" run --rm --no-deps --pull missing audit
