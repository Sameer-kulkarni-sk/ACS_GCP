# ✅ GKE Deployment Fixed

## Problem Identified

When running `bash scripts/deploy-gke.sh` on Windows, you got:
```
ERROR: failed to build: invalid tag "gcr.io//gcp-compare-app:1.0"
```

**Root Cause:** The `PROJECT_ID` variable was empty because:
1. Windows PowerShell was running the bash script
2. The gcloud command to fetch PROJECT_ID returned whitespace/newline
3. The variable didn't get properly trimmed

---

## What Was Fixed

### 1. **Created Windows PowerShell Script** ✅
- **File:** `deploy-gke.ps1` (new)
- **Features:**
  - Proper Windows path handling
  - Correctly fetches and trims PROJECT_ID
  - Better error checking
  - Color-coded output
  - Prompts to port-forward at end
  - Works on Windows PowerShell

### 2. **Fixed Bash Script** ✅
- **File:** `scripts/deploy-gke.sh` (updated)
- **Changes:**
  - Added `tr -d '[:space:]'` to remove whitespace from PROJECT_ID
  - Added error checking for empty PROJECT_ID
  - Better error messages

### 3. **Created Comprehensive GKE Guide** ✅
- **File:** `docs/GKE_DEPLOYMENT.md` (new)
- **Includes:**
  - Quick deploy with PowerShell script
  - Step-by-step manual deployment
  - Troubleshooting section
  - Cost estimates
  - Common operations

### 4. **Updated Deployment Guide** ✅
- **File:** `docs/DEPLOY_AND_MONITOR.md` (updated)
- **Changes:**
  - Now recommends PowerShell script for Windows
  - Clear distinction between Windows and Linux/macOS

---

## Deploy to GKE Now

### On Windows (Recommended)

```powershell
cd C:\Users\Pillai\gcp-compare-project
powershell -ExecutionPolicy Bypass -File deploy-gke.ps1
```

**The script will:**
1. ✅ Check prerequisites (gcloud, kubectl, docker, npm)
2. ✅ Get your GCP project ID
3. ✅ Install npm dependencies
4. ✅ Configure Docker
5. ✅ Build Docker image
6. ✅ Push to Google Container Registry
7. ✅ Create GKE cluster (takes ~5-10 minutes on first run)
8. ✅ Configure kubectl
9. ✅ Deploy application with 3 replicas
10. ✅ Set up auto-scaling (3-10 pods)
11. ✅ Show your app's external IP
12. ✅ Optionally set up port forwarding

### On Linux/macOS

```bash
bash scripts/deploy-gke.sh
```

---

## What You Get

After successful deployment:

### 🎯 GKE Cluster
- **Name:** `gcp-compare-cluster`
- **Nodes:** 3 (auto-scaling available)
- **Region:** us-central1
- **Zone:** us-central1-a

### 📦 Deployment
- **Name:** `gcp-compare-app`
- **Replicas:** 3 pods
- **Auto-scaling:** 3-10 pods
- **Image:** `gcr.io/YOUR-PROJECT/gcp-compare-app:1.0`

### ⚙️ Service
- **Name:** `gcp-compare-service`
- **Type:** LoadBalancer
- **External IP:** Your public app URL
- **Port:** 80

---

## Monitor Your Deployment

### In Google Cloud Console

```powershell
# Open Workloads
Start-Process "https://console.cloud.google.com/kubernetes/workloads"

# Open Logs
Start-Process "https://console.cloud.google.com/logs"
```

**What to see:**
- ✅ Workload: `gcp-compare-app` with 3/3 Ready pods
- ✅ Service: `gcp-compare-service` with external IP
- ✅ All pods showing: Status = Running
- ✅ Logs being captured in real-time

### From Terminal

```powershell
# View pods
kubectl get pods

# View services
kubectl get svc

# View logs
kubectl logs deployment/gcp-compare-app -f

# View metrics
kubectl top pods
kubectl top nodes
```

---

## Test Your App

### Get External IP

```powershell
$IP = kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
Write-Host "App URL: http://$IP"
```

### Test Endpoints

```powershell
# Visit in browser
http://<external-ip>/
http://<external-ip>/health
http://<external-ip>/api/info
http://<external-ip>/api/comparison

# Or test with curl
curl http://<external-ip>/health
```

---

## Useful Commands

```powershell
# View all pods
kubectl get pods

# View specific pod logs
kubectl logs pod/POD_NAME

# Follow logs live
kubectl logs deployment/gcp-compare-app -f

# Port forward to local machine
kubectl port-forward svc/gcp-compare-service 8080:80

# Scale deployment
kubectl scale deployment gcp-compare-app --replicas=5

# Update image (after building new version)
kubectl set image deployment/gcp-compare-app app=gcr.io/PROJECT_ID/gcp-compare-app:2.0

# Rollback to previous version
kubectl rollout undo deployment/gcp-compare-app
```

---

## Troubleshooting

### "docker: command not found"
```
Install Docker Desktop from docker.com
```

### "kubectl: command not found"
```
Install kubectl with: gcloud components install kubectl
```

### "invalid tag" error
```
Means PROJECT_ID is empty - make sure gcloud is properly configured
Run: gcloud init
```

### External IP stuck on "pending"
```
Wait 2-3 minutes and check again
kubectl get svc gcp-compare-service
```

---

## Cost Estimate

**Running this setup:**
- 3 n1-standard-1 nodes: ~$100/month
- Storage & networking: ~$20-50/month
- **Total: ~$120-150/month**

**Use free tier:** Stop cluster when not in use:
```powershell
gcloud container clusters delete gcp-compare-cluster --zone us-central1-a
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| **deploy-gke.ps1** | PowerShell deployment script (Windows) |
| **scripts/deploy-gke.sh** | Bash deployment script (Linux/macOS) |
| **docs/GKE_DEPLOYMENT.md** | Complete GKE deployment guide |
| **docs/DEPLOY_AND_MONITOR.md** | Combined GAE + GKE guide |

---

## Next Steps

1. **Deploy Now:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File deploy-gke.ps1
   ```

2. **Wait 5-10 minutes** for cluster creation and deployment

3. **Check status:**
   ```powershell
   kubectl get pods
   kubectl get svc
   ```

4. **Get your app URL:**
   ```powershell
   kubectl get svc gcp-compare-service
   ```

5. **Monitor in console:**
   ```powershell
   Start-Process "https://console.cloud.google.com/kubernetes/workloads"
   ```

Your GKE deployment is ready! 🚀

