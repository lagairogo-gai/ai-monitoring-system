#!/bin/bash
# Complete AI Monitoring System Project Setup Script

echo "🚀 Setting up AI Monitoring System project structure..."

# Create main project directory
PROJECT_NAME="ai-monitoring-system"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p {
    src/{agents,api,core,utils},
    frontend/{src/{components,pages,hooks,utils},public,build},
    config,
    scripts,
    docker,
    kubernetes,
    tests/{unit,integration,load,security},
    docs/{api,deployment,architecture},
    logs,
    data,
    ssl,
    monitoring/{prometheus,grafana},
    .github/workflows
}

# Create main application files
echo "📝 Creating main application files..."

cat > src/main.py << 'EOF'
"""
AI-Powered IT Operations Monitoring System
Main application entry point
"""
import os
import asyncio
import logging
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from core.config import SystemConfig
from core.security import SecurityManager
from agents.orchestrator import EnhancedOrchestratorAgent
from agents.monitoring import MonitoringAgent
from agents.rca import RCAAgent
from agents.pager import PagerAgent
from agents.ticketing import TicketingAgent
from agents.email import EmailAgent
from agents.remediation import RemediationAgent
from agents.validation import ValidationAgent
from api.routes import setup_routes
from core.monitoring import SystemMonitor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class MonitoringSystemApp:
    """Main application class"""
    
    def __init__(self):
        self.config = self._load_config()
        self.security_manager = SecurityManager(self.config)
        self.app = FastAPI(
            title="AI Monitoring System",
            description="AI-Powered IT Operations Monitoring",
            version="1.0.0"
        )
        self.orchestrator = None
        self.system_monitor = None
        
        # Setup CORS
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        # Initialize system
        self._initialize_system()
        
    def _load_config(self) -> SystemConfig:
        """Load configuration from environment"""
        return SystemConfig(
            openai_api_key=os.getenv("OPENAI_API_KEY", ""),
            datadog_api_key=os.getenv("DATADOG_API_KEY", ""),
            datadog_app_key=os.getenv("DATADOG_APP_KEY", ""),
            pagerduty_api_key=os.getenv("PAGERDUTY_API_KEY", ""),
            servicenow_username=os.getenv("SERVICENOW_USERNAME", ""),
            servicenow_password=os.getenv("SERVICENOW_PASSWORD", ""),
            email_username=os.getenv("EMAIL_USERNAME", ""),
            email_password=os.getenv("EMAIL_PASSWORD", ""),
            redis_url=os.getenv("REDIS_URL", "redis://localhost:6379/0"),
            database_url=os.getenv("DATABASE_URL", "sqlite:///monitoring.db")
        )
    
    async def _initialize_system(self):
        """Initialize the complete monitoring system"""
        try:
            # Initialize orchestrator
            self.orchestrator = EnhancedOrchestratorAgent(self.config, self.security_manager)
            
            # Initialize all agents
            agents = {
                "monitoring": MonitoringAgent(self.config, self.security_manager),
                "rca": RCAAgent(self.config, self.security_manager),
                "pager": PagerAgent(self.config, self.security_manager),
                "ticketing": TicketingAgent(self.config, self.security_manager),
                "email": EmailAgent(self.config, self.security_manager),
                "remediation": RemediationAgent(self.config, self.security_manager),
                "validation": ValidationAgent(self.config, self.security_manager)
            }
            
            # Register agents with orchestrator
            for name, agent in agents.items():
                self.orchestrator.register_agent(name, agent)
            
            # Initialize system monitoring
            self.system_monitor = SystemMonitor(self.config)
            await self.system_monitor.start_monitoring()
            
            # Setup API routes
            setup_routes(self.app, self.orchestrator, self.security_manager)
            
            # Serve frontend
            self.app.mount("/", StaticFiles(directory="frontend/build", html=True), name="static")
            
            logger.info("AI Monitoring System initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize system: {e}")
            raise
    
    def run(self, host: str = "0.0.0.0", port: int = 8000):
        """Run the application"""
        uvicorn.run(self.app, host=host, port=port)

if __name__ == "__main__":
    app = MonitoringSystemApp()
    app.run()
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
langchain==0.0.352
langchain-openai==0.0.5
langchain-google-genai==0.0.6
openai==1.3.8
google-generativeai==0.3.2
requests==2.31.0
redis==5.0.1
celery==5.3.4
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
alembic==1.13.1
cryptography==41.0.8
pyjwt==2.8.0
bcrypt==4.1.2
pydantic==2.5.2
python-multipart==0.0.6
websockets==12.0
aiofiles==23.2.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
prometheus-client==0.19.0
structlog==23.2.0
tenacity==8.2.3
httpx==0.25.2
psutil==5.9.6
paramiko==3.3.1
aioredis==2.0.1
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc g++ curl nodejs npm git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Build frontend
WORKDIR /app/frontend
RUN npm install && npm run build

# Back to main directory
WORKDIR /app

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "src/main.py"]
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  ai-monitoring:
    build: .
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - DATADOG_API_KEY=${DATADOG_API_KEY}
      - DATADOG_APP_KEY=${DATADOG_APP_KEY}
      - PAGERDUTY_API_KEY=${PAGERDUTY_API_KEY}
      - SERVICENOW_USERNAME=${SERVICENOW_USERNAME}
      - SERVICENOW_PASSWORD=${SERVICENOW_PASSWORD}
      - EMAIL_USERNAME=${EMAIL_USERNAME}
      - EMAIL_PASSWORD=${EMAIL_PASSWORD}
      - REDIS_URL=redis://redis:6379/0
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/monitoring
    depends_on:
      - redis
      - postgres
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    networks:
      - monitoring_network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - monitoring_network

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=monitoring
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - monitoring_network

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring_network

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring_network

volumes:
  redis_data:
  postgres_data:
  grafana_data:

networks:
  monitoring_network:
    driver: bridge
EOF

# Create .env template
cat > .env.template << 'EOF'
# LLM Configuration
OPENAI_API_KEY=your_openai_api_key_here
GOOGLE_API_KEY=your_google_api_key_here
AZURE_ENDPOINT=your_azure_endpoint_here
AZURE_API_KEY=your_azure_api_key_here

# Datadog Configuration
DATADOG_API_KEY=your_datadog_api_key_here
DATADOG_APP_KEY=your_datadog_app_key_here
DATADOG_SITE=datadoghq.eu

# PagerDuty Configuration
PAGERDUTY_API_KEY=your_pagerduty_api_key_here
PAGERDUTY_SERVICE_ID=your_pagerduty_service_id_here

# ServiceNow Configuration
SERVICENOW_INSTANCE=dev221843.service-now.com
SERVICENOW_USERNAME=your_servicenow_username_here
SERVICENOW_PASSWORD=your_servicenow_password_here

# Email Configuration
EMAIL_USERNAME=your_email_here
EMAIL_PASSWORD=your_email_password_here
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587

# Database
REDIS_URL=redis://localhost:6379/0
DATABASE_URL=postgresql://postgres:password@localhost:5432/monitoring
EOF

# Create frontend package.json
cat > frontend/package.json << 'EOF'
{
  "name": "ai-monitoring-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.4",
    "@testing-library/react": "^13.3.0",
    "@testing-library/user-event": "^13.5.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "lucide-react": "^0.263.1",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24"
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

# Create tailwind config
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# Create deployment script
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Deploying AI Monitoring System..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.template .env
    echo "⚠️  Please edit .env file with your actual credentials!"
    exit 1
fi

# Create necessary directories
mkdir -p logs data ssl

# Generate SSL certificates if they don't exist
if [ ! -f ssl/server.crt ]; then
    echo "🔐 Generating SSL certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/server.key \
        -out ssl/server.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
fi

# Build and start services
echo "🏗️  Building and starting services..."
docker-compose build --no-cache
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Application is running!"
    echo "📊 Dashboard: http://localhost:8000"
    echo "📈 Grafana: http://localhost:3000 (admin/admin)"
    echo "🔍 Prometheus: http://localhost:9090"
else
    echo "❌ Application failed to start"
    docker-compose logs ai-monitoring
fi
EOF

chmod +x scripts/deploy.sh

# Create README.md
cat > README.md << 'EOF'
# AI-Powered IT Operations Monitoring System

A comprehensive multi-agent AI monitoring solution that provides intelligent incident detection, automated root cause analysis, and self-healing capabilities.

## 🏗️ Architecture

- **7 AI Agents**: Monitoring, RCA, Pager, Ticketing, Email, Remediation, Validation
- **Orchestrator**: Intelligent workflow coordination
- **Frontend**: React dashboard with real-time visualization
- **Integrations**: Datadog, PagerDuty, ServiceNow

## 🚀 Quick Start

1. **Clone and setup:**
```bash
git clone <your-repo-url>
cd ai-monitoring-system
cp .env.template .env
# Edit .env with your credentials
```

2. **Deploy:**
```bash
./scripts/deploy.sh
```

3. **Access:**
- Dashboard: http://localhost:8000
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090

## 📝 Configuration

Edit `.env` file with your API keys and credentials:
- OpenAI API key for LLM capabilities
- Datadog API keys for monitoring
- PagerDuty integration key
- ServiceNow credentials
- Email settings

## 🔧 Development

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install frontend dependencies
cd frontend && npm install

# Run development server
python src/main.py
```

## 📚 Documentation

- [API Documentation](docs/api/)
- [Deployment Guide](docs/deployment/)
- [Architecture Overview](docs/architecture/)

## 🛡️ Security

The system includes:
- JWT authentication
- Data encryption
- Rate limiting
- Security scanning
- Approval workflows

## 📊 Monitoring

Built-in monitoring with:
- Prometheus metrics
- Grafana dashboards
- Health checks
- Performance monitoring

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Environment
.env
.env.local
.env.production
.venv
env/
venv/

# Logs
logs/
*.log

# Data
data/
*.db
*.sqlite

# SSL certificates
ssl/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# React build
frontend/build/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore

# Temporary files
*.tmp
*.temp
EOF

# Create GitHub Actions workflow
cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        python -m pytest tests/ -v
    
    - name: Security scan
      run: |
        pip install safety bandit
        safety check
        bandit -r src/

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t ai-monitoring:latest .
    
    - name: Test Docker image
      run: |
        docker run --rm ai-monitoring:latest python -c "import src.main; print('Build successful')"

  deploy:
    needs: [test, build]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: |
        echo "Deploy to production"
        # Add your deployment commands here
EOF

echo "✅ Project structure created successfully!"
echo ""
echo "📁 Project structure:"
find . -type f -name "*.py" -o -name "*.yml" -o -name "*.json" -o -name "*.md" -o -name "*.sh" | head -20
echo ""
echo "🚀 Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. cp .env.template .env"
echo "3. Edit .env with your credentials"
echo "4. ./scripts/deploy.sh"
echo ""
echo "📝 Note: You'll need to copy the actual agent code from the artifacts"
echo "   into the respective files in src/agents/ directory"
