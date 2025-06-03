#!/bin/sh
set -e

echo "Waiting for Debezium Connect REST API to be ready..."
for i in $(seq 1 30); do
  if curl -sf http://debezium:8083/connectors > /dev/null 2>&1; then
    echo "Debezium Connect is ready!"
    break
  fi
  echo "Still waiting for Debezium Connect REST API... (attempt $i/30)"
  sleep 10
done

# Wait a bit more to ensure all plugins are loaded
echo "Waiting for plugins to be loaded..."
sleep 15

# Check if connector already exists
if curl -sf http://debezium:8083/connectors/outbox-connector > /dev/null 2>&1; then
  echo "Connector 'outbox-connector' already exists. Skipping registration."
  exit 0
fi

echo "Registering outbox connector..."
response=$(curl -s -w "%{http_code}" -X POST http://debezium:8083/connectors \
  -H "Content-Type: application/json" \
  -d @/connector-config.json)

http_code=$(echo "$response" | tail -c 3)
body=$(echo "$response" | sed '$s/...$//')

if [ "$http_code" = "201" ] || [ "$http_code" = "409" ]; then
  echo "Connector registered successfully or already exists."
  echo "Response: $body"
else
  echo "Failed to register connector. HTTP Code: $http_code"
  echo "Response: $body"
  exit 1
fi

echo "Connector registration completed."
