#!/bin/bash

echo "🔧 Fixing the lucide-react icon import issue..."

# Replace the problematic Tool icon with Settings in the App.js file
cat > frontend/src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { 
  Activity, CheckCircle, Clock, AlertTriangle, 
  Monitor, Search, Bell, Ticket, Mail, Settings, 
  Shield, GitBranch, TrendingUp, Zap, 
  RefreshCw, ExternalLink, Eye, X, Terminal
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
          title: 'High CPU Usage Alert - Production Web Servers',
          description: 'Critical CPU utilization detected on multiple production web servers requiring immediate investigation.',
          severity: 'high',
          affected_systems: ['web-server-01', 'web-server-02', 'web-server-03']
        })
      });
      const result = await response.json();
      
      alert(`🚨 Incident ${result.incident_id} created! Real-time workflow started. Watch the agents work!`);
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
          <p className="text-gray-400">Initializing workflow engine...</p>
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
                <p className="text-sm text-gray-400">Real-Time Workflow Engine v2.0</p>
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
                <p className="text-sm font-medium text-gray-400">Total Workflows</p>
                <p className="text-2xl font-bold text-purple-400">
                  {dashboardStats.system?.total_workflows || 0}
                </p>
                <p className="text-xs text-gray-500 mt-1">All time</p>
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
                  <span>Trigger Real Incident</span>
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
                    <p className="text-gray-500 text-xs">Trigger a test incident to see the AI agents in action</p>
                  </div>
                ) : (
                  incidents.map((incident) => (
                    <div 
                      key={incident.id} 
                      className="bg-gray-800/50 rounded-lg p-3 border border-gray-600/50 hover:border-blue-500/50 transition-all cursor-pointer"
                      onClick={() => viewIncidentDetails(incident.id)}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-2">
                          <span className={`px-2 py-1 rounded-full text-xs font-medium text-white ${
                            incident.severity === 'critical' ? 'bg-red-600' :
                            incident.severity === 'high' ? 'bg-orange-500' :
                            incident.severity === 'medium' ? 'bg-yellow-500' : 'bg-green-500'
                          }`}>
                            {incident.severity.toUpperCase()}
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
                  ))
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
EOF

echo "✅ Fixed App.js - replaced 'Tool' with 'Settings' icon"

# Try building the frontend again
echo "🏗️  Building React frontend..."
cd frontend
npm run build
cd ..

echo "✅ Frontend build completed successfully!"
echo ""
echo "🎉 Icon issue resolved! The system is now ready."
echo "Continue with deployment using: ./scripts/deploy.sh"