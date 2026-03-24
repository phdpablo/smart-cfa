#!/bin/bash

# Pause the RStudio container (does NOT delete it)
# Data inside is preserved. Run start.sh to resume.

echo "⏸️  Pausing RStudio container..."
docker compose -f docker-compose.yml stop

if [ $? -eq 0 ]; then
  echo "✅ Container paused. Your data is preserved."
  echo "   Run './start.sh' to resume your work."
else
  echo "❌ Error stopping container."
  exit 1
fi

exit 0