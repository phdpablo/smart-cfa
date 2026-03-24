#!/bin/bash

# Start or resume the RStudio container
# If paused, resumes with all data intact
# If new, creates and waits for initialization (~15 seconds for LaTeX sync on first run)

echo "🚀 Starting RStudio..."

# Start/resume container (will resume if paused, create if doesn't exist)
docker compose -f docker-compose.yml up -d

echo "✅ Container starting. Waiting about 30 seconds for RStudio to be ready..."
sleep 30

# Open the RStudio URL in the default web browser
if command -v xdg-open > /dev/null; then
  xdg-open "http://127.0.0.1:8787"
elif command -v open > /dev/null; then
  open "http://127.0.0.1:8787"
elif command -v start > /dev/null; then
  start "http://127.0.0.1:8787"
else
  echo "⚠️  Could not open browser. Please visit http://127.0.0.1:8787 manually."
fi

exit 0
