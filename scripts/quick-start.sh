#!/bin/bash

echo "⚡ AI Monitoring System - Quick Start"
echo "====================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Run deployment
echo "🚀 Starting enhanced deployment..."
./scripts/deploy.sh

# Wait for system to be ready
echo ""
echo "⏳ Waiting for system to fully initialize..."
sleep 10

# Run tests
echo ""
echo "🧪 Running feature tests..."
./scripts/test-enhanced-features.sh

echo ""
echo "🎉 QUICK START COMPLETE!"
echo ""
echo "Your AI Monitoring System is now ready with:"
echo "  🔄 Real-time workflow execution"
echo "  📊 Live agent progress tracking"
echo "  📝 Detailed execution logs"
echo "  🔗 WebSocket real-time updates"
echo ""
echo "🌐 Open: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/api/docs"
