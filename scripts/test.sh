#!/bin/bash

echo "🧪 Running tests..."

# Basic health check
echo "Testing health endpoint..."
if curl -f http://localhost:8000/health; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
fi

# Test API status
echo "Testing status endpoint..."
if curl -f http://localhost:8000/api/status; then
    echo "✅ Status endpoint passed"
else
    echo "❌ Status endpoint failed"
fi

echo "Tests completed"
