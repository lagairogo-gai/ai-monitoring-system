#!/bin/bash
echo "🛑 Stopping Complete MCP + A2A Enhanced AI Monitoring System..."

# Kill the main application
if [[ -f app.pid ]]; then
    PID=$(cat app.pid)
    echo "🔄 Stopping application (PID: $PID)..."
    kill $PID 2>/dev/null && echo "✅ Application stopped" || echo "⚠️  Application may already be stopped"
    rm -f app.pid
else
    echo "🔍 No PID file found, attempting to find and stop process..."
    pkill -f "python.*main.py" 2>/dev/null && echo "✅ Process stopped" || echo "⚠️  No matching process found"
fi

echo "✅ System stopped successfully"
