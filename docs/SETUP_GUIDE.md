# Setup and Deployment Guide

This guide provides step-by-step instructions for deploying the GCP Compare Project to both Google App Engine and Google Kubernetes Engine.

## Prerequisites

### Required Tools
- Google Cloud SDK (`gcloud`)
- Docker
- kubectl (for GKE)
- Node.js 18+
- Git

### Installation
```bash
# Install Google Cloud SDK
# Windows: https://cloud.google.com/sdk/docs/install
# macOS: brew install google-cloud-sdk
# Linux: https://cloud.google.com/sdk/docs/install

# Initialize gcloud
gcloud init

# Set your project
gcloud config set project PROJECT_ID
```

## Google App Engine Deployment

### Step 1: Prepare Your Application

```bash
# Navigate to project directory
cd gcp-compare-project

# Install dependencies
npm install

# Test locally
npm run gae:local
# Visit http://localhost:8080
```

### Step 2: Create App Engine Application

```bash
# Create new App Engine app (first time only)
gcloud app create --region=us-central

# View available regions
gcloud app regions list
```

### Step 3: Deploy to App Engine

```bash
# Deploy the application
gcloud app deploy

# View deployment status
gcloud app describe

# Open application in browser
gcloud app browse

# View logs
gcloud app logs read -n 50

# Check traffic splitting (for canary deployments)
gcloud app describe --summarize
```

### Step 4: Manage App Engine

```bash
# View all services
gcloud app services list

# View all versions
gcloud app versions list

# View instances
gcloud app instances list

# Stop a version
gcloud app versions stop VERSION_ID

# Delete a version
gcloud app versions delete VERSION_ID

# View traffic splitting
gcloud app services describe default
```

### Step 5: Monitoring and Debugging

```bash
# View logs
gcloud app logs read

# Filter logs by service
gcloud app logs read --service=default

# Follow logs (tail)
gcloud app logs read -n 50 --follow

# Export logs to Cloud Logging
gcloud logging sinks list

# View metrics in Cloud Console
# https://console.cloud.google.com/appengine/metrics
```

### Step 6: Update Application

```bash
# Make code changes
# Update version in package.json

# Deploy new version
gcloud app deploy

# Monitor deployment
gcloud app versions list
```

## Google Kubernetes Engine Deployment

### Step 1: Prepare Your Application

```bash
# Navigate to project directory
cd gcp-compare-project

# Install dependencies
npm install

# Test locally
npm run gke:local
# Visit http://localhost:8080
```

### Step 2: Build Docker Image

```bash
# Configure Docker authentication
gcloud auth configure-docker

# Set your project ID
PROJECT_ID=$(gcloud config get-value project)

# Build image
docker build -t gcr.io/$PROJECT_ID/gcp-compare-app:1.0 .

# Test image locally
docker run -p 8080:8080 gcr.io/$PROJECT_ID/gcp-compare-app:1.0

# Push image to Google Container Registry
docker push gcr.io/$PROJECT_ID/gcp-compare-app:1.0
```

### Step 3: Create GKE Cluster

```bash
# Set cluster variables
CLUSTER_NAME="gcp-compare-cluster"
REGION="us-central1"
ZONE="us-central1-a"

# Create standard cluster
gcloud container clusters create $CLUSTER_NAME \
  --num-nodes 3 \
  --zone $ZONE \
  --machine-type n1-standard-1 \
  --enable-autoscaling \
  --min-nodes 3 \
  --max-nodes 10 \
  --enable-stackdriver-kubernetes \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver

# Or use regional cluster for high availability
gcloud container clusters create $CLUSTER_NAME \
  --region $REGION \
  --num-nodes 2 \
  --machine-type n1-standard-1 \
  --enable-autoscaling \
  --min-nodes 2 \
  --max-nodes 10

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE
# or for regional:
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION
```

### Step 4: Update Deployment Manifest

```bash
# Edit deployment.yaml and update IMAGE field
# Replace: gcr.io/PROJECT_ID/gcp-compare-app:latest
# With: gcr.io/<your-project-id>/gcp-compare-app:1.0

sed -i "s/gcr.io\/PROJECT_ID/gcr.io\/$PROJECT_ID/g" gke/deployment.yaml
```

### Step 5: Deploy to GKE

```bash
# Apply RBAC and service account
kubectl apply -f gke/service-account.yaml

# Apply configuration
kubectl apply -f gke/configmap.yaml

# Deploy application
kubectl apply -f gke/deployment.yaml

# Check deployment status
kubectl rollout status deployment/gcp-compare-app

# View pods
kubectl get pods
kubectl get pods -w  # Watch pods

# View services
kubectl get svc

# View external IP (wait for assignment)
kubectl get service gcp-compare-service
```

### Step 6: Verify Deployment

```bash
# Get service external IP
EXTERNAL_IP=$(kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test application
curl http://$EXTERNAL_IP
curl http://$EXTERNAL_IP/health
curl http://$EXTERNAL_IP/api/info
curl http://$EXTERNAL_IP/api/comparison

# View logs
kubectl logs deployment/gcp-compare-app
kubectl logs deployment/gcp-compare-app -f  # Follow logs
kubectl logs pod/POD_NAME

# Port forward for local testing
kubectl port-forward svc/gcp-compare-service 8080:80
# Visit http://localhost:8080
```

### Step 7: Configure Ingress (Optional)

```bash
# Apply ingress configuration
kubectl apply -f gke/ingress.yaml

# Check ingress status
kubectl get ingress

# Get ingress IP
kubectl get ingress gcp-compare-ingress

# DNS configuration
# Point your domain to the ingress IP
```

### Step 8: Monitor GKE Cluster

```bash
# View cluster info
gcloud container clusters describe $CLUSTER_NAME --zone $ZONE

# View cluster nodes
kubectl get nodes
kubectl describe nodes

# View resource usage
kubectl top nodes
kubectl top pods

# View events
kubectl get events
kubectl describe pod POD_NAME

# View metrics
# https://console.cloud.google.com/kubernetes/workload
```

### Step 9: Update Application on GKE

```bash
# Make code changes

# Build new image
docker build -t gcr.io/$PROJECT_ID/gcp-compare-app:2.0 .

# Push image
docker push gcr.io/$PROJECT_ID/gcp-compare-app:2.0

# Update deployment
kubectl set image deployment/gcp-compare-app \
  app=gcr.io/$PROJECT_ID/gcp-compare-app:2.0

# Or update deployment.yaml and apply:
kubectl apply -f gke/deployment.yaml

# Monitor rolling update
kubectl rollout status deployment/gcp-compare-app
kubectl rollout history deployment/gcp-compare-app

# Rollback if needed
kubectl rollout undo deployment/gcp-compare-app
```

### Step 10: Cleanup GKE

```bash
# Delete service and deployment
kubectl delete -f gke/deployment.yaml
kubectl delete -f gke/service-account.yaml

# Delete cluster
gcloud container clusters delete $CLUSTER_NAME --zone $ZONE
```

## Local Development

### Running Locally

```bash
# Install dependencies
npm install

# Run as GAE
npm run gae:local

# Or run as GKE simulation
npm run gke:local

# Run in development mode
npm run dev

# Run tests
npm test
```

### Testing the Application

```bash
# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/api/info
curl http://localhost:8080/api/comparison
curl http://localhost:8080/api/metrics
```

## Troubleshooting

### App Engine Issues

```bash
# View detailed logs
gcloud app logs read -n 100 --service=default

# Check deployment errors
gcloud app deploy --verbosity=debug

# Verify app.yaml configuration
cat app.yaml

# Check instance health
gcloud app versions describe VERSION_ID

# SSH into instance (flexible env only)
gcloud app instances describe INSTANCE_ID
```

### GKE Issues

```bash
# Check pod status
kubectl describe pod POD_NAME

# View pod logs
kubectl logs POD_NAME
kubectl logs POD_NAME -c container-name

# Check deployment status
kubectl describe deployment gcp-compare-app

# Check service
kubectl describe service gcp-compare-service

# Check ingress
kubectl describe ingress gcp-compare-ingress

# View events
kubectl get events --sort-by='.lastTimestamp'

# Debug connectivity
kubectl exec -it POD_NAME -- /bin/bash
kubectl port-forward svc/gcp-compare-service 8080:80
```

## Performance Optimization

### App Engine
- Use min_instances to reduce cold starts
- Enable caching headers
- Optimize code for fast execution

### GKE
- Right-size resource requests/limits
- Use proper health checks
- Configure proper autoscaling thresholds
- Use cluster autoscaling

## Security Best Practices

### App Engine
- Use virtual service accounts
- Enable HTTPS enforcement
- Set security headers
- Use Cloud IAM for access control

### GKE
- Use Network Policies for pod-to-pod communication
- Use Pod Security Policies
- Enable RBAC
- Use private clusters
- Regular security scanning

## Cost Optimization

### App Engine
- Set appropriate resource limits
- Use App Engine Standard for variable workloads
- Enable caching

### GKE
- Use Preemptible VMs for non-critical workloads
- Right-size node pools
- Use cluster autoscaling
- Monitor resource utilization
- Use GKE cost optimization recommendations

## Additional Resources

- [App Engine Documentation](https://cloud.google.com/appengine/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Container Registry Documentation](https://cloud.google.com/container-registry/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
