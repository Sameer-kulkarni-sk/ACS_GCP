# Deploy to Google Kubernetes Engine (GKE)

Complete guide to deploy to GKE from Windows.

## Prerequisites

Make sure you have installed:
- Google Cloud SDK (`gcloud`)
- Docker Desktop
- kubectl
- Node.js 18+

Verify installation:
```powershell
gcloud --version
kubectl version --client
docker --version
npm --version
```

---

## Quick Deploy (Automated Script)

### On Windows (PowerShell)

```powershell
cd C:\Users\Pillai\gcp-compare-project
powershell -ExecutionPolicy Bypass -File deploy-gke.ps1
```

**That's it!** The script will:
1. ✅ Check all prerequisites
2. ✅ Get your GCP project ID
3. ✅ Install npm dependencies
4. ✅ Build Docker image
5. ✅ Push image to Google Container Registry
6. ✅ Create GKE cluster (if needed)
7. ✅ Deploy application with 3 replicas
8. ✅ Set up auto-scaling (3-10 pods)
9. ✅ Show your app's external IP

**Time:** 5-10 minutes (mostly cluster creation)

### What You Get

After deployment:
- ✅ GKE cluster: `gcp-compare-cluster` (3 nodes)
- ✅ Deployment: `gcp-compare-app` (3 replicas, auto-scaling)
- ✅ Service: `gcp-compare-service` (LoadBalancer)
- ✅ External IP: Your app is publicly accessible
- ✅ Auto-scaling: Scales 3-10 pods based on CPU

---

## Manual Deployment (Step by Step)

If you prefer to run commands manually:

### Step 1: Set Variables

```powershell
$PROJECT_ID = gcloud config get-value project
$REGION = "us-central1"
$ZONE = "us-central1-a"
$CLUSTER_NAME = "gcp-compare-cluster"
$IMAGE_NAME = "gcp-compare-app"
$IMAGE_TAG = "1.0"

Write-Host "Project: $PROJECT_ID"
Write-Host "Image: gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
```

### Step 2: Install Dependencies & Build Image

```powershell
# Install npm dependencies
npm install

# Configure Docker
gcloud auth configure-docker

# Build image
docker build -t "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}" .

# Push to registry
docker push "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
```

### Step 3: Create GKE Cluster

```powershell
# Check if cluster exists
gcloud container clusters describe $CLUSTER_NAME --zone $ZONE 2>$null

# If it doesn't exist, create it (takes 5-10 minutes)
gcloud container clusters create $CLUSTER_NAME `
    --num-nodes 3 `
    --zone $ZONE `
    --machine-type n1-standard-1 `
    --enable-autoscaling `
    --min-nodes 3 `
    --max-nodes 10 `
    --enable-stackdriver-kubernetes `
    --quiet
```

### Step 4: Configure kubectl

```powershell
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --quiet
```

### Step 5: Deploy Application

```powershell
# Update image in deployment.yaml
$deploymentFile = "gke/deployment.yaml"
$content = Get-Content $deploymentFile -Raw
$content = $content -replace 'gcr\.io/PROJECT_ID/gcp-compare-app:latest', "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
Set-Content $deploymentFile $content

# Apply manifests
kubectl apply -f gke/service-account.yaml
kubectl apply -f gke/configmap.yaml
kubectl apply -f gke/deployment.yaml

# Wait for deployment
kubectl rollout status deployment/gcp-compare-app --timeout=5m
```

### Step 6: Get Your App URL

```powershell
# Get service details
kubectl get svc gcp-compare-service

# Extract external IP
$EXTERNAL_IP = kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
Write-Host "App URL: http://$EXTERNAL_IP"
```

---

## Check Deployment Status

### View Pods

```powershell
# List all pods
kubectl get pods

# Get pod details
kubectl get pods -o wide

# Describe deployment
kubectl describe deployment gcp-compare-app
```

### View Service

```powershell
kubectl get svc gcp-compare-service

# Detailed service info
kubectl describe svc gcp-compare-service
```

### View Logs

```powershell
# View deployment logs
kubectl logs deployment/gcp-compare-app

# Follow logs (tail -f)
kubectl logs deployment/gcp-compare-app -f

# View specific pod logs
kubectl logs pod/POD_NAME

# View last 50 lines
kubectl logs deployment/gcp-compare-app -n default --tail=50
```

---

## Test Your Application

### Access Your App

Once the external IP is assigned, visit:
```
http://<external-ip>/
http://<external-ip>/health
http://<external-ip>/api/info
http://<external-ip>/api/comparison
http://<external-ip>/api/metrics
```

### Port Forward (Local Testing)

```powershell
# Forward local port 8080 to service
kubectl port-forward svc/gcp-compare-service 8080:80

# Then visit http://localhost:8080
```

### Test with curl

```powershell
$IP = kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test health endpoint
curl "http://$IP/health"

# Test API
curl "http://$IP/api/info" | ConvertFrom-Json

# Test comparison
curl "http://$IP/api/comparison" | ConvertFrom-Json
```

---

## Monitor in Google Cloud Console

### Open Console

```powershell
Start-Process "https://console.cloud.google.com/kubernetes/workloads"
```

### View Workloads

1. Go to **Kubernetes Engine > Workloads**
2. Click `gcp-compare-app`
3. See:
   - ✅ 3/3 Ready pods
   - Pod status: Running
   - Replicas: 3
   - CPU/Memory usage

### View Services

1. Go to **Kubernetes Engine > Services & Ingress**
2. Click `gcp-compare-service`
3. See:
   - Type: LoadBalancer
   - External IP: Your app URL
   - Endpoints: List of pods

### View Logs

1. Go to **Cloud Logging**
2. Filter:
   ```
   resource.type="k8s_container"
   resource.labels.pod_name=~"gcp-compare.*"
   ```
3. View logs in real-time

### View Metrics

1. Go to **Kubernetes Engine > Clusters**
2. Click cluster name
3. See:
   - Node CPU/Memory
   - Pod count
   - Network traffic
   - Disk usage

---

## Common Operations

### Scale Deployment

```powershell
# Scale to 5 replicas
kubectl scale deployment gcp-compare-app --replicas=5

# Verify
kubectl get deployment gcp-compare-app
```

### Update Image

```powershell
# Build new image
docker build -t "gcr.io/$PROJECT_ID/gcp-compare-app:2.0" .
docker push "gcr.io/$PROJECT_ID/gcp-compare-app:2.0"

# Update deployment
kubectl set image deployment/gcp-compare-app app=gcr.io/$PROJECT_ID/gcp-compare-app:2.0

# Check rollout
kubectl rollout status deployment/gcp-compare-app
```

### View Rollout History

```powershell
kubectl rollout history deployment/gcp-compare-app
```

### Rollback to Previous Version

```powershell
kubectl rollout undo deployment/gcp-compare-app
kubectl rollout status deployment/gcp-compare-app
```

---

## Cleanup

### Delete Deployment

```powershell
kubectl delete -f gke/deployment.yaml
kubectl delete -f gke/service-account.yaml
```

### Delete Cluster (Warning: Destructive)

```powershell
# This will DELETE your cluster and all data
gcloud container clusters delete gcp-compare-cluster --zone us-central1-a --quiet
```

---

## Troubleshooting

### Docker Build Failed

```powershell
# Error: "invalid tag" or "invalid reference format"
# Solution: Check PROJECT_ID is set correctly

$PROJECT_ID = & gcloud config get-value project 2>$null
if ([string]::IsNullOrEmpty($PROJECT_ID)) {
    Write-Host "ERROR: Project ID is empty"
    Write-Host "Run: gcloud init"
    exit 1
}

Write-Host "Project: $PROJECT_ID"
```

### kubectl Access Denied

```powershell
# Error: "The connection to the server was refused"
# Solution: Re-configure cluster credentials

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE
```

### Pods Not Starting

```powershell
# Check pod status
kubectl describe pod POD_NAME

# View logs
kubectl logs POD_NAME

# Check for resource issues
kubectl top nodes
kubectl top pods
```

### External IP Pending

```powershell
# Service may take time to get external IP
# Wait and check again
Start-Sleep -Seconds 10
kubectl get svc gcp-compare-service

# If still pending after 5 minutes, check service
kubectl describe svc gcp-compare-service
```

---

## Cost Estimates

**GKE Pricing:**
- 3 n1-standard-1 nodes: ~$100/month
- Storage & Networking: ~$20-50/month
- **Total: ~$120-150/month**

**Reduce Costs:**
- Use preemptible VMs
- Reduce node count
- Use autoscaling efficiently

Check costs:
```powershell
Start-Process "https://console.cloud.google.com/billing/reports"
```

---

## Next Steps

1. ✅ Run: `powershell -ExecutionPolicy Bypass -File deploy-gke.ps1`
2. ✅ Wait for deployment (5-10 minutes)
3. ✅ Get external IP
4. ✅ Visit `http://<external-ip>/`
5. ✅ Monitor in Google Cloud Console
6. ✅ Test endpoints
7. ✅ View logs and metrics

Your GKE cluster is ready! 🚀

