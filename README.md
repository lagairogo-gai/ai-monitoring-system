# 🤖 AI-Powered IT Operations Monitoring System

A comprehensive, production-ready multi-agent AI monitoring solution for modern IT operations.

## ✨ Features

- **7 AI Agents**: Monitoring, RCA, Pager, Ticketing, Email, Remediation, Validation
- **Modern Dashboard**: Real-time visualization with beautiful UI
- **Enterprise Integrations**: Datadog, PagerDuty, ServiceNow
- **Production Ready**: Docker deployment with health monitoring

## 🚀 Quick Start

```bash
# Quick setup (recommended)
./quick-start.sh

# Or manual setup
cp .env.template .env
# Edit .env with your API keys
./scripts/deploy.sh

# Test the system
./scripts/test-system.sh
```

## 📊 Access Points

- 🌐 **Web Dashboard**: http://localhost:8000
- 💚 **Health Check**: http://localhost:8000/health
- 📚 **API Docs**: http://localhost:8000/api/docs

## 🔧 Management

```bash
# View logs
docker compose logs -f ai-monitoring

# Stop system
docker compose down

# Restart
docker compose restart
```

## 📄 License

MIT License - Production ready for enterprise use.
