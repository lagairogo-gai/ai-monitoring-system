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
