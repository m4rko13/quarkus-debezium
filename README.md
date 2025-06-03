# 🚀 Quarkus Debezium Demo

A complete demonstration of **Event-Driven Architecture** using Quarkus and Debezium for Change Data Capture (CDC).

## ⚡ Quick Start

### Two-Command Setup
```bash
# 1. Setup everything (requires sudo for Docker)
sudo ./setup.sh

# 2. Test the demo
./test.sh
```

That's it! 🎉

### What This Demo Shows

This project demonstrates how to implement the **Outbox Pattern** with:
- **Quarkus** REST API for order management  
- **Debezium** for Change Data Capture
- **Kafka** for event streaming
- **PostgreSQL** with Write-Ahead Logging

### Architecture Flow
```
[POST /order] → [Order Entity] → [CDI Event] → [OutboxEvent Table] → [Debezium CDC] → [Kafka Topic]
```

## 📋 Prerequisites

- **Docker & Docker Compose**
- **Java 21+**
- **Maven 3.8+**

## 🧪 What The Test Shows

The `./test.sh` script verifies:
- ✅ **Order API** creates orders via REST
- ✅ **CDI Events** trigger OutboxEvent records  
- ✅ **Debezium CDC** captures database changes
- ✅ **Kafka Topics** receive event messages
- ✅ **Complete event flow** verification

## 🖥️ Services & Ports

| Service | URL | Purpose |
|---------|-----|---------|
| **Quarkus API** | http://localhost:8081 | Order management REST API |
| **Kafka UI** | http://localhost:8080 | Kafka topics and messages |
| **Debezium API** | http://localhost:8083 | Connector management |
| **PostgreSQL** | localhost:5432 | Database (postgres/postgres) |

## 📋 Manual Testing

### Create Orders via API
```bash
curl -X POST http://localhost:8081/order \
  -H "Content-Type: application/json" \
  -d '{"number":"ORDER-001","customerId":"CUSTOMER-123"}'
```

### View Kafka Messages
```bash
sudo docker compose exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic simple.public.outboxevent \
  --from-beginning
```

### Check Database Events
```bash
sudo docker compose exec postgres psql -U postgres -d postgres \
  -c "SELECT id, aggregatetype, aggregateid, type FROM outboxevent;"
```

## 🏗️ How It Works

### 1. Order Creation
- REST API receives POST request
- `OrderService` persists `Order` entity  
- CDI event `OrderCreatedEvent` is fired

### 2. Outbox Pattern
- `ManualOutboxService` observes CDI events
- Writes event data to `outboxevent` table
- All within same database transaction

### 3. Change Data Capture
- Debezium connector monitors PostgreSQL WAL
- Detects changes in `outboxevent` table
- Publishes events to Kafka topics

### 4. Event Streaming
- Events appear in `simple.public.outboxevent` topic
- Can be consumed by downstream services
- Enables event-driven microservices architecture

## 📁 Project Structure

```
src/main/java/org/acme/
   Order.java                  # JPA Entity
   OrderService.java           # Business logic with CDI events
   OrderResource.java          # REST endpoints
   OrderCreatedEvent.java      # Outbox event implementation
   OrderRepository.java        # Data access
   ManualOutboxService.java    # Manual outbox implementation
src/main/resources/
   application.properties      # Local development config
   application-docker.properties # Docker environment config
   application-dev.properties  # Development overrides
   import.sql                  # OutboxEvent table creation
docker-compose.yml             # Complete infrastructure
setup.sh                       # One-command setup
test.sh                        # Comprehensive demo test
```

## 🔧 Troubleshooting

### Services Not Starting
```bash
# Check service status
sudo docker compose ps

# View logs
sudo docker compose logs quarkus-app
sudo docker compose logs debezium

# Restart everything
sudo docker compose down
sudo ./setup.sh
```

### No Kafka Messages
```bash
# Check connector status
curl http://localhost:8083/connectors/simple-connector/status

# Check outbox table has records
sudo docker compose exec postgres psql -U postgres -d postgres \
  -c "SELECT COUNT(*) FROM outboxevent;"
```

## 🔄 Development Workflow

### Local Development (without Docker)
```bash
# Start only infrastructure
sudo docker compose up -d postgres kafka zookeeper debezium

# Run Quarkus in dev mode
./mvnw quarkus:dev
```

### Configuration Profiles
- **default**: Local development with localhost connections
- **docker**: Container environment with service names  
- **dev**: Development overrides

## ✨ Key Features Demonstrated

✅ **Outbox Pattern** - Reliable event publishing  
✅ **Change Data Capture** - Database-driven events  
✅ **Event-Driven Architecture** - Microservices communication  
✅ **Transactional Consistency** - Events and data in sync  
✅ **Kafka Integration** - Scalable event streaming  
✅ **Docker Compose** - Complete local environment  

## 🧹 Cleanup

```bash
# Stop all services
sudo docker compose down

# Remove volumes (deletes data)
sudo docker compose down -v
```

## 🛠️ Technologies Used

- **[Quarkus](https://quarkus.io/)** - Supersonic Subatomic Java
- **[Debezium](https://debezium.io/)** - Change Data Capture platform
- **[Apache Kafka](https://kafka.apache.org/)** - Event streaming platform
- **[PostgreSQL](https://postgresql.org/)** - Database with logical replication
- **[Docker Compose](https://docs.docker.com/compose/)** - Multi-container orchestration

---

🎉 **Happy Event Streaming!** This demo provides a solid foundation for building event-driven microservices with Quarkus and Debezium.