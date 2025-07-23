#!/bin/bash

# =============================================================================
# SCRIPT 4: HELPER METHODS AND API ENDPOINTS
# Adds all helper methods and FastAPI endpoints
# =============================================================================

echo "🚀 SCRIPT 4: Helper Methods and API Endpoints"
echo "============================================="

echo "🔧 Adding helper methods and API endpoints to main.py..."

# Append the helper methods and API implementations
cat >> src/main.py << 'EOF'
    
    # HELPER METHODS FOR ENHANCED FUNCTIONALITY
    def _get_enhanced_escalation_team(self, incident_type: str, severity: str) -> str:
        """Get enhanced escalation team based on incident type and severity"""
        teams = {
            "database": "Database Engineering",
            "security": "Security Operations Center", 
            "network": "Network Operations Team",
            "infrastructure": "Infrastructure Engineering",
            "container": "Platform Engineering",
            "storage": "Storage Engineering",
            "api": "API Platform Team",
            "dns": "Network Operations",
            "authentication": "Identity & Access Management"
        }
        base_team = teams.get(incident_type, "General Operations")
        
        if severity == "critical":
            return f"Senior {base_team} + Management"
        elif severity == "high":
            return f"Senior {base_team}"
        return base_team
    
    def _get_specialized_on_call_engineer(self, incident_type: str, severity: str) -> str:
        """Get specialized on-call engineer based on incident type"""
        engineers = {
            "database": random.choice(["Sarah Chen (DB Architect)", "Marcus Rodriguez (Sr. DBA)", "Priya Patel (DB Performance)"]),
            "security": random.choice(["Alex Thompson (Security Lead)", "Jordan Kim (Incident Response)", "Riley Foster (Threat Analysis)"]),
            "network": random.choice(["David Wilson (Network Architect)", "Maya Singh (Sr. Network Engineer)", "Chris Anderson (NOC Lead)"]),
            "infrastructure": random.choice(["Sam Parker (Infrastructure Lead)", "Jessica Liu (Cloud Architect)", "Tyler Brown (SRE)"]),
            "container": random.choice(["Morgan Davis (K8s Expert)", "Casey Johnson (Platform Lead)", "Avery Taylor (DevOps)"])
        }
        base_engineer = engineers.get(incident_type, random.choice(["Jamie Smith (Sr. Engineer)", "Taylor Jones (Operations)", "Cameron Lee (Specialist)"]))
        
        if severity == "critical":
            return f"{base_engineer} + Backup Engineer"
        return base_engineer
    
    def _get_intelligent_ticket_classification(self, incident: Incident) -> tuple:
        """Get intelligent ticket classification using MCP context"""
        priority_map = {
            "critical": "0 - Emergency",
            "high": "1 - Critical", 
            "medium": "2 - High",
            "low": "3 - Medium"
        }
        
        base_priority = priority_map.get(incident.severity.value, "2 - High")
        
        # Enhanced categories with subcategories
        classifications = {
            "database": ("Database Services", "Performance Degradation"),
            "security": ("Security Incident", "Threat Response"),
            "network": ("Network Infrastructure", "Connectivity Issues"),
            "infrastructure": ("Infrastructure", "System Outage"),
            "container": ("Platform Services", "Container Orchestration"),
            "api": ("Application Services", "API Gateway")
        }
        
        category, subcategory = classifications.get(incident.incident_type, ("General Services", "System Issue"))
        return base_priority, f"{category} - MCP Enhanced", subcategory
    
    def _get_enhanced_resolution_estimate(self, incident_type: str, severity: str) -> str:
        """Get enhanced resolution time estimate"""
        base_estimates = {
            "database": "2-4 hours",
            "security": "1-6 hours (depends on scope)",
            "network": "1-3 hours",
            "infrastructure": "2-6 hours", 
            "container": "1-2 hours",
            "api": "1-2 hours"
        }
        
        base = base_estimates.get(incident_type, "2-4 hours")
        if severity == "critical":
            return f"{base} (expedited with senior engineers)"
        return base
    
    def _get_comprehensive_stakeholders(self, incident: Incident) -> List[str]:
        """Get comprehensive stakeholder list for notifications"""
        base_stakeholders = [f"{incident.incident_type}-team@company.com", "it-operations@company.com"]
        
        # Severity-based stakeholders
        if incident.severity.value in ["critical", "high"]:
            base_stakeholders.extend(["management@company.com", "incident-commander@company.com"])
            
        if incident.severity.value == "critical":
            base_stakeholders.extend(["cto@company.com", "executive-team@company.com"])
        
        # Incident-type specific stakeholders
        type_stakeholders = {
            "security": ["security-team@company.com", "compliance@company.com", "legal@company.com"],
            "database": ["dba-team@company.com", "backend-developers@company.com"],
            "network": ["network-ops@company.com", "telecom@company.com"],
            "container": ["platform-team@company.com", "devops@company.com", "sre@company.com"]
        }
        
        base_stakeholders.extend(type_stakeholders.get(incident.incident_type, []))
        return list(set(base_stakeholders))
    
    def _get_communication_strategy(self, incident_type: str, severity: str) -> str:
        """Get communication strategy based on incident characteristics"""
        strategies = {
            "security": "Security incident communication protocol with legal and compliance review",
            "database": "Database incident communication with application teams and business stakeholders",
            "network": "Network outage communication with all affected teams and external partners",
            "infrastructure": "Infrastructure incident communication with service owners and customers",
            "container": "Container platform communication with development teams and product owners"
        }
        
        base_strategy = strategies.get(incident_type, "Standard incident communication protocol")
        
        if severity == "critical":
            return f"Crisis {base_strategy} with executive briefings"
        
        return base_strategy
    
    def _get_comprehensive_remediation_actions(self, incident_type: str) -> List[str]:
        """Get comprehensive remediation actions for incident type"""
        actions = {
            "database": [
                "connection_pool_scaling_and_optimization",
                "query_performance_analysis_and_tuning",
                "database_replica_failover_activation",
                "connection_cleanup_and_monitoring"
            ],
            "security": [
                "immediate_system_isolation_and_containment",
                "credential_rotation_and_access_review",
                "security_patch_deployment_and_hardening",
                "threat_monitoring_enhancement"
            ],
            "network": [
                "traffic_rerouting_and_load_distribution",
                "redundant_path_activation",
                "network_hardware_replacement",
                "routing_table_optimization"
            ],
            "container": [
                "pod_restart_and_rescheduling",
                "resource_limit_increase_and_optimization",
                "kubernetes_node_scaling",
                "container_image_update_and_security_scan"
            ]
        }
        return actions.get(incident_type, [
            "service_restart_and_health_verification",
            "resource_scaling_and_optimization", 
            "configuration_review_and_reset",
            "monitoring_enhancement_and_alerting"
        ])
    
    def _get_remediation_strategy(self, incident_type: str) -> str:
        """Get remediation strategy for incident type"""
        strategies = {
            "database": "Database-first approach with connection optimization and query tuning",
            "security": "Security-first containment with immediate isolation and threat mitigation",
            "network": "Network-centric approach with traffic rerouting and redundancy activation",
            "container": "Container orchestration optimization with resource scaling and health tuning",
            "infrastructure": "Infrastructure-wide approach with resource optimization and service recovery"
        }
        return strategies.get(incident_type, "Comprehensive system recovery with monitoring enhancement")
    
    def _get_automation_level(self, incident_type: str) -> str:
        """Get automation level for incident type"""
        levels = {
            "container": "high",
            "api": "high",
            "infrastructure": "medium",
            "database": "medium",
            "network": "low",
            "security": "low"  # Security requires manual oversight
        }
        return levels.get(incident_type, "medium")
    
    def _get_comprehensive_validation_results(self, incident_type: str, successful: bool) -> Dict[str, str]:
        """Get comprehensive validation results for incident type"""
        if successful:
            results = {
                "database": {
                    "connection_pool": "Optimal (420/500 connections)",
                    "query_performance": "Baseline restored (<45ms avg)",
                    "cpu_utilization": "Normal (42%)",
                    "memory_usage": "Stable (58%)",
                    "mcp_validation": "Passed"
                },
                "security": {
                    "threat_level": "Green (Low Risk)",
                    "access_controls": "Active and Verified",
                    "monitoring_systems": "Enhanced and Operational",
                    "compliance_status": "Compliant",
                    "a2a_security_check": "Passed"
                },
                "network": {
                    "latency": "Optimal (6ms avg)",
                    "packet_loss": "None (0%)",
                    "bandwidth_utilization": "Normal (65%)",
                    "redundancy_status": "Active",
                    "mcp_network_validation": "Passed"
                },
                "container": {
                    "pod_status": "All Pods Running and Ready",
                    "resource_utilization": "Optimal",
                    "cluster_health": "Healthy",
                    "service_mesh": "Operational",
                    "kubernetes_validation": "Passed"
                }
            }
        else:
            results = {
                "database": {
                    "connection_pool": "Elevated usage (465/500)",
                    "query_performance": "Improved but monitoring (85ms avg)",
                    "cpu_utilization": "Moderate (68%)",
                    "memory_usage": "Elevated (74%)",
                    "mcp_status": "Monitoring Required"
                },
                "security": {
                    "threat_level": "Yellow (Elevated)",
                    "access_controls": "Active with Enhanced Monitoring",
                    "monitoring_systems": "Enhanced with Continuous Review",
                    "compliance_status": "Under Review",
                    "a2a_security_status": "Enhanced Monitoring"
                }
            }
        
        return results.get(incident_type, {
            "overall_status": "Healthy" if successful else "Monitoring",
            "performance": "Optimal" if successful else "Improved",
            "mcp_validation": "Passed" if successful else "Monitoring Required"
        })
    
    async def _log_activity(self, execution: AgentExecution, message: str, level: str = "INFO"):
        """Enhanced log activity with MCP context"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "level": level,
            "message": message,
            "execution_id": execution.execution_id,
            "mcp_context_id": execution.mcp_context_id
        }
        execution.logs.append(log_entry)
        logger.info(f"[{execution.incident_id}] {execution.agent_name}: {message}")

# Global complete enhanced workflow engine
workflow_engine = CompleteEnhancedWorkflowEngine()

# =============================================================================
# COMPLETE ENHANCED FASTAPI APPLICATION
# =============================================================================

class CompleteEnhancedMonitoringApp:
    def __init__(self):
        self.app = FastAPI(
            title="Complete MCP + A2A Enhanced AI Monitoring System",
            description="ALL Previous Features + Model Context Protocol + Agent-to-Agent Communication",
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
        # Enhanced incident triggering with real-time updates
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
                "message": f"Complete MCP+A2A Enhanced Incident {incident.id} workflow initiated with real-time updates",
                "affected_systems": len(incident.affected_systems),
                "enhanced_features": [
                    "Model Context Protocol", 
                    "Agent-to-Agent Communication", 
                    "Real-time WebSocket Updates",
                    "All 7 Agents Dashboard",
                    "Comprehensive Analysis"
                ]
            }
        
        # Complete agent information with execution history
        @self.app.get("/api/agents")
        async def get_complete_agents():
            agent_configs = {
                "monitoring": "Complete enhanced monitoring with incident-type specific metric collection, MCP context analysis, and A2A intelligence sharing",
                "rca": "AI-powered comprehensive root cause analysis with machine learning correlation, MCP shared insights, and cross-agent pattern recognition", 
                "pager": "Intelligent escalation to specialized teams with context-aware notification routing, A2A coordination, and enhanced stakeholder management",
                "ticketing": "Smart ticket classification with automated priority assignment, MCP-enhanced categorization, and intelligent workflow routing",
                "email": "Context-aware stakeholder notifications with incident-specific communication protocols, A2A coordinated messaging, and personalized content",
                "remediation": "Automated remediation with incident-type specific procedures, RCA-enhanced actions, A2A validation coordination, and comprehensive safety checks",
                "validation": "Comprehensive health verification with specialized testing, cross-agent validation, MCP context analysis, and enhanced monitoring setup"
            }
            
            agents_data = {}
            for agent_id, description in agent_configs.items():
                executions = workflow_engine.agent_execution_history[agent_id]
                recent = executions[-1] if executions else None
                
                # Calculate enhanced statistics
                successful_count = len([e for e in executions if e.status == AgentStatus.SUCCESS])
                total_count = len(executions)
                avg_duration = sum([e.duration_seconds for e in executions if e.duration_seconds > 0]) / max(total_count, 1)
                
                # MCP + A2A specific stats
                mcp_enhanced_count = len([e for e in executions if e.contextual_insights_used])
                a2a_messages_total = sum([e.a2a_messages_sent + e.a2a_messages_received for e in executions])
                collaborations_total = sum([len(e.collaboration_sessions) for e in executions])
                
                agents_data[agent_id] = {
                    "agent_id": agent_id,
                    "agent_name": f"Complete Enhanced {agent_id.title()} Agent",
                    "status": "ready",
                    "description": description,
                    "total_executions": total_count,
                    "successful_executions": successful_count,
                    "success_rate": (successful_count / max(total_count, 1)) * 100,
                    "average_duration": round(avg_duration, 2),
                    "last_activity": recent.started_at.isoformat() if recent and recent.started_at else "Never",
                    "enhanced_features": {
                        "mcp_enhanced_executions": mcp_enhanced_count,
                        "a2a_messages_total": a2a_messages_total,
                        "collaborations_total": collaborations_total,
                        "context_aware": True,
                        "real_time_updates": True
                    },
                    "capabilities": workflow_engine.a2a_protocol.agent_capabilities.get(agent_id, []),
                    "recent_performance": {
                        "last_execution_status": recent.status.value if recent else "idle",
                        "last_duration": recent.duration_seconds if recent else 0,
                        "last_progress": recent.progress if recent else 0
                    }
                }
            
            return {
                "agents": agents_data, 
                "total_agents": 7,
                "system_capabilities": {
                    "mcp_context_sharing": True,
                    "a2a_communication": True,
                    "real_time_collaboration": True,
                    "comprehensive_analysis": True
                }
            }
        
        # Enhanced MCP context endpoints with real-time data
        @self.app.get("/api/mcp/contexts")
        async def get_enhanced_mcp_contexts():
            contexts = []
            for context_id, context in workflow_engine.mcp_registry.contexts.items():
                contexts.append({
                    "context_id": context.context_id,
                    "incident_id": context.incident_id,
                    "context_type": context.context_type,
                    "created_at": context.created_at.isoformat(),
                    "updated_at": context.updated_at.isoformat(),
                    "context_version": context.context_version,
                    "agent_count": len(context.agent_insights),
                    "confidence_avg": sum(context.confidence_scores.values()) / len(context.confidence_scores) if context.confidence_scores else 0.0,
                    "data_sources": len(context.data_sources),
                    "correlation_patterns": len(context.correlation_patterns),
                    "shared_knowledge_keys": list(context.shared_knowledge.keys()),
                    "agent_insights_summary": {
                        agent_id: {
                            "confidence": insight["confidence"],
                            "timestamp": insight["timestamp"]
                        }
                        for agent_id, insight in context.agent_insights.items()
                    }
                })
            
            return {
                "total_contexts": len(contexts), 
                "contexts": contexts,
                "system_stats": {
                    "total_agent_insights": sum(len(c.agent_insights) for c in workflow_engine.mcp_registry.contexts.values()),
                    "avg_context_confidence": sum(c.confidence_avg for c in contexts) / len(contexts) if contexts else 0.0,
                    "active_subscriptions": len(workflow_engine.mcp_registry.context_subscriptions)
                }
            }
        
        # Enhanced A2A protocol endpoints with detailed message tracking
        @self.app.get("/api/a2a/messages/history")
        async def get_enhanced_a2a_message_history(limit: int = 50):
            recent_messages = workflow_engine.a2a_protocol.message_history[-limit:]
            
            # Message statistics
            message_types = {}
            priority_counts = {}
            agent_activity = {}
            
            for msg in workflow_engine.a2a_protocol.message_history:
                # Count message types
                message_types[msg.message_type] = message_types.get(msg.message_type, 0) + 1
                
                # Count priorities
                priority_counts[msg.priority] = priority_counts.get(msg.priority, 0) + 1
                
                # Track agent activity
                if msg.sender_agent_id not in agent_activity:
                    agent_activity[msg.sender_agent_id] = {"sent": 0, "received": 0}
                if msg.receiver_agent_id not in agent_activity:
                    agent_activity[msg.receiver_agent_id] = {"sent": 0, "received": 0}
                
                agent_activity[msg.sender_agent_id]["sent"] += 1
                agent_activity[msg.receiver_agent_id]["received"] += 1
            
            return {
                "total_messages": len(workflow_engine.a2a_protocol.message_history),
                "recent_messages": [msg.to_dict() for msg in recent_messages],
                "message_statistics": {
                    "by_type": message_types,
                    "by_priority": priority_counts,
                    "agent_activity": agent_activity
                },
                "system_status": {
                    "active_collaborations": len(workflow_engine.a2a_protocol.active_collaborations),
                    "registered_agents": len(workflow_engine.a2a_protocol.agent_capabilities),
                    "total_capabilities": sum(len(caps) for caps in workflow_engine.a2a_protocol.agent_capabilities.values())
                }
            }
        
        # Enhanced A2A collaborations with detailed tracking
        @self.app.get("/api/a2a/collaborations")
        async def get_enhanced_a2a_collaborations():
            collaborations = []
            for collab_id, collab in workflow_engine.a2a_protocol.active_collaborations.items():
                collaborations.append({
                    "collaboration_id": collab_id,
                    "initiator": collab["initiator"],
                    "participants": collab["participants"],
                    "task": collab["task"],
                    "context": collab["context"],
                    "status": collab["status"],
                    "created_at": collab["created_at"],
                    "message_count": len(collab["messages"]),
                    "duration": (datetime.now() - datetime.fromisoformat(collab["created_at"])).total_seconds(),
                    "participant_count": len(collab["participants"])
                })
            
            return {
                "total_collaborations": len(collaborations),
                "collaborations": collaborations,
                "collaboration_statistics": {
                    "avg_participants": sum(c["participant_count"] for c in collaborations) / len(collaborations) if collaborations else 0,
                    "avg_duration": sum(c["duration"] for c in collaborations) / len(collaborations) if collaborations else 0,
                    "most_active_initiator": max(workflow_engine.a2a_protocol.agent_capabilities.keys(), key=lambda x: len([c for c in collaborations if c["initiator"] == x])) if collaborations else None
                }
            }
        
        # Complete enhanced incident status with ALL features
        @self.app.get("/api/incidents/{incident_id}/status")
        async def get_complete_incident_status(incident_id: str):
            incident = None
            if incident_id in workflow_engine.active_incidents:
                incident = workflow_engine.active_incidents[incident_id]
            else:
                incident = next((i for i in workflow_engine.incident_history if i.id == incident_id), None)
            
            if not incident:
                return {"error": "Incident not found"}
            
            # Get comprehensive MCP context data
            mcp_data = {}
            if incident.mcp_context_id:
                context = workflow_engine.mcp_registry.get_context(incident.mcp_context_id)
                if context:
                    mcp_data = {
                        "context_id": context.context_id,
                        "context_version": context.context_version,
                        "agent_insights_count": len(context.agent_insights),
                        "avg_confidence": sum(context.confidence_scores.values()) / len(context.confidence_scores) if context.confidence_scores else 0.0,
                        "correlation_patterns": len(context.correlation_patterns),
                        "shared_knowledge": context.shared_knowledge,
                        "agent_insights_detail": context.agent_insights,
                        "confidence_scores": context.confidence_scores
                    }
            
            # Get comprehensive A2A data
            a2a_data = {
                "total_messages_sent": sum(exec.a2a_messages_sent for exec in incident.executions.values()),
                "total_messages_received": sum(exec.a2a_messages_received for exec in incident.executions.values()),
                "active_collaborations": len(incident.a2a_collaborations),
                "cross_agent_insights": len(incident.cross_agent_insights),
                "collaboration_details": incident.a2a_collaborations,
                "message_breakdown": {
                    agent_id: {
                        "sent": execution.a2a_messages_sent,
                        "received": execution.a2a_messages_received,
                        "collaborations": len(execution.collaboration_sessions)
                    }
                    for agent_id, execution in incident.executions.items()
                }
            }
            
            return {
                "incident_id": incident.id,
                "title": incident.title,
                "description": incident.description,
                "severity": incident.severity.value,
                "incident_type": incident.incident_type,
                "status": incident.status,
                "workflow_status": incident.workflow_status,
                "current_agent": incident.current_agent,
                "completed_agents": incident.completed_agents,
                "failed_agents": incident.failed_agents,
                "created_at": incident.created_at.isoformat(),
                "updated_at": incident.updated_at.isoformat(),
                "affected_systems": incident.affected_systems,
                "root_cause": incident.root_cause,
                "resolution": incident.resolution,
                "pagerduty_incident_id": incident.pagerduty_incident_id,
                "servicenow_ticket_id": incident.servicenow_ticket_id,
                "remediation_applied": incident.remediation_applied,
                "enhanced_features": {
                    "mcp_context": mcp_data,
                    "a2a_protocol": a2a_data
                },
                "executions": {
                    agent_id: {
                        "agent_name": execution.agent_name,
                        "status": execution.status.value,
                        "progress": execution.progress,
                        "started_at": execution.started_at.isoformat() if execution.started_at else None,
                        "completed_at": execution.completed_at.isoformat() if execution.completed_at else None,
                        "duration": execution.duration_seconds,
                        "log_count": len(execution.logs),
                        "error": execution.error_message,
                        "mcp_enhanced": bool(execution.contextual_insights_used),
                        "a2a_messages": {
                            "sent": execution.a2a_messages_sent,
                            "received": execution.a2a_messages_received
                        },
                        "collaborations": len(execution.collaboration_sessions),
                        "contextual_insights": execution.contextual_insights_used,
                        "output_data": execution.output_data
                    }
                    for agent_id, execution in incident.executions.items()
                }
            }

EOF

echo ""
echo "✅ SCRIPT 4 COMPLETED SUCCESSFULLY!"
echo "=================================="
echo ""
echo "📋 Helper Methods and API Summary:"
echo "  ✅ All helper methods implemented"
echo "  ✅ Enhanced API endpoints created"
echo "  ✅ MCP and A2A endpoints added"
echo "  ✅ Comprehensive incident status API"
echo ""
echo "🚀 Ready for Script 5: Dashboard Stats and WebSocket"
echo "   Run: ./script_5_dashboard_websocket.sh"