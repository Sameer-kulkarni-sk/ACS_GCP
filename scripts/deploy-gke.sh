#!/bin/bash

# Google Kubernetes Engine Deployment Script
# This script automates the deployment process to GKE

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Google Kubernetes Engine Deployment${NC}"
echo -e "${GREEN}========================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: docker is not installed${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: Could not get GCP project ID${NC}"
    echo -e "${YELLOW}Run: gcloud init${NC}"
    exit 1
fi

REGION="us-central1"
ZONE="us-central1-a"
CLUSTER_NAME="gcp-compare-cluster"
IMAGE_NAME="gcp-compare-app"
IMAGE_TAG="1.0"

echo -e "\n${YELLOW}Configuration:${NC}"
echo -e "  Project ID:    ${PROJECT_ID}"
echo -e "  Region:        ${REGION}"
echo -e "  Zone:          ${ZONE}"
echo -e "  Cluster:       ${CLUSTER_NAME}"
echo -e "  Image:         gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}"

# Install dependencies
echo -e "\n${YELLOW}Installing Node dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Configure Docker
echo -e "\n${YELLOW}Configuring Docker authentication...${NC}"
gcloud auth configure-docker --quiet
echo -e "${GREEN}✓ Docker configured${NC}"

# Build Docker image
echo -e "\n${YELLOW}Building Docker image...${NC}"
docker build -t gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG} .
echo -e "${GREEN}✓ Docker image built${NC}"

# Push image
echo -e "\n${YELLOW}Pushing image to Google Container Registry...${NC}"
docker push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}
echo -e "${GREEN}✓ Image pushed${NC}"

# Check if cluster exists
echo -e "\n${YELLOW}Checking GKE cluster...${NC}"
if ! gcloud container clusters describe ${CLUSTER_NAME} --zone ${ZONE} &> /dev/null; then
    echo -e "${YELLOW}Creating GKE cluster...${NC}"
    gcloud container clusters create ${CLUSTER_NAME} \
        --num-nodes 3 \
        --zone ${ZONE} \
        --machine-type n1-standard-1 \
        --enable-autoscaling \
        --min-nodes 3 \
        --max-nodes 10 \
        --enable-stackdriver-kubernetes \
        --quiet
    echo -e "${GREEN}✓ Cluster created${NC}"
else
    echo -e "${GREEN}✓ Cluster already exists${NC}"
fi

# Get cluster credentials
echo -e "\n${YELLOW}Configuring kubectl...${NC}"
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --quiet
echo -e "${GREEN}✓ kubectl configured${NC}"

# Update manifests with correct image
echo -e "\n${YELLOW}Updating Kubernetes manifests...${NC}"
sed -i.bak "s|gcr.io/PROJECT_ID/gcp-compare-app:latest|gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}|g" gke/deployment.yaml
echo -e "${GREEN}✓ Manifests updated${NC}"

# Apply RBAC
echo -e "\n${YELLOW}Applying RBAC and Service Account...${NC}"
kubectl apply -f gke/service-account.yaml
echo -e "${GREEN}✓ RBAC configured${NC}"

# Apply ConfigMap
echo -e "\n${YELLOW}Applying ConfigMap...${NC}"
kubectl apply -f gke/configmap.yaml
echo -e "${GREEN}✓ ConfigMap created${NC}"

# Deploy application
echo -e "\n${YELLOW}Deploying application to GKE...${NC}"
kubectl apply -f gke/deployment.yaml
echo -e "${GREEN}✓ Application deployed${NC}"

# Wait for deployment
echo -e "\n${YELLOW}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/gcp-compare-app
echo -e "${GREEN}✓ Deployment ready${NC}"

# Get service info
echo -e "\n${YELLOW}Getting service information...${NC}"
sleep 5
EXTERNAL_IP=$(kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending...")

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${BLUE}Cluster Details:${NC}"
echo -e "  Cluster Name:  ${CLUSTER_NAME}"
echo -e "  Zone:          ${ZONE}"
echo -e "  Nodes:         3 (auto-scaling 3-10)"

echo -e "\n${BLUE}Application Details:${NC}"
echo -e "  Deployment:    gcp-compare-app"
echo -e "  Replicas:      3"
echo -e "  Image:         gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
echo -e "  Service IP:    ${EXTERNAL_IP}"

echo -e "\n${YELLOW}Useful commands:${NC}"
echo "  View pods:              kubectl get pods"
echo "  View services:          kubectl get svc"
echo "  View logs:              kubectl logs deployment/gcp-compare-app"
echo "  Follow logs:            kubectl logs deployment/gcp-compare-app -f"
echo "  Port forward:           kubectl port-forward svc/gcp-compare-service 8080:80"
echo "  Describe deployment:    kubectl describe deployment/gcp-compare-app"
echo "  Scale deployment:       kubectl scale deployment gcp-compare-app --replicas=5"
echo "  Update image:           kubectl set image deployment/gcp-compare-app app=gcr.io/${PROJECT_ID}/${IMAGE_NAME}:2.0"
echo "  Rollout status:         kubectl rollout status deployment/gcp-compare-app"
echo "  Rollback:               kubectl rollout undo deployment/gcp-compare-app"

if [[ "${EXTERNAL_IP}" != "Pending..." ]]; then
    echo -e "\n${GREEN}Application URL: http://${EXTERNAL_IP}${NC}"
else
    echo -e "\n${YELLOW}External IP is pending. Run 'kubectl get svc' to check status.${NC}"
fi

# Ask if user wants to port forward
read -p "Setup port forwarding to 8080? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setting up port forwarding...${NC}"
    echo -e "${GREEN}Application will be available at http://localhost:8080${NC}"
    kubectl port-forward svc/gcp-compare-service 8080:80
fi
