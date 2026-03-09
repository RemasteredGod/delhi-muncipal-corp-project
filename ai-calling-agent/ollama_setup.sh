#!/usr/bin/env bash
# Run this ONCE after `docker compose up --build` to pull the Mistral LLM.
# Usage: bash ollama_setup.sh

CONTAINER=$(docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}" | head -n1)

if [ -z "$CONTAINER" ]; then
  echo "ERROR: Ollama container is not running. Start it first with: docker compose up -d"
  exit 1
fi

echo "Pulling mistral model inside container $CONTAINER ..."
docker exec -it "$CONTAINER" ollama pull mistral
echo "Done. Mistral model is ready."
