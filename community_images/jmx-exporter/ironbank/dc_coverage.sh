#!/bin/bash

set -x
set -e

# Get the JSON file path from the first argument
JSON_PARAMS="$1"

# Print the JSON content
echo "Json params for docker compose coverage:"
cat "$JSON_PARAMS"

# Extract the PROJECT_NAME from the JSON file
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Construct the CONTAINER_NAME
CONTAINER_NAME="${PROJECT_NAME}"-jmx-exporter-1
echo "Container name: ${CONTAINER_NAME}"

# Execute commands inside the container
docker exec -i "${CONTAINER_NAME}" bash -c "/opt/jmx_exporter/commands.sh"

curl http://localhost:12345/metrics
