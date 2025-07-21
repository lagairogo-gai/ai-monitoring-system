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
