#!/bin/bash
set -e

echo "🚀 Quarkus Debezium Demo Setup (Containerized)"
echo "=============================================="

# Check if running with sudo for docker commands
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script requires sudo for Docker commands"
    echo "   Please run: sudo ./setup.sh"
    echo ""
    echo "   Alternative: Add user to docker group first:"
    echo "   sudo usermod -aG docker $USER && newgrp docker"
    exit 1
fi

# Check prerequisites - only Docker needed now!
echo "1️⃣ Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is required but not available"
    exit 1
fi

echo "✅ Prerequisites met (Docker only!)"

# Stop any existing services and clean
echo ""
echo "2️⃣ Cleaning up existing setup..."
docker compose down 2>/dev/null || true

# Build and start services
echo ""
echo "3️⃣ Building and starting all services (including Java build)..."
echo "   This may take a few minutes on first run..."
docker compose up -d --build

echo ""
echo "4️⃣ Waiting for services to start..."
echo "   This may take 60-90 seconds..."

# Wait for PostgreSQL
echo -n "   PostgreSQL: "
for i in {1..30}; do
    if docker compose exec postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo "✅"
        break
    fi
    sleep 2
    if [ $i -eq 30 ]; then echo "❌ Timeout"; exit 1; fi
done

# Wait for Kafka
echo -n "   Kafka: "
for i in {1..30}; do
    if docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
        echo "✅"
        break
    fi
    sleep 3
    if [ $i -eq 30 ]; then echo "❌ Timeout"; exit 1; fi
done

# Wait for Debezium
echo -n "   Debezium: "
for i in {1..60}; do
    if curl -sf http://localhost:8083/connectors >/dev/null 2>&1; then
        echo "✅"
        break
    fi
    sleep 3
    if [ $i -eq 60 ]; then echo "❌ Timeout"; exit 1; fi
done

# Wait for Quarkus App (more generous timeout for first build)
echo -n "   Quarkus App: "
for i in {1..120}; do
    if curl -sf http://localhost:8081/q/health >/dev/null 2>&1 || curl -sf http://localhost:8081/ >/dev/null 2>&1; then
        echo "✅"
        break
    fi
    sleep 3
    if [ $i -eq 120 ]; then 
        echo "❌ Timeout"
        echo ""
        echo "🐛 Quarkus logs:"
        docker compose logs --tail 15 quarkus-app
        echo ""
        echo "ℹ️  App might be running - try: curl http://localhost:8081/order"
        break
    fi
done

# Setup Debezium Connector
echo ""
echo "5️⃣ Setting up Debezium connector..."
sleep 10

connector_status=$(curl -s http://localhost:8083/connectors/simple-connector/status 2>/dev/null | jq -r '.connector.state' 2>/dev/null || echo "NOT_FOUND")

if [ "$connector_status" != "RUNNING" ]; then
    echo "   Creating Debezium connector..."
    response=$(curl -s -w "%{http_code}" -X POST http://localhost:8083/connectors \
      -H "Content-Type: application/json" \
      -d '{
        "name": "simple-connector",
        "config": {
          "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
          "tasks.max": "1",
          "database.hostname": "postgres",
          "database.port": "5432",
          "database.user": "postgres",
          "database.password": "postgres",
          "database.dbname": "postgres",
          "database.server.name": "pgserver1",
          "slot.name": "debezium_simple",
          "plugin.name": "pgoutput",
          "table.include.list": "public.outboxevent",
          "key.converter": "org.apache.kafka.connect.json.JsonConverter",
          "key.converter.schemas.enable": "false",
          "value.converter": "org.apache.kafka.connect.json.JsonConverter",
          "value.converter.schemas.enable": "false",
          "snapshot.mode": "initial",
          "topic.prefix": "simple"
        }
      }')
    
    http_code=$(echo "$response" | tail -c 4 | head -c 3)
    if [ "$http_code" = "201" ]; then
        echo "✅ Connector created successfully"
    else
        echo "⚠️  Connector creation returned HTTP $http_code"
        echo "   Full response: $response"
    fi
else
    echo "✅ Connector already running"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Services running on:"
echo "   • Quarkus App:    http://localhost:8081"
echo "   • Kafka UI:       http://localhost:8080" 
echo "   • Debezium API:   http://localhost:8083"
echo "   • PostgreSQL:     localhost:5432"
echo ""
echo "💡 No local Java/Maven installation required!"
echo "   Everything runs in Docker containers."
echo ""
echo "🧪 Run the demo test:"
echo "   ./test.sh"
echo ""