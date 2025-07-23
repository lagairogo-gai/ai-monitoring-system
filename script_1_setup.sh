#!/bin/bash

# =============================================================================
# SCRIPT 1: INITIAL SETUP AND DEPENDENCIES
# Sets up project structure and installs required packages
# =============================================================================

echo "🚀 SCRIPT 1: Initial Setup and Dependencies"
echo "============================================"

# Check if running as root and warn
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  Warning: Running as root. Consider running as a regular user."
fi

# Create directory structure
echo "📁 Creating project structure..."
mkdir -p {src,frontend/src,frontend/public,logs,backups}

# Create package.json for React frontend
echo "📦 Creating React frontend configuration..."
cat > frontend/package.json << 'EOF'
{
  "name": "complete-mcp-a2a-monitoring-frontend",
  "version": "3.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "lucide-react": "^0.263.1",
    "web-vitals": "^3.3.2"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Create requirements.txt for Python backend
echo "🐍 Creating Python backend requirements..."
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
websockets==11.0.3
python-multipart==0.0.6
jinja2==3.1.2
aiofiles==23.2.1
pydantic==2.4.2
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
email-validator==2.1.0
EOF

# Install Python dependencies
echo "🔧 Installing Python dependencies..."
if command -v pip3 &> /dev/null; then
    pip3 install -r requirements.txt --quiet
elif command -v pip &> /dev/null; then
    pip install -r requirements.txt --quiet
else
    echo "❌ Error: pip not found. Please install Python pip first."
    exit 1
fi

# Create backup directory
echo "💾 Creating backup directory..."
BACKUP_DIR="backups/setup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Install Node.js dependencies for frontend
echo "📦 Installing Node.js dependencies..."
cd frontend
if command -v npm &> /dev/null; then
    npm install --silent
elif command -v yarn &> /dev/null; then
    yarn install --silent
else
    echo "⚠️  Warning: npm/yarn not found. Frontend dependencies not installed."
    echo "   Please install Node.js and npm, then run 'npm install' in the frontend directory."
fi
cd ..

echo ""
echo "✅ SCRIPT 1 COMPLETED SUCCESSFULLY!"
echo "=================================="
echo ""
echo "📋 Setup Summary:"
echo "  ✅ Project structure created"
echo "  ✅ Python dependencies installed"
echo "  ✅ React frontend configured"
echo "  ✅ Node.js dependencies installed"
echo ""
echo "🚀 Ready for Script 2: Backend Core Implementation"
echo "   Run: ./script_2_backend_core.sh"