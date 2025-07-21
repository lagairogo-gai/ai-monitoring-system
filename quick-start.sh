#!/bin/bash

echo "🚀 AI Monitoring System - Quick Start"
echo "===================================="
echo ""

if [ -f .env ]; then
    echo "✅ System already configured"
    echo "🚀 Starting deployment..."
    ./scripts/deploy.sh
    exit 0
fi

echo "📝 First-time setup detected"
echo ""
echo "🔧 Step 1: Creating configuration file..."
cp .env.template .env

echo "✅ Configuration template created"
echo ""
echo "⚙️  Step 2: Edit your configuration"
echo ""
echo "📋 You can start with basic settings and add integrations later"
echo ""

if command -v code &> /dev/null; then
    echo "🔧 Opening .env in VS Code..."
    code .env
elif command -v nano &> /dev/null; then
    echo "🔧 Opening .env in nano..."
    nano .env
else
    echo "📝 Please edit .env file with your preferred editor:"
    echo "   nano .env"
fi

echo ""
echo "🚀 After editing .env, run:"
echo "   ./scripts/deploy.sh"
echo ""
echo "📊 Then access your dashboard at:"
echo "   http://localhost:8000"
