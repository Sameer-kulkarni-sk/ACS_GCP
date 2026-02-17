# Deploy to Google Kubernetes Engine (GKE)
# PowerShell script for Windows

Write-Host "========================================" -ForegroundColor Green
Write-Host "Google Kubernetes Engine Deployment" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$tools = @("gcloud", "kubectl", "docker", "npm")
foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "  [OK] $tool" -ForegroundColor Green
    }
    else {
        Write-Host "  [FAIL] $tool is not installed" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Get project ID
$PROJECT_ID = & gcloud config get-value project 2>$null
if ([string]::IsNullOrEmpty($PROJECT_ID)) {
    Write-Host "ERROR: No GCP project configured" -ForegroundColor Red
    Write-Host "Run: gcloud init" -ForegroundColor Yellow
    exit 1
}

$PROJECT_ID = $PROJECT_ID.Trim()
$REGION = "us-central1"
$ZONE = "us-central1-a"
$CLUSTER_NAME = "gcp-compare-cluster"
$IMAGE_NAME = "gcp-compare-app"
$IMAGE_TAG = "1.0"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Project ID:    $PROJECT_ID"
Write-Host "  Region:        $REGION"
Write-Host "  Zone:          $ZONE"
Write-Host "  Cluster:       $CLUSTER_NAME"
Write-Host "  Image:         gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
Write-Host ""

# Install dependencies
Write-Host "Installing Node dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Dependencies installed" -ForegroundColor Green
Write-Host ""

# Configure Docker
Write-Host "Configuring Docker authentication..." -ForegroundColor Yellow
gcloud auth configure-docker --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker configuration failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker configured" -ForegroundColor Green
Write-Host ""

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
Write-Host "  Image: gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}" -ForegroundColor Cyan
docker build -t "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}" .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker image built" -ForegroundColor Green
Write-Host ""

# Push image
Write-Host "Pushing image to Google Container Registry..." -ForegroundColor Yellow
docker push "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker push failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Image pushed" -ForegroundColor Green
Write-Host ""

# Check if cluster exists
Write-Host "Checking GKE cluster..." -ForegroundColor Yellow
$clusterExists = gcloud container clusters describe $CLUSTER_NAME --zone $ZONE 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating GKE cluster..." -ForegroundColor Yellow
    Write-Host "This may take 5-10 minutes..." -ForegroundColor Yellow
    gcloud container clusters create $CLUSTER_NAME `
        --num-nodes 3 `
        --zone $ZONE `
        --machine-type n1-standard-1 `
        --enable-autoscaling `
        --min-nodes 3 `
        --max-nodes 10 `
        --enable-stackdriver-kubernetes `
        --quiet

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Cluster creation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] Cluster created" -ForegroundColor Green
}
else {
    Write-Host "[OK] Cluster already exists" -ForegroundColor Green
}
Write-Host ""

# Get cluster credentials
Write-Host "Configuring kubectl..." -ForegroundColor Yellow
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: kubectl configuration failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] kubectl configured" -ForegroundColor Green
Write-Host ""

# Update manifests with correct image
Write-Host "Updating Kubernetes manifests..." -ForegroundColor Yellow
$deploymentFile = "gke/deployment.yaml"
$content = Get-Content $deploymentFile -Raw
$content = $content -replace 'gcr\.io/PROJECT_ID/gcp-compare-app:latest', "gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
Set-Content $deploymentFile $content
Write-Host "[OK] Manifests updated" -ForegroundColor Green
Write-Host ""

# Apply RBAC
Write-Host "Applying RBAC and Service Account..." -ForegroundColor Yellow
kubectl apply -f gke/service-account.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: RBAC application failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] RBAC configured" -ForegroundColor Green
Write-Host ""

# Apply ConfigMap
Write-Host "Applying ConfigMap..." -ForegroundColor Yellow
kubectl apply -f gke/configmap.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: ConfigMap application failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] ConfigMap created" -ForegroundColor Green
Write-Host ""

# Deploy application
Write-Host "Deploying application to GKE..." -ForegroundColor Yellow
kubectl apply -f gke/deployment.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Deployment failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Application deployed" -ForegroundColor Green
Write-Host ""

# Wait for deployment
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
kubectl rollout status deployment/gcp-compare-app --timeout=5m
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Deployment may still be rolling out" -ForegroundColor Yellow
}
Write-Host "[OK] Deployment ready" -ForegroundColor Green
Write-Host ""

# Get service info
Write-Host "Getting service information..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$services = kubectl get svc gcp-compare-service -o json | ConvertFrom-Json
$externalIp = $services.status.loadBalancer.ingress[0].ip

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Cluster Details:" -ForegroundColor Cyan
Write-Host "  Cluster Name:  $CLUSTER_NAME"
Write-Host "  Zone:          $ZONE"
Write-Host "  Nodes:         3 (auto-scaling 3-10)"
Write-Host ""

Write-Host "Application Details:" -ForegroundColor Cyan
Write-Host "  Deployment:    gcp-compare-app"
Write-Host "  Replicas:      3"
Write-Host "  Image:         gcr.io/$PROJECT_ID/${IMAGE_NAME}:${IMAGE_TAG}"
Write-Host ""

if ([string]::IsNullOrEmpty($externalIp) -or $externalIp -eq "pending") {
    Write-Host "Service IP:    Pending (check back in a moment)" -ForegroundColor Yellow
}
else {
    Write-Host "Service IP:    $externalIp" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access your app at:" -ForegroundColor Cyan
    Write-Host "  http://$externalIp" -ForegroundColor Green
}

Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "  View pods:              kubectl get pods"
Write-Host "  View services:          kubectl get svc"
Write-Host "  View logs:              kubectl logs deployment/gcp-compare-app"
Write-Host "  Follow logs:            kubectl logs deployment/gcp-compare-app -f"
Write-Host "  Port forward:           kubectl port-forward svc/gcp-compare-service 8080:80"
Write-Host "  Describe deployment:    kubectl describe deployment/gcp-compare-app"
Write-Host "  Scale deployment:       kubectl scale deployment gcp-compare-app --replicas=5"
Write-Host "  Update image:           kubectl set image deployment/gcp-compare-app app=gcr.io/$PROJECT_ID/${IMAGE_NAME}:2.0"
Write-Host ""

Write-Host "Console Links:" -ForegroundColor Cyan
Write-Host "  Clusters:     https://console.cloud.google.com/kubernetes/clusters"
Write-Host "  Workloads:    https://console.cloud.google.com/kubernetes/workloads"
Write-Host "  Services:     https://console.cloud.google.com/kubernetes/discovery"
Write-Host "  Logs:         https://console.cloud.google.com/logs"
Write-Host ""

# Offer port forwarding
$portForward = Read-Host "Setup port forwarding to 8080? (y/n)"
if ($portForward -eq "y" -or $portForward -eq "Y") {
    Write-Host ""
    Write-Host "Setting up port forwarding..." -ForegroundColor Yellow
    Write-Host "Application will be available at: http://localhost:8080" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
    kubectl port-forward svc/gcp-compare-service 8080:80
}

