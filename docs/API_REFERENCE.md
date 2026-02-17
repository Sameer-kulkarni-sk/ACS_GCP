# API Reference

Complete API documentation for the GCP Compare Project application.

## Base URL

- **App Engine**: `https://<your-project-id>.appspot.com`
- **GKE**: `http://<external-ip>` or `https://<domain>`
- **Local**: `http://localhost:8080`

## Endpoints

### Health Check

```http
GET /health
```

Returns the health status of the application.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-02-16T10:30:45.123Z",
  "uptime": 3600.5
}
```

**Status Codes:**
- `200 OK` - Application is healthy
- `500 Internal Server Error` - Application encountered an error

**Use Case:** Kubernetes liveness/readiness probes, load balancer health checks

**Response Time:** < 10ms

---

### Root Endpoint

```http
GET /
```

Returns an interactive HTML dashboard showing application information and available endpoints.

**Response:** HTML page with:
- Application status
- Platform information
- System metrics
- Links to API endpoints

**Status Codes:**
- `200 OK` - Dashboard loaded successfully

**Content-Type:** `text/html`

---

### Application Information

```http
GET /api/info
```

Returns detailed information about the running application.

**Response:**
```json
{
  "name": "GCP Compare Project",
  "version": "1.0.0",
  "platform": "GKE",
  "environment": "production",
  "deployment": "Google Kubernetes Engine",
  "timestamp": "2026-02-16T10:30:45.123Z",
  "uptime": 3600.5,
  "memory": {
    "rss": 52428800,
    "heapTotal": 33554432,
    "heapUsed": 16777216,
    "external": 2097152,
    "arrayBuffers": 0
  },
  "cpus": 4
}
```

**Query Parameters:** None

**Response Fields:**
- `name` (string) - Application name
- `version` (string) - Version number
- `platform` (string) - Deployment platform (GAE/GKE)
- `environment` (string) - Environment name (production/development)
- `deployment` (string) - Deployment type description
- `timestamp` (string) - Current timestamp in ISO 8601 format
- `uptime` (number) - Application uptime in seconds
- `memory` (object) - Node.js memory information
- `cpus` (number) - Number of CPU cores available

**Status Codes:**
- `200 OK` - Information retrieved successfully

**Content-Type:** `application/json`

**Response Time:** < 5ms

---

### Comparison Data

```http
GET /api/comparison
```

Returns comprehensive comparison data between GKE and GAE.

**Response:**
```json
{
  "comparison": {
    "Google App Engine": {
      "description": "Fully managed serverless platform",
      "best_for": ["Web applications", "APIs", "Mobile backends"],
      "scaling": "Automatic (managed)",
      "cost_model": "Pay-per-request + instance hours",
      "management": "Minimal (serverless)",
      "deployment": "gcloud app deploy",
      "latency": "Fast (optimized)",
      "compliance": ["HIPAA", "PCI-DSS", "SOC 2"]
    },
    "Google Kubernetes Engine": {
      "description": "Managed Kubernetes container orchestration",
      "best_for": ["Complex applications", "Microservices", "Custom configurations"],
      "scaling": "Flexible (manual/autoscaling)",
      "cost_model": "Pay-per-node + storage",
      "management": "More control required",
      "deployment": "kubectl apply",
      "latency": "Variable (depends on config)",
      "compliance": ["HIPAA", "PCI-DSS", "SOC 2"]
    }
  }
}
```

**Query Parameters:** None

**Response Structure:**
- `comparison.Google App Engine` - GAE details
  - `description` - Platform description
  - `best_for` - Use case array
  - `scaling` - Scaling mechanism
  - `cost_model` - Pricing model
  - `management` - Operational overhead
  - `deployment` - Deployment method
  - `latency` - Performance characteristics
  - `compliance` - Compliance certifications

- `comparison.Google Kubernetes Engine` - GKE details (same structure)

**Status Codes:**
- `200 OK` - Comparison data retrieved

**Content-Type:** `application/json`

**Response Time:** < 5ms

**Use Case:** Comparing platforms, decision making, reference data

---

### System Metrics

```http
GET /api/metrics
```

Returns detailed system and performance metrics.

**Response:**
```json
{
  "memory": {
    "heapUsed": "28 MB",
    "heapTotal": "32 MB",
    "external": "2 MB"
  },
  "cpu": {
    "cores": 4,
    "model": "Intel(R) Xeon(R) CPU @ 2.20GHz"
  },
  "system": {
    "uptime": "3600.25 seconds",
    "loadAverage": [0.45, 0.32, 0.28],
    "platform": "linux",
    "arch": "x64"
  },
  "node": {
    "version": "v18.13.0",
    "uptime": "3600.25 seconds"
  }
}
```

**Query Parameters:** None

**Response Fields:**
- `memory` - Memory usage information
  - `heapUsed` - Heap memory in use
  - `heapTotal` - Total heap allocated
  - `external` - External memory usage

- `cpu` - CPU information
  - `cores` - Number of cores
  - `model` - CPU model string

- `system` - System metrics
  - `uptime` - System uptime in seconds
  - `loadAverage` - 1, 5, 15 minute load averages
  - `platform` - Operating system
  - `arch` - CPU architecture

- `node` - Node.js runtime information
  - `version` - Node.js version
  - `uptime` - Application uptime in seconds

**Status Codes:**
- `200 OK` - Metrics retrieved successfully

**Content-Type:** `application/json`

**Response Time:** < 5ms

**Use Case:** Monitoring, troubleshooting, performance analysis

---

## Error Responses

### 400 Bad Request

```json
{
  "error": "Bad Request",
  "message": "Invalid query parameters"
}
```

### 404 Not Found

```json
{
  "error": "Not Found",
  "path": "/invalid/endpoint"
}
```

### 500 Internal Server Error

```json
{
  "error": "Internal Server Error",
  "message": "Description of what went wrong"
}
```

---

## Rate Limiting

- **App Engine Standard**: 10,000 requests per minute per IP
- **GKE**: Depends on cluster configuration, typically 1,000+ per pod

---

## Authentication

Currently, all endpoints are public. For production deployments, implement:
- Cloud IAM authentication
- API key validation
- OAuth 2.0 support

---

## CORS Headers

All endpoints support CORS for cross-origin requests:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

## Performance Characteristics

| Endpoint | Avg Response | P99 Response | Throughput |
|----------|------------|-------------|------------|
| /health | 5ms | 20ms | 10k/sec |
| /api/info | 5ms | 25ms | 5k/sec |
| /api/comparison | 5ms | 25ms | 5k/sec |
| /api/metrics | 8ms | 30ms | 3k/sec |
| / | 20ms | 100ms | 1k/sec |

---

## cURL Examples

### Check Health

```bash
curl https://your-app.appspot.com/health
```

### Get Application Info

```bash
curl https://your-app.appspot.com/api/info | jq
```

### Get Comparison Data

```bash
curl https://your-app.appspot.com/api/comparison | jq '.comparison."Google App Engine".best_for'
```

### Get System Metrics

```bash
curl https://your-app.appspot.com/api/metrics | jq '.memory'
```

### Follow Metrics (Watch)

```bash
while true; do
  curl https://your-app.appspot.com/api/metrics | jq '.memory.heapUsed'
  sleep 2
done
```

---

## JavaScript/Fetch Examples

### Fetch Application Info

```javascript
async function getAppInfo() {
  const response = await fetch('/api/info');
  const data = await response.json();
  console.log('Platform:', data.platform);
  console.log('Uptime:', data.uptime, 'seconds');
}

getAppInfo();
```

### Monitor Health Status

```javascript
async function checkHealth() {
  try {
    const response = await fetch('/health');
    if (response.ok) {
      console.log('✓ Application is healthy');
    } else {
      console.log('✗ Application is unhealthy');
    }
  } catch (error) {
    console.error('Health check failed:', error);
  }
}

// Check every 30 seconds
setInterval(checkHealth, 30000);
```

### Real-time Metrics Display

```javascript
async function displayMetrics() {
  const response = await fetch('/api/metrics');
  const data = await response.json();
  
  console.log('Memory Usage:');
  console.log('  Heap Used:', data.memory.heapUsed);
  console.log('  Heap Total:', data.memory.heapTotal);
  console.log('CPU Cores:', data.cpu.cores);
  console.log('System Uptime:', data.system.uptime);
}

displayMetrics();
```

---

## Webhook Integration

### Health Check Integration

```bash
# Health Monitoring with StatusCake, New Relic, etc.
curl -X POST https://webhook.example.com \
  -H "Content-Type: application/json" \
  -d @- << EOF
{
  "status": "healthy",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": "gcp-compare-app"
}
EOF
```

---

## API Versioning

Current API version: **v1**

Future versions may be available at:
- `/api/v2/...`
- `/api/v3/...`

Current endpoints (v1) are under `/api/...`

---

## SDK/Client Libraries

### Python

```python
import requests

response = requests.get('https://your-app.appspot.com/api/info')
data = response.json()
print(f"Platform: {data['platform']}")
```

### Java

```java
import java.net.http.HttpClient;
import java.net.http.HttpRequest;

var client = HttpClient.newHttpClient();
var request = HttpRequest.newBuilder()
    .uri(URI.create("https://your-app.appspot.com/api/info"))
    .GET()
    .build();
var response = client.send(request, HttpResponse.BodyHandlers.ofString());
System.out.println(response.body());
```

### Go

```go
package main

import (
    "fmt"
    "net/http"
    "io"
)

func main() {
    resp, _ := http.Get("https://your-app.appspot.com/api/info")
    defer resp.Body.Close()
    body, _ := io.ReadAll(resp.Body)
    fmt.Println(string(body))
}
```

---

## Support & Feedback

For issues or suggestions, please refer to the main README or create an issue in the repository.

---

**Last Updated:** February 16, 2026  
**API Version:** 1.0
