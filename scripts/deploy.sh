#!/bin/bash
set -e

echo "🚀 AI Monitoring System v2.0 - Enhanced Deployment"
echo "=================================================="

# Detect Docker Compose command
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Docker Compose not found"
    exit 1
fi

echo "✅ Using: $DOCKER_COMPOSE"

# Check environment
if [ ! -f .env ]; then
    echo "⚠️  Creating .env file from template..."
    cp .env.template .env 2>/dev/null || echo "DATADOG_API_KEY=demo_key" > .env
    echo "Please edit .env with your actual credentials!"
fi

# Clean slate
echo "🧹 Cleaning up existing deployment..."
$DOCKER_COMPOSE down -v --remove-orphans 2>/dev/null || true

# Build with enhancements
echo "🏗️  Building enhanced system (this may take a few minutes)..."
$DOCKER_COMPOSE build --no-cache

echo "🚀 Starting enhanced services..."
$DOCKER_COMPOSE up -d

# Enhanced health check
echo "⏳ Waiting for enhanced services..."
sleep 30

echo "🔍 Running enhanced health checks..."

# Check services
for i in {1..20}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Enhanced AI Monitoring System is ready!"
        break
    fi
    if [ $i -eq 20 ]; then
        echo "❌ System failed to start"
        $DOCKER_COMPOSE logs --tail=20 ai-monitoring
        exit 1
    fi
    echo "Waiting for system startup... ($i/20)"
    sleep 3
done

# Test enhanced features
echo "🧪 Testing enhanced features..."
sleep 5

# Test the new API endpoints
echo "Testing enhanced API endpoints..."
curl -s http://localhost:8000/api/dashboard/stats > /dev/null && echo "✅ Dashboard stats API working"
curl -s http://localhost:8000/api/agents > /dev/null && echo "✅ Enhanced agents API working"
curl -s http://localhost:8000/api/incidents > /dev/null && echo "✅ Incidents API working"

echo ""
echo "🎉 ENHANCED DEPLOYMENT SUCCESSFUL!"
echo "======================================"
echo ""
echo "🆕 NEW FEATURES AVAILABLE:"
echo "  🔄 Real-time incident workflow execution"
echo "  📊 Live agent progress tracking with progress bars"
echo "  📝 Detailed console logs for each agent"
echo "  🔗 WebSocket real-time updates"
echo "  📱 Interactive agent dashboard with click-to-view"
echo "  📈 Comprehensive incident history and analytics"
echo ""
echo "📊 Access Points:"
echo "  🌐 Enhanced Dashboard:    http://localhost:8000"
echo "  💚 Health Check:         http://localhost:8000/health"
echo "  📊 Dashboard Stats:      http://localhost:8000/api/dashboard/stats"
echo "  🤖 Agent Details:        http://localhost:8000/api/agents"
echo "  📋 Incident History:     http://localhost:8000/api/incidents"
echo "  📚 API Documentation:    http://localhost:8000/api/docs"
echo ""
echo "🧪 Try the Enhanced Features:"
echo "  1. Click 'Trigger Real Incident' to see agents work in real-time"
echo "  2. Watch live progress bars as each agent executes"
echo "  3. Click on agent tiles to view execution history"
echo "  4. View detailed console logs for each agent"
echo "  5. See complete incident workflow from start to resolution"
echo ""
echo "🔧 Management Commands:"
echo "  View logs:    $DOCKER_COMPOSE logs -f ai-monitoring"
echo "  Stop system:  $DOCKER_COMPOSE down"
echo "  Restart:      $DOCKER_COMPOSE restart"
echo ""
echo "🌟 Your AI Monitoring System now has REAL-TIME WORKFLOW EXECUTION!"
