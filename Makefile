# Quarkus Debezium Demo - Containerized Development

.PHONY: help build start stop clean logs test

help: ## Show this help message
	@echo "Quarkus Debezium Demo - Containerized Commands"
	@echo "============================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build all Docker images
	docker compose build

start: ## Start all services (includes building if needed)
	sudo ./setup.sh

stop: ## Stop all services
	docker compose down

clean: ## Stop services and remove all containers, networks, images
	docker compose down --rmi all --volumes --remove-orphans
	docker system prune -f

logs: ## Show logs from all services
	docker compose logs -f

logs-app: ## Show logs from Quarkus application only
	docker compose logs -f quarkus-app

test: ## Run the demo test
	./test.sh

dev: ## Start services in development mode with live reload
	@echo "Starting development environment..."
	@echo "Note: Code changes require container rebuild in this setup"
	$(MAKE) start

status: ## Show status of all services
	docker compose ps

restart: ## Restart all services
	docker compose restart

rebuild: ## Force rebuild and restart all services
	docker compose down
	docker compose up -d --build

shell-app: ## Open shell in Quarkus application container
	docker compose exec quarkus-app /bin/bash

shell-postgres: ## Open PostgreSQL shell
	docker compose exec postgres psql -U postgres -d postgres