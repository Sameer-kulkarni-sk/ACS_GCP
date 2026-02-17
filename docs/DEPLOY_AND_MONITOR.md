# Deploy & Monitor in Google Cloud Console

Complete guide to deploy your GCP Compare Project and monitor it in the Google Cloud Console.

## Option 1: Deploy to Google App Engine (Easiest)

### Step 1: Fix & Prepare

```bash
# Make sure you're in the project directory
cd C:\Users\Pillai\gcp-compare-project

# Update npm dependencies (sync package-lock.json)
npm install

# Verify package.json is ready
cat package.json
```

### Step 2: Deploy

```bash
# Deploy to App Engine
gcloud app deploy

# This will:
# - Upload your code
# - Detect it's a Node.js app
# - Install dependencies in the cloud
# - Start your application
# - Assign a public URL
# Takes: 1-2 minutes
```

### Step 3: Open Your App

#### Open the Console
```
https://console.cloud.google.com
```

#### Navigate to App Engine
1. In the left sidebar, click **App Engine**
2. You'll see:
   - ✅ Green checkmark = App is running
   - Dashboard showing traffic, errors, latency
   - Real-time metrics

#### Check Deployment Status
1. Click `Cloud > App Engine > Versions`
2. You'll see your deployed version with:
   - Version number (v1, v2, etc.)
   - Status: SERVING
   - Instances count
   - Traffic percentage

#### View Logs
1. Go to **App Engine > Logs**
2. Or use **Cloud Logging** in left sidebar
3. Filter logs:
   ```
   resource.type="gae_app"
   severity="ERROR" OR severity="WARNING"
   ```

#### Monitor Metrics
1. Go to **App Engine > Metrics**
2. View:
   - Requests/second
   - Error rate
   - Latency (p50, p95, p99)
   - CPU utilization
   - Memory usage
   - Number of instances

#### Test Your Application
```bash
# Open in browser
gcloud app browse

# Or view the URL
gcloud app describe --format='value(defaultHostname)'
```

### Step 3: Test Endpoints

Once deployed, test these URLs:

```
Dashboard:        https://your-project.appspot.com/
Health Check:     https://your-project.appspot.com/health
App Info:         https://your-project.appspot.com/api/info
Comparison:       https://your-project.appspot.com/api/comparison
Metrics:          https://your-project.appspot.com/api/metrics
```

### Step 4: Monitor Logs in Console

#### Real-time Logs
```bash
# Follow logs in terminal
gcloud app logs read -n 50 --follow
```

**In Console:**
1. Go to **Cloud Logging**
2. Set filter: `resource.type="gae_app"`
3. Click **Auto Refresh** for live logs

#### View Error Rates
1. Go to **Error Reporting** (sidebar)
2. See all errors grouped
3. Click error to see stack trace

---

## Option 2: Deploy to Google Kubernetes Engine (More Control)

### Step 1: Deploy (Choose One)

#### On Windows (PowerShell - Recommended)
```powershell
powershell -ExecutionPolicy Bypass -File deploy-gke.ps1
```

**What the script does:**
- ✅ Checks gcloud, kubectl, docker are installed
- ✅ Gets your GCP project ID
- ✅ Installs npm dependencies
- ✅ Builds Docker image
- ✅ Pushes to Google Container Registry
- ✅ Creates GKE cluster (or uses existing)
- ✅ Configures kubectl
- ✅ Deploys application with 3 replicas
- ✅ Sets up auto-scaling (3-10 pods)
- ✅ Shows your external IP
- ✅ Takes ~5-10 minutes (cluster creation takes longest)

#### On Linux/macOS (Bash)
```bash
bash scripts/deploy-gke.sh
```

### Step 2: View in Google Cloud Console

#### Open the Console
```
https://console.cloud.google.com
```

#### Navigate to Kubernetes Engine
1. In left sidebar, click **Kubernetes Engine**
2. Click **Clusters**
3. You'll see your cluster: `gcp-compare-cluster`

#### Check Workloads
1. Go to **Kubernetes Engine > Workloads**
2. You'll see deployment: `gcp-compare-app`
3. Status shows:
   - ✅ 3/3 Ready pods
   - Green health indicator
   - Memory/CPU usage

#### View Pods
1. Go to **Kubernetes Engine > Workloads**
2. Click on `gcp-compare-app`
3. See all 3 running pods:
   - Pod names
   - Status: Running
   - CPU usage
   - Memory usage
   - Restart count

#### Check Load Balancer
1. Go to **Kubernetes Engine > Services & Ingress**
2. You'll see: `gcp-compare-service`
3. Copy the **External IP**
4. Visit: `http://<external-ip>`

#### Monitor Cluster Metrics
1. Go to **Kubernetes Engine > Clusters**
2. Click cluster name
3. View metrics:
   - Node CPU/Memory
   - Pod count
   - Network traffic
   - Disk usage

### Step 3: Test Your Application

```bash
# Get external IP
kubectl get svc gcp-compare-service

# Test application
$EXTERNAL_IP = kubectl get svc gcp-compare-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
curl http://$EXTERNAL_IP
curl http://$EXTERNAL_IP/health
curl http://$EXTERNAL_IP/api/info
```

### Step 4: Monitor with Logs

#### GKE Logs in Console
1. Go to **Cloud Logging**
2. Set filter:
   ```
   resource.type="k8s_container"
   resource.labels.namespace_name="default"
   resource.labels.pod_name=~"gcp-compare.*"
   ```
3. View logs in real-time

#### Logs from Terminal
```bash
# View deployment logs
kubectl logs deployment/gcp-compare-app

# Follow logs (tail -f)
kubectl logs deployment/gcp-compare-app -f

# View specific pod
kubectl logs pod/gcp-compare-app-abc123-xyz
```

---

## Console Monitoring Dashboards

### Create Custom Dashboard

1. In Google Cloud Console, go to **Monitoring > Dashboards**
2. Click **Create Dashboard**
3. Click **Add Widget**
4. Add these widgets:

#### For App Engine:
```
- Requests per second (gae_app)
- Error rate (gae_app)
- Latency p50/p95/p99
- Instance count
- CPU utilization
- Memory utilization
```

#### For GKE:
```
- Pod count (k8s_pod)
- Container CPU usage
- Container Memory usage
- Network received bytes
- Network sent bytes
- Restart count
```

---

## Useful Console Links

### App Engine
- Dashboard: `https://console.cloud.google.com/appengine`
- Versions: `https://console.cloud.google.com/appengine/versions`
- Metrics: `https://console.cloud.google.com/appengine/metrics`
- Logs: `https://console.cloud.google.com/logs`

### GKE
- Clusters: `https://console.cloud.google.com/kubernetes/clusters`
- Workloads: `https://console.cloud.google.com/kubernetes/workloads`
- Services: `https://console.cloud.google.com/kubernetes/discovery`
- Logs: `https://console.cloud.google.com/logs`

### Monitoring
- Monitoring: `https://console.cloud.google.com/monitoring`
- Dashboards: `https://console.cloud.google.com/monitoring/dashboards`
- Alerts: `https://console.cloud.google.com/monitoring/alerting`
- Logs: `https://console.cloud.google.com/logs`

### Cost Management
- Billing: `https://console.cloud.google.com/billing`
- Cost Analysis: `https://console.cloud.google.com/billing/reports`

---

## Troubleshooting Deployment

### Package Lock File Sync Error (npm ci failed)

**Error message:**
```
npm error `npm ci` can only install packages when your package.json 
and package-lock.json are in sync. Please update your lock file 
with `npm install` before continuing.
```

**Solution:**
```bash
# Fix by syncing lock file locally
npm install

# Then redeploy
gcloud app deploy
```

### App Engine Deployment Failed

```bash
# Check deployment errors
gcloud app deploy --verbosity=debug

# Check quota issues
gcloud app describe

# View recent deployments
gcloud app versions list

# Check logs for errors
gcloud app logs read -n 100
```

### GKE Deployment Failed

```bash
# Check cluster status
kubectl get nodes
kubectl get pods

# Describe pod for errors
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Check service status
kubectl describe svc gcp-compare-service

# Check deployment status
kubectl describe deployment gcp-compare-app
```

---

## Performance Testing

### Load Testing with Console Metrics

#### Before Load Test
1. Note current metrics in Console
2. Check baseline latency

#### Create Load
```bash
# Using Apache Bench (ab)
ab -n 1000 -c 10 http://your-app.appspot.com/

# Or using curl in a loop
for i in {1..100}; do curl http://$EXTERNAL_IP/; done
```

#### Monitor in Console
Watch these metrics during load:
- Request rate increase
- Latency increase
- Error rate (should stay 0)
- Instance/Pod count increase (auto-scaling)
- CPU/Memory increase

---

## Health Checks in Console

### App Engine Health
1. Go to **App Engine > Dashboard**
2. Green checkmark = Healthy
3. Red = Issues (check logs)

### GKE Health
1. Go to **Kubernetes Engine > Workloads**
2. Each pod shows:
   - 🟢 Green = Running and Ready
   - 🟡 Yellow = Starting/Pending
   - 🔴 Red = CrashLoop/Failed

### Health Check Endpoint
Both platforms use `/health` endpoint:

```bash
curl https://your-app.appspot.com/health
# Returns:
# {"status":"healthy","timestamp":"...","uptime":...}
```

---

## Scaling Verification

### App Engine Auto-scaling
1. Go to **App Engine > Metrics**
2. Create traffic spike (e.g., with `ab` tool)
3. Watch in Console:
   - Instance count grows
   - Latency stays low
   - Instances scale back down when traffic decreases

### GKE Auto-scaling
1. Go to **Kubernetes Engine > Workloads**
2. Create traffic spike
3. Watch in Console:
   - Pod count grows (3 → 10)
   - CPU usage metric shows strain
   - Pods distribute across nodes
   - Pods scale back when traffic decreases

---

## Cost Monitoring

### Check Running Costs

1. Go to **Billing > Cost Management**
2. View:
   - Daily cost estimate
   - By-service breakdown
   - App Engine costs
   - GKE node costs
   - Ingress/Egress costs

### Set Budget Alerts

1. Go to **Billing > Budgets**
2. Create new budget:
   - Set limit (e.g., $50/month)
   - Set alert threshold (80%)
   - Receive email when exceeded

---

## Quick Commands Cheat Sheet

```powershell
# App Engine
gcloud app deploy                    # Deploy
gcloud app browse                    # Open app
gcloud app logs read -n 50 -f       # View logs
gcloud app versions list             # List versions
gcloud app describe                  # Get info

# GKE
kubectl get pods                     # List pods
kubectl logs deployment/gcp-compare-app -f  # Logs
kubectl describe deployment gcp-compare-app # Details
kubectl get svc gcp-compare-service  # Get service IP
kubectl scale deployment gcp-compare-app --replicas=5  # Scale

# Monitoring
gcloud monitoring dashboards list    # List dashboards
gcloud logs read                     # Cloud Logging
```

---

## Next Steps

1. ✅ Deploy application (App Engine or GKE)
2. ✅ Open Google Cloud Console
3. ✅ Navigate to service dashboard
4. ✅ Monitor metrics and logs
5. ✅ Test endpoints
6. ✅ View health status
7. ✅ Check cost estimates
8. ✅ Create alerts if needed

Your application is production-ready! 🚀

