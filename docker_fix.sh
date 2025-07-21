# Fix the Docker build issue

# 1. Update Dockerfile to use npm install instead of npm ci
cat > Dockerfile << 'DOCKER_FIX_EOF'
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
# Use npm install instead of npm ci since we don't have package-lock.json
RUN npm install --only=production
COPY frontend/ ./
RUN npm run build

FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 appuser

RUN mkdir -p /app/logs /app/data && \
    chown -R appuser:appuser /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY --from=frontend-builder /app/frontend/build ./frontend/build

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "src/main.py"]
DOCKER_FIX_EOF

# 2. Create package-lock.json by running npm install locally (if npm is available)
if command -v npm &> /dev/null; then
    echo "📦 Generating package-lock.json..."
    cd frontend
    npm install
    cd ..
    echo "✅ package-lock.json created"
else
    echo "📝 npm not found locally - Docker will handle package installation"
fi

# 3. Alternative: Create a simpler Dockerfile that doesn't require package-lock.json
cat > Dockerfile.simple << 'SIMPLE_DOCKER_EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies including Node.js
RUN apt-get update && apt-get install -y \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 appuser

# Create directories with proper permissions
RUN mkdir -p /app/logs /app/data && \
    chown -R appuser:appuser /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Build frontend inside the same container
WORKDIR /app/frontend
RUN npm install && npm run build

# Go back to app directory
WORKDIR /app

# Ensure proper ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "src/main.py"]
SIMPLE_DOCKER_EOF

# 4. Update the deployment script to handle both Dockerfiles
cat > scripts/deploy.sh << 'DEPLOY_FIX_EOF'
#!/bin/bash
set -e

echo "🚀 AI Monitoring System - Production Deployment"
echo "================================================"

# Detect Docker Compose command
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

echo "✅ Using: $DOCKER_COMPOSE"

# Check if .env exists
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file from template..."
    cp .env.template .env
    echo "⚠️  IMPORTANT: Edit .env file with your actual API keys and credentials!"
    echo ""
    echo "🔧 Edit .env file and run this script again."
    exit 1
fi

echo "✅ Configuration file found"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p logs data ssl
chmod 755 logs data ssl

# Check if we should use the simple Dockerfile
if [ ! -f frontend/package-lock.json ]; then
    echo "📝 No package-lock.json found, using simplified Docker build..."
    cp Dockerfile.simple Dockerfile
fi

# Clean up existing containers
echo "🧹 Cleaning up existing deployment..."
$DOCKER_COMPOSE down -v --remove-orphans

# Build and start services
echo ""
echo "🏗️  Building application (this may take a few minutes)..."
$DOCKER_COMPOSE build --no-cache

echo ""
echo "🚀 Starting services..."
$DOCKER_COMPOSE up -d

# Wait for services to be ready
echo ""
echo "⏳ Waiting for services to initialize..."
sleep 30

# Health checks
echo "🔍 Running health checks..."

# Check Redis
echo "  • Checking Redis..."
for i in {1..10}; do
    if $DOCKER_COMPOSE exec redis redis-cli ping > /dev/null 2>&1; then
        echo "    ✅ Redis is ready"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "    ❌ Redis failed to start"
        $DOCKER_COMPOSE logs redis
        exit 1
    fi
    sleep 2
done

# Check main application
echo "  • Checking main application..."
for i in {1..20}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo "    ✅ Application is ready"
        break
    fi
    if [ $i -eq 20 ]; then
        echo "    ❌ Application failed to start"
        echo ""
        echo "📋 Application logs:"
        $DOCKER_COMPOSE logs --tail=20 ai-monitoring
        exit 1
    fi
    sleep 3
done

# Success message
echo ""
echo "🎉 DEPLOYMENT SUCCESSFUL!"
echo "========================"
echo ""
echo "📊 Access Points:"
echo "  🌐 Web Dashboard:     http://localhost:8000"
echo "  💚 Health Check:      http://localhost:8000/health"
echo "  📊 System Status:     http://localhost:8000/api/status"
echo "  🤖 Agent Info:        http://localhost:8000/api/agents"
echo "  📚 API Documentation: http://localhost:8000/api/docs"
echo ""
echo "🧪 Quick Tests:"
echo "  curl http://localhost:8000/health"
echo "  curl http://localhost:8000/api/status"
echo ""
echo "🔧 Management Commands:"
echo "  View logs:    $DOCKER_COMPOSE logs -f ai-monitoring"
echo "  Stop system:  $DOCKER_COMPOSE down"
echo "  Restart:      $DOCKER_COMPOSE restart"
echo "  Rebuild:      $DOCKER_COMPOSE down && ./scripts/deploy.sh"
echo ""
echo "🌟 The AI Monitoring System is now ready for production use!"
DEPLOY_FIX_EOF

# 5. Create a frontend build script for local development
cat > scripts/build-frontend.sh << 'BUILD_FRONTEND_EOF'
#!/bin/bash

echo "🎨 Building frontend locally..."

cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build the frontend
echo "🏗️  Building React app..."
npm run build

echo "✅ Frontend build completed!"

# Copy to main directory for Docker
cd ..
if [ -d "frontend/build" ]; then
    echo "📁 Frontend build ready at frontend/build/"
    echo "🚀 You can now run: ./scripts/deploy.sh"
else
    echo "❌ Frontend build failed"
    exit 1
fi
BUILD_FRONTEND_EOF

chmod +x scripts/build-frontend.sh

echo "🔧 Docker build issues fixed!"
echo ""
echo "📝 Changes made:"
echo "  • Updated Dockerfile to use 'npm install' instead of 'npm ci'"
echo "  • Created Dockerfile.simple as fallback option"
echo "  • Updated deployment script to handle missing package-lock.json"
echo "  • Added frontend build script for local development"
echo ""
echo "🚀 Now try deploying again:"
echo "  ./scripts/deploy.sh"
echo ""
echo "💡 Alternative options:"
echo "  1. Build frontend first: ./scripts/build-frontend.sh"
echo "  2. Use simple Docker build: cp Dockerfile.simple Dockerfile"