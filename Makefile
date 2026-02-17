.PHONY: help install dev test build docker-push deploy-gae deploy-gke clean logs monitor

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Variables
PROJECT_ID ?= $(shell gcloud config get-value project)
CLUSTER_NAME ?= gcp-compare-cluster
ZONE ?= us-central1-a
IMAGE_NAME ?= gcp-compare-app
IMAGE_TAG ?= 1.0
REGISTRY ?= gcr.io

help: ## Show this help message
	@echo "$(GREEN)GCP Compare Project - Available Tasks$(NC)"
	@echo "$(YELLOW)make [target]$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make install          # Install dependencies"
	@echo "  make dev              # Run locally"
	@echo "  make build            # Build Docker image"
	@echo "  make deploy-gae       # Deploy to App Engine"
	@echo "  make deploy-gke       # Deploy to GKE"
	@echo "  make clean            # Clean up resources"

install: ## Install dependencies
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	npm install
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

dev: ## Run locally in development mode
	@echo "$(YELLOW)Starting local development server...$(NC)"
	npm run dev

gae-local: ## Run as App Engine locally
	@echo "$(YELLOW)Starting as App Engine...$(NC)"
	npm run gae:local

gke-local: ## Run as GKE locally
	@echo "$(YELLOW)Starting as GKE...$(NC)"
	npm run gke:local

docker-local: ## Run with Docker Compose locally
	@echo "$(YELLOW)Starting with Docker Compose...$(NC)"
	docker-compose up

docker-local-build: ## Build local Docker image
	@echo "$(YELLOW)Building Docker image...$(NC)"
	docker build -t gcp-compare-app:local .
	@echo "$(GREEN)✓ Image built$(NC)"

docker-local-run: docker-local-build ## Run local Docker image
	@echo "$(YELLOW)Running Docker container...$(NC)"
	docker run -p 8080:8080 \
		-e NODE_ENV=development \
		-e PLATFORM=Docker \
		gcp-compare-app:local

test: ## Run tests (placeholder)
	@echo "$(YELLOW)Running tests...$(NC)"
	npm test

lint: ## Lint code
	@echo "$(YELLOW)Linting code...$(NC)"
	npm run lint || echo "No linter configured"

build: ## Build Docker image for production
	@echo "$(YELLOW)Building Docker image for $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG)...$(NC)"
	docker build -t $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "$(GREEN)✓ Image built$(NC)"

docker-push: build ## Push Docker image to Google Container Registry
	@echo "$(YELLOW)Configuring Docker authentication...$(NC)"
	gcloud auth configure-docker
	@echo "$(YELLOW)Pushing image...$(NC)"
	docker push $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "$(GREEN)✓ Image pushed to $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG)$(NC)"

deploy-gae: ## Deploy to Google App Engine
	@echo "$(YELLOW)Deploying to Google App Engine...$(NC)"
	gcloud app deploy --quiet
	@echo "$(GREEN)✓ Deployed to App Engine$(NC)"
	@echo "$(YELLOW)Opening application...$(NC)"
	gcloud app browse

deploy-gke: docker-push ## Deploy to Google Kubernetes Engine
	@echo "$(YELLOW)Deploying to GKE...$(NC)"
	@echo "  Cluster: $(CLUSTER_NAME)"
	@echo "  Zone: $(ZONE)"
	@echo ""
	@echo "$(YELLOW)Getting cluster credentials...$(NC)"
	gcloud container clusters get-credentials $(CLUSTER_NAME) --zone $(ZONE) || \
		(echo "$(YELLOW)Creating cluster...$(NC)" && \
		gcloud container clusters create $(CLUSTER_NAME) \
			--num-nodes 3 \
			--zone $(ZONE) \
			--machine-type n1-standard-1 \
			--enable-autoscaling \
			--min-nodes 3 \
			--max-nodes 10)
	
	@echo "$(YELLOW)Updating manifests...$(NC)"
	sed -i.bak "s|gcr.io/PROJECT_ID/gcp-compare-app:latest|$(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG)|g" gke/deployment.yaml
	
	@echo "$(YELLOW)Applying Kubernetes manifests...$(NC)"
	kubectl apply -f gke/service-account.yaml
	kubectl apply -f gke/configmap.yaml
	kubectl apply -f gke/deployment.yaml
	
	@echo "$(YELLOW)Waiting for deployment...$(NC)"
	kubectl rollout status deployment/gcp-compare-app
	
	@echo "$(GREEN)✓ Deployed to GKE$(NC)"
	@echo ""
	@echo "$(YELLOW)Getting service information...$(NC)"
	@sleep 5
	@kubectl get svc gcp-compare-service

logs-gae: ## View App Engine logs
	@echo "$(YELLOW)Fetching App Engine logs...$(NC)"
	gcloud app logs read -n 50 --follow

logs-gke: ## View GKE logs
	@echo "$(YELLOW)Fetching GKE logs...$(NC)"
	kubectl logs deployment/gcp-compare-app -f

logs-docker: ## View Docker Compose logs
	@echo "$(YELLOW)Fetching Docker Compose logs...$(NC)"
	docker-compose logs -f

monitor-gae: ## Monitor App Engine
	@echo "$(YELLOW)Monitoring App Engine...$(NC)"
	@watch -n 2 'gcloud app versions list'

monitor-gke: ## Monitor GKE
	@echo "$(YELLOW)Monitoring GKE...$(NC)"
	@watch -n 2 'kubectl get pods,svc'

port-forward-gke: ## Port forward GKE service
	@echo "$(YELLOW)Port forwarding to 8080...$(NC)"
	@echo "$(GREEN)Application available at http://localhost:8080$(NC)"
	kubectl port-forward svc/gcp-compare-service 8080:80

describe-gae: ## Show App Engine information
	@echo "$(YELLOW)App Engine Information:$(NC)"
	gcloud app describe
	@echo ""
	@echo "$(YELLOW)Versions:$(NC)"
	gcloud app versions list
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	gcloud app services list

describe-gke: ## Show GKE cluster information
	@echo "$(YELLOW)GKE Cluster Information:$(NC)"
	gcloud container clusters describe $(CLUSTER_NAME) --zone $(ZONE)
	@echo ""
	@echo "$(YELLOW)Nodes:$(NC)"
	kubectl get nodes
	@echo ""
	@echo "$(YELLOW)Pods:$(NC)"
	kubectl get pods -o wide
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	kubectl get services

clean: ## Clean up local resources
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker-compose down || true
	docker rmi gcp-compare-app:local || true
	rm -rf node_modules
	rm -rf .gae/
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-gke: ## Remove GKE deployment
	@echo "$(YELLOW)Removing GKE deployment...$(NC)"
	kubectl delete -f gke/deployment.yaml || true
	kubectl delete -f gke/service-account.yaml || true
	@echo "$(GREEN)✓ GKE deployment removed$(NC)"

delete-gke-cluster: ## Delete entire GKE cluster (WARNING: destructive)
	@echo "$(RED)$(BOLD)WARNING: This will delete the entire cluster!$(NC)"
	@read -p "Continue? [y/N] " confirm && [ "$${confirm}" = "y" ] || exit 1
	@echo "$(YELLOW)Deleting cluster $(CLUSTER_NAME)...$(NC)"
	gcloud container clusters delete $(CLUSTER_NAME) --zone $(ZONE) --quiet
	@echo "$(GREEN)✓ Cluster deleted$(NC)"

validate: ## Validate configuration files
	@echo "$(YELLOW)Validating app.yaml...$(NC)"
	gcloud app describe > /dev/null && echo "$(GREEN)✓ app.yaml valid$(NC)" || echo "$(YELLOW)⚠ app.yaml invalid$(NC)"
	@echo ""
	@echo "$(YELLOW)Validating Kubernetes manifests...$(NC)"
	kubectl apply --dry-run=client -f gke/deployment.yaml > /dev/null && echo "$(GREEN)✓ deployment.yaml valid$(NC)" || echo "$(YELLOW)⚠ deployment.yaml invalid$(NC)"
	kubectl apply --dry-run=client -f gke/service-account.yaml > /dev/null && echo "$(GREEN)✓ service-account.yaml valid$(NC)" || echo "$(YELLOW)⚠ service-account.yaml invalid$(NC)"
	@echo ""
	@echo "$(YELLOW)Validating package.json...$(NC)"
	node -e "require('./package.json')" && echo "$(GREEN)✓ package.json valid$(NC)" || echo "$(YELLOW)⚠ package.json invalid$(NC)"

info: ## Show project information
	@echo "$(GREEN)GCP Compare Project Information$(NC)"
	@echo "=================================="
	@echo "$(YELLOW)Project:$(NC) $(PROJECT_ID)"
	@echo "$(YELLOW)Image:$(NC) $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "$(YELLOW)Cluster:$(NC) $(CLUSTER_NAME)"
	@echo "$(YELLOW)Zone:$(NC) $(ZONE)"
	@echo ""
	@echo "$(YELLOW)Documentation:$(NC)"
	@echo "  - README: ./README.md"
	@echo "  - Comparison: ./docs/COMPARISON.md"
	@echo "  - Setup: ./docs/SETUP_GUIDE.md"
	@echo "  - Architecture: ./docs/ARCHITECTURE.md"
	@echo "  - API: ./docs/API_REFERENCE.md"
	@echo "  - Quick Start: ./docs/QUICKSTART.md"
