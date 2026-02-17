# Quick Start Guide

Get up and running in minutes!

## 5-Minute Setup

### Prerequisites Check
```bash
# Verify you have the required tools
gcloud --version
docker --version
npm --version
node --version
```

### Deploy to App Engine (Easiest)

```bash
# Step 1: Initialize Google Cloud
gcloud init
gcloud config set project YOUR_PROJECT_ID

# Step 2: Navigate to project
cd gcp-compare-project

# Step 3: Install dependencies
npm install

# Step 4: Deploy
gcloud app deploy

# Step 5: Open in browser
gcloud app browse
```

That's it! Your app is now live.

---

## 10-Minute Setup

### Deploy to Google Kubernetes Engine (More Control)

```bash
# Step 1: Set variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export CLUSTER_NAME="gcp-compare-cluster"

# Step 2: Build Docker image
docker build -t gcr.io/$PROJECT_ID/gcp-compare-app:1.0 .

# Step 3: Push to registry
gcloud auth configure-docker
docker push gcr.io/$PROJECT_ID/gcp-compare-app:1.0

# Step 4: Create cluster
gcloud container clusters create $CLUSTER_NAME \
  --num-nodes 3 \
  --zone us-central1-a

# Step 5: Deploy application
kubectl apply -f gke/deployment.yaml

# Step 6: Check status
kubectl get services
```

---

## Local Testing (2 Minutes)

```bash
# Install dependencies
npm install

# Run locally
npm run gae:local

# Open browser to
http://localhost:8080
```

---

## Next Steps

1. **Read the Comparison**: [docs/COMPARISON.md](../docs/COMPARISON.md)
2. **Understand Architecture**: [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
3. **View Full Setup Guide**: [docs/SETUP_GUIDE.md](../docs/SETUP_GUIDE.md)
4. **Check API Docs**: [docs/API_REFERENCE.md](../docs/API_REFERENCE.md)

---

## Common Commands

### App Engine

```bash
# View logs
gcloud app logs read

# Browse app
gcloud app browse

# Stop version
gcloud app versions stop VERSION_ID
```

### GKE

```bash
# View pods
kubectl get pods

# View logs
kubectl logs deployment/gcp-compare-app

# Port forward
kubectl port-forward svc/gcp-compare-service 8080:80

# Scale deployment
kubectl scale deployment gcp-compare-app --replicas=5
```

---

## Troubleshooting

### App Engine deployment fails
```bash
# Check quota
gcloud app describe

# Check deployment errors
gcloud app deploy --verbosity=debug
```

### GKE pods not starting
```bash
# Check pod status
kubectl describe pod POD_NAME

# Check logs
kubectl logs POD_NAME

# Delete and redeploy
kubectl delete -f gke/deployment.yaml
kubectl apply -f gke/deployment.yaml
```

### Local app not running
```bash
# Check port is free
netstat -tulpn | grep 8080

# Check Node.js version
node --version

# Check dependencies
npm list
```

---

## Configuration

### Change deployment region (App Engine)
Edit `gae/app.yaml`:
```yaml
runtime: nodejs22
env: standard
```

### Change cluster size (GKE)
Edit `gke/deployment.yaml`:
```yaml
spec:
  replicas: 5  # Change this number
```

---

## Cost Estimates

### App Engine
- Small spike instance: ~$3-5/month
- Regular usage: $50-150/month

### GKE
- Minimum cluster (3 nodes): ~$120/month
- With storage/networking: $150-200/month

---

## Need Help?

1. Check [SETUP_GUIDE.md](../docs/SETUP_GUIDE.md#troubleshooting)
2. Review [ARCHITECTURE.md](../docs/ARCHITECTURE.md)
3. See [API_REFERENCE.md](../docs/API_REFERENCE.md)

---

**Estimated time to live:** 
- App Engine: 2-3 minutes
- GKE: 5-10 minutes
- Local: 1 minute

