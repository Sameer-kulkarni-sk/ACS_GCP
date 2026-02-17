const express = require('express');
const os = require('os');
const app = express();

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Application info
const appInfo = {
  name: 'GCP Compare Project',
  version: '1.0.0',
  platform: process.env.PLATFORM || 'unknown',
  environment: process.env.NODE_ENV || 'development',
  deployment: process.env.DEPLOYMENT_TYPE || 'unknown'
};

// Endpoints

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>GCP Compare Project</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; }
        h1 { color: #1f2937; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }
        .card { border: 1px solid #ddd; border-radius: 4px; padding: 15px; background-color: #f9fafb; }
        .card h3 { margin-top: 0; color: #1f2937; }
        .links { margin-top: 20px; }
        a { color: #2563eb; text-decoration: none; display: inline-block; margin-right: 15px; }
        a:hover { text-decoration: underline; }
        code { background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 GCP Compare Project</h1>
        <p>Comparing Google Kubernetes Engine (GKE) vs Google App Engine (GAE)</p>
        
        <div class="info-grid">
          <div class="card">
            <h3>📦 App Information</h3>
            <p><strong>Platform:</strong> ${appInfo.platform}</p>
            <p><strong>Environment:</strong> ${appInfo.environment}</p>
            <p><strong>Deployment:</strong> ${appInfo.deployment}</p>
            <p><strong>Hostname:</strong> ${os.hostname()}</p>
          </div>
          
          <div class="card">
            <h3>🔗 Available Endpoints</h3>
            <p><code>/health</code> - Health check</p>
            <p><code>/api/info</code> - Application info</p>
            <p><code>/api/comparison</code> - GKE vs GAE comparison</p>
            <p><code>/api/metrics</code> - System metrics</p>
          </div>
        </div>
        
        <div class="links">
          <a href="/health">Health Check</a>
          <a href="/api/info">App Info</a>
          <a href="/api/comparison">Comparison</a>
          <a href="/api/metrics">Metrics</a>
        </div>
      </div>
    </body>
    </html>
  `);
});

// App info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    ...appInfo,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpus: os.cpus().length
  });
});

// Comparison endpoint
app.get('/api/comparison', (req, res) => {
  res.json({
    comparison: {
      "Google App Engine": {
        description: "Fully managed serverless platform",
        best_for: ["Web applications", "APIs", "Mobile backends"],
        scaling: "Automatic (managed)",
        cost_model: "Pay-per-request + instance hours",
        management: "Minimal (serverless)",
        deployment: "gcloud app deploy",
        latency: "Fast (optimized)",
        compliance: ["HIPAA", "PCI-DSS", "SOC 2"]
      },
      "Google Kubernetes Engine": {
        description: "Managed Kubernetes container orchestration",
        best_for: ["Complex applications", "Microservices", "Custom configurations"],
        scaling: "Flexible (manual/autoscaling)",
        cost_model: "Pay-per-node + storage",
        management: "More control required",
        deployment: "kubectl apply",
        latency: "Variable (depends on config)",
        compliance: ["HIPAA", "PCI-DSS", "SOC 2"]
      }
    }
  });
});

// System metrics endpoint
app.get('/api/metrics', (req, res) => {
  const mem = process.memoryUsage();
  const cpus = os.cpus();
  
  res.json({
    memory: {
      heapUsed: Math.round(mem.heapUsed / 1024 / 1024) + ' MB',
      heapTotal: Math.round(mem.heapTotal / 1024 / 1024) + ' MB',
      external: Math.round(mem.external / 1024 / 1024) + ' MB'
    },
    cpu: {
      cores: cpus.length,
      model: cpus[0].model
    },
    system: {
      uptime: os.uptime() + ' seconds',
      loadAverage: os.loadavg(),
      platform: os.platform(),
      arch: os.arch()
    },
    node: {
      version: process.version,
      uptime: process.uptime() + ' seconds'
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

// Start server
const port = process.env.PORT || 8080;
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`[${new Date().toISOString()}] Server started on port ${port}`);
  console.log(`Platform: ${appInfo.platform}`);
  console.log(`Environment: ${appInfo.environment}`);
  console.log(`Deployment: ${appInfo.deployment}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
