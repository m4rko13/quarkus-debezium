#!/bin/sh
set -e

echo "Waiting for Debezium Connect REST API to be ready..."
until curl -sf http://debezium:8083/connectors; do
  echo "Still waiting for Debezium Connect REST API..."
  sleep 5
done

echo "Waiting for Kafka broker to be ready..."
until nc -z kafka 9092; do
  echo "Still waiting for Kafka..."
  sleep 2
done

# Optional: Prüfen, ob Postgres erreichbar ist
until nc -z postgres 5432; do
  echo "Still waiting for Postgres..."
  sleep 2
done

echo "Registering connector"
curl -X POST http://debezium:8083/connectors \
  -H "Content-Type: application/json" \
  -d @/connector-config.json
echo "Connector registered."
