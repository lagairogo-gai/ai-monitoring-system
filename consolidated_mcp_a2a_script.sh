#!/bin/bash

# =============================================================================
# CONSOLIDATED MCP + A2A ENHANCED AI MONITORING SYSTEM
# Complete setup script with Model Context Protocol & Agent-to-Agent Communication
# Version: 3.0.0 - One Script, Complete System
# =============================================================================

echo "🚀 CONSOLIDATED MCP + A2A ENHANCED AI MONITORING SYSTEM"
echo "======================================================"
echo "Complete setup with Model Context Protocol & Agent-to-Agent Communication"
echo ""

# Check if running as root and warn
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  Warning: Running as root. Consider running as a regular user."
fi

# Create directory structure
echo "📁 Creating project structure..."
mkdir -p {src,frontend/src,frontend/public,logs,backups}

# Create package.json for React frontend
echo "📦 Creating React frontend configuration..."
cat > frontend/package.json << 'EOF_PACKAGE'
{
  "name": "mcp-a2a-monitoring-frontend",
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
EOF_PACKAGE

# Create requirements.txt for Python backend
echo "🐍 Creating Python backend requirements..."
cat > requirements.txt << 'EOF_REQUIREMENTS'
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
EOF_REQUIREMENTS

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

# Create complete MCP + A2A enhanced main.py
echo "🧠 Creating MCP + A2A enhanced backend..."
cat > src/main.py << 'EOF_MAIN_PY'
"""
MCP + A2A Enhanced AI Monitoring System
Model Context Protocol + Agent-to-Agent Communication Architecture
Complete consolidated implementation
"""
import os
import asyncio
import json
import time
import uuid
import logging
import sys
import random
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Set
from enum import Enum
from dataclasses import dataclass, field
from pathlib import Path

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Setup logging
logs_dir = Path("logs")
logs_dir.mkdir(exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(logs_dir / "app.log")
    ]
)
logger = logging.getLogger(__name__)

# =============================================================================
# MODEL CONTEXT PROTOCOL (MCP) IMPLEMENTATION
# =============================================================================

@dataclass
class MCPContext:
    """Model Context Protocol - Shared context between agents"""
    context_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    incident_id: str = ""
    context_type: str = "incident_analysis"
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    
    # Context data
    shared_knowledge: Dict[str, Any] = field(default_factory=dict)
    agent_insights: Dict[str, Any] = field(default_factory=dict)
    correlation_patterns: List[Dict[str, Any]] = field(default_factory=list)
    learned_behaviors: Dict[str, Any] = field(default_factory=dict)
    
    # Context metadata
    confidence_scores: Dict[str, float] = field(default_factory=dict)
    data_sources: List[str] = field(default_factory=list)
    context_version: int = 1
    
    def update_context(self, agent_id: str, new_data: Dict[str, Any], confidence: float = 0.8):
        """Update context with new agent insights"""
        self.agent_insights[agent_id] = {
            "data": new_data,
            "timestamp": datetime.now().isoformat(),
            "confidence": confidence
        }
        self.confidence_scores[agent_id] = confidence
        self.updated_at = datetime.now()
        self.context_version += 1
    
    def get_contextual_insights(self, requesting_agent: str) -> Dict[str, Any]:
        """Get relevant context for requesting agent"""
        relevant_insights = {}
        
        for agent_id, insight in self.agent_insights.items():
            if agent_id != requesting_agent and insight["confidence"] > 0.7:
                relevant_insights[agent_id] = insight
        
        return {
            "shared_knowledge": self.shared_knowledge,
            "peer_insights": relevant_insights,
            "correlation_patterns": self.correlation_patterns,
            "context_confidence": sum(self.confidence_scores.values()) / len(self.confidence_scores) if self.confidence_scores else 0.0
        }

class MCPRegistry:
    """Registry for managing MCP contexts"""
    
    def __init__(self):
        self.contexts: Dict[str, MCPContext] = {}
        self.context_subscriptions: Dict[str, Set[str]] = {}
    
    def create_context(self, incident_id: str, context_type: str = "incident_analysis") -> MCPContext:
        context = MCPContext(incident_id=incident_id, context_type=context_type)
        self.contexts[context.context_id] = context
        logger.info(f"📋 Created MCP context {context.context_id} for incident {incident_id}")
        return context
    
    def get_context(self, context_id: str) -> Optional[MCPContext]:
        return self.contexts.get(context_id)
    
    def subscribe_agent(self, agent_id: str, context_id: str):
        if agent_id not in self.context_subscriptions:
            self.context_subscriptions[agent_id] = set()
        self.context_subscriptions[agent_id].add(context_id)

# =============================================================================
# AGENT-TO-AGENT (A2A) PROTOCOL IMPLEMENTATION
# =============================================================================

@dataclass
class A2AMessage:
    """Agent-to-Agent Protocol Message"""
    message_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    sender_agent_id: str = ""
    receiver_agent_id: str = ""
    message_type: str = "info_request"
    content: Dict[str, Any] = field(default_factory=dict)
    priority: str = "normal"
    created_at: datetime = field(default_factory=datetime.now)
    requires_response: bool = False
    correlation_id: str = ""
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "message_id": self.message_id,
            "sender": self.sender_agent_id,
            "receiver": self.receiver_agent_id,
            "type": self.message_type,
            "content": self.content,
            "priority": self.priority,
            "timestamp": self.created_at.isoformat(),
            "requires_response": self.requires_response,
            "correlation_id": self.correlation_id
        }

class A2AProtocol:
    """Agent-to-Agent Communication Protocol"""
    
    def __init__(self):
        self.message_queue: Dict[str, List[A2AMessage]] = {}
        self.active_collaborations: Dict[str, Dict[str, Any]] = {}
        self.message_history: List[A2AMessage] = []
        self.agent_capabilities: Dict[str, List[str]] = {}
    
    def register_agent_capabilities(self, agent_id: str, capabilities: List[str]):
        self.agent_capabilities[agent_id] = capabilities
        logger.info(f"🤝 Registered A2A capabilities for {agent_id}: {capabilities}")
    
    def send_message(self, message: A2AMessage):
        if message.receiver_agent_id not in self.message_queue:
            self.message_queue[message.receiver_agent_id] = []
        
        self.message_queue[message.receiver_agent_id].append(message)
        self.message_history.append(message)
        logger.info(f"📨 A2A Message: {message.sender_agent_id} → {message.receiver_agent_id} [{message.message_type}]")
    
    def get_messages(self, agent_id: str) -> List[A2AMessage]:
        messages = self.message_queue.get(agent_id, [])
        self.message_queue[agent_id] = []
        return messages
    
    def initiate_collaboration(self, initiator: str, participants: List[str], task: str, context: Dict[str, Any]) -> str:
        collab_id = str(uuid.uuid4())
        self.active_collaborations[collab_id] = {
            "id": collab_id,
            "initiator": initiator,
            "participants": participants,
            "task": task,
            "context": context,
            "status": "active",
            "created_at": datetime.now().isoformat(),
            "messages": []
        }
        
        for participant in participants:
            if participant != initiator:
                message = A2AMessage(
                    sender_agent_id=initiator,
                    receiver_agent_id=participant,
                    message_type="collaboration_request",
                    content={
                        "collaboration_id": collab_id,
                        "task": task,
                        "context": context
                    },
                    requires_response=True,
                    correlation_id=collab_id
                )
                self.send_message(message)
        
        logger.info(f"🤝 Started A2A collaboration {collab_id}: {task}")
        return collab_id

# =============================================================================
# ENHANCED AGENT SYSTEM
# =============================================================================

class AgentStatus(Enum):
    IDLE = "idle"
    RUNNING = "running"
    SUCCESS = "success"
    ERROR = "error"
    WAITING = "waiting"
    COLLABORATING = "collaborating"

class IncidentSeverity(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

@dataclass
class AgentExecution:
    agent_id: str
    agent_name: str
    execution_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    incident_id: str = ""
    status: AgentStatus = AgentStatus.IDLE
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    progress: int = 0
    logs: List[Dict[str, Any]] = field(default_factory=list)
    input_data: Dict[str, Any] = field(default_factory=dict)
    output_data: Dict[str, Any] = field(default_factory=dict)
    error_message: str = ""
    duration_seconds: float = 0.0
    
    # MCP + A2A enhancements
    mcp_context_id: str = ""
    a2a_messages_sent: int = 0
    a2a_messages_received: int = 0
    collaboration_sessions: List[str] = field(default_factory=list)
    contextual_insights_used: Dict[str, Any] = field(default_factory=dict)

@dataclass
class Incident:
    id: str = field(default_factory=lambda: f"INC-{int(time.time())}")
    title: str = ""
    description: str = ""
    severity: IncidentSeverity = IncidentSeverity.MEDIUM
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    status: str = "open"
    affected_systems: List[str] = field(default_factory=list)
    workflow_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    workflow_status: str = "in_progress"
    current_agent: str = ""
    completed_agents: List[str] = field(default_factory=list)
    failed_agents: List[str] = field(default_factory=list)
    executions: Dict[str, AgentExecution] = field(default_factory=dict)
    root_cause: str = ""
    resolution: str = ""
    pagerduty_incident_id: str = ""
    servicenow_ticket_id: str = ""
    remediation_applied: List[str] = field(default_factory=list)
    incident_type: str = ""
    
    # MCP + A2A enhancements
    mcp_context_id: str = ""
    a2a_collaborations: List[str] = field(default_factory=list)
    cross_agent_insights: Dict[str, Any] = field(default_factory=dict)

# Diverse incident scenarios
INCIDENT_SCENARIOS = [
    {
        "title": "Database Connection Pool Exhaustion - Production MySQL",
        "description": "Production MySQL database experiencing connection pool exhaustion with applications unable to establish new connections.",
        "severity": "critical",
        "affected_systems": ["mysql-prod-01", "mysql-prod-02", "app-servers-pool"],
        "incident_type": "database",
        "root_cause": "Connection pool exhaustion due to long-running queries and insufficient connection cleanup"
    },
    {
        "title": "DDoS Attack Detected - Main Web Application",
        "description": "Distributed Denial of Service attack targeting main web application. Traffic spike: 50,000 requests/second.",
        "severity": "critical",
        "affected_systems": ["web-app-prod", "load-balancer-01", "cdn-endpoints"],
        "incident_type": "security",
        "root_cause": "Coordinated DDoS attack using botnet across multiple geographic regions"
    },
    {
        "title": "Kubernetes Pod Crash Loop - Microservices",
        "description": "Critical microservices experiencing crash loop backoff in Kubernetes cluster.",
        "severity": "high",
        "affected_systems": ["k8s-cluster-prod", "user-service", "order-service"],
        "incident_type": "container",
        "root_cause": "Memory limits too restrictive for current workload causing OOMKilled events"
    },
    {
        "title": "SSL Certificate Expiration - E-commerce Platform",
        "description": "SSL certificates for main e-commerce platform expired, causing browser security warnings.",
        "severity": "critical",
        "affected_systems": ["ecommerce-frontend", "payment-gateway", "api-endpoints"],
        "incident_type": "security",
        "root_cause": "SSL certificate auto-renewal process failed due to DNS validation issues"
    },
    {
        "title": "API Rate Limit Exceeded - Payment Integration",
        "description": "Third-party payment API rate limits exceeded causing transaction failures.",
        "severity": "high",
        "affected_systems": ["payment-service", "checkout-api", "billing-system"],
        "incident_type": "api",
        "root_cause": "Inefficient API call patterns and missing request throttling mechanisms"
    },
    {
        "title": "Ransomware Detection - File Server Encryption",
        "description": "Ransomware activity detected on file servers with multiple encrypted files.",
        "severity": "critical",
        "affected_systems": ["file-server-01", "backup-server", "shared-storage"],
        "incident_type": "security",
        "root_cause": "Ransomware infiltration through compromised email attachment"
    }
]

# =============================================================================
# ENHANCED WORKFLOW ENGINE
# =============================================================================

class MCPEnhancedWorkflowEngine:
    """Enhanced Workflow Engine with MCP + A2A Protocol support"""
    
    def __init__(self):
        self.active_incidents: Dict[str, Incident] = {}
        self.incident_history: List[Incident] = []
        self.agent_execution_history: Dict[str, List[AgentExecution]] = {
            "monitoring": [], "rca": [], "pager": [], "ticketing": [], 
            "email": [], "remediation": [], "validation": []
        }
        
        # MCP + A2A components
        self.mcp_registry = MCPRegistry()
        self.a2a_protocol = A2AProtocol()
        
        self._register_agent_capabilities()
    
    def _register_agent_capabilities(self):
        """Register agent capabilities for A2A collaboration"""
        capabilities = {
            "monitoring": ["metric_analysis", "anomaly_detection", "system_health_check"],
            "rca": ["root_cause_analysis", "pattern_correlation", "dependency_mapping"],
            "pager": ["escalation_routing", "stakeholder_notification", "team_coordination"],
            "ticketing": ["ticket_classification", "priority_assignment", "workflow_routing"],
            "email": ["stakeholder_communication", "status_broadcasting", "executive_reporting"],
            "remediation": ["automated_fixes", "rollback_procedures", "system_recovery"],
            "validation": ["health_verification", "performance_testing", "compliance_checking"]
        }
        
        for agent_id, agent_capabilities in capabilities.items():
            self.a2a_protocol.register_agent_capabilities(agent_id, agent_capabilities)
    
    async def trigger_incident_workflow(self, incident_data: Dict[str, Any]) -> Incident:
        """Enhanced incident workflow with MCP + A2A support"""
        scenario = random.choice(INCIDENT_SCENARIOS)
        incident = Incident(
            title=scenario["title"],
            description=scenario["description"],
            severity=IncidentSeverity(scenario["severity"]),
            affected_systems=scenario["affected_systems"],
            incident_type=scenario["incident_type"]
        )
        
        # Create MCP context
        mcp_context = self.mcp_registry.create_context(incident.id, "incident_analysis")
        incident.mcp_context_id = mcp_context.context_id
        
        # Initialize shared context
        mcp_context.shared_knowledge = {
            "incident_details": {
                "title": incident.title,
                "type": incident.incident_type,
                "severity": incident.severity.value,
                "affected_systems": incident.affected_systems
            },
            "scenario_data": scenario
        }
        
        logger.info(f"🎭 Selected MCP+A2A scenario: {scenario['incident_type']} - {scenario['title']}")
        
        self.active_incidents[incident.id] = incident
        asyncio.create_task(self._execute_enhanced_workflow(incident))
        return incident
    
    async def _execute_enhanced_workflow(self, incident: Incident):
        """Execute workflow with MCP context sharing and A2A collaboration"""
        workflow_steps = [
            ("monitoring", self._execute_enhanced_monitoring_agent),
            ("rca", self._execute_enhanced_rca_agent),
            ("pager", self._execute_enhanced_pager_agent),
            ("ticketing", self._execute_enhanced_ticketing_agent),
            ("email", self._execute_enhanced_email_agent),
            ("remediation", self._execute_enhanced_remediation_agent),
            ("validation", self._execute_enhanced_validation_agent)
        ]
        
        try:
            for agent_id, agent_func in workflow_steps:
                incident.current_agent = agent_id
                incident.updated_at = datetime.now()
                
                # Subscribe agent to MCP context
                self.mcp_registry.subscribe_agent(agent_id, incident.mcp_context_id)
                
                execution = await agent_func(incident)
                incident.executions[agent_id] = execution
                self.agent_execution_history[agent_id].append(execution)
                
                if execution.status == AgentStatus.SUCCESS:
                    incident.completed_agents.append(agent_id)
                else:
                    incident.failed_agents.append(agent_id)
                
                # Process A2A messages
                await self._process_a2a_messages(agent_id, incident)
                
                await asyncio.sleep(random.uniform(1.5, 3.0))
            
            incident.workflow_status = "completed"
            incident.current_agent = ""
            incident.status = "resolved" if len(incident.failed_agents) == 0 else "partially_resolved"
            
            self.incident_history.append(incident)
            del self.active_incidents[incident.id]
            
        except Exception as e:
            incident.workflow_status = "failed"
            incident.status = "failed"
            logger.error(f"Enhanced workflow failed for incident {incident.id}: {str(e)}")
    
    async def _process_a2a_messages(self, agent_id: str, incident: Incident):
        """Process pending A2A messages for an agent"""
        messages = self.a2a_protocol.get_messages(agent_id)
        
        for message in messages:
            logger.info(f"📨 Processing A2A message for {agent_id}: {message.message_type}")
            
            if agent_id in incident.executions:
                incident.executions[agent_id].a2a_messages_received += 1
            
            # Handle message types
            if message.message_type == "collaboration_request":
                collab_id = message.content.get("collaboration_id")
                if agent_id in incident.executions:
                    incident.executions[agent_id].collaboration_sessions.append(collab_id)
            elif message.message_type == "data_share":
                # Update MCP context with shared data
                mcp_context = self.mcp_registry.get_context(incident.mcp_context_id)
                if mcp_context:
                    shared_data = message.content.get("data", {})
                    confidence = message.content.get("confidence", 0.8)
                    mcp_context.update_context(message.sender_agent_id, shared_data, confidence)
    
    # Enhanced agent implementations
    async def _execute_enhanced_monitoring_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="monitoring", agent_name="Enhanced Monitoring Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            # Get MCP context
            mcp_context = self.mcp_registry.get_context(incident.mcp_context_id)
            if mcp_context:
                contextual_insights = mcp_context.get_contextual_insights("monitoring")
                execution.contextual_insights_used = contextual_insights
            
            await self._log_activity(execution, f"🔍 Enhanced monitoring with MCP context for {incident.incident_type}...")
            execution.progress = 30
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            # Type-specific monitoring with A2A collaboration
            if incident.incident_type == "security":
                await self._log_activity(execution, "🚨 Security threat analysis with A2A intelligence sharing...")
                execution.progress = 70
                
                # Share threat data with security-capable agents
                threat_data = {
                    "threat_indicators": random.randint(100, 500),
                    "attack_vectors": ["ddos", "malware", "phishing"],
                    "severity_assessment": incident.severity.value
                }
                
                # Send to RCA agent for pattern analysis
                message = A2AMessage(
                    sender_agent_id="monitoring",
                    receiver_agent_id="rca",
                    message_type="data_share",
                    content={"data": threat_data, "confidence": 0.9}
                )
                self.a2a_protocol.send_message(message)
                execution.a2a_messages_sent += 1
                
                execution.output_data = {
                    "anomaly_type": "security_breach",
                    "threat_level": "Critical",
                    "a2a_intelligence_shared": True
                }
            
            elif incident.incident_type == "database":
                await self._log_activity(execution, "📊 Database metrics analysis with peer collaboration...")
                execution.progress = 60
                
                # Request collaboration with RCA agent
                collab_id = self.a2a_protocol.initiate_collaboration(
                    "monitoring", ["rca"], 
                    "database_pattern_analysis",
                    {"incident_type": incident.incident_type, "severity": incident.severity.value}
                )
                execution.collaboration_sessions.append(collab_id)
                
                execution.output_data = {
                    "anomaly_type": "connection_exhaustion",
                    "metrics_analyzed": 15420,
                    "collaboration_initiated": True
                }
            
            else:
                await self._log_activity(execution, f"📊 Standard {incident.incident_type} monitoring with MCP context...")
                execution.output_data = {"anomaly_type": f"{incident.incident_type}_degradation"}
            
            # Update MCP context
            if mcp_context:
                mcp_context.update_context("monitoring", execution.output_data, 0.9)
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Enhanced monitoring completed with MCP+A2A features")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_rca_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="rca", agent_name="Enhanced RCA Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            # Get enhanced context from MCP
            mcp_context = self.mcp_registry.get_context(incident.mcp_context_id)
            contextual_data = {}
            if mcp_context:
                contextual_data = mcp_context.get_contextual_insights("rca")
                execution.contextual_insights_used = contextual_data
            
            await self._log_activity(execution, "🧠 Enhanced RCA analysis with cross-agent insights...")
            execution.progress = 30
            await asyncio.sleep(random.uniform(2.0, 3.0))
            
            # Use contextual insights for better analysis
            confidence_boost = 0.15 if contextual_data.get("peer_insights") else 0.0
            if confidence_boost:
                await self._log_activity(execution, "💡 Leveraging peer agent insights for enhanced analysis...")
            
            # Get scenario-specific root cause
            scenario = None
            for s in INCIDENT_SCENARIOS:
                if s["title"] == incident.title:
                    scenario = s
                    break
            
            root_cause = scenario["root_cause"] if scenario else f"{incident.incident_type.title()} issue requiring investigation"
            enhanced_confidence = min(0.99, random.uniform(0.85, 0.97) + confidence_boost)
            
            await self._log_activity(execution, "🔍 Cross-correlating with MCP knowledge base...")
            execution.progress = 70
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            execution.output_data = {
                "root_cause": root_cause,
                "confidence": enhanced_confidence,
                "mcp_enhanced": True,
                "used_peer_insights": bool(contextual_data.get("peer_insights")),
                "context_confidence": contextual_data.get("context_confidence", 0.0)
            }
            
            # Share findings with remediation agent
            if incident.incident_type in ["security", "database", "container"]:
                rca_findings = {
                    "root_cause_summary": root_cause,
                    "confidence_score": enhanced_confidence,
                    "recommended_actions": ["automated_remediation", "system_optimization"]
                }
                
                message = A2AMessage(
                    sender_agent_id="rca",
                    receiver_agent_id="remediation",
                    message_type="data_share",
                    content={"data": rca_findings, "confidence": enhanced_confidence},
                    priority="high"
                )
                self.a2a_protocol.send_message(message)
                execution.a2a_messages_sent += 1
            
            # Update MCP context
            if mcp_context:
                mcp_context.update_context("rca", execution.output_data, enhanced_confidence)
            
            incident.root_cause = execution.output_data["root_cause"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ Enhanced RCA completed - Confidence: {enhanced_confidence:.1%}")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_pager_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="pager", agent_name="Enhanced Pager Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"📞 Intelligent escalation with MCP context...")
            execution.progress = 40
            await asyncio.sleep(random.uniform(1.0, 1.8))
            
            team = self._get_escalation_team(incident.incident_type)
            
            await self._log_activity(execution, f"📱 Context-aware escalation to {team}...")
            execution.progress = 80
            await asyncio.sleep(random.uniform(1.0, 1.5))
            
            # Request coordination with email agent
            coord_message = A2AMessage(
                sender_agent_id="pager",
                receiver_agent_id="email",
                message_type="collaboration_request",
                content={
                    "task": "coordinated_notification",
                    "escalation_team": team,
                    "incident_details": {
                        "type": incident.incident_type,
                        "severity": incident.severity.value,
                        "title": incident.title
                    }
                },
                priority="high"
            )
            self.a2a_protocol.send_message(coord_message)
            execution.a2a_messages_sent += 1
            
            execution.output_data = {
                "pagerduty_incident_id": f"PD-{incident.incident_type.upper()}-{incident.id[-6:]}",
                "escalated_to": team,
                "on_call_engineer": self._get_on_call_engineer(incident.incident_type),
                "coordinated_notification": True
            }
            
            incident.pagerduty_incident_id = execution.output_data["pagerduty_incident_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Enhanced escalation with A2A coordination completed")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_ticketing_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="ticketing", agent_name="Enhanced Ticketing Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"🎫 MCP-enhanced ticket creation...")
            execution.progress = 50
            await asyncio.sleep(random.uniform(1.2, 2.0))
            
            priority, category = self._get_enhanced_ticket_classification(incident)
            
            execution.output_data = {
                "ticket_id": f"MCP-{incident.incident_type.upper()}{datetime.now().strftime('%Y%m%d')}{incident.id[-4:]}",
                "priority": priority,
                "category": category,
                "mcp_enhanced_classification": True
            }
            
            incident.servicenow_ticket_id = execution.output_data["ticket_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ MCP-enhanced ticket created")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_email_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="email", agent_name="Enhanced Email Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "📧 A2A coordinated communication...")
            execution.progress = 60
            await asyncio.sleep(random.uniform(1.0, 1.5))
            
            stakeholders = self._get_enhanced_stakeholders(incident)
            
            execution.output_data = {
                "emails_sent": stakeholders,
                "a2a_coordinated": True,
                "mcp_context_used": True
            }
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Enhanced communication completed")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_remediation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="remediation", agent_name="Enhanced Remediation Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            # Get RCA insights from MCP context
            mcp_context = self.mcp_registry.get_context(incident.mcp_context_id)
            rca_insights = {}
            if mcp_context and "rca" in mcp_context.agent_insights:
                rca_insights = mcp_context.agent_insights["rca"]["data"]
            
            await self._log_activity(execution, "🔧 Intelligent remediation with RCA insights...")
            execution.progress = 30
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            # Enhanced remediation based on RCA findings
            base_actions = self._get_remediation_actions(incident.incident_type)
            if rca_insights.get("recommended_actions"):
                enhanced_actions = base_actions + ["mcp_optimized_fix", "a2a_coordinated_recovery"]
            else:
                enhanced_actions = base_actions
            
            await self._log_activity(execution, f"⚡ Executing {len(enhanced_actions)} AI-optimized procedures...")
            execution.progress = 80
            await asyncio.sleep(random.uniform(2.0, 3.0))
            
            execution.output_data = {
                "actions_performed": enhanced_actions,
                "rca_enhanced": bool(rca_insights),
                "intelligence_confidence": rca_insights.get("confidence", 0.8)
            }
            
            incident.remediation_applied = execution.output_data["actions_performed"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Enhanced remediation completed")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_enhanced_validation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="validation", agent_name="Enhanced Validation Agent",
            incident_id=incident.id, mcp_context_id=incident.mcp_context_id
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            # Get comprehensive context from MCP
            mcp_context = self.mcp_registry.get_context(incident.mcp_context_id)
            confidence_factors = []
            if mcp_context and mcp_context.confidence_scores:
                confidence_factors = list(mcp_context.confidence_scores.values())
            
            overall_confidence = sum(confidence_factors) / len(confidence_factors) if confidence_factors else 0.8
            
            await self._log_activity(execution, f"🔍 Comprehensive validation with MCP context...")
            execution.progress = 40
            await asyncio.sleep(random.uniform(2.0, 3.0))
            
            await self._log_activity(execution, f"📊 Cross-agent validation with {len(confidence_factors)} data sources...")
            execution.progress = 80
            await asyncio.sleep(random.uniform(1.5, 2.0))
            
            # Success rate influenced by overall confidence
            success_threshold = 0.75 + (overall_confidence * 0.15)
            resolution_successful = random.random() < success_threshold
            
            execution.output_data = {
                "incident_resolved": resolution_successful,
                "validation_score": random.uniform(0.90, 0.98) if resolution_successful else random.uniform(0.70, 0.85),
                "mcp_enhanced": True,
                "cross_agent_validation": True,
                "confidence_factors_used": len(confidence_factors),
                "overall_system_confidence": overall_confidence
            }
            
            # Final MCP context update
            if mcp_context:
                mcp_context.update_context("validation", execution.output_data, 0.95)
                mcp_context.shared_knowledge["final_resolution"] = {
                    "status": "resolved" if resolution_successful else "partially_resolved",
                    "confidence": overall_confidence,
                    "validated_at": datetime.now().isoformat()
                }
            
            if resolution_successful:
                incident.resolution = f"{incident.incident_type.title()} fully resolved using MCP+A2A enhanced analysis with {overall_confidence:.1%} confidence"
                incident.status = "resolved"
            else:
                incident.resolution = f"{incident.incident_type.title()} partially resolved - MCP analysis suggests continued monitoring"
                incident.status = "partially_resolved"
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            status_msg = "fully resolved" if resolution_successful else "partially resolved"
            await self._log_activity(execution, f"✅ Enhanced validation completed - Issue {status_msg}")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    # Helper methods
    def _get_escalation_team(self, incident_type: str) -> str:
        teams = {
            "database": "Database Engineering",
            "security": "Security Operations Center", 
            "network": "Network Operations Team",
            "infrastructure": "Infrastructure Engineering",
            "container": "Platform Engineering",
            "api": "API Platform Team"
        }
        return teams.get(incident_type, "General Operations")
    
    def _get_on_call_engineer(self, incident_type: str) -> str:
        engineers = {
            "database": random.choice(["Sarah Chen", "Marcus Rodriguez"]),
            "security": random.choice(["Alex Thompson", "Jordan Kim"]),
            "container": random.choice(["Sam Parker", "Jessica Liu"])
        }
        return engineers.get(incident_type, "Jamie Smith")
    
    def _get_enhanced_ticket_classification(self, incident: Incident) -> tuple:
        priority_map = {"critical": "0 - Emergency", "high": "1 - High", "medium": "2 - Medium", "low": "3 - Low"}
        base_priority = priority_map.get(incident.severity.value, "2 - Medium")
        
        categories = {
            "database": "Database Services - MCP Enhanced",
            "security": "Security Incident - A2A Coordinated",
            "container": "Container Platform - AI Optimized"
        }
        category = categories.get(incident.incident_type, "General - AI Enhanced")
        
        return base_priority, category
    
    def _get_enhanced_stakeholders(self, incident: Incident) -> List[str]:
        return [f"{incident.incident_type}-team@company.com", "mcp-ops@company.com", "a2a-coordination@company.com"]
    
    def _get_remediation_actions(self, incident_type: str) -> List[str]:
        actions = {
            "database": ["connection_pool_scaling", "query_optimization", "replica_failover"],
            "security": ["system_isolation", "credential_rotation", "security_patching"],
            "container": ["pod_restart", "resource_scaling", "node_optimization"],
            "api": ["rate_limit_tuning", "backend_scaling", "circuit_breaker_reset"]
        }
        return actions.get(incident_type, ["service_restart", "resource_scaling"])
    
    async def _log_activity(self, execution: AgentExecution, message: str, level: str = "INFO"):
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "level": level,
            "message": message,
            "execution_id": execution.execution_id,
            "mcp_context_id": execution.mcp_context_id
        }
        execution.logs.append(log_entry)
        logger.info(f"[{execution.incident_id}] {execution.agent_name}: {message}")

# Global enhanced workflow engine
workflow_engine = MCPEnhancedWorkflowEngine()

# =============================================================================
# FASTAPI APPLICATION WITH MCP + A2A APIS
# =============================================================================

class MCPEnhancedMonitoringApp:
    def __init__(self):
        self.app = FastAPI(
            title="MCP + A2A Enhanced AI Monitoring System",
            description="Model Context Protocol + Agent-to-Agent Communication Architecture",
            version="3.0.0",
            docs_url="/api/docs"
        )
        
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        self._setup_routes()
    
    def _setup_routes(self):
        @self.app.post("/api/trigger-incident")
        async def trigger_incident(incident_data: dict):
            incident = await workflow_engine.trigger_incident_workflow(incident_data)
            return {
                "incident_id": incident.id,
                "workflow_id": incident.workflow_id,
                "mcp_context_id": incident.mcp_context_id,
                "status": "workflow_started",
                "title": incident.title,
                "severity": incident.severity.value,
                "incident_type": incident.incident_type,
                "message": f"MCP+A2A Enhanced Incident {incident.id} workflow initiated",
                "enhanced_features": ["Model Context Protocol", "Agent-to-Agent Communication"]
            }
        
        @self.app.get("/api/mcp/contexts")
        async def get_mcp_contexts():
            contexts = []
            for context_id, context in workflow_engine.mcp_registry.contexts.items():
                contexts.append({
                    "context_id": context.context_id,
                    "incident_id": context.incident_id,
                    "created_at": context.created_at.isoformat(),
                    "context_version": context.context_version,
                    "agent_count": len(context.agent_insights),
                    "confidence_avg": sum(context.confidence_scores.values()) / len(context.confidence_scores) if context.confidence_scores else 0.0
                })
            
            return {"total_contexts": len(contexts), "contexts": contexts}
        
        @self.app.get("/api/a2a/messages/history")
        async def get_a2a_message_history(limit: int = 20):
            recent_messages = workflow_engine.a2a_protocol.message_history[-limit:]
            return {
                "total_messages": len(workflow_engine.a2a_protocol.message_history),
                "recent_messages": [msg.to_dict() for msg in recent_messages]
            }
        
        @self.app.get("/api/a2a/collaborations")
        async def get_a2a_collaborations():
            collaborations = []
            for collab_id, collab in workflow_engine.a2a_protocol.active_collaborations.items():
                collaborations.append({
                    "collaboration_id": collab_id,
                    "initiator": collab["initiator"],
                    "participants": collab["participants"],
                    "task": collab["task"],
                    "status": collab["status"],
                    "created_at": collab["created_at"]
                })
            
            return {"collaborations": collaborations}
        
        @self.app.get("/api/incidents/{incident_id}/status")
        async def get_enhanced_incident_status(incident_id: str):
            incident = None
            if incident_id in workflow_engine.active_incidents:
                incident = workflow_engine.active_incidents[incident_id]
            else:
                incident = next((i for i in workflow_engine.incident_history if i.id == incident_id), None)
            
            if not incident:
                return {"error": "Incident not found"}
            
            # Get MCP context data
            mcp_data = {}
            if incident.mcp_context_id:
                context = workflow_engine.mcp_registry.get_context(incident.mcp_context_id)
                if context:
                    mcp_data = {
                        "context_version": context.context_version,
                        "agent_insights_count": len(context.agent_insights),
                        "avg_confidence": sum(context.confidence_scores.values()) / len(context.confidence_scores) if context.confidence_scores else 0.0
                    }
            
            # Get A2A data
            a2a_data = {
                "total_messages_sent": sum(exec.a2a_messages_sent for exec in incident.executions.values()),
                "total_messages_received": sum(exec.a2a_messages_received for exec in incident.executions.values()),
                "active_collaborations": len(incident.a2a_collaborations)
            }
            
            return {
                "incident_id": incident.id,
                "title": incident.title,
                "severity": incident.severity.value,
                "incident_type": incident.incident_type,
                "status": incident.status,
                "workflow_status": incident.workflow_status,
                "resolution": incident.resolution,
                "enhanced_features": {
                    "mcp_context": mcp_data,
                    "a2a_protocol": a2a_data
                },
                "executions": {
                    agent_id: {
                        "status": execution.status.value,
                        "progress": execution.progress,
                        "mcp_enhanced": bool(execution.contextual_insights_used),
                        "a2a_messages": {
                            "sent": execution.a2a_messages_sent,
                            "received": execution.a2a_messages_received
                        },
                        "collaborations": len(execution.collaboration_sessions)
                    }
                    for agent_id, execution in incident.executions.items()
                }
            }
        
        @self.app.get("/api/dashboard/stats")
        async def get_enhanced_dashboard_stats():
            all_incidents = list(workflow_engine.active_incidents.values()) + workflow_engine.incident_history
            
            # MCP statistics
            mcp_stats = {
                "total_contexts": len(workflow_engine.mcp_registry.contexts),
                "avg_context_confidence": 0.0
            }
            
            if workflow_engine.mcp_registry.contexts:
                confidences = []
                for context in workflow_engine.mcp_registry.contexts.values():
                    if context.confidence_scores:
                        confidences.extend(context.confidence_scores.values())
                mcp_stats["avg_context_confidence"] = sum(confidences) / len(confidences) if confidences else 0.0
            
            # A2A statistics
            a2a_stats = {
                "total_messages": len(workflow_engine.a2a_protocol.message_history),
                "active_collaborations": len(workflow_engine.a2a_protocol.active_collaborations),
                "registered_agents": len(workflow_engine.a2a_protocol.agent_capabilities)
            }
            
            return {
                "incidents": {
                    "total_all_time": len(all_incidents),
                    "active": len(workflow_engine.active_incidents),
                    "enhanced_resolution_rate": 95.0
                },
                "enhanced_features": {
                    "mcp": mcp_stats,
                    "a2a": a2a_stats
                },
                "system": {
                    "version": "3.0.0 - MCP+A2A Enhanced",
                    "available_scenarios": len(INCIDENT_SCENARIOS)
                }
            }
        
        @self.app.get("/health")
        async def enhanced_health_check():
            return {
                "status": "healthy",
                "service": "MCP + A2A Enhanced AI Monitoring System",
                "version": "3.0.0",
                "architecture": {
                    "model_context_protocol": "Active",
                    "agent_to_agent_protocol": "Active",
                    "cross_agent_intelligence": "Enabled"
                },
                "features": [
                    "Model Context Protocol (MCP)",
                    "Agent-to-Agent (A2A) Communication",
                    "Cross-agent intelligence sharing",
                    "Collaborative problem solving"
                ],
                "workflow_engine": {
                    "active_incidents": len(workflow_engine.active_incidents),
                    "mcp_contexts": len(workflow_engine.mcp_registry.contexts),
                    "a2a_collaborations": len(workflow_engine.a2a_protocol.active_collaborations)
                }
            }
        
        # Serve frontend
        frontend_path = Path("frontend/build")
        if frontend_path.exists():
            self.app.mount("/", StaticFiles(directory=str(frontend_path), html=True), name="static")
        else:
            @self.app.get("/")
            async def root():
                return {
                    "message": "🚀 MCP + A2A Enhanced AI Monitoring System v3.0",
                    "version": "3.0.0",
                    "architecture": "Model Context Protocol + Agent-to-Agent Communication",
                    "new_features": [
                        "🧠 Model Context Protocol - Shared intelligence across agents",
                        "🤝 Agent-to-Agent Protocol - Direct agent communication",
                        "🔗 Cross-agent collaboration and coordination"
                    ]
                }
    
    def run(self, host: str = "0.0.0.0", port: int = 8000):
        logger.info("🚀 Starting MCP + A2A Enhanced AI Monitoring System v3.0...")
        logger.info("🧠 Model Context Protocol: ACTIVE")
        logger.info("🤝 Agent-to-Agent Protocol: ACTIVE")
        uvicorn.run(self.app, host=host, port=port, log_level="info")

if __name__ == "__main__":
    app = MCPEnhancedMonitoringApp()
    app.run()
EOF_MAIN_PY

# Create enhanced React frontend
echo "🎨 Creating MCP + A2A enhanced frontend..."
cat > frontend/src/App.js << 'EOF_FRONTEND'
import React, { useState, useEffect } from 'react';
import { 
  Activity, AlertTriangle, Monitor, Search, Bell, Ticket, Mail, Settings, 
  Shield, TrendingUp, Zap, RefreshCw, Eye, X, Brain, MessageSquare, 
  Network, Share2, Target, Database, Wifi, Server, Lock, Container, HardDrive
} from 'lucide-react';

function App() {
  const [dashboardStats, setDashboardStats] = useState({});
  const [incidents, setIncidents] = useState([]);
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [mcpContexts, setMcpContexts] = useState([]);
  const [a2aMessages, setA2aMessages] = useState([]);
  const [a2aCollaborations, setA2aCollaborations] = useState([]);
  const [showMcpModal, setShowMcpModal] = useState(false);
  const [showA2aModal, setShowA2aModal] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [activeWorkflows, setActiveWorkflows] = useState(new Set());

  useEffect(() => {
    fetchAllData();
    const interval = setInterval(fetchAllData, 3000);
    return () => clearInterval(interval);
  }, []);

  const fetchAllData = async () => {
    try {
      const [statsRes, incidentsRes, mcpRes, a2aRes] = await Promise.all([
        fetch('/api/dashboard/stats'),
        fetch('/api/incidents?limit=10'),
        fetch('/api/mcp/contexts'),
        fetch('/api/a2a/messages/history?limit=20')
      ]);

      const [statsData, incidentsData, mcpData, a2aData] = await Promise.all([
        statsRes.json(),
        incidentsRes.json(),
        mcpData.json(),
        a2aData.json()
      ]);

      setDashboardStats(statsData);
      setIncidents(incidentsData.incidents || []);
      setMcpContexts(mcpData.contexts || []);
      setA2aMessages(a2aData.recent_messages || []);
      setIsLoading(false);
      
      const activeIds = new Set(incidentsData.incidents
        .filter(i => i.workflow_status === 'in_progress')
        .map(i => i.id));
      setActiveWorkflows(activeIds);
      
    } catch (err) {
      console.error('Failed to fetch data:', err);
      setIsLoading(false);
    }
  };

  const fetchA2aCollaborations = async () => {
    try {
      const response = await fetch('/api/a2a/collaborations');
      const data = await response.json();
      setA2aCollaborations(data.collaborations || []);
    } catch (err) {
      console.error('Failed to fetch A2A collaborations:', err);
    }
  };

  const triggerTestIncident = async () => {
    try {
      const response = await fetch('/api/trigger-incident', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: '', description: '', severity: 'high' })
      });
      const result = await response.json();
      
      const alertMessage = `🚀 NEW MCP+A2A ENHANCED INCIDENT!\n\n` +
                          `Type: ${result.incident_type}\n` +
                          `Severity: ${result.severity}\n` +
                          `ID: ${result.incident_id}\n` +
                          `MCP Context: ${result.mcp_context_id?.slice(0,8)}...\n\n` +
                          `🧠 Model Context Protocol: Agents share intelligence\n` +
                          `🤝 Agent-to-Agent Protocol: Direct collaboration`;
      
      alert(alertMessage);
      fetchAllData();
      
    } catch (err) {
      console.error('Failed to trigger incident:', err);
      alert('Failed to trigger incident. Please try again.');
    }
  };

  const viewIncidentDetails = async (incidentId) => {
    try {
      const response = await fetch(`/api/incidents/${incidentId}/status`);
      const incidentData = await response.json();
      setSelectedIncident(incidentData);
    } catch (err) {
      console.error('Failed to fetch incident details:', err);
    }
  };

  const getIncidentTypeIcon = (incidentType) => {
    const icons = {
      database: Database, security: Lock, network: Wifi,
      infrastructure: Server, container: Container, api: Activity
    };
    return icons[incidentType] || AlertTriangle;
  };

  const getIncidentTypeColor = (incidentType) => {
    const colors = {
      database: 'text-blue-400', security: 'text-red-400', 
      container: 'text-cyan-400', api: 'text-pink-400'
    };
    return colors[incidentType] || 'text-gray-400';
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="flex items-center justify-center mb-4">
            <Brain className="w-8 h-8 text-purple-400 animate-pulse mr-2" />
            <MessageSquare className="w-8 h-8 text-blue-400 animate-bounce mr-2" />
            <Network className="w-8 h-8 text-green-400 animate-spin" />
          </div>
          <h2 className="text-2xl font-bold text-white mb-2">Loading MCP + A2A Enhanced System</h2>
          <p className="text-gray-400">Initializing Model Context Protocol and Agent-to-Agent Communication...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900">
      <style jsx global>{`
        .glass {
          background: rgba(255, 255, 255, 0.1);
          backdrop-filter: blur(10px);
          border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .mcp-glow { box-shadow: 0 0 20px rgba(168, 85, 247, 0.3); }
        .a2a-glow { box-shadow: 0 0 20px rgba(59, 130, 246, 0.3); }
      `}</style>
      
      <header className="glass border-b border-purple-700/50">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="p-2 bg-gradient-to-br from-purple-500/20 to-blue-500/20 rounded-xl">
                <div className="flex space-x-1">
                  <Brain className="w-6 h-6 text-purple-400" />
                  <MessageSquare className="w-6 h-6 text-blue-400" />
                </div>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-white">MCP + A2A Enhanced AI System</h1>
                <p className="text-sm text-gray-300">Model Context Protocol • Agent-to-Agent Communication • Collective Intelligence</p>
              </div>
              {activeWorkflows.size > 0 && (
                <div className="flex items-center space-x-2 ml-8 bg-gradient-to-r from-purple-500/20 to-blue-500/20 px-3 py-1 rounded-lg">
                  <Network className="w-4 h-4 text-purple-400 animate-spin" />
                  <span className="text-purple-400 font-medium">{activeWorkflows.size} Enhanced Workflows</span>
                </div>
              )}
            </div>
            <div className="text-right">
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                <p className="text-sm font-medium text-green-400">MCP + A2A Active</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-6 py-8">
        {/* Enhanced Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <div className="glass mcp-glow rounded-xl p-6 hover:bg-purple-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-purple-300">MCP Contexts</p>
                <p className="text-2xl font-bold text-purple-400">{dashboardStats.enhanced_features?.mcp?.total_contexts || 0}</p>
                <p className="text-xs text-purple-500 mt-1">Shared Intelligence</p>
              </div>
              <Brain className="w-8 h-8 text-purple-400" />
            </div>
          </div>

          <div className="glass a2a-glow rounded-xl p-6 hover:bg-blue-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-300">A2A Messages</p>
                <p className="text-2xl font-bold text-blue-400">{dashboardStats.enhanced_features?.a2a?.total_messages || 0}</p>
                <p className="text-xs text-blue-500 mt-1">Agent Communication</p>
              </div>
              <MessageSquare className="w-8 h-8 text-blue-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-green-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-green-300">Active Incidents</p>
                <p className="text-2xl font-bold text-green-400">{dashboardStats.incidents?.active || 0}</p>
                <p className="text-xs text-green-500 mt-1">Enhanced Resolution</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-green-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-yellow-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-yellow-300">Collaborations</p>
                <p className="text-2xl font-bold text-yellow-400">{dashboardStats.enhanced_features?.a2a?.active_collaborations || 0}</p>
                <p className="text-xs text-yellow-500 mt-1">Cross-agent</p>
              </div>
              <Share2 className="w-8 h-8 text-yellow-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-pink-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-pink-300">Intelligence</p>
                <p className="text-2xl font-bold text-pink-400">
                  {Math.round((dashboardStats.enhanced_features?.mcp?.avg_context_confidence || 0) * 100)}%
                </p>
                <p className="text-xs text-pink-500 mt-1">Confidence</p>
              </div>
              <Target className="w-8 h-8 text-pink-400" />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          {/* Enhanced Controls */}
          <div className="xl:col-span-1 space-y-6">
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Enhanced Controls</h3>
              <div className="space-y-3">
                <button
                  onClick={triggerTestIncident}
                  className="w-full bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 hover:from-purple-600 hover:via-pink-600 hover:to-red-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2 shadow-lg transform hover:scale-105"
                >
                  <div className="flex space-x-1">
                    <Brain className="w-4 h-4" />
                    <MessageSquare className="w-4 h-4" />
                  </div>
                  <span>Generate MCP+A2A Incident</span>
                </button>
                <p className="text-xs text-gray-400 text-center">
                  Enhanced with collective intelligence & agent collaboration
                </p>
                
                <div className="grid grid-cols-2 gap-2">
                  <button 
                    onClick={() => {setShowMcpModal(true); fetchAllData();}}
                    className="bg-gradient-to-r from-purple-500/20 to-purple-600/20 border border-purple-500/50 text-purple-300 px-3 py-2 rounded-lg text-sm font-medium hover:bg-purple-500/30 transition-all flex items-center justify-center space-x-1"
                  >
                    <Brain className="w-3 h-3" />
                    <span>MCP Status</span>
                  </button>
                  
                  <button 
                    onClick={() => {setShowA2aModal(true); fetchA2aCollaborations();}}
                    className="bg-gradient-to-r from-blue-500/20 to-blue-600/20 border border-blue-500/50 text-blue-300 px-3 py-2 rounded-lg text-sm font-medium hover:bg-blue-500/30 transition-all flex items-center justify-center space-x-1"
                  >
                    <MessageSquare className="w-3 h-3" />
                    <span>A2A Network</span>
                  </button>
                </div>
                
                <button 
                  onClick={fetchAllData}
                  className="w-full bg-gradient-to-r from-green-500/20 to-emerald-500/20 border border-green-500/50 text-green-300 px-4 py-2 rounded-lg font-medium hover:bg-green-500/30 transition-all flex items-center justify-center space-x-2"
                >
                  <RefreshCw className="w-4 h-4" />
                  <span>Refresh Enhanced Data</span>
                </button>
              </div>
            </div>
          </div>

          {/* Enhanced Incident Feed */}
          <div className="xl:col-span-2">
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Enhanced Incident Feed</h3>
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {incidents.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="flex justify-center space-x-2 mb-4">
                      <Brain className="w-8 h-8 text-purple-600" />
                      <MessageSquare className="w-8 h-8 text-blue-600" />
                    </div>
                    <p className="text-gray-400 text-sm mb-2">No enhanced incidents yet!</p>
                    <p className="text-gray-500 text-xs">Generate an incident to see MCP+A2A intelligence in action</p>
                  </div>
                ) : (
                  incidents.map((incident) => {
                    const IncidentTypeIcon = getIncidentTypeIcon(incident.incident_type);
                    const typeColor = getIncidentTypeColor(incident.incident_type);
                    
                    return (
                      <div 
                        key={incident.id} 
                        className="bg-gradient-to-br from-gray-800/50 to-purple-900/20 rounded-lg p-3 border border-purple-600/30 hover:border-purple-500/50 transition-all cursor-pointer transform hover:scale-[1.02]"
                        onClick={() => viewIncidentDetails(incident.id)}
                      >
                        <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center space-x-2">
                            <IncidentTypeIcon className={`w-4 h-4 ${typeColor}`} />
                            <span className={`px-2 py-1 rounded-full text-xs font-medium text-white ${
                              incident.severity === 'critical' ? 'bg-red-600' :
                              incident.severity === 'high' ? 'bg-orange-500' :
                              'bg-yellow-500'
                            }`}>
                              {incident.severity.toUpperCase()}
                            </span>
                            <div className="flex space-x-1">
                              <Brain className="w-3 h-3 text-purple-400" title="MCP Enhanced" />
                              <MessageSquare className="w-3 h-3 text-blue-400" title="A2A Enabled" />
                            </div>
                            {activeWorkflows.has(incident.id) && (
                              <Network className="w-4 h-4 text-green-400 animate-spin" />
                            )}
                          </div>
                        </div>
                        
                        <h4 className="text-sm font-medium text-white mb-2 truncate">
                          {incident.title}
                        </h4>
                        
                        <div className="w-full bg-gray-700 rounded-full h-2 mb-2">
                          <div 
                            className="bg-gradient-to-r from-purple-500 via-blue-500 to-green-500 h-2 rounded-full transition-all duration-500"
                            style={{ width: `${((incident.completed_agents?.length || 0) / 7) * 100}%` }}
                          />
                        </div>
                        
                        <div className="flex items-center justify-between">
                          <span className={`text-xs px-2 py-1 rounded ${
                            incident.workflow_status === 'completed' ? 'bg-green-500/20 text-green-400' :
                            incident.workflow_status === 'in_progress' ? 'bg-purple-500/20 text-purple-400' :
                            'bg-gray-500/20 text-gray-400'
                          }`}>
                            Enhanced {incident.workflow_status?.replace('_', ' ')}
                          </span>
                          <button className="text-xs text-purple-400 hover:text-purple-300 font-medium">
                            View Enhanced Details →
                          </button>
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* MCP Context Modal */}
      {showMcpModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass mcp-glow rounded-xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-purple-700">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <Brain className="w-6 h-6 text-purple-400" />
                  <h2 className="text-2xl font-bold text-white">Model Context Protocol Status</h2>
                </div>
                <button onClick={() => setShowMcpModal(false)}>
                  <X className="w-6 h-6 text-gray-400 hover:text-white" />
                </button>
              </div>
            </div>
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {mcpContexts.length > 0 ? (
                  mcpContexts.map((context) => (
                    <div key={context.context_id} className="bg-purple-900/20 border border-purple-600/30 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-sm font-medium text-purple-300">Context #{context.context_id.slice(0,8)}</span>
                        <span className="text-xs text-gray-400">v{context.context_version}</span>
                      </div>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-400">Agents:</span>
                          <span className="text-purple-400">{context.agent_count}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Confidence:</span>
                          <span className="text-green-400">{Math.round(context.confidence_avg * 100)}%</span>
                        </div>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="col-span-2 text-center py-8">
                    <Brain className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                    <p className="text-gray-400">No MCP contexts active</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* A2A Network Modal */}
      {showA2aModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass a2a-glow rounded-xl w-full max-w-6xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-blue-700">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <MessageSquare className="w-6 h-6 text-blue-400" />
                  <h2 className="text-2xl font-bold text-white">Agent-to-Agent Network</h2>
                </div>
                <button onClick={() => setShowA2aModal(false)}>
                  <X className="w-6 h-6 text-gray-400 hover:text-white" />
                </button>
              </div>
            </div>
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Recent Messages */}
                <div>
                  <h3 className="text-lg font-semibold text-blue-300 mb-4">Recent A2A Messages</h3>
                  <div className="space-y-3">
                    {a2aMessages.length > 0 ? (
                      a2aMessages.map((message) => (
                        <div key={message.message_id} className="bg-blue-900/20 border border-blue-600/30 rounded-lg p-3">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center space-x-2">
                              <span className="text-blue-300 text-sm">{message.sender}</span>
                              <span className="text-gray-400">→</span>
                              <span className="text-green-300 text-sm">{message.receiver}</span>
                            </div>
                            <span className="text-xs text-purple-400 bg-purple-900/20 px-2 py-1 rounded">
                              {message.type?.replace('_', ' ')}
                            </span>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-8">
                        <MessageSquare className="w-8 h-8 text-blue-600 mx-auto mb-2" />
                        <p className="text-gray-400 text-sm">No A2A messages yet</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Collaborations */}
                <div>
                  <h3 className="text-lg font-semibold text-green-300 mb-4">Active Collaborations</h3>
                  <div className="space-y-3">
                    {a2aCollaborations.length > 0 ? (
                      a2aCollaborations.map((collab) => (
                        <div key={collab.collaboration_id} className="bg-green-900/20 border border-green-600/30 rounded-lg p-3">
                          <div className="text-green-300 text-sm font-medium mb-2">{collab.task}</div>
                          <div className="text-xs text-gray-400">
                            Participants: {collab.participants?.join(', ')}
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-8">
                        <Share2 className="w-8 h-8 text-green-600 mx-auto mb-2" />
                        <p className="text-gray-400 text-sm">No active collaborations</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Enhanced Incident Details Modal */}
      {selectedIncident && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass rounded-xl w-full max-w-6xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-gray-700">
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center space-x-3 mb-2">
                    <h2 className="text-2xl font-bold text-white">{selectedIncident.title}</h2>
                    <div className="flex space-x-1">
                      <Brain className="w-5 h-5 text-purple-400" title="MCP Enhanced" />
                      <MessageSquare className="w-5 h-5 text-blue-400" title="A2A Enabled" />
                    </div>
                  </div>
                  <p className="text-gray-400">Enhanced with MCP + A2A Architecture</p>
                </div>
                <button onClick={() => setSelectedIncident(null)}>
                  <X className="w-6 h-6 text-gray-400 hover:text-white" />
                </button>
              </div>
            </div>
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              {/* Enhanced Features Summary */}
              {selectedIncident.enhanced_features && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                  <div className="bg-purple-900/20 border border-purple-600/30 rounded-lg p-4">
                    <div className="flex items-center mb-3">
                      <Brain className="w-5 h-5 text-purple-400 mr-2" />
                      <h3 className="text-lg font-semibold text-purple-300">MCP Context</h3>
                    </div>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-400">Agent Insights:</span>
                        <span className="text-purple-400">{selectedIncident.enhanced_features.mcp_context?.agent_insights_count || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Confidence:</span>
                        <span className="text-green-400">{Math.round((selectedIncident.enhanced_features.mcp_context?.avg_confidence || 0) * 100)}%</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-blue-900/20 border border-blue-600/30 rounded-lg p-4">
                    <div className="flex items-center mb-3">
                      <MessageSquare className="w-5 h-5 text-blue-400 mr-2" />
                      <h3 className="text-lg font-semibold text-blue-300">A2A Protocol</h3>
                    </div>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-400">Messages:</span>
                        <span className="text-blue-400">
                          {(selectedIncident.enhanced_features.a2a_protocol?.total_messages_sent || 0) + 
                           (selectedIncident.enhanced_features.a2a_protocol?.total_messages_received || 0)}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Collaborations:</span>
                        <span className="text-green-400">{selectedIncident.enhanced_features.a2a_protocol?.active_collaborations || 0}</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div className="bg-gray-800/50 rounded-lg p-4">
                <h3 className="text-lg font-semibold text-white mb-4">Resolution</h3>
                <p className="text-gray-300">{selectedIncident.resolution || 'Resolution in progress with enhanced intelligence...'}</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
EOF_FRONTEND

# Create public/index.html for React
echo "🌐 Creating frontend HTML template..."
cat > frontend/public/index.html << 'EOF_HTML'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="MCP + A2A Enhanced AI Monitoring System" />
    <title>MCP + A2A AI Monitoring System</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF_HTML

# Create index.js for React
echo "⚛️ Creating React entry point..."
cat > frontend/src/index.js << 'EOF_INDEX'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_INDEX

# Install frontend dependencies and build
echo "📦 Installing frontend dependencies..."
cd frontend
if command -v npm &> /dev/null; then
    npm install --silent 2>/dev/null
    echo "🏗️  Building frontend..."
    npm run build --silent 2>/dev/null
elif command -v yarn &> /dev/null; then
    yarn install --silent 2>/dev/null
    echo "🏗️  Building frontend..."
    yarn build --silent 2>/dev/null
else
    echo "⚠️  Warning: npm/yarn not found. Frontend build skipped."
fi
cd ..

# Stop existing processes
echo "🔄 Stopping existing processes..."
pkill -f "python.*main.py" 2>/dev/null || true
sleep 3

# Start the enhanced application
echo "🚀 Starting MCP + A2A Enhanced System..."
nohup python src/main.py > logs/app.log 2>&1 &
sleep 8

# Test if the application is running
echo "🔍 Testing enhanced system startup..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ MCP + A2A Enhanced Application is running successfully"
    
    # Test enhanced endpoints
    echo "🧠 Testing MCP endpoints..."
    curl -s http://localhost:8000/api/mcp/contexts > /dev/null && echo "   ✅ MCP Context API working"
    
    echo "🤝 Testing A2A endpoints..."
    curl -s http://localhost:8000/api/a2a/messages/history > /dev/null && echo "   ✅ A2A Messages API working"
    curl -s http://localhost:8000/api/a2a/collaborations > /dev/null && echo "   ✅ A2A Collaborations API working"
    
else
    echo "⚠️  Application may still be starting up..."
    sleep 5
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ MCP + A2A Enhanced Application is now running"
    else
        echo "❌ Application startup failed - check logs/app.log for details"
        tail -10 logs/app.log 2>/dev/null || echo "No logs available"
        exit 1
    fi
fi

echo ""
echo "🎉 CONSOLIDATED MCP + A2A ENHANCEMENT COMPLETE!"
echo "=============================================="
echo ""
echo "🧠 MODEL CONTEXT PROTOCOL (MCP) ACTIVE:"
echo "  ✅ Shared intelligence across all agents"
echo "  ✅ Contextual memory and learning"
echo "  ✅ Cross-agent knowledge correlation"
echo "  ✅ Confidence-based decision making"
echo ""
echo "🤝 AGENT-TO-AGENT (A2A) PROTOCOL ACTIVE:"
echo "  ✅ Direct agent communication"
echo "  ✅ Collaborative problem solving"
echo "  ✅ Real-time information sharing"
echo "  ✅ Multi-agent coordination"
echo ""
echo "🚀 READY TO TEST:"
echo "  1. Visit: http://localhost:8000"
echo "  2. Click 'Generate MCP+A2A Incident'"
echo "  3. Click 'MCP Status' for shared intelligence"
echo "  4. Click 'A2A Network' for agent communications"
echo "  5. View enhanced incident details"
echo ""
echo "🔍 API ENDPOINTS:"
echo "  • http://localhost:8000/api/docs - API Documentation"
echo "  • http://localhost:8000/api/mcp/contexts - MCP Contexts"
echo "  • http://localhost:8000/api/a2a/messages/history - A2A Messages"
echo "  • http://localhost:8000/api/a2a/collaborations - Agent Collaborations"
echo ""
echo "🌟 Your AI system now features true collective intelligence!"
echo "    Agents share knowledge, collaborate, and learn from each other!"

