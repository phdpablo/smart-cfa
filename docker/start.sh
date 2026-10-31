#!/usr/bin/env bash
set -e

# Resolve Compose relative to this script, regardless of the current directory.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
compose_file="$script_dir/docker-compose.yml"

echo "Starting RStudio..."
docker compose -f "$compose_file" up -d

# Wait for RStudio before opening the browser.
ready=false
for ((attempt = 1; attempt <= 60; attempt++)); do
  if docker compose -f "$compose_file" exec -T article curl --max-time 2 -fsS -o /dev/null http://127.0.0.1:8787/ >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 2
done
if [[ "$ready" != true ]]; then
  echo "RStudio did not respond within 120 seconds. Container logs:"
  docker compose -f "$compose_file" logs --tail 50 article
  exit 1
fi

url="http://${RSTUDIO_IP:-127.0.0.1}:8787"
if command -v xdg-open >/dev/null; then
  xdg-open "$url" || echo "Open $url in your browser."
elif command -v open >/dev/null; then
  open "$url" || echo "Open $url in your browser."
else
  echo "Open $url in your browser."
fi
