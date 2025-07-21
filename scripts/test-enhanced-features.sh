#!/bin/bash

echo "🧪 AI Monitoring System v2.0 - Enhanced Features Test"
echo "===================================================="

BASE_URL="http://localhost:8000"
PASS=0
FAIL=0

test_endpoint() {
    local name="$1"
    local url="$2"
    local method="${3:-GET}"
    local data="$4"
    
    echo -n "Testing $name... "
    
    if [ "$method" = "POST" ]; then
        response=$(curl -s -X POST "$url" -H "Content-Type: application/json" -d "$data" -w "%{http_code}")
    else
        response=$(curl -s "$url" -w "%{http_code}")
    fi
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo "✅ PASS"
        ((PASS++))
    else
        echo "❌ FAIL (HTTP $http_code)"
        ((FAIL++))
    fi
}

echo ""
echo "🔍 Testing Enhanced API Endpoints..."

# Test core endpoints
test_endpoint "Health Check" "$BASE_URL/health"
test_endpoint "Enhanced Dashboard Stats" "$BASE_URL/api/dashboard/stats"
test_endpoint "Enhanced Agents Info" "$BASE_URL/api/agents"
test_endpoint "Incidents List" "$BASE_URL/api/incidents"

# Test real incident workflow
echo ""
echo "🚀 Testing Real-Time Incident Workflow..."

incident_data='{
    "title": "Test High CPU Alert - Real Workflow",
    "description": "Testing real-time agent execution with live progress tracking",
    "severity": "high",
    "affected_systems": ["test-server-01", "test-server-02"]
}'

echo -n "Triggering real incident workflow... "
response=$(curl -s -X POST "$BASE_URL/api/trigger-incident" -H "Content-Type: application/json" -d "$incident_data")

if echo "$response" | grep -q "incident_id"; then
    echo "✅ PASS"
    ((PASS++))
    
    # Extract incident ID for follow-up tests
    incident_id=$(echo "$response" | grep -o '"incident_id":"[^"]*"' | cut -d'"' -f4)
    echo "📋 Created incident: $incident_id"
    
    # Wait a moment for workflow to start
    echo "⏳ Waiting for workflow to begin..."
    sleep 3
    
    # Test incident status endpoint
    test_endpoint "Incident Status Tracking" "$BASE_URL/api/incidents/$incident_id/status"
    
    # Wait for some agent execution
    echo "⏳ Waiting for agents to execute (10 seconds)..."
    sleep 10
    
    # Test agent logs (try monitoring agent)
    test_endpoint "Agent Logs - Monitoring" "$BASE_URL/api/incidents/$incident_id/agent/monitoring/logs"
    
    # Test agent history
    test_endpoint "Agent History - Monitoring" "$BASE_URL/api/agents/monitoring/history"
    
else
    echo "❌ FAIL"
    ((FAIL++))
fi

echo ""
echo "📊 Test Results:"
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"
echo "  📈 Success Rate: $(( PASS * 100 / (PASS + FAIL) ))%"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 ALL ENHANCED FEATURES WORKING!"
    echo ""
    echo "🎯 What to try next:"
    echo "  1. Open http://localhost:8000 in your browser"
    echo "  2. Click 'Trigger Real Incident' and watch the magic happen"
    echo "  3. See agents execute in real-time with progress bars"
    echo "  4. Click on agent tiles to view execution history"
    echo "  5. View detailed console logs for each agent"
    echo "  6. Watch the complete incident resolution workflow"
    echo ""
    echo "🔗 Pro tip: Open browser dev tools to see WebSocket real-time updates!"
    
    exit 0
else
    echo ""
    echo "⚠️  Some enhanced features failed. Check the logs:"
    echo "  docker compose logs ai-monitoring"
    exit 1
fi
