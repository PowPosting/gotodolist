.PHONY: help build run stop clean test deploy

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

run: ## Run application with Docker Compose
	docker-compose up

run-detached: ## Run application in background
	docker-compose up -d

stop: ## Stop running containers
	docker-compose down

restart: ## Restart containers
	docker-compose restart

logs: ## View logs
	docker-compose logs -f

logs-backend: ## View backend logs
	docker-compose logs -f backend

logs-frontend: ## View frontend logs
	docker-compose logs -f frontend

clean: ## Remove containers and images
	docker-compose down -v --rmi all

ps: ## List running containers
	docker-compose ps

shell-backend: ## Open shell in backend container
	docker-compose exec backend sh

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend sh

test: ## Run tests
	@echo "Running backend tests..."
	cd go-server && go test ./...
	@echo "Running frontend tests..."
	cd client && npm test -- --watchAll=false

build-prod: ## Build production images
	docker build -t go-server:prod ./go-server
	docker build -t react-client:prod ./client

deploy-local: build run-detached ## Build and run in background

setup-gcp: ## Setup GCP (run setup-cicd script)
	@if [ "$$OS" = "Windows_NT" ]; then \
		./setup-cicd.bat; \
	else \
		chmod +x setup-cicd.sh && ./setup-cicd.sh; \
	fi

dev-backend: ## Run backend in development mode
	cd go-server && go run main.go

dev-frontend: ## Run frontend in development mode
	cd client && npm start

install-backend: ## Install backend dependencies
	cd go-server && go mod download

install-frontend: ## Install frontend dependencies
	cd client && npm install

install: install-backend install-frontend ## Install all dependencies

# Version Management
version-patch: ## Bump patch version (1.0.0 -> 1.0.1)
	@if [ "$$OS" = "Windows_NT" ]; then \
		./version.bat patch "Patch release"; \
	else \
		chmod +x version.sh && ./version.sh patch "Patch release"; \
	fi

version-minor: ## Bump minor version (1.0.0 -> 1.1.0)
	@if [ "$$OS" = "Windows_NT" ]; then \
		./version.bat minor "Minor release"; \
	else \
		chmod +x version.sh && ./version.sh minor "Minor release"; \
	fi

version-major: ## Bump major version (1.0.0 -> 2.0.0)
	@if [ "$$OS" = "Windows_NT" ]; then \
		./version.bat major "Major release"; \
	else \
		chmod +x version.sh && ./version.sh major "Major release"; \
	fi

version-show: ## Show current version
	@git describe --tags --abbrev=0 2>/dev/null || echo "No version tags yet"

version-list: ## List all version tags
	@git tag -l "v*" --sort=-version:refname

release: ## Create and push release tag
	@echo "Creating release..."
	@git push origin main
	@git push --follow-tags
	@echo "Release pushed! Check GitHub Actions for deployment status."

