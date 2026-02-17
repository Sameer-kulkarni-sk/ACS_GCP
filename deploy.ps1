# Deploy to Google App Engine
# Run this script to deploy your application

Write-Host "========================================" -ForegroundColor Green
Write-Host "GCP App Engine Deployment Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check gcloud
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: gcloud CLI is not installed" -ForegroundColor Red
    exit 1
}
Write-Host "gcloud: OK" -ForegroundColor Green

# Check npm
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: npm is not installed" -ForegroundColor Red
    exit 1
}
Write-Host "npm: OK" -ForegroundColor Green

# Check project
$PROJECT_ID = & gcloud config get-value project 2>$null
if ([string]::IsNullOrEmpty($PROJECT_ID)) {
    Write-Host "ERROR: No GCP project configured" -ForegroundColor Red
    Write-Host "Run: gcloud init" -ForegroundColor Yellow
    exit 1
}
Write-Host "Project: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies installed" -ForegroundColor Green
Write-Host ""

# Deploy
Write-Host "Deploying to App Engine..." -ForegroundColor Yellow
Write-Host "This may take 1-2 minutes..." -ForegroundColor Yellow
Write-Host ""

gcloud app deploy --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Get app URL
    $APP_URL = & gcloud app describe --format='value(defaultHostname)' 2>$null
    
    Write-Host "Your application is live!" -ForegroundColor Green
    Write-Host "URL: https://$APP_URL" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "View in Google Cloud Console:" -ForegroundColor Yellow
    Write-Host "  https://console.cloud.google.com/appengine" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Test endpoints:" -ForegroundColor Yellow
    Write-Host "  Dashboard:  https://$APP_URL/" -ForegroundColor Cyan
    Write-Host "  Health:     https://$APP_URL/health" -ForegroundColor Cyan
    Write-Host "  Info:       https://$APP_URL/api/info" -ForegroundColor Cyan
    Write-Host "  Comparison: https://$APP_URL/api/comparison" -ForegroundColor Cyan
    Write-Host "  Metrics:    https://$APP_URL/api/metrics" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "View logs:" -ForegroundColor Yellow
    Write-Host "  gcloud app logs read -n 50 --follow" -ForegroundColor Cyan
    Write-Host ""
    
    # Offer to open in browser
    $OpenBrowser = Read-Host "Open application in browser? (y/n)"
    if ($OpenBrowser -eq "y" -or $OpenBrowser -eq "Y") {
        Start-Process "https://$APP_URL"
    }
    
    # Offer to open console
    $OpenConsole = Read-Host "Open Google Cloud Console? (y/n)"
    if ($OpenConsole -eq "y" -or $OpenConsole -eq "Y") {
        Start-Process "https://console.cloud.google.com/appengine"
    }
} else {
    Write-Host ""
    Write-Host "DEPLOYMENT FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check error message above" -ForegroundColor Yellow
    Write-Host "  2. Run: gcloud app deploy --verbosity=debug" -ForegroundColor Yellow
    Write-Host "  3. View logs: gcloud app logs read -n 100" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
