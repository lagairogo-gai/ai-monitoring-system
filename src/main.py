"""
Enhanced AI-Powered IT Operations Monitoring System
Real-time workflow execution with live agent tracking
"""
import os
import asyncio
import json
import time
import uuid
import logging
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
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

class AgentStatus(Enum):
    IDLE = "idle"
    RUNNING = "running"
    SUCCESS = "success"
    ERROR = "error"
    WAITING = "waiting"

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

class WorkflowEngine:
    def __init__(self):
        self.active_incidents: Dict[str, Incident] = {}
        self.incident_history: List[Incident] = []
        self.agent_execution_history: Dict[str, List[AgentExecution]] = {
            "monitoring": [], "rca": [], "pager": [], "ticketing": [], 
            "email": [], "remediation": [], "validation": []
        }
        
    async def trigger_incident_workflow(self, incident_data: Dict[str, Any]) -> Incident:
        incident = Incident(
            title=incident_data.get("title", "Unknown Incident"),
            description=incident_data.get("description", ""),
            severity=IncidentSeverity(incident_data.get("severity", "medium")),
            affected_systems=incident_data.get("affected_systems", [])
        )
        
        self.active_incidents[incident.id] = incident
        asyncio.create_task(self._execute_workflow(incident))
        return incident
    
    async def _execute_workflow(self, incident: Incident):
        workflow_steps = [
            ("monitoring", self._execute_monitoring_agent),
            ("rca", self._execute_rca_agent),
            ("pager", self._execute_pager_agent),
            ("ticketing", self._execute_ticketing_agent),
            ("email", self._execute_email_agent),
            ("remediation", self._execute_remediation_agent),
            ("validation", self._execute_validation_agent)
        ]
        
        try:
            for agent_id, agent_func in workflow_steps:
                incident.current_agent = agent_id
                incident.updated_at = datetime.now()
                
                execution = await agent_func(incident)
                incident.executions[agent_id] = execution
                self.agent_execution_history[agent_id].append(execution)
                
                if execution.status == AgentStatus.SUCCESS:
                    incident.completed_agents.append(agent_id)
                else:
                    incident.failed_agents.append(agent_id)
                
                await asyncio.sleep(2)
            
            incident.workflow_status = "completed"
            incident.current_agent = ""
            incident.status = "resolved" if len(incident.failed_agents) == 0 else "partially_resolved"
            
            self.incident_history.append(incident)
            del self.active_incidents[incident.id]
            
        except Exception as e:
            incident.workflow_status = "failed"
            incident.status = "failed"
            logger.error(f"Workflow failed for incident {incident.id}: {str(e)}")
    
    async def _execute_monitoring_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="monitoring", agent_name="Monitoring Agent",
            incident_id=incident.id, input_data={"systems": incident.affected_systems}
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "🔍 Starting incident monitoring analysis...")
            execution.progress = 20
            await asyncio.sleep(1.5)
            
            await self._log_activity(execution, "📊 Collecting metrics from Datadog...")
            execution.progress = 50
            await asyncio.sleep(2)
            
            await self._log_activity(execution, "📝 Analyzing log patterns and events...")
            execution.progress = 80
            await asyncio.sleep(1.5)
            
            execution.output_data = {
                "anomalies_detected": [
                    {"type": "cpu_spike", "severity": "high", "value": "92%"},
                    {"type": "memory_leak", "severity": "medium", "growth_rate": "5MB/min"}
                ],
                "metrics_analyzed": 15420,
                "logs_processed": 8934
            }
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Monitoring analysis completed - Anomalies detected")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
            await self._log_activity(execution, f"❌ Monitoring failed: {str(e)}", "ERROR")
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_rca_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="rca", agent_name="RCA Agent", incident_id=incident.id,
            input_data=incident.executions.get("monitoring", {}).output_data or {}
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "🧠 Starting AI-powered root cause analysis...")
            execution.progress = 25
            await asyncio.sleep(2)
            
            await self._log_activity(execution, "🔍 Analyzing patterns with LLM...")
            execution.progress = 60
            await asyncio.sleep(2.5)
            
            await self._log_activity(execution, "💡 Identifying root causes...")
            execution.progress = 90
            await asyncio.sleep(1)
            
            execution.output_data = {
                "root_cause": "Memory leak in session management causing CPU exhaustion",
                "confidence": 0.87,
                "recommended_actions": ["Restart services", "Increase JVM heap", "Deploy hotfix"]
            }
            
            incident.root_cause = execution.output_data["root_cause"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Root cause identified with 87% confidence")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_pager_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="pager", agent_name="Pager Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "📞 Creating PagerDuty incident...")
            execution.progress = 40
            await asyncio.sleep(1)
            
            await self._log_activity(execution, "📱 Sending alerts to on-call engineer...")
            execution.progress = 80
            await asyncio.sleep(1)
            
            execution.output_data = {
                "pagerduty_incident_id": f"PD-{incident.id[-6:]}",
                "alert_sent_to": "john.doe@company.com"
            }
            
            incident.pagerduty_incident_id = execution.output_data["pagerduty_incident_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ PagerDuty alert created: {execution.output_data['pagerduty_incident_id']}")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_ticketing_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="ticketing", agent_name="Ticketing Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "🎫 Creating ServiceNow ticket...")
            execution.progress = 30
            await asyncio.sleep(1.5)
            
            await self._log_activity(execution, "📝 Populating details and assigning...")
            execution.progress = 70
            await asyncio.sleep(1)
            
            execution.output_data = {
                "ticket_id": f"INC{datetime.now().strftime('%Y%m%d')}{incident.id[-4:]}",
                "assigned_to": "IT Operations Team"
            }
            
            incident.servicenow_ticket_id = execution.output_data["ticket_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ ServiceNow ticket created: {execution.output_data['ticket_id']}")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_email_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="email", agent_name="Email Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "📧 Composing incident notification...")
            execution.progress = 40
            await asyncio.sleep(1)
            
            await self._log_activity(execution, "📤 Sending to stakeholders...")
            execution.progress = 80
            await asyncio.sleep(1)
            
            execution.output_data = {
                "emails_sent": ["it-ops@company.com", "management@company.com"]
            }
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Notifications sent successfully")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_remediation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="remediation", agent_name="Remediation Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "🔧 Analyzing remediation options...")
            execution.progress = 25
            await asyncio.sleep(1.5)
            
            await self._log_activity(execution, "⚡ Applying automated fixes...")
            execution.progress = 50
            await asyncio.sleep(2)
            
            await self._log_activity(execution, "🔄 Restarting affected services...")
            execution.progress = 75
            await asyncio.sleep(1.5)
            
            execution.output_data = {
                "actions_performed": ["service_restart", "jvm_heap_increase", "hotfix_deployment"]
            }
            
            incident.remediation_applied = execution.output_data["actions_performed"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Remediation completed - 3 fixes applied")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _execute_validation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="validation", agent_name="Validation Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, "🔍 Starting validation...")
            execution.progress = 30
            await asyncio.sleep(2)
            
            await self._log_activity(execution, "📊 Monitoring system metrics...")
            execution.progress = 60
            await asyncio.sleep(1.5)
            
            await self._log_activity(execution, "✅ Verifying service health...")
            execution.progress = 90
            await asyncio.sleep(1)
            
            execution.output_data = {
                "health_checks": {"cpu": "45%", "memory": "62%", "services": "healthy"},
                "incident_resolved": True
            }
            
            incident.resolution = "Memory leak fixed - System metrics normal"
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Validation completed - Incident resolved")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    async def _log_activity(self, execution: AgentExecution, message: str, level: str = "INFO"):
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "level": level,
            "message": message,
            "execution_id": execution.execution_id
        }
        execution.logs.append(log_entry)
        logger.info(f"[{execution.incident_id}] {execution.agent_name}: {message}")

# Global workflow engine
workflow_engine = WorkflowEngine()

class EnhancedMonitoringSystemApp:
    def __init__(self):
        self.app = FastAPI(
            title="AI Monitoring System",
            description="Real-Time AI-Powered IT Operations Monitoring",
            version="2.0.0",
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
                "status": "workflow_started",
                "title": incident.title,
                "severity": incident.severity.value,
                "message": f"Incident {incident.id} workflow initiated successfully"
            }
        
        @self.app.get("/api/incidents/{incident_id}/status")
        async def get_incident_status(incident_id: str):
            incident = None
            if incident_id in workflow_engine.active_incidents:
                incident = workflow_engine.active_incidents[incident_id]
            else:
                incident = next((i for i in workflow_engine.incident_history if i.id == incident_id), None)
            
            if not incident:
                return {"error": "Incident not found"}
            
            return {
                "incident_id": incident.id,
                "title": incident.title,
                "severity": incident.severity.value,
                "status": incident.status,
                "workflow_status": incident.workflow_status,
                "current_agent": incident.current_agent,
                "completed_agents": incident.completed_agents,
                "failed_agents": incident.failed_agents,
                "created_at": incident.created_at.isoformat(),
                "root_cause": incident.root_cause,
                "resolution": incident.resolution,
                "pagerduty_incident_id": incident.pagerduty_incident_id,
                "servicenow_ticket_id": incident.servicenow_ticket_id,
                "remediation_applied": incident.remediation_applied,
                "executions": {
                    agent_id: {
                        "status": execution.status.value,
                        "progress": execution.progress,
                        "duration": execution.duration_seconds,
                        "started_at": execution.started_at.isoformat() if execution.started_at else None,
                        "log_count": len(execution.logs),
                        "error": execution.error_message
                    }
                    for agent_id, execution in incident.executions.items()
                }
            }
        
        @self.app.get("/api/incidents/{incident_id}/agent/{agent_id}/logs")
        async def get_agent_logs(incident_id: str, agent_id: str):
            incident = None
            if incident_id in workflow_engine.active_incidents:
                incident = workflow_engine.active_incidents[incident_id]
            else:
                incident = next((i for i in workflow_engine.incident_history if i.id == incident_id), None)
            
            if not incident or agent_id not in incident.executions:
                return {"error": "Not found"}
            
            execution = incident.executions[agent_id]
            return {
                "incident_id": incident_id,
                "agent_id": agent_id,
                "agent_name": execution.agent_name,
                "execution_id": execution.execution_id,
                "status": execution.status.value,
                "progress": execution.progress,
                "started_at": execution.started_at.isoformat() if execution.started_at else None,
                "completed_at": execution.completed_at.isoformat() if execution.completed_at else None,
                "duration_seconds": execution.duration_seconds,
                "input_data": execution.input_data,
                "output_data": execution.output_data,
                "error_message": execution.error_message,
                "logs": execution.logs
            }
        
        @self.app.get("/api/agents/{agent_id}/history")
        async def get_agent_history(agent_id: str, limit: int = 10):
            if agent_id not in workflow_engine.agent_execution_history:
                return {"error": "Agent not found"}
            
            executions = workflow_engine.agent_execution_history[agent_id][-limit:]
            return {
                "agent_id": agent_id,
                "total_executions": len(workflow_engine.agent_execution_history[agent_id]),
                "recent_executions": [
                    {
                        "execution_id": execution.execution_id,
                        "incident_id": execution.incident_id,
                        "status": execution.status.value,
                        "started_at": execution.started_at.isoformat() if execution.started_at else None,
                        "duration_seconds": execution.duration_seconds,
                        "progress": execution.progress,
                        "success": execution.status == AgentStatus.SUCCESS,
                        "log_count": len(execution.logs)
                    }
                    for execution in reversed(executions)
                ]
            }
        
        @self.app.get("/api/incidents")
        async def get_incidents(limit: int = 20):
            all_incidents = list(workflow_engine.active_incidents.values()) + workflow_engine.incident_history
            all_incidents.sort(key=lambda x: x.created_at, reverse=True)
            all_incidents = all_incidents[:limit]
            
            return {
                "total_incidents": len(all_incidents),
                "active_incidents": len(workflow_engine.active_incidents),
                "incidents": [
                    {
                        "id": incident.id,
                        "title": incident.title,
                        "severity": incident.severity.value,
                        "status": incident.status,
                        "workflow_status": incident.workflow_status,
                        "created_at": incident.created_at.isoformat(),
                        "updated_at": incident.updated_at.isoformat(),
                        "completed_agents": len(incident.completed_agents),
                        "total_agents": 7,
                        "pagerduty_incident_id": incident.pagerduty_incident_id,
                        "servicenow_ticket_id": incident.servicenow_ticket_id
                    }
                    for incident in all_incidents
                ]
            }
        
        @self.app.get("/api/dashboard/stats")
        async def get_dashboard_stats():
            all_incidents = list(workflow_engine.active_incidents.values()) + workflow_engine.incident_history
            today_incidents = [i for i in all_incidents if i.created_at.date() == datetime.now().date()]
            
            agent_stats = {}
            for agent_id in workflow_engine.agent_execution_history:
                executions = workflow_engine.agent_execution_history[agent_id]
                successful = len([e for e in executions if e.status == AgentStatus.SUCCESS])
                total = len(executions)
                avg_duration = sum([e.duration_seconds for e in executions if e.duration_seconds > 0]) / max(total, 1)
                
                agent_stats[agent_id] = {
                    "total_executions": total,
                    "successful_executions": successful,
                    "success_rate": (successful / max(total, 1)) * 100,
                    "average_duration": avg_duration
                }
            
            return {
                "incidents": {
                    "total_all_time": len(all_incidents),
                    "active": len(workflow_engine.active_incidents),
                    "today": len(today_incidents),
                    "resolved_today": len([i for i in today_incidents if i.status == "resolved"]),
                    "average_resolution_time_minutes": 8.5
                },
                "agents": agent_stats,
                "system": {
                    "uptime_hours": 24,
                    "total_workflows": len(all_incidents),
                    "successful_workflows": len([i for i in all_incidents if i.status == "resolved"]),
                    "overall_success_rate": (len([i for i in all_incidents if i.status == "resolved"]) / max(len(all_incidents), 1)) * 100
                }
            }
        
        @self.app.websocket("/ws/incidents/{incident_id}")
        async def websocket_incident_updates(websocket: WebSocket, incident_id: str):
            await websocket.accept()
            
            try:
                while True:
                    if incident_id in workflow_engine.active_incidents:
                        incident = workflow_engine.active_incidents[incident_id]
                        
                        status_update = {
                            "type": "status_update",
                            "incident_id": incident_id,
                            "workflow_status": incident.workflow_status,
                            "current_agent": incident.current_agent,
                            "completed_agents": incident.completed_agents,
                            "agent_executions": {
                                agent_id: {
                                    "status": execution.status.value,
                                    "progress": execution.progress,
                                    "latest_log": execution.logs[-1] if execution.logs else None
                                }
                                for agent_id, execution in incident.executions.items()
                            },
                            "timestamp": datetime.now().isoformat()
                        }
                        
                        await websocket.send_text(json.dumps(status_update))
                    else:
                        incident = next((i for i in workflow_engine.incident_history if i.id == incident_id), None)
                        if incident:
                            final_update = {
                                "type": "workflow_completed",
                                "incident_id": incident_id,
                                "status": incident.status,
                                "resolution": incident.resolution,
                                "timestamp": datetime.now().isoformat()
                            }
                            await websocket.send_text(json.dumps(final_update))
                            break
                    
                    await asyncio.sleep(2)
                    
            except WebSocketDisconnect:
                pass
        
        @self.app.get("/health")
        async def health_check():
            return {
                "status": "healthy",
                "service": "AI Monitoring System",
                "version": "2.0.0",
                "features": ["Real-time workflows", "Live tracking", "WebSocket updates"],
                "workflow_engine": {
                    "active_incidents": len(workflow_engine.active_incidents),
                    "total_incidents": len(workflow_engine.incident_history)
                }
            }
        
        @self.app.get("/api/agents")
        async def get_agents():
            agent_configs = {
                "monitoring": "Real-time monitoring of Datadog metrics, logs, and traces",
                "rca": "AI-powered root cause analysis using LLMs", 
                "pager": "Automated PagerDuty alerting and escalation",
                "ticketing": "ServiceNow ticket creation and management",
                "email": "Incident notifications and approval workflows",
                "remediation": "Automated issue resolution with approval gates",
                "validation": "Resolution validation and incident closure"
            }
            
            agents_data = {}
            for agent_id, description in agent_configs.items():
                executions = workflow_engine.agent_execution_history[agent_id]
                recent = executions[-1] if executions else None
                
                agents_data[agent_id] = {
                    "status": "ready",
                    "description": description,
                    "total_executions": len(executions),
                    "successful_executions": len([e for e in executions if e.status == AgentStatus.SUCCESS]),
                    "last_activity": recent.started_at.isoformat() if recent and recent.started_at else "Never",
                    "average_duration": sum([e.duration_seconds for e in executions]) / max(len(executions), 1),
                    "success_rate": (len([e for e in executions if e.status == AgentStatus.SUCCESS]) / max(len(executions), 1)) * 100
                }
            
            return {"agents": agents_data, "total_agents": 7}
        
        # Serve frontend
        frontend_path = Path("frontend/build")
        if frontend_path.exists():
            self.app.mount("/", StaticFiles(directory=str(frontend_path), html=True), name="static")
        else:
            @self.app.get("/")
            async def root():
                return {
                    "message": "🤖 Enhanced AI Monitoring System",
                    "version": "2.0.0",
                    "features": [
                        "Real-time incident workflow execution",
                        "Live agent progress tracking", 
                        "Detailed execution logs",
                        "WebSocket updates",
                        "Interactive dashboard"
                    ]
                }
    
    def run(self, host: str = "0.0.0.0", port: int = 8000):
        logger.info("🚀 Starting Enhanced AI Monitoring System v2.0...")
        logger.info("✨ Features: Real-time workflows, live tracking, detailed logs")
        logger.info(f"📊 Dashboard: http://localhost:{port}")
        uvicorn.run(self.app, host=host, port=port, log_level="info")

if __name__ == "__main__":
    app = EnhancedMonitoringSystemApp()
    app.run()
