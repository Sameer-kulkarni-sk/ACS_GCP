# Architecture Overview

This document describes the architecture of the GCP Compare Project and how the same application is deployed on both Google App Engine and Google Kubernetes Engine.

## Project Structure

```
gcp-compare-project/
├── app.js                          # Main Express application
├── package.json                    # Node.js dependencies
├── Dockerfile                      # Container image definition
├── app.yaml                        # Old Config (kept for reference)
│
├── gae/                            # Google App Engine specific
│   ├── app.yaml                    # GAE configuration
│   └── Dockerfile                  # GAE-optimized Dockerfile
│
├── gke/                            # Google Kubernetes Engine specific
│   ├── deployment.yaml             # Kubernetes Deployment
│   ├── service-account.yaml        # RBAC configuration
│   ├── configmap.yaml              # Configuration management
│   ├── ingress.yaml                # Ingress configuration
│   └── Dockerfile                  # GKE-optimized Dockerfile
│
├── docs/                           # Documentation
│   ├── COMPARISON.md               # GKE vs GAE comparison
│   ├── SETUP_GUIDE.md             # Deployment instructions
│   ├── ARCHITECTURE.md             # This file
│   └── API_REFERENCE.md            # API endpoints documentation
│
└── scripts/                        # Deployment scripts
    ├── deploy-gae.sh               # GAE deployment automation
    └── deploy-gke.sh               # GKE deployment automation
```

## Application Architecture

### Core Application (app.js)

The main application is a Node.js Express server with the following components:

#### 1. Health Check Endpoint
```
GET /health
```
- Responds with health status
- Used by both platforms for monitoring
- Quick to execute

#### 2. API Endpoints
```
GET /api/info        - Application information
GET /api/comparison  - GKE vs GAE comparison data
GET /api/metrics     - System metrics and statistics
```

#### 3. Static Web UI
```
GET /
```
- HTML dashboard showing platform information
- Links to all available endpoints
- Real-time system metrics display

## Deployment Architecture

### Google App Engine Architecture

```
┌─────────────────────────────────────┐
│     Google App Engine                │
│  ┌───────────────────────────────┐  │
│  │  Load Balancer (Google)       │  │
│  └────────────┬──────────────────┘  │
│               │                      │
│  ┌────────────▼──────────────────┐  │
│  │  Instance 1 (auto-scaled)     │  │
│  │  ├─ Node.js runtime           │  │
│  │  └─ app.js running            │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  Instance 2 (auto-scaled)     │  │
│  │  ├─ Node.js runtime           │  │
│  │  └─ app.js running            │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  Instance N (auto-scaled)     │  │
│  │  ├─ Node.js runtime           │  │
│  │  └─ app.js running            │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌───────────────────────────────┐  │
│  │  Built-in Services            │  │
│  │  ├─ Cloud Logging             │  │
│  │  ├─ Cloud Monitoring          │  │
│  │  ├─ Cloud IAM                 │  │
│  │  └─ HTTPS Certificate Mgmt    │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Characteristics:**
- Serverless platform
- Automatic scaling
- Managed runtime environment
- Built-in monitoring and logging
- No server management required

### Google Kubernetes Engine Architecture

```
┌──────────────────────────────────────────────────┐
│         Google Kubernetes Engine                 │
│  ┌────────────────────────────────────────────┐  │
│  │    GKE Control Plane (Managed by Google)   │  │
│  │  ├─ API Server                             │  │
│  │  ├─ etcd (State storage)                   │  │
│  │  ├─ Scheduler                              │  │
│  │  └─ Controller Manager                     │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  ┌────────────────────────────────────────────┐  │
│  │        Load Balancer / Ingress             │  │
│  │  └──────────────┬──────────────────────────┘  │
│  │                 │                             │
│  │    ┌────────────┼──────────────┐              │
│  │    │            │              │              │
│  │  ┌─▼──┐      ┌──▼──┐      ┌───▼──┐          │
│  │  │Node│      │Node │      │Node N│          │
│  │  │ 1  │      │ 2   │      │ ...  │          │
│  │  └─┬──┘      └──┬──┘      └───┬──┘          │
│  │    │            │              │              │
│  │  ┌─▼────────┬─▼───────┬───────▼──┐          │
│  │  │ Pod 1    │ Pod 2   │ Pod N    │          │
│  │  │(app.js)  │(app.js) │(app.js)  │          │
│  │  │          │         │          │          │
│  │  │┌────────┐│┌───────┐│┌────────┐│         │
│  │  ││Container││Contain││Container││         │
│  │  ││ Image  ││ Er    ││ Image   ││         │
│  │  │└────────┘│└───────┘│└────────┘│         │
│  │  └──┬───────┴──┬──────┴──────┬───┘         │
│  │     │          │             │              │
│  │  ┌──▼──────────▼─────────────▼──┐          │
│  │  │    Cluster Services           │          │
│  │  │ ├─ Horizontal Pod Autoscaler  │          │
│  │  │ ├─ Vertical Pod Autoscaler    │          │
│  │  │ ├─ Google Cloud Monitoring    │          │
│  │  │ ├─ Google Cloud Logging       │          │
│  │  │ ├─ Config Management/Helm     │          │
│  │  │ └─ Network Policies           │          │
│  │  └───────────────────────────────┘          │
│  │                                              │
│  │  ┌─────────────────────────────────────┐   │
│  │  │    Persistent Storage (optional)     │   │
│  │  │  ├─ Google Cloud Storage            │   │
│  │  │  └─ Persistent Volumes              │   │
│  │  └─────────────────────────────────────┘   │
│  └────────────────────────────────────────────┘
└──────────────────────────────────────────────────┘
```

**Characteristics:**
- Container orchestration platform
- Manual control with automation options
- Managed control plane
- Custom networking and routing
- Highly scalable and flexible

## Network Architecture

### App Engine Network Flow

```
Client Request
     │
     ▼
   HTTPS (Automatic)
     │
     ▼
Google's Global Load Balancer
     │
     ▼
Regional App Engine
     │
     ├─ Route based on load
     │
     ▼
Instance Pool (auto-scaled)
     │
     ▼
Express Server (app.js)
     │
     ▼
Response
```

### GKE Network Flow

```
Client Request
     │
     ▼
   HTTPS (Manual setup)
     │
     ▼
Google Cloud Load Balancer
     │
     ▼
Kubernetes Ingress
     │
     ▼
Service (gcp-compare-service)
     │
     ├─ kube-proxy routing
     │
     ├───┬────┬────┐
     │   │    │    │
     ▼   ▼    ▼    ▼
   Pod Pod  Pod  Pod (Replicated)
     │   │    │    │
     └───┼────┼────┘
         │
         ▼
     Express Server (app.js)
         │
         ▼
     Response
```

## Deployment Process

### App Engine Deployment Flow

```
┌─────────────┐
│ Source Code │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ gcloud app deploy   │
└──────┬──────────────┘
       │
       ▼
┌──────────────────────┐
│ Build Phase          │
│ ├─ npm install       │
│ └─ Validate config   │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Deploy Phase         │
│ ├─ Create VM         │
│ ├─ Deploy app        │
│ └─ Update routing    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Running Application  │
└──────────────────────┘
```

### GKE Deployment Flow

```
┌─────────────┐
│ Source Code │
└──────┬──────┘
       │
       ▼
┌──────────────────────┐
│ Build Container      │
│ docker build -t ...  │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Push to Registry     │
│ docker push ...      │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Create Cluster       │
│ gcloud container ... │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Apply Manifests      │
│ kubectl apply -f ... │
└──────┬───────────────┘
       │
       ├─ ServiceAccount & RBAC
       ├─ ConfigMaps
       ├─ Deployment
       ├─ Service
       └─ HPA
       │
       ▼
┌──────────────────────┐
│ Running Application  │
└──────────────────────┘
```

## Scaling Architecture

### App Engine Auto-Scaling

```
Request Volume
      ▲
      │     ┌─────────────────┐
  HIGH│────▶│ Spinning up      │
      │     │ new instances    │
      │     └──────────┬───────┘
      │                │
NORMAL│     ┌──────────▼────────┐
      │────▶│ Existing instances │
      │     └────────────────────┘
      │
      │     ┌─────────────────┐
   LOW │────▶│ Shutting down   │
      │     │ unused instances │
      │     └─────────────────┘
      └─────────────────────────────▶ Time
       
Configuration: min 1, max 10 instances
Scaling Metric: CPU and throughput
```

### GKE Auto-Scaling (Horizontal Pod Autoscaler)

```
CPU Usage
    ▲
100%│     ┌─────────────────┐
    │────▶│ Scale up pods   │
    │     │ +1 pod at a time│
    │     └──────────┬───────┘
    │                │
 70%│     ┌──────────▼────────┐
    │────▶│ Desired state     │
    │     │ (maintain CPU)    │
    │     └────────────────────┘
    │
 40%│     ┌─────────────────┐
    │────▶│ Scale down pods │
    │     │ -1 pod at a time│
    │     └─────────────────┘
    │
    └─────────────────────────────▶ Time
    
Configuration: min 3, max 10 pods
Target Metric: 70% CPU, 80% Memory
Behavior: Scale up quickly, scale down slowly
```

## Storage Architecture

### App Engine Storage

- **Ephemeral**: Uses local disk (limited)
- **Persistent**: Cloud Storage (recommended)
- **Sessions**: Cloud Datastore or Cloud Memorystore
- **Logs**: Automatic to Cloud Logging

### GKE Storage

- **Ephemeral**: emptyDir volumes
- **Persistent**: Google Cloud Storage, Persistent Volumes
- **Sessions**: Redis on Memorystore
- **Logs**: Stackdriver Logging integration

## Security Architecture

### App Engine Security

```
┌──────────────────────────┐
│ Security Layers          │
├──────────────────────────┤
│ 1. HTTPS Enforcement     │
│    (Automatic)           │
├──────────────────────────┤
│ 2. DDoS Protection       │
│    (Google Protected)    │
├──────────────────────────┤
│ 3. IAM Access Control    │
│    (Cloud IAM)           │
├──────────────────────────┤
│ 4. OS Patching           │
│    (Google Managed)      │
├──────────────────────────┤
│ 5. Firewall Rules        │
│    (Limited control)     │
└──────────────────────────┘
```

### GKE Security

```
┌───────────────────────────┐
│ Security Layers           │
├───────────────────────────┤
│ 1. Network Policies       │
│    (Pod-to-pod filtering) │
├───────────────────────────┤
│ 2. RBAC (Role-Based)      │
│    (Fine-grained access)  │
├───────────────────────────┤
│ 3. Pod Security Policies  │
│    (Pod restrictions)     │
├───────────────────────────┤
│ 4. Secrets Encryption     │
│    (etcd encryption)      │
├───────────────────────────┤
│ 5. Network Security       │
│    (VPC, firewalls)       │
├───────────────────────────┤
│ 6. Container Scanning     │
│    (Vulnerability scan)   │
├───────────────────────────┤
│ 7. OS Patching            │
│    (Node auto-upgrade)    │
└───────────────────────────┘
```

## Cost Model

### App Engine Costs

```
Total Cost = Instance Hours + Requests + Networking + Storage

Example:
- 2 instances × 24hr × 30 days × $0.02/hr = $28.80
- 1M requests × $0.12/M = $0.12
- 1GB egress × $0.12 = $0.12
────────────────────────────────────
Total: ~$30/month
```

### GKE Costs

```
Total Cost = Node VMs + Persistent Storage + Ingress + Egress

Example:
- 3 n1-standard-1 nodes × $0.05/hr × 730 hr = $109.50
- 10GB storage × $0.17/GB = $1.70
- Ingress/Egress = $5-20
────────────────────────────────────
Total: ~$120-140/month
```

## Decision Tree

```
Start
  │
  ▼
Is this a simple web app or API?
  │
  ├─ YES ──────────────► Use App Engine
  │
  ├─ NO
      │
      ▼
  Need fine-grained control?
      │
      ├─ YES ──────────────► Use GKE
      │
      ├─ NO
          │
          ▼
      Complex architecture / microservices?
          │
          ├─ YES ──────────────► Use GKE
          │
          ├─ NO
              │
              ▼
          Variable traffic patterns?
              │
              ├─ YES (and small scale) ──► Use App Engine
              │
              └─ NO (or large scale) ────► Use GKE
```

## Comparison Summary

| Aspect | App Engine | GKE |
|--------|-----------|-----|
| Deployment | Single command | Multi-step process |
| Scaling | Fully automatic | HPA + manual |
| Cost predictability | Variable | Predictable |
| Operational complexity | Low | High |
| Infrastructure control | Minimal | Full |
| Learning curve | Gentle | Steep |
| Time to production | Hours | Days |
| Long-term flexibility | Limited | Unlimited |

This architecture supports both simple and complex deployments while maintaining the same application code.
