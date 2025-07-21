                    {
                        "title": scenario["title"],
                        "incident_type": scenario["incident_type"],
                        "severity": scenario["severity"],
                        "affected_systems": len(scenario["affected_systems"])
                    }
                    for scenario in INCIDENT_SCENARIOS
                ]
            }
        
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
                        "Interactive dashboard",
                        f"{len(INCIDENT_SCENARIOS)} diverse incident scenarios"
                    ]
                }
    
    def run(self, host: str = "0.0.0.0", port: int = 8000):
        logger.info("🚀 Starting Enhanced AI Monitoring System v2.0...")
        logger.info("✨ Features: Real-time workflows, live tracking, detailed logs")
        logger.info(f"🎭 Available incident scenarios: {len(INCIDENT_SCENARIOS)}")
        logger.info(f"📊 Dashboard: http://localhost:{port}")
        uvicorn.run(self.app, host=host, port=port, log_level="info")

if __name__ == "__main__":
    app = EnhancedMonitoringSystemApp()
    app.run()
EOF_ENHANCED_MAIN

echo "✅ Enhanced main application with diverse incidents created"

# Update the React frontend to show incident type
echo "🎨 Updating React frontend to display incident types..."

cat > frontend/src/App.js << 'EOF_FRONTEND'
import React, { useState, useEffect } from 'react';
import { 
  Activity, CheckCircle, Clock, AlertTriangle, 
  Monitor, Search, Bell, Ticket, Mail, Settings, 
  Shield, GitBranch, TrendingUp, Zap, 
  RefreshCw, ExternalLink, Eye, X, Terminal,
  Database, Wifi, Server, Lock, Container
} from 'lucide-react';

function App() {
  const [dashboardStats, setDashboardStats] = useState({});
  const [agents, setAgents] = useState({});
  const [incidents, setIncidents] = useState([]);
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [agentLogs, setAgentLogs] = useState(null);
  const [showLogs, setShowLogs] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(new Date());
  const [activeWorkflows, setActiveWorkflows] = useState(new Set());

  useEffect(() => {
    fetchAllData();
    const interval = setInterval(fetchAllData, 3000);
    return () => clearInterval(interval);
  }, []);

  const fetchAllData = async () => {
    try {
      const [statsRes, agentsRes, incidentsRes] = await Promise.all([
        fetch('/api/dashboard/stats'),
        fetch('/api/agents'),
        fetch('/api/incidents?limit=10')
      ]);

      const [statsData, agentsData, incidentsData] = await Promise.all([
        statsRes.json(),
        agentsRes.json(),
        incidentsRes.json()
      ]);

      setDashboardStats(statsData);
      setAgents(agentsData.agents || {});
      setIncidents(incidentsData.incidents || []);
      setLastUpdate(new Date());
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

  const triggerTestIncident = async () => {
    try {
      const response = await fetch('/api/trigger-incident', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: '', // Empty title will trigger random scenario selection
          description: '',
          severity: 'high'
        })
      });
      const result = await response.json();
      
      alert(`🚨 ${result.incident_type?.toUpperCase()} Incident Created!\n\nID: ${result.incident_id}\nTitle: ${result.title}\n\nReal-time workflow started. Watch the agents work!`);
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

  const viewAgentLogs = async (incidentId, agentId) => {
    try {
      const response = await fetch(`/api/incidents/${incidentId}/agent/${agentId}/logs`);
      const logsData = await response.json();
      setAgentLogs(logsData);
      setShowLogs(true);
    } catch (err) {
      console.error('Failed to fetch agent logs:', err);
    }
  };

  const getAgentIcon = (agentName) => {
    const icons = {
      monitoring: Monitor, 
      rca: Search, 
      pager: Bell,
      ticketing: Ticket, 
      email: Mail, 
      remediation: Settings,
      validation: Shield
    };
    return icons[agentName] || Activity;
  };

  const getIncidentTypeIcon = (incidentType) => {
    const icons = {
      database: Database,
      security: Lock,
      network: Wifi,
      infrastructure: Server,
      container: Container,
      storage: Server,
      api: Activity,
      dns: Wifi
    };
    return icons[incidentType] || AlertTriangle;
  };

  const getIncidentTypeColor = (incidentType) => {
    const colors = {
      database: 'text-blue-400',
      security: 'text-red-400',
      network: 'text-green-400',
      infrastructure: 'text-purple-400',
      container: 'text-cyan-400',
      storage: 'text-yellow-400',
      api: 'text-pink-400',
      dns: 'text-indigo-400'
    };
    return colors[incidentType] || 'text-gray-400';
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'running': return 'bg-blue-500 animate-pulse';
      case 'success': return 'bg-green-500';
      case 'error': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center">
        <div className="text-center">
          <Activity className="w-12 h-12 text-blue-400 animate-spin mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Loading Real-Time AI Monitoring</h2>
          <p className="text-gray-400">Initializing diverse incident scenarios...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
      <header className="glass border-b border-gray-700/50">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="p-2 bg-blue-500/20 rounded-xl">
                <GitBranch className="w-8 h-8 text-blue-400" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-white">AI Monitoring System</h1>
                <p className="text-sm text-gray-400">Real-Time Workflow Engine v2.0 - 24 Incident Types</p>
              </div>
              {activeWorkflows.size > 0 && (
                <div className="flex items-center space-x-2 ml-8 bg-orange-500/20 px-3 py-1 rounded-lg">
                  <Activity className="w-4 h-4 text-orange-400 animate-spin" />
                  <span className="text-orange-400 font-medium">{activeWorkflows.size} Active Workflows</span>
                </div>
              )}
            </div>
            <div className="text-right">
              <p className="text-sm text-gray-400">Last Updated</p>
              <p className="text-sm font-medium text-white">{lastUpdate.toLocaleTimeString()}</p>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-6 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="glass rounded-xl p-6 hover:bg-white/[0.15] transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Active Incidents</p>
                <p className="text-2xl font-bold text-orange-400">{dashboardStats.incidents?.active || 0}</p>
                <p className="text-xs text-gray-500 mt-1">{dashboardStats.incidents?.today || 0} today</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-orange-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-white/[0.15] transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Success Rate</p>
                <p className="text-2xl font-bold text-green-400">
                  {dashboardStats.system?.overall_success_rate?.toFixed(1) || 100}%
                </p>
                <p className="text-xs text-gray-500 mt-1">Auto-resolved</p>
              </div>
              <TrendingUp className="w-8 h-8 text-green-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-white/[0.15] transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Avg Resolution</p>
                <p className="text-2xl font-bold text-blue-400">
                  {Math.round(dashboardStats.incidents?.average_resolution_time_minutes || 8.5)}m
                </p>
                <p className="text-xs text-gray-500 mt-1">Fully automated</p>
              </div>
              <Clock className="w-8 h-8 text-blue-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6 hover:bg-white/[0.15] transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Incident Types</p>
                <p className="text-2xl font-bold text-purple-400">24</p>
                <p className="text-xs text-gray-500 mt-1">Scenarios available</p>
              </div>
              <Zap className="w-8 h-8 text-purple-400" />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          <div className="xl:col-span-2">
            <div className="glass rounded-xl p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-semibold text-white">AI Agents Dashboard</h3>
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-sm text-green-400">All Systems Operational</span>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {Object.entries(agents).map(([agentId, agent]) => {
                  const IconComponent = getAgentIcon(agentId);
                  return (
                    <div key={agentId} className="bg-gray-800/50 rounded-lg p-4 border border-gray-600/50 hover:border-blue-500/50 transition-all cursor-pointer">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-3">
                          <div className="p-2 bg-blue-500/20 rounded-lg">
                            <IconComponent className="w-5 h-5 text-blue-400" />
                          </div>
                          <div>
                            <span className="font-medium text-white capitalize">{agentId}</span>
                            <p className="text-xs text-gray-400">{agent.last_activity}</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-1">
                          <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                          <span className="text-xs text-green-400 font-medium">Ready</span>
                        </div>
                      </div>
                      
                      <p className="text-sm text-gray-400 mb-3">{agent.description}</p>
                      
                      <div className="grid grid-cols-2 gap-2 text-xs">
                        <div>
                          <span className="text-gray-500">Executions:</span>
                          <span className="text-blue-400 font-medium ml-1">{agent.total_executions}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Success:</span>
                          <span className="text-green-400 font-medium ml-1">{agent.success_rate?.toFixed(1)}%</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Avg Time:</span>
                          <span className="text-purple-400 font-medium ml-1">{agent.average_duration?.toFixed(1)}s</span>
                        </div>
                        <div className="flex items-center">
                          <Eye className="w-3 h-3 text-gray-400 mr-1" />
                          <span className="text-gray-400">Clickable</span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Quick Actions</h3>
              <div className="space-y-3">
                <button
                  onClick={triggerTestIncident}
                  className="w-full bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2 shadow-lg"
                >
                  <AlertTriangle className="w-4 h-4" />
                  <span>Trigger Random Incident</span>
                </button>
                
                <button 
                  onClick={fetchAllData}
                  className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2 shadow-lg"
                >
                  <RefreshCw className="w-4 h-4" />
                  <span>Refresh Data</span>
                </button>
                
                <a 
                  href="/api/docs" 
                  target="_blank"
                  className="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2 shadow-lg"
                >
                  <ExternalLink className="w-4 h-4" />
                  <span>API Documentation</span>
                </a>
              </div>
            </div>

            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Recent Incidents</h3>
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {incidents.length === 0 ? (
                  <div className="text-center py-8">
                    <AlertTriangle className="w-12 h-12 text-gray-600 mx-auto mb-4" />
                    <p className="text-gray-400 text-sm mb-2">No incidents yet!</p>
                    <p className="text-gray-500 text-xs">Trigger an incident to see diverse AI agent workflows</p>
                  </div>
                ) : (
                  incidents.map((incident) => {
                    const IncidentTypeIcon = getIncidentTypeIcon(incident.incident_type);
                    const typeColor = getIncidentTypeColor(incident.incident_type);
                    
                    return (
                      <div 
                        key={incident.id} 
                        className="bg-gray-800/50 rounded-lg p-3 border border-gray-600/50 hover:border-blue-500/50 transition-all cursor-pointer"
                        onClick={() => viewIncidentDetails(incident.id)}
                      >
                        <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center space-x-2">
                            <IncidentTypeIcon className={`w-4 h-4 ${typeColor}`} />
                            <span className={`px-2 py-1 rounded-full text-xs font-medium text-white ${
                              incident.severity === 'critical' ? 'bg-red-600' :
                              incident.severity === 'high' ? 'bg-orange-500' :
                              incident.severity === 'medium' ? 'bg-yellow-500' : 'bg-green-500'
                            }`}>
                              {incident.severity.toUpperCase()}
                            </span>
                            <span className={`text-xs px-2 py-1 rounded-full bg-gray-700 ${typeColor}`}>
                              {incident.incident_type?.toUpperCase()}
                            </span>
                            {activeWorkflows.has(incident.id) && (
                              <Activity className="w-4 h-4 text-orange-400 animate-spin" />
                            )}
                          </div>
                          <span className="text-xs text-gray-400">
                            {new Date(incident.created_at).toLocaleTimeString()}
                          </span>
                        </div>
                        
                        <h4 className="text-sm font-medium text-white mb-2 truncate">
                          {incident.title}
                        </h4>
                        
                        <div className="flex items-center justify-between text-xs mb-2">
                          <span className="text-gray-400">Progress:</span>
                          <span className="text-blue-400">
                            {incident.completed_agents}/{incident.total_agents} agents completed
                          </span>
                        </div>
                        
                        <div className="w-full bg-gray-700 rounded-full h-2 mb-2">
                          <div 
                            className="bg-gradient-to-r from-blue-500 to-green-500 h-2 rounded-full transition-all duration-500"
                            style={{ width: `${(incident.completed_agents / incident.total_agents) * 100}%` }}
                          />
                        </div>
                        
                        <div className="flex items-center justify-between">
                          <span className={`text-xs px-2 py-1 rounded ${
                            incident.workflow_status === 'completed' ? 'bg-green-500/20 text-green-400' :
                            incident.workflow_status === 'in_progress' ? 'bg-blue-500/20 text-blue-400' :
                            'bg-gray-500/20 text-gray-400'
                          }`}>
                            {incident.workflow_status.replace('_', ' ')}
                          </span>
                          <button className="text-xs text-blue-400 hover:text-blue-300">
                            View Details →
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

      {selectedIncident && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass rounded-xl w-full max-w-6xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-gray-700">
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center space-x-3 mb-2">
                    {selectedIncident.incident_type && (
                      <>
                        {React.createElement(getIncidentTypeIcon(selectedIncident.incident_type), {
                          className: `w-6 h-6 ${getIncidentTypeColor(selectedIncident.incident_type)}`
                        })}
                        <span className={`px-2 py-1 rounded-full text-sm font-medium ${getIncidentTypeColor(selectedIncident.incident_type)} bg-gray-700`}>
                          {selectedIncident.incident_type.toUpperCase()}
                        </span>
                      </>
                    )}
                  </div>
                  <h2 className="text-2xl font-bold text-white">{selectedIncident.title}</h2>
                  <div className="flex items-center space-x-4 mt-2">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium text-white ${
                      selectedIncident.severity === 'critical' ? 'bg-red-600' :
                      selectedIncident.severity === 'high' ? 'bg-orange-500' :
                      selectedIncident.severity === 'medium' ? 'bg-yellow-500' : 'bg-green-500'
                    }`}>
                      {selectedIncident.severity?.toUpperCase()}
                    </span>
                    <span className="text-gray-400">ID: {selectedIncident.incident_id}</span>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedIncident(null)}
                  className="text-gray-400 hover:text-white"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
            </div>
            
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              <h3 className="text-lg font-semibold text-white mb-4">Real-Time Workflow Progress</h3>
              <div className="grid grid-cols-1 lg:grid-cols-7 gap-4 mb-8">
                {['monitoring', 'rca', 'pager', 'ticketing', 'email', 'remediation', 'validation'].map((agentId) => {
                  const execution = selectedIncident.executions?.[agentId];
                  const IconComponent = getAgentIcon(agentId);
                  
                  return (
                    <div key={agentId} className={`bg-gray-800/50 rounded-lg p-4 border-2 transition-all ${
                      execution?.status === 'running' ? 'border-blue-500 animate-pulse' :
                      execution?.status === 'success' ? 'border-green-500' :
                      execution?.status === 'error' ? 'border-red-500' : 'border-gray-600'
                    }`}>
                      <div className="flex items-center justify-between mb-2">
                        <IconComponent className="w-6 h-6 text-blue-400" />
                        <span className={`w-3 h-3 rounded-full ${getStatusColor(execution?.status || 'idle')}`}></span>
                      </div>
                      
                      <h4 className="text-sm font-medium text-white capitalize mb-1">{agentId}</h4>
                      <p className="text-xs text-gray-400 mb-2">
                        {execution?.status === 'running' ? 'In Progress...' :
                         execution?.status === 'success' ? 'Completed' :
                         execution?.status === 'error' ? 'Failed' : 'Waiting'}
                      </p>
                      
                      {execution && (
                        <>
                          <div className="w-full bg-gray-700 rounded-full h-1.5 mb-2">
                            <div 
                              className={`h-1.5 rounded-full transition-all duration-500 ${
                                execution.status === 'success' ? 'bg-green-500' :
                                execution.status === 'error' ? 'bg-red-500' : 'bg-blue-500'
                              }`}
                              style={{ width: `${execution.progress || 0}%` }}
                            />
                          </div>
                          
                          <div className="text-xs text-gray-400 mb-2">
                            {execution.duration ? `${execution.duration.toFixed(1)}s` : 'Running...'}
                          </div>
                          
                          <button
                            onClick={() => viewAgentLogs(selectedIncident.incident_id, agentId)}
                            className="text-xs bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 rounded flex items-center space-x-1"
                          >
                            <Terminal className="w-3 h-3" />
                            <span>View Logs</span>
                          </button>
                        </>
                      )}
                    </div>
                  );
                })}
              </div>

              {selectedIncident.root_cause && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  <div className="bg-gray-800/50 rounded-lg p-4">
                    <h4 className="text-lg font-semibold text-white mb-3">Analysis Results</h4>
                    <div className="space-y-3">
                      <div>
                        <span className="text-gray-400">Root Cause:</span>
                        <p className="text-white mt-1">{selectedIncident.root_cause}</p>
                      </div>
                      {selectedIncident.resolution && (
                        <div>
                          <span className="text-gray-400">Resolution:</span>
                          <p className="text-white mt-1">{selectedIncident.resolution}</p>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="bg-gray-800/50 rounded-lg p-4">
                    <h4 className="text-lg font-semibold text-white mb-3">Integration Results</h4>
                    <div className="space-y-2 text-sm">
                      {selectedIncident.pagerduty_incident_id && (
                        <div className="flex justify-between">
                          <span className="text-gray-400">PagerDuty:</span>
                          <span className="text-white">{selectedIncident.pagerduty_incident_id}</span>
                        </div>
                      )}
                      {selectedIncident.servicenow_ticket_id && (
                        <div className="flex justify-between">
                          <span className="text-gray-400">ServiceNow:</span>
                          <span className="text-white">{selectedIncident.servicenow_ticket_id}</span>
                        </div>
                      )}
                      {selectedIncident.remediation_applied?.length > 0 && (
                        <div>
                          <span className="text-gray-400">Remediation:</span>
                          <div className="mt-1">
                            {selectedIncident.remediation_applied.map((action, index) => (
                              <div key={index} className="flex items-center space-x-2">
                                <CheckCircle className="w-4 h-4 text-green-400" />
                                <span className="text-white text-xs">{action.replace('_', ' ')}</span>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {showLogs && agentLogs && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass rounded-xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-gray-700">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold text-white">{agentLogs.agent_name} - Console Logs</h2>
                  <p className="text-gray-400">Real-time execution details</p>
                </div>
                <button
                  onClick={() => setShowLogs(false)}
                  className="text-gray-400 hover:text-white"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
            </div>
            
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="bg-black rounded-lg p-4 font-mono text-sm">
                {agentLogs.logs?.length > 0 ? (
                  agentLogs.logs.map((log, index) => (
                    <div key={index} className="mb-2">
                      <span className="text-gray-500">
                        [{new Date(log.timestamp).toLocaleTimeString()}]
                      </span>
                      <span className={`ml-2 ${log.level === 'ERROR' ? 'text-red-400' : 'text-green-400'}`}>
                        {log.message}
                      </span>
                    </div>
                  ))
                ) : (
                  <p className="text-gray-400">No logs available</p>
                )}
              </div>
              
              {agentLogs.output_data && Object.keys(agentLogs.output_data).length > 0 && (
                <div className="mt-6">
                  <h3 className="text-lg font-semibold text-white mb-4">Agent Output Data</h3>
                  <div className="bg-black rounded-lg p-4">
                    <pre className="text-green-400 text-sm overflow-x-auto">
                      {JSON.stringify(agentLogs.output_data, null, 2)}
                    </pre>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
EOF_FRONTEND

echo "✅ Enhanced React frontend with incident type display created"

# Build the frontend
echo "🏗️  Building enhanced frontend..."
cd frontend
npm run build
cd ..

echo "✅ Frontend build completed"

# Restart the application
echo "🔄 Restarting application with diverse incidents..."

# Kill existing process if running
pkill -f "python.*main.py" || true

# Start the enhanced application
echo "🚀 Starting enhanced application..."
nohup python src/main.py > logs/app.log 2>&1 &

sleep 3

echo ""
echo "🎉 DIVERSE INCIDENTS ENHANCEMENT COMPLETED!"
echo "==========================================="
echo ""
echo "🆕 NEW FEATURES ADDED:"
echo "  ✅ 24 different incident scenarios with realistic details"
echo "  ✅ Incident type classification (Database, Security, Network, etc.)"
echo "  ✅ Type-specific agent behaviors and responses"
echo "  ✅ Incident-specific monitoring data and root causes"
echo "  ✅ Dynamic escalation teams based on incident type"
echo "  ✅ Variable timing and realistic execution patterns"
echo "  ✅ Enhanced UI with incident type icons and colors"
echo ""
echo "🎭 AVAILABLE INCIDENT TYPES:"
echo "  🗄️  Database (Connection pools, slow queries, corruption)"
echo "  🔒 Security (DDoS, ransomware, data breaches)"
echo "  🌐 Network (Switch failures, DNS issues, connectivity)"
echo "  🖥️  Infrastructure (CPU, memory, disk failures)"
echo "  📦 Container (Kubernetes pods, Docker registry)"
echo "  💾 Storage (RAID failures, disk corruption)"
echo "  🔗 API (Rate limiting, gateway issues)"
echo "  🌍 DNS (Resolution failures, configuration drift)"
echo ""
echo "✨ ENHANCED AGENT BEHAVIORS:"
echo "  📊 Monitoring: Type-specific metrics and analysis"
echo "  🧠 RCA: Incident-specific root cause analysis"
echo "  📞 Pager: Smart escalation to appropriate teams"
echo "  🎫 Ticketing: Intelligent priority and categorization"
echo "  📧 Email: Context-aware stakeholder notifications"
echo "  🔧 Remediation: Type-specific automated fixes"
echo "  ✅ Validation: Incident-specific health checks"
echo ""
echo "🚀 TRY IT NOW:"
echo "  1. Visit: http://35.232.141.161:8000"
echo "  2. Click 'Trigger Random Incident'"
echo "  3. Watch different incident types trigger unique workflows"
echo "  4. Each click will show a different scenario!"
echo ""
echo "🔍 WHAT TO OBSERVE:"
echo "  • Different incident titles and descriptions each time"
echo "  • Type-specific icons and colors in the UI"
echo "  • Agents performing different actions based on incident type"
echo "  • Varied execution times and realistic behavior"
echo "  • Context-specific root causes and resolutions"
echo ""
echo "🌟 Each incident now provides a unique, realistic experience"
echo "    showcasing how AI agents adapt to different operational scenarios!"        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_incident_specific_actions(self, incident_type: str) -> List[str]:
        """Get incident-specific recommended actions"""
        actions_map = {
            "database": ["Scale connection pool", "Optimize slow queries", "Add read replicas"],
            "security": ["Isolate affected systems", "Reset compromised credentials", "Apply security patches"],
            "network": ["Failover to backup systems", "Replace faulty hardware", "Update routing tables"],
            "infrastructure": ["Scale resources", "Restart services", "Apply system updates"],
            "container": ["Increase resource limits", "Restart pods", "Update container images"],
            "storage": ["Replace failed disks", "Initiate RAID rebuild", "Migrate data"],
            "api": ["Enable rate limiting", "Scale backend services", "Optimize API calls"],
            "dns": ["Update DNS configuration", "Restart DNS services", "Check upstream resolvers"]
        }
        return actions_map.get(incident_type, ["Restart services", "Scale resources", "Apply updates"])
    
    async def _execute_pager_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="pager", agent_name="Pager Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"📞 Creating PagerDuty alert for {incident.incident_type} incident...")
            execution.progress = 40
            await asyncio.sleep(random.uniform(0.8, 1.5))
            
            # Determine escalation based on incident type and severity
            escalation_team = self._get_escalation_team(incident.incident_type, incident.severity.value)
            
            await self._log_activity(execution, f"📱 Escalating to {escalation_team} team...")
            execution.progress = 80
            await asyncio.sleep(random.uniform(0.8, 1.2))
            
            execution.output_data = {
                "pagerduty_incident_id": f"PD-{incident.incident_type.upper()}-{incident.id[-6:]}",
                "escalated_to": escalation_team,
                "notification_methods": ["SMS", "Phone", "Email", "Slack"],
                "severity_mapped": incident.severity.value
            }
            
            incident.pagerduty_incident_id = execution.output_data["pagerduty_incident_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ {escalation_team} team notified via PagerDuty")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_escalation_team(self, incident_type: str, severity: str) -> str:
        """Determine which team to escalate to based on incident type"""
        team_map = {
            "database": "Database Engineering",
            "security": "Security Operations",
            "network": "Network Operations",
            "infrastructure": "Infrastructure Engineering",
            "container": "Platform Engineering",
            "storage": "Storage Engineering",
            "api": "API Gateway Team",
            "dns": "Network Operations"
        }
        base_team = team_map.get(incident_type, "General Operations")
        
        if severity == "critical":
            return f"Senior {base_team}"
        return base_team
    
    async def _execute_ticketing_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="ticketing", agent_name="Ticketing Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"🎫 Creating ServiceNow ticket for {incident.incident_type}...")
            execution.progress = 30
            await asyncio.sleep(random.uniform(1.0, 1.8))
            
            # Set priority and category based on incident type
            priority, category = self._get_ticket_classification(incident.incident_type, incident.severity.value)
            
            await self._log_activity(execution, f"📝 Setting priority to {priority} and categorizing...")
            execution.progress = 70
            await asyncio.sleep(random.uniform(0.8, 1.2))
            
            execution.output_data = {
                "ticket_id": f"{incident.incident_type.upper()}{datetime.now().strftime('%Y%m%d')}{incident.id[-4:]}",
                "priority": priority,
                "category": category,
                "assigned_to": self._get_escalation_team(incident.incident_type, incident.severity.value),
                "estimated_resolution": self._get_resolution_estimate(incident.incident_type)
            }
            
            incident.servicenow_ticket_id = execution.output_data["ticket_id"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ Ticket {execution.output_data['ticket_id']} created")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_ticket_classification(self, incident_type: str, severity: str) -> tuple:
        """Get ticket priority and category based on incident type"""
        priority_map = {
            "critical": "1 - Critical",
            "high": "2 - High", 
            "medium": "3 - Medium",
            "low": "4 - Low"
        }
        
        category_map = {
            "database": "Database - Performance",
            "security": "Security - Incident Response",
            "network": "Network - Connectivity",
            "infrastructure": "Infrastructure - System Failure",
            "container": "Platform - Container Services",
            "storage": "Storage - Hardware Failure",
            "api": "Application - API Services",
            "dns": "Network - DNS Services"
        }
        
        return priority_map.get(severity, "3 - Medium"), category_map.get(incident_type, "General - Infrastructure")
    
    def _get_resolution_estimate(self, incident_type: str) -> str:
        """Get estimated resolution time based on incident type"""
        estimates = {
            "database": "2-4 hours",
            "security": "4-8 hours", 
            "network": "1-3 hours",
            "infrastructure": "2-6 hours",
            "container": "1-2 hours",
            "storage": "4-12 hours",
            "api": "1-2 hours",
            "dns": "30 minutes - 2 hours"
        }
        return estimates.get(incident_type, "2-4 hours")
    
    async def _execute_email_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="email", agent_name="Email Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"📧 Composing {incident.incident_type} incident notification...")
            execution.progress = 40
            await asyncio.sleep(random.uniform(0.8, 1.2))
            
            # Determine stakeholders based on incident type and severity
            stakeholders = self._get_incident_stakeholders(incident.incident_type, incident.severity.value)
            
            await self._log_activity(execution, f"📤 Notifying {len(stakeholders)} stakeholder groups...")
            execution.progress = 80
            await asyncio.sleep(random.uniform(0.8, 1.5))
            
            execution.output_data = {
                "emails_sent": stakeholders,
                "notification_type": f"{incident.incident_type}_incident",
                "executive_briefing": incident.severity.value in ["critical", "high"]
            }
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, "✅ Stakeholder notifications sent successfully")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_incident_stakeholders(self, incident_type: str, severity: str) -> List[str]:
        """Get stakeholders to notify based on incident type"""
        base_stakeholders = [f"{incident_type}-team@company.com", "it-ops@company.com"]
        
        if severity in ["critical", "high"]:
            base_stakeholders.extend(["management@company.com", "cto@company.com"])
            
        if incident_type == "security":
            base_stakeholders.extend(["security-team@company.com", "compliance@company.com"])
        elif incident_type == "database":
            base_stakeholders.extend(["dba-team@company.com", "backend-dev@company.com"])
        elif incident_type == "network":
            base_stakeholders.extend(["network-ops@company.com", "telecom@company.com"])
            
        return base_stakeholders
    
    async def _execute_remediation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="remediation", agent_name="Remediation Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"🔧 Analyzing {incident.incident_type} remediation options...")
            execution.progress = 25
            await asyncio.sleep(random.uniform(1.0, 2.0))
            
            # Get incident-specific remediation actions
            remediation_actions = self._get_remediation_actions(incident.incident_type, incident.severity.value)
            
            await self._log_activity(execution, f"⚡ Applying {len(remediation_actions)} automated fixes...")
            execution.progress = 50
            await asyncio.sleep(random.uniform(2.0, 3.5))
            
            await self._log_activity(execution, f"🔄 Executing {incident.incident_type}-specific recovery procedures...")
            execution.progress = 75
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            execution.output_data = {
                "actions_performed": remediation_actions,
                "rollback_available": incident.incident_type != "security",  # Security incidents often can't be rolled back
                "automation_level": "high" if incident.incident_type in ["container", "api"] else "medium"
            }
            
            incident.remediation_applied = execution.output_data["actions_performed"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ {incident.incident_type.title()} remediation completed")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_remediation_actions(self, incident_type: str, severity: str) -> List[str]:
        """Get incident-specific remediation actions"""
        action_map = {
            "database": ["connection_pool_scaling", "query_optimization", "replica_failover"],
            "security": ["account_isolation", "credential_reset", "security_patching", "network_segmentation"],
            "network": ["traffic_rerouting", "hardware_replacement", "failover_activation"],
            "infrastructure": ["resource_scaling", "service_restart", "load_balancing"],
            "container": ["pod_restart", "resource_limit_increase", "image_update"],
            "storage": ["disk_replacement", "raid_rebuild", "data_migration"],
            "api": ["rate_limit_enforcement", "backend_scaling", "cache_optimization"],
            "dns": ["dns_config_update", "resolver_restart", "cache_flush"]
        }
        
        actions = action_map.get(incident_type, ["service_restart", "resource_scaling"])
        
        # Add additional actions for critical incidents
        if severity == "critical":
            if incident_type == "database":
                actions.append("emergency_read_replica")
            elif incident_type == "security":
                actions.append("incident_containment")
            elif incident_type == "network":
                actions.append("emergency_bypass")
                
        return actions
    
    async def _execute_validation_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(agent_id="validation", agent_name="Validation Agent", incident_id=incident.id)
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        try:
            await self._log_activity(execution, f"🔍 Starting {incident.incident_type} resolution validation...")
            execution.progress = 30
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            await self._log_activity(execution, f"📊 Monitoring {incident.incident_type} system metrics...")
            execution.progress = 60
            await asyncio.sleep(random.uniform(1.5, 2.0))
            
            await self._log_activity(execution, f"✅ Verifying {incident.incident_type} service health...")
            execution.progress = 90
            await asyncio.sleep(random.uniform(1.0, 1.5))
            
            # Generate incident-specific validation results
            validation_results = self._get_validation_results(incident.incident_type)
            
            execution.output_data = {
                "health_checks": validation_results,
                "incident_resolved": random.choice([True, True, True, False]),  # 75% success rate
                "validation_score": random.uniform(0.85, 0.98),
                "incident_type": incident.incident_type
            }
            
            if execution.output_data["incident_resolved"]:
                incident.resolution = self._get_resolution_message(incident.incident_type)
            else:
                incident.resolution = f"{incident.incident_type.title()} issue partially resolved - monitoring continues"
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ {incident.incident_type.title()} validation completed")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR
            execution.error_message = str(e)
        
        execution.completed_at = datetime.now()
        execution.duration_seconds = (execution.completed_at - execution.started_at).total_seconds()
        return execution
    
    def _get_validation_results(self, incident_type: str) -> Dict[str, str]:
        """Get incident-specific validation results"""
        result_map = {
            "database": {"connections": "Normal", "query_time": "<100ms", "cpu": "45%", "memory": "62%"},
            "security": {"threat_level": "Low", "access_controls": "Active", "monitoring": "Enabled"},
            "network": {"latency": "12ms", "packet_loss": "0%", "bandwidth": "Normal"},
            "infrastructure": {"cpu": "35%", "memory": "58%", "disk": "72%", "services": "Healthy"},
            "container": {"pods": "Running", "memory": "Normal", "cpu": "40%", "replicas": "3/3"},
            "storage": {"raid_status": "Optimal", "disk_health": "Good", "io_latency": "2ms"},
            "api": {"response_time": "45ms", "error_rate": "0.1%", "throughput": "Normal"},
            "dns": {"resolution_time": "15ms", "query_success": "99.8%", "cache_hit": "85%"}
        }
        return result_map.get(incident_type, {"status": "Healthy", "performance": "Normal"})
    
    def _get_resolution_message(self, incident_type: str) -> str:
        """Get incident-specific resolution message"""
        messages = {
            "database": "Database connection pool optimized and performance restored to normal levels",
            "security": "Security threat contained and systems hardened against future attacks",
            "network": "Network connectivity restored and redundancy verified",
            "infrastructure": "Infrastructure scaled and system performance normalized",
            "container": "Container resources optimized and pod stability restored",
            "storage": "Storage system repaired and data integrity verified",
            "api": "API rate limiting configured and backend performance optimized",
            "dns": "DNS configuration corrected and resolution performance restored"
        }
        return messages.get(incident_type, "System issue resolved and normal operations restored")
    
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
                "incident_type": incident.incident_type,
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
                "incident_type": getattr(incident, 'incident_type', 'general'),
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
                        "incident_type": getattr(incident, 'incident_type', 'general'),
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
            
            # Incident type statistics
            incident_types = {}
            for incident in all_incidents:
                incident_type = getattr(incident, 'incident_type', 'general')
                incident_types[incident_type] = incident_types.get(incident_type, 0) + 1
            
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
                    "average_resolution_time_minutes": 8.5,
                    "by_type": incident_types
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
                            "incident_type": getattr(incident, 'incident_type', 'general'),
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
                "features": ["Real-time workflows", "Live tracking", "WebSocket updates", "Diverse incidents"],
                "workflow_engine": {
                    "active_incidents": len(workflow_engine.active_incidents),
                    "total_incidents": len(workflow_engine.incident_history),
                    "available_scenarios": len(INCIDENT_SCENARIOS)
                }
            }
        
        @self.app.get("/api/agents")
        async def get_agents():
            agent_configs = {
                "monitoring": "Real-time monitoring of infrastructure metrics, logs, and traces",
                "rca": "AI-powered root cause analysis using machine learning models", 
                "pager": "Automated incident escalation and team notification",
                "ticketing": "ServiceNow ticket creation with intelligent classification",
                "email": "Stakeholder notifications with context-aware messaging",
                "remediation": "Automated issue resolution with safety controls",
                "validation": "Resolution verification and system health validation"
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
        
        # Get available incident scenarios
        @self.app.get("/api/incident-scenarios")
        async def get_incident_scenarios():
            return {
                "total_scenarios": len(INCIDENT_SCENARIOS),
                "scenarios": [
                    {
                        "title": scenario["title"],
                        "incident_type": scenario["incident_type"],
                        "severity": scenario["severity"],
                        "affected_systems": len(scenario["affected_systems"])
                    }#!/bin/bash

echo "🚨 Adding 20+ Diverse Incident Scenarios to AI Monitoring System"
echo "=============================================================="

# Update the main.py file to include diverse incident scenarios
echo "🔧 Enhancing main.py with diverse incident scenarios..."

# Create the enhanced main.py with random incident selection
cat > src/main.py << 'EOF_ENHANCED_MAIN'
"""
Enhanced AI-Powered IT Operations Monitoring System
Real-time workflow execution with diverse incident scenarios
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
    incident_type: str = ""

# Diverse incident scenarios database
INCIDENT_SCENARIOS = [
    {
        "title": "Database Connection Pool Exhaustion - Production MySQL",
        "description": "Production MySQL database experiencing connection pool exhaustion with applications unable to establish new connections. Active connections peaked at 500/500 limit.",
        "severity": "critical",
        "affected_systems": ["mysql-prod-01", "mysql-prod-02", "app-servers-pool"],
        "incident_type": "database",
        "root_cause_template": "Connection pool exhaustion due to long-running queries and insufficient connection cleanup",
        "monitoring_data": {
            "connection_count": 500,
            "slow_queries": 45,
            "cpu_usage": "85%",
            "response_time": "15.2s"
        }
    },
    {
        "title": "DDoS Attack Detected - Main Web Application",
        "description": "Distributed Denial of Service attack targeting main web application. Traffic spike detected at 50,000 requests/second from multiple IP ranges.",
        "severity": "critical",
        "affected_systems": ["web-app-prod", "load-balancer-01", "cdn-endpoints"],
        "incident_type": "security",
        "root_cause_template": "Coordinated DDoS attack using botnet across multiple geographic regions",
        "monitoring_data": {
            "request_rate": "50,000/sec",
            "error_rate": "78%",
            "origin_countries": ["Unknown", "Multiple"],
            "blocked_ips": 15420
        }
    },
    {
        "title": "Redis Cache Cluster Memory Exhaustion",
        "description": "Redis cache cluster experiencing memory exhaustion leading to cache misses and degraded application performance across all services.",
        "severity": "high",
        "affected_systems": ["redis-cluster-01", "redis-cluster-02", "microservices-backend"],
        "incident_type": "infrastructure",
        "root_cause_template": "Memory leak in session data storage causing gradual memory exhaustion",
        "monitoring_data": {
            "memory_usage": "98%",
            "cache_hit_ratio": "23%",
            "evicted_keys": 89234,
            "connected_clients": 1024
        }
    },
    {
        "title": "SSL Certificate Expiration - E-commerce Platform",
        "description": "SSL certificates for main e-commerce platform expired, causing browser security warnings and preventing customer transactions.",
        "severity": "critical",
        "affected_systems": ["ecommerce-frontend", "payment-gateway", "api-endpoints"],
        "incident_type": "security",
        "root_cause_template": "SSL certificate auto-renewal process failed due to DNS validation issues",
        "monitoring_data": {
            "expired_certs": 3,
            "failed_transactions": 245,
            "bounce_rate": "89%",
            "customer_complaints": 67
        }
    },
    {
        "title": "Kubernetes Pod Crash Loop - Microservices",
        "description": "Critical microservices experiencing crash loop backoff in Kubernetes cluster. Pod restart count exceeded threshold with OOMKilled status.",
        "severity": "high",
        "affected_systems": ["k8s-cluster-prod", "user-service", "order-service"],
        "incident_type": "container",
        "root_cause_template": "Memory limits too restrictive for current workload causing OOMKilled events",
        "monitoring_data": {
            "restart_count": 847,
            "memory_limit": "512Mi",
            "memory_usage": "1.2Gi",
            "failed_pods": 12
        }
    },
    {
        "title": "Ransomware Detection - File Server Encryption",
        "description": "Ransomware activity detected on file servers. Multiple files showing .locked extension and ransom note detected in shared directories.",
        "severity": "critical",
        "affected_systems": ["file-server-01", "backup-server", "shared-storage"],
        "incident_type": "security",
        "root_cause_template": "Ransomware infiltration through compromised email attachment and lateral movement",
        "monitoring_data": {
            "encrypted_files": 15678,
            "affected_shares": 8,
            "ransom_amount": "$50,000",
            "infection_vector": "Email attachment"
        }
    },
    {
        "title": "API Rate Limit Exceeded - Third-party Integration",
        "description": "Third-party payment API rate limits exceeded causing transaction failures. 95% of payment requests returning 429 Too Many Requests errors.",
        "severity": "high",
        "affected_systems": ["payment-service", "checkout-api", "billing-system"],
        "incident_type": "integration",
        "root_cause_template": "Inefficient API call patterns and missing request throttling mechanisms",
        "monitoring_data": {
            "api_calls_per_minute": 10000,
            "rate_limit": 5000,
            "failed_payments": 1847,
            "queue_depth": 15000
        }
    },
    {
        "title": "Storage Array Disk Failure - RAID Degraded",
        "description": "Storage array experiencing multiple disk failures. RAID 5 array in degraded state with 2 out of 8 disks failed. Risk of data loss if additional disk fails.",
        "severity": "critical",
        "affected_systems": ["storage-array-01", "database-volumes", "vm-datastores"],
        "incident_type": "hardware",
        "root_cause_template": "Hardware failure due to disk age and excessive wear from high I/O workloads",
        "monitoring_data": {
            "failed_disks": 2,
            "total_disks": 8,
            "array_status": "Degraded",
            "rebuild_eta": "8 hours"
        }
    },
    {
        "title": "Network Switch Stack Failure - Data Center",
        "description": "Core network switch stack failure in primary data center causing network segmentation and connectivity issues across multiple VLANs.",
        "severity": "critical",
        "affected_systems": ["core-switch-stack", "vlan-infrastructure", "inter-dc-links"],
        "incident_type": "network",
        "root_cause_template": "Switch stack master election failure due to firmware bug and split-brain condition",
        "monitoring_data": {
            "affected_vlans": 12,
            "disconnected_devices": 245,
            "packet_loss": "35%",
            "failover_time": "12 minutes"
        }
    },
    {
        "title": "Docker Registry Corruption - Container Deployment",
        "description": "Docker registry experiencing image corruption preventing container deployments. Multiple layers showing checksum mismatches and pull failures.",
        "severity": "high",
        "affected_systems": ["docker-registry", "ci-cd-pipeline", "deployment-systems"],
        "incident_type": "container",
        "root_cause_template": "Storage corruption in registry backend due to disk I/O errors",
        "monitoring_data": {
            "corrupted_images": 23,
            "failed_pulls": 156,
            "registry_size": "2.3TB",
            "storage_errors": 89
        }
    },
    {
        "title": "Active Directory Domain Controller Failure",
        "description": "Primary Active Directory domain controller failure causing authentication issues across the organization. Users unable to log in to domain resources.",
        "severity": "critical",
        "affected_systems": ["ad-dc-primary", "ad-dc-secondary", "domain-workstations"],
        "incident_type": "authentication",
        "root_cause_template": "Hardware failure on primary DC with delayed replication to secondary controllers",
        "monitoring_data": {
            "failed_logins": 1456,
            "affected_users": 890,
            "replication_lag": "45 minutes",
            "dc_status": "Offline"
        }
    },
    {
        "title": "Elasticsearch Cluster Split Brain - Search Service",
        "description": "Elasticsearch cluster experiencing split brain condition with multiple master nodes causing search service inconsistencies and data conflicts.",
        "severity": "high",
        "affected_systems": ["elasticsearch-cluster", "search-api", "analytics-dashboard"],
        "incident_type": "search",
        "root_cause_template": "Network partition causing split brain with multiple master elections",
        "monitoring_data": {
            "master_nodes": 3,
            "cluster_status": "Red",
            "unassigned_shards": 45,
            "search_errors": "67%"
        }
    },
    {
        "title": "CDN Origin Server Overload - Media Streaming",
        "description": "CDN origin servers experiencing overload during peak streaming hours. Cache miss ratio increased to 85% causing direct origin hits and slow response times.",
        "severity": "high",
        "affected_systems": ["cdn-origin-servers", "media-cache", "streaming-platform"],
        "incident_type": "cdn",
        "root_cause_template": "CDN cache invalidation storm and insufficient origin server capacity",
        "monitoring_data": {
            "cache_hit_ratio": "15%",
            "origin_response_time": "8.5s",
            "concurrent_streams": 45000,
            "bandwidth_usage": "95%"
        }
    },
    {
        "title": "Message Queue Deadlock - Event Processing",
        "description": "RabbitMQ message queue experiencing deadlock condition. Consumer processes hanging and message backlog growing exponentially.",
        "severity": "high",
        "affected_systems": ["rabbitmq-cluster", "event-processors", "notification-service"],
        "incident_type": "messaging",
        "root_cause_template": "Circular dependency in message processing causing deadlock condition",
        "monitoring_data": {
            "queue_depth": 125000,
            "dead_letter_count": 8934,
            "consumer_count": 0,
            "memory_usage": "92%"
        }
    },
    {
        "title": "Cloud Storage Bucket Misconfiguration - Data Exposure",
        "description": "AWS S3 bucket misconfiguration detected exposing sensitive customer data to public internet. Security scan identified 15,000 accessible files.",
        "severity": "critical",
        "affected_systems": ["s3-customer-data", "cloud-infrastructure", "data-pipeline"],
        "incident_type": "security",
        "root_cause_template": "Bucket policy misconfiguration during infrastructure automation deployment",
        "monitoring_data": {
            "exposed_files": 15000,
            "data_size": "45GB",
            "access_logs": "Unknown",
            "discovery_time": "2 hours"
        }
    },
    {
        "title": "DNS Resolution Failure - External Services",
        "description": "DNS resolution failures for external services causing application timeouts. Multiple DNS queries failing with NXDOMAIN responses.",
        "severity": "medium",
        "affected_systems": ["dns-servers", "external-apis", "web-applications"],
        "incident_type": "dns",
        "root_cause_template": "DNS server configuration drift and upstream resolver connectivity issues",
        "monitoring_data": {
            "failed_queries": 12456,
            "nxdomain_rate": "45%",
            "resolver_timeout": "15s",
            "affected_domains": 23
        }
    },
    {
        "title": "Load Balancer Health Check Failures - Web Tier",
        "description": "Load balancer health checks failing for web tier causing traffic routing issues. 6 out of 10 backend servers marked as unhealthy.",
        "severity": "high",
        "affected_systems": ["load-balancer", "web-servers", "application-tier"],
        "incident_type": "loadbalancer",
        "root_cause_template": "Health check endpoint timeout due to database connection bottleneck",
        "monitoring_data": {
            "healthy_servers": 4,
            "total_servers": 10,
            "health_check_timeout": "30s",
            "traffic_distribution": "Uneven"
        }
    },
    {
        "title": "Backup System Corruption - Data Recovery",
        "description": "Backup system experiencing data corruption during nightly backup process. Last 3 backup sets failed integrity checks with checksum mismatches.",
        "severity": "critical",
        "affected_systems": ["backup-servers", "tape-library", "backup-software"],
        "incident_type": "backup",
        "root_cause_template": "Storage media degradation and backup software bug causing data corruption",
        "monitoring_data": {
            "failed_backups": 3,
            "corruption_rate": "15%",
            "affected_data": "2.5TB",
            "last_good_backup": "4 days ago"
        }
    },
    {
        "title": "VPN Concentrator Overload - Remote Access",
        "description": "VPN concentrator experiencing connection overload during peak remote work hours. New connection attempts failing with resource exhaustion errors.",
        "severity": "medium",
        "affected_systems": ["vpn-concentrator", "remote-access", "authentication-server"],
        "incident_type": "vpn",
        "root_cause_template": "Concurrent connection limit exceeded due to increased remote work demand",
        "monitoring_data": {
            "active_connections": 2000,
            "connection_limit": 2000,
            "failed_attempts": 456,
            "cpu_usage": "95%"
        }
    },
    {
        "title": "Container Registry Authentication Failure",
        "description": "Container registry authentication service failure preventing Docker image pulls and pushes. CI/CD pipelines failing across all environments.",
        "severity": "high",
        "affected_systems": ["container-registry", "ci-cd-pipeline", "deployment-automation"],
        "incident_type": "container",
        "root_cause_template": "Authentication service database connection failure and token validation issues",
        "monitoring_data": {
            "failed_authentications": 789,
            "affected_pipelines": 34,
            "registry_downtime": "2 hours",
            "error_rate": "98%"
        }
    },
    {
        "title": "IoT Device Botnet Activity - Network Security",
        "description": "Suspicious botnet activity detected from IoT devices. Multiple devices showing coordinated outbound traffic patterns to unknown command and control servers.",
        "severity": "high",
        "affected_systems": ["iot-devices", "network-security", "firewall-systems"],
        "incident_type": "security",
        "root_cause_template": "IoT device firmware vulnerability exploited for botnet recruitment",
        "monitoring_data": {
            "infected_devices": 67,
            "c2_servers": 5,
            "outbound_traffic": "500MB/hour",
            "device_types": ["cameras", "sensors", "controllers"]
        }
    },
    {
        "title": "Log Aggregation System Disk Full - Monitoring",
        "description": "Log aggregation system experiencing disk space exhaustion. Log ingestion stopped and historical data at risk of loss due to storage constraints.",
        "severity": "medium",
        "affected_systems": ["log-aggregation", "elasticsearch", "monitoring-dashboard"],
        "incident_type": "monitoring",
        "root_cause_template": "Log retention policy misconfiguration and unexpected log volume spike",
        "monitoring_data": {
            "disk_usage": "98%",
            "log_ingestion_rate": "0 MB/s",
            "retention_period": "90 days",
            "data_at_risk": "1.2TB"
        }
    },
    {
        "title": "API Gateway Rate Limiting Malfunction",
        "description": "API gateway rate limiting system malfunction allowing excessive requests to backend services. Database connection pool saturation detected.",
        "severity": "high",
        "affected_systems": ["api-gateway", "backend-services", "database-pool"],
        "incident_type": "api",
        "root_cause_template": "Rate limiting service configuration error bypassing request throttling",
        "monitoring_data": {
            "requests_per_second": 15000,
            "rate_limit_bypassed": "78%",
            "backend_errors": 2456,
            "db_pool_usage": "100%"
        }
    }
]

class WorkflowEngine:
    def __init__(self):
        self.active_incidents: Dict[str, Incident] = {}
        self.incident_history: List[Incident] = []
        self.agent_execution_history: Dict[str, List[AgentExecution]] = {
            "monitoring": [], "rca": [], "pager": [], "ticketing": [], 
            "email": [], "remediation": [], "validation": []
        }
        
    async def trigger_incident_workflow(self, incident_data: Dict[str, Any]) -> Incident:
        # If no title provided, select a random scenario
        if not incident_data.get("title") or incident_data.get("title") == "High CPU Usage Alert - Production Web Servers":
            scenario = random.choice(INCIDENT_SCENARIOS)
            incident = Incident(
                title=scenario["title"],
                description=scenario["description"],
                severity=IncidentSeverity(scenario["severity"]),
                affected_systems=scenario["affected_systems"],
                incident_type=scenario["incident_type"]
            )
        else:
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
                
                await asyncio.sleep(random.uniform(1.5, 3.0))  # Variable timing
            
            incident.workflow_status = "completed"
            incident.current_agent = ""
            incident.status = "resolved" if len(incident.failed_agents) == 0 else "partially_resolved"
            
            self.incident_history.append(incident)
            del self.active_incidents[incident.id]
            
        except Exception as e:
            incident.workflow_status = "failed"
            incident.status = "failed"
            logger.error(f"Workflow failed for incident {incident.id}: {str(e)}")
    
    def get_incident_specific_data(self, incident: Incident):
        """Get incident-specific monitoring data and context"""
        for scenario in INCIDENT_SCENARIOS:
            if scenario["title"] == incident.title:
                return scenario
        return None
    
    async def _execute_monitoring_agent(self, incident: Incident) -> AgentExecution:
        execution = AgentExecution(
            agent_id="monitoring", agent_name="Monitoring Agent",
            incident_id=incident.id, input_data={"systems": incident.affected_systems}
        )
        
        execution.status = AgentStatus.RUNNING
        execution.started_at = datetime.now()
        
        scenario_data = self.get_incident_specific_data(incident)
        
        try:
            if incident.incident_type == "database":
                await self._log_activity(execution, "🔍 Analyzing database connection metrics...")
                execution.progress = 20
                await asyncio.sleep(random.uniform(1.0, 2.0))
                
                await self._log_activity(execution, "📊 Collecting MySQL performance data...")
                execution.progress = 50
                await asyncio.sleep(random.uniform(1.5, 2.5))
                
                await self._log_activity(execution, "📝 Analyzing connection pool exhaustion...")
                execution.progress = 80
                await asyncio.sleep(random.uniform(1.0, 2.0))
                
                execution.output_data = {
                    "database_connections": scenario_data["monitoring_data"]["connection_count"],
                    "slow_queries": scenario_data["monitoring_data"]["slow_queries"],
                    "cpu_usage": scenario_data["monitoring_data"]["cpu_usage"],
                    "response_time": scenario_data["monitoring_data"]["response_time"],
                    "anomaly_type": "connection_exhaustion"
                }
                
            elif incident.incident_type == "security":
                await self._log_activity(execution, "🚨 Security threat detection in progress...")
                execution.progress = 25
                await asyncio.sleep(random.uniform(1.0, 2.0))
                
                await self._log_activity(execution, "🔒 Analyzing security event patterns...")
                execution.progress = 60
                await asyncio.sleep(random.uniform(2.0, 3.0))
                
                await self._log_activity(execution, "⚠️ Threat intelligence correlation...")
                execution.progress = 85
                await asyncio.sleep(random.uniform(1.0, 1.5))
                
                execution.output_data = {
                    "threat_indicators": scenario_data["monitoring_data"],
                    "security_events": 15420,
                    "threat_level": "High",
                    "anomaly_type": "security_breach"
                }
                
            elif incident.incident_type == "network":
                await self._log_activity(execution, "🌐 Network topology analysis initiated...")
                execution.progress = 30
                await asyncio.sleep(random.uniform(1.5, 2.0))
                
                await self._log_activity(execution, "📡 Collecting network performance metrics...")
                execution.progress = 65
                await asyncio.sleep(random.uniform(2.0, 2.5))
                
                await self._log_activity(execution, "🔍 Analyzing packet loss and latency...")
                execution.progress = 90
                await asyncio.sleep(random.uniform(1.0, 1.5))
                
                execution.output_data = {
                    "network_metrics": scenario_data["monitoring_data"],
                    "affected_segments": len(incident.affected_systems),
                    "packet_analysis": "Complete",
                    "anomaly_type": "network_failure"
                }
                
            else:  # Default infrastructure
                await self._log_activity(execution, "🔍 Infrastructure health scan initiated...")
                execution.progress = 20
                await asyncio.sleep(random.uniform(1.0, 2.0))
                
                await self._log_activity(execution, "📊 Collecting system metrics...")
                execution.progress = 50
                await asyncio.sleep(random.uniform(1.5, 2.5))
                
                await self._log_activity(execution, "📝 Correlating performance data...")
                execution.progress = 80
                await asyncio.sleep(random.uniform(1.0, 2.0))
                
                execution.output_data = {
                    "system_metrics": scenario_data["monitoring_data"] if scenario_data else {"cpu": "85%", "memory": "78%"},
                    "affected_services": len(incident.affected_systems),
                    "anomaly_type": "infrastructure_degradation"
                }
            
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ {incident.incident_type.title()} monitoring analysis completed")
            
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
        
        scenario_data = self.get_incident_specific_data(incident)
        
        try:
            await self._log_activity(execution, f"🧠 AI-powered RCA for {incident.incident_type} incident...")
            execution.progress = 25
            await asyncio.sleep(random.uniform(1.5, 2.5))
            
            if incident.incident_type == "database":
                await self._log_activity(execution, "🔍 Analyzing database query patterns and locks...")
                execution.progress = 60
                await asyncio.sleep(random.uniform(2.0, 3.0))
                
                root_cause = scenario_data["root_cause_template"] if scenario_data else "Database connection pool misconfiguration"
                
            elif incident.incident_type == "security":
                await self._log_activity(execution, "🛡️ Correlating security events with threat intelligence...")
                execution.progress = 60
                await asyncio.sleep(random.uniform(2.5, 3.5))
                
                root_cause = scenario_data["root_cause_template"] if scenario_data else "Security breach via compromised credentials"
                
            elif incident.incident_type == "network":
                await self._log_activity(execution, "🌐 Network path analysis and failure point identification...")
                execution.progress = 60
                await asyncio.sleep(random.uniform(2.0, 3.0))
                
                root_cause = scenario_data["root_cause_template"] if scenario_data else "Network hardware failure causing connectivity issues"
                
            else:
                await self._log_activity(execution, "💡 Cross-system dependency analysis...")
                execution.progress = 60
                await asyncio.sleep(random.uniform(2.0, 2.5))
                
                root_cause = scenario_data["root_cause_template"] if scenario_data else "Infrastructure resource exhaustion"
            
            await self._log_activity(execution, "💡 Root cause identified with high confidence...")
            execution.progress = 90
            await asyncio.sleep(random.uniform(1.0, 1.5))
            
            execution.output_data = {
                "root_cause": root_cause,
                "confidence": random.uniform(0.82, 0.95),
                "incident_type": incident.incident_type,
                "analysis_depth": "comprehensive",
                "recommended_actions": self._get_incident_specific_actions(incident.incident_type)
            }
            
            incident.root_cause = execution.output_data["root_cause"]
            execution.progress = 100
            execution.status = AgentStatus.SUCCESS
            await self._log_activity(execution, f"✅ Root cause identified: {incident.incident_type} related issue")
            
        except Exception as e:
            execution.status = AgentStatus.ERROR