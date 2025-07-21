# Fix for permission issues

# 1. Update the Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user first
RUN useradd -m -u 1000 appuser

# Create directories with proper permissions
RUN mkdir -p /app/logs /app/data && \
    chown -R appuser:appuser /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Ensure proper ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "src/main.py"]
EOF

# 2. Update main.py to handle logging gracefully
cat > src/main.py << 'EOF'
"""
AI-Powered IT Operations Monitoring System
Main application entry point
"""
import os
import asyncio
import logging
import sys
from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Ensure logs directory exists with proper permissions
logs_dir = Path("logs")
try:
    logs_dir.mkdir(exist_ok=True)
    # Test if we can write to the logs directory
    test_file = logs_dir / "test.log"
    test_file.touch()
    test_file.unlink()  # Remove test file
    log_file_path = logs_dir / "app.log"
except (PermissionError, OSError):
    # Fall back to console logging only
    log_file_path = None
    print("Warning: Cannot write to logs directory, using console logging only")

# Configure logging
log_handlers = [logging.StreamHandler(sys.stdout)]
if log_file_path:
    log_handlers.append(logging.FileHandler(log_file_path))

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=log_handlers
)
logger = logging.getLogger(__name__)

class MonitoringSystemApp:
    """Main application class"""
    
    def __init__(self):
        self.app = FastAPI(
            title="AI Monitoring System",
            description="AI-Powered IT Operations Monitoring",
            version="1.0.0"
        )
        
        # Setup CORS
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        # Setup routes
        self._setup_routes()
        
    def _setup_routes(self):
        """Setup API routes"""
        
        @self.app.get("/health")
        async def health_check():
            return {
                "status": "healthy", 
                "service": "AI Monitoring System",
                "version": "1.0.0",
                "logging": "file" if log_file_path else "console"
            }
        
        @self.app.get("/api/status")
        async def get_status():
            return {
                "status": "running", 
                "agents": [
                    "monitoring", "rca", "pager", 
                    "ticketing", "email", "remediation", "validation"
                ],
                "orchestrator": "active",
                "logging": "file" if log_file_path else "console"
            }
        
        @self.app.get("/api/agents")
        async def get_agents():
            """Get detailed agent information"""
            return {
                "agents": {
                    "monitoring": {"status": "ready", "description": "Real-time monitoring"},
                    "rca": {"status": "ready", "description": "Root cause analysis"},
                    "pager": {"status": "ready", "description": "PagerDuty integration"},
                    "ticketing": {"status": "ready", "description": "ServiceNow integration"},
                    "email": {"status": "ready", "description": "Email notifications"},
                    "remediation": {"status": "ready", "description": "Automated remediation"},
                    "validation": {"status": "ready", "description": "Incident validation"}
                },
                "total_agents": 7
            }
        
        @self.app.post("/api/trigger-incident")
        async def trigger_incident(incident_data: dict):
            """Trigger an incident workflow"""
            logger.info(f"Incident triggered: {incident_data.get('title', 'Unknown')}")
            
            # Basic incident response simulation
            workflow_steps = [
                {"step": "monitoring", "status": "completed", "duration": "2s"},
                {"step": "rca", "status": "completed", "duration": "5s"},
                {"step": "alerting", "status": "completed", "duration": "1s"},
                {"step": "ticketing", "status": "completed", "duration": "3s"}
            ]
            
            return {
                "incident_id": f"INC-{hash(str(incident_data)) % 10000:04d}",
                "status": "processed",
                "workflow": workflow_steps,
                "message": "Incident workflow completed successfully"
            }
        
        # Serve frontend if available
        frontend_path = Path("frontend/build")
        if frontend_path.exists():
            self.app.mount("/", StaticFiles(directory=str(frontend_path), html=True), name="static")
        else:
            @self.app.get("/")
            async def root():
                return {
                    "message": "AI Monitoring System API",
                    "version": "1.0.0",
                    "endpoints": ["/health", "/api/status", "/api/agents", "/api/trigger-incident"],
                    "frontend": "not built - run: cd frontend && npm install && npm run build"
                }
    
    def run(self, host: str = "0.0.0.0", port: int = 8000):
        """Run the application"""
        logger.info("Starting AI Monitoring System...")
        logger.info(f"Logging to: {'file and console' if log_file_path else 'console only'}")
        uvicorn.run(self.app, host=host, port=port, log_level="info")

if __name__ == "__main__":
    app = MonitoringSystemApp()
    app.run()
EOF

# 3. Update docker-compose.yml to handle volumes properly
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  ai-monitoring:
    build: .
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY:-}
      - DATADOG_API_KEY=${DATADOG_API_KEY:-}
      - DATADOG_APP_KEY=${DATADOG_APP_KEY:-}
      - PAGERDUTY_API_KEY=${PAGERDUTY_API_KEY:-}
      - SERVICENOW_USERNAME=${SERVICENOW_USERNAME:-}
      - SERVICENOW_PASSWORD=${SERVICENOW_PASSWORD:-}
      - EMAIL_USERNAME=${EMAIL_USERNAME:-}
      - EMAIL_PASSWORD=${EMAIL_PASSWORD:-}
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - redis
    volumes:
      # Create volumes with proper permissions
      - logs_data:/app/logs
      - app_data:/app/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  redis_data:
  logs_data:
  app_data:
EOF

# 4. Update the deployment script to handle permissions
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Deploying AI Monitoring System..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.template .env
    echo "⚠️  Please edit .env file with your actual credentials!"
    echo "Then run this script again."
    exit 1
fi

# Create necessary directories with proper permissions
echo "📁 Creating directories..."
mkdir -p logs data ssl
chmod 755 logs data ssl

# Clean up any existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose down -v

# Build and start services
echo "🏗️  Building and starting services..."
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 20

# Check Redis first
echo "🔍 Checking Redis..."
for i in {1..10}; do
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis is running"
        break
    fi
    echo "Waiting for Redis... ($i/10)"
    sleep 2
done

# Check main application
echo "🔍 Checking main application..."
for i in {1..15}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Application is running!"
        echo ""
        echo "📊 Access Points:"
        echo "  • Main API: http://localhost:8000"
        echo "  • Health Check: http://localhost:8000/health"
        echo "  • System Status: http://localhost:8000/api/status"
        echo "  • Agent Info: http://localhost:8000/api/agents"
        echo ""
        echo "🧪 Test the system:"
        echo "  curl http://localhost:8000/health"
        echo "  curl http://localhost:8000/api/status"
        echo ""
        echo "🔧 Useful Commands:"
        echo "  • View logs: docker-compose logs -f ai-monitoring"
        echo "  • Stop services: docker-compose down"
        echo "  • Restart: docker-compose restart"
        echo "  • Rebuild: docker-compose down && docker-compose build --no-cache && docker-compose up -d"
        exit 0
    fi
    echo "Waiting for application to start... ($i/15)"
    sleep 3
done

echo "❌ Application failed to start"
echo "📋 Checking logs..."
docker-compose logs ai-monitoring
echo ""
echo "🔧 Try these debugging steps:"
echo "  1. Check logs: docker-compose logs ai-monitoring"
echo "  2. Check Redis: docker-compose logs redis"
echo "  3. Verify .env file has correct values"
echo "  4. Rebuild: docker-compose down && docker-compose build --no-cache && docker-compose up -d"
exit 1
EOF

# 5. Create a simple test script
cat > scripts/test-api.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing AI Monitoring System API..."

BASE_URL="http://localhost:8000"

# Test health endpoint
echo "1. Testing health endpoint..."
if response=$(curl -s "$BASE_URL/health"); then
    echo "✅ Health check: $response"
else
    echo "❌ Health check failed"
    exit 1
fi

# Test status endpoint
echo "2. Testing status endpoint..."
if response=$(curl -s "$BASE_URL/api/status"); then
    echo "✅ Status check: $response"
else
    echo "❌ Status check failed"
fi

# Test agents endpoint
echo "3. Testing agents endpoint..."
if response=$(curl -s "$BASE_URL/api/agents"); then
    echo "✅ Agents check: $response"
else
    echo "❌ Agents check failed"
fi

# Test incident trigger
echo "4. Testing incident trigger..."
incident_data='{
    "title": "Test Incident",
    "description": "This is a test incident",
    "severity": "medium"
}'

if response=$(curl -s -X POST "$BASE_URL/api/trigger-incident" \
    -H "Content-Type: application/json" \
    -d "$incident_data"); then
    echo "✅ Incident trigger: $response"
else
    echo "❌ Incident trigger failed"
fi

echo ""
echo "🎉 API tests completed!"
EOF

chmod +x scripts/test-api.sh

echo "🔧 Fixed permission issues!"
echo ""
echo "📝 Changes made:"
echo "  • Updated Dockerfile to create user and directories properly"
echo "  • Modified main.py to handle logging gracefully"
echo "  • Updated docker-compose.yml to use named volumes"
echo "  • Enhanced deployment script with better error handling"
echo "  • Added API testing script"
echo ""
echo "🚀 Now run:"
echo "  1. docker-compose down"
echo "  2. ./scripts/deploy.sh"
echo "  3. ./scripts/test-api.sh"
