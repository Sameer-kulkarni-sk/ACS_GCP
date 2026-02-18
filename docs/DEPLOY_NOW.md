# Deploy Instructions - Quick Reference

## ✅ Prerequisites Check

Before deploying, make sure you have:

```powershell
# Check gcloud is installed
gcloud --version

# Check you're logged in
gcloud auth list

# Check project is set
gcloud config get-value project
```

---

## 🚀 Deploy to Google App Engine (Recommended - 2 minutes)

```powershell
# 1. Navigate to project
cd "C:\Users\Pillai\gcp-compare-project"

# 2. Update dependencies
npm install

# 3. Deploy
gcloud app deploy

# 4. When asked "Do you want to continue? (Y/n)" → Type: Y and Enter
```

**Wait for deployment to complete** (takes ~1-2 minutes)

Once complete, you'll see:
```
Deployed service [default] to [https://YOUR-PROJECT.appspot.com]
```

---

## 📱 Access Your App

```powershell
# Option 1: Automatic (opens browser)
gcloud app browse

# Option 2: Manual - Copy URL
gcloud app describe --format='value(defaultHostname)'
# Then visit: https://YOUR-PROJECT.appspot.com
```

---

## 📊 View in Google Cloud Console

### Open Console
```powershell
Start-Process "https://console.cloud.google.com/appengine"
```

### Check Status
1. Click **App Engine** in sidebar
2. You should see:
   - ✅ Green checkmark next to your app
   - Status: **SERVING**
   - **Version** shows your deployed version

### View Real-time Logs
```powershell
# Follow logs in terminal (shows new logs as they arrive)
gcloud app logs read -n 50 --follow
```

In Console:
1. Click **Cloud Logging** in sidebar
2. Filter: `resource.type="gae_app"`
3. Click **Auto Refresh** to see logs in real-time

### Monitor Metrics
In Console:
1. Go to **App Engine > Metrics**
2. View:
   - Requests per second
   - Error rate
   - Latency (response time)
   - Instance count
   - CPU & Memory usage

---

## ✅ Test Your Endpoints

Your app should be running at: `https://YOUR-PROJECT.appspot.com`

Test these URLs:

```
Dashboard:    https://YOUR-PROJECT.appspot.com/
Health:       https://YOUR-PROJECT.appspot.com/health
Info:         https://YOUR-PROJECT.appspot.com/api/info
Comparison:   https://YOUR-PROJECT.appspot.com/api/comparison
Metrics:      https://YOUR-PROJECT.appspot.com/api/metrics
```

---

## 🔧 If Deployment Fails

### Error: "npm ci" sync error

```powershell
# Run npm install locally first
npm install

# Then try deploying again
gcloud app deploy
```

### Error: "Quota exceeded"

```powershell
# Check your quota
gcloud app describe

# View billing/quota details
gcloud billing accounts list
```

### Other errors

```powershell
# Get detailed error info
gcloud app deploy --verbosity=debug

# Check logs for deployment errors
gcloud app logs read -n 100
```

---

## 📊 Verify Success Checklist

- ✅ Deployment shows "Deployed service [default]"
- ✅ Console shows green status
- ✅ Can access `https://YOUR-PROJECT.appspot.com/`
- ✅ `/health` endpoint returns `{"status":"healthy",...}`
- ✅ Can see traffic metrics in Console
- ✅ Logs are being captured

---

## 🔄 Update Your App

After making code changes:

```powershell
# 1. Update code
# 2. Test locally: npm run dev
# 3. Deploy new version
gcloud app deploy
```

App Engine creates a new version automatically. You can see all versions in Console under **App Engine > Versions**.

---

## 💰 Check Costs

Your app is likely on the **free tier** if you use < 28 instance hours/day.

Check in Console:
1. Go to **Billing > Cost Management**
2. View daily estimated cost
3. (Usually $0-5/month for demos)

---

## 📚 Next Steps

1. Read [docs/DEPLOY_AND_MONITOR.md](./docs/DEPLOY_AND_MONITOR.md) for detailed guide
2. Read [docs/COMPARISON.md](./docs/COMPARISON.md) to understand GKE vs GAE
3. Read [docs/QUICKSTART.md](./docs/QUICKSTART.md) for other deployment options

---

**Deployment Status:** Ready to deploy! ✅

