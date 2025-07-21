#!/bin/bash

echo "🧪 AI Monitoring System - Comprehensive Test Suite"
echo "=================================================="

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
echo "🔍 Running endpoint tests..."

test_endpoint "Health Check" "$BASE_URL/health"
test_endpoint "System Status" "$BASE_URL/api/status"
test_endpoint "Agents Info" "$BASE_URL/api/agents"
test_endpoint "System Metrics" "$BASE_URL/api/metrics"
test_endpoint "Workflows" "$BASE_URL/api/workflows"

incident_data='{
    "title": "Test Incident - API Validation",
    "description": "Automated test incident",
    "severity": "medium"
}'

test_endpoint "Incident Trigger" "$BASE_URL/api/trigger-incident" "POST" "$incident_data"

echo ""
echo "📊 Test Results:"
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"
echo "  📈 Success Rate: $(( PASS * 100 / (PASS + FAIL) ))%"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 All tests passed! System is fully operational."
    echo ""
    echo "🔗 Try these manual tests:"
    echo "  • Open http://localhost:8000 in your browser"
    echo "  • Click 'Trigger Test Incident' button"
    echo "  • Check API docs at http://localhost:8000/api/docs"
    exit 0
else
    echo ""
    echo "⚠️  Some tests failed. Check the system logs:"
    echo "  docker compose logs ai-monitoring"
    exit 1
fi
