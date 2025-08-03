import React, { useState, useEffect, useRef } from 'react';
import { 
  Activity, CheckCircle, Clock, AlertTriangle, 
  Monitor, Search, Bell, Ticket, Mail, Settings, 
  Shield, GitBranch, TrendingUp, Zap, 
  RefreshCw, ExternalLink, Eye, X, Terminal,
  Database, Wifi, Server, Lock, Container, HardDrive,
  Brain, MessageSquare, Network, Share2, Layers, Target,
  Play, Pause, BarChart3, Globe, Users
} from 'lucide-react';

function App() {
  const [dashboardStats, setDashboardStats] = useState({});
  const [agents, setAgents] = useState({});
  const [incidents, setIncidents] = useState([]);
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [selectedAgent, setSelectedAgent] = useState(null);
  const [agentHistory, setAgentHistory] = useState(null);
  const [mcpContexts, setMcpContexts] = useState([]);
  const [a2aMessages, setA2aMessages] = useState([]);
  const [a2aCollaborations, setA2aCollaborations] = useState([]);
  const [showMcpModal, setShowMcpModal] = useState(false);
  const [showA2aModal, setShowA2aModal] = useState(false);
  const [showAgentModal, setShowAgentModal] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(new Date());
  const [activeWorkflows, setActiveWorkflows] = useState(new Set());
  const [realTimeUpdates, setRealTimeUpdates] = useState([]);
  const [isConnected, setIsConnected] = useState(false);
  const websocketRef = useRef(null);

  useEffect(() => {
    fetchAllData();
    setupWebSocket();
    const interval = setInterval(fetchAllData, 3000);
    return () => {
      clearInterval(interval);
      if (websocketRef.current) {
        websocketRef.current.close();
      }
    };
  }, []);

  const setupWebSocket = () => {
    const wsUrl = `ws://${window.location.host}/ws/realtime`;
    const ws = new WebSocket(wsUrl);
    
    ws.onopen = () => {
      setIsConnected(true);
      console.log('WebSocket connected for real-time updates');
    };
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      handleRealTimeUpdate(data);
    };
    
    ws.onclose = () => {
      setIsConnected(false);
      console.log('WebSocket disconnected');
      // Attempt to reconnect after 3 seconds
      setTimeout(setupWebSocket, 3000);
    };
    
    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      setIsConnected(false);
    };
    
    websocketRef.current = ws;
  };

  const handleRealTimeUpdate = (data) => {
    setRealTimeUpdates(prev => [data, ...prev.slice(0, 49)]); // Keep last 50 updates
    
    // Handle different types of real-time updates
    switch (data.type) {
      case 'mcp_update':
        fetchMcpContexts();
        break;
      case 'a2a_update':
        fetchA2aData();
        break;
      case 'workflow_update':
        fetchAllData();
        break;
      default:
        break;
    }
  };

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

  const fetchMcpContexts = async () => {
    try {
      const response = await fetch('/api/mcp/contexts');
      const data = await response.json();
      setMcpContexts(data.contexts || []);
    } catch (err) {
      console.error('Failed to fetch MCP contexts:', err);
    }
  };

  const fetchA2aData = async () => {
    try {
      const [messagesRes, collabRes] = await Promise.all([
        fetch('/api/a2a/messages/history?limit=20'),
        fetch('/api/a2a/collaborations')
      ]);
      
      const [messagesData, collabData] = await Promise.all([
        messagesRes.json(),
        collabRes.json()
      ]);
      
      setA2aMessages(messagesData.recent_messages || []);
      setA2aCollaborations(collabData.collaborations || []);
    } catch (err) {
      console.error('Failed to fetch A2A data:', err);
    }
  };

  const triggerTestIncident = async () => {
    try {
      const response = await fetch('/api/trigger-incident', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: '', 
          description: '',
          severity: 'high'
        })
      });
      const result = await response.json();
      
      const alertMessage = `🚀 NEW COMPLETE MCP+A2A ENHANCED INCIDENT!\n\n` +
                          `Type: ${result.incident_type}\n` +
                          `Severity: ${result.severity}\n` +
                          `ID: ${result.incident_id}\n` +
                          `MCP Context: ${result.mcp_context_id?.slice(0,8)}...\n\n` +
                          `Title: ${result.title}\n\n` +
                          `✨ ALL 7 AGENTS + MCP + A2A Features Active!\n` +
                          `🧠 Model Context Protocol: Shared intelligence\n` +
                          `🤝 Agent-to-Agent Protocol: Direct collaboration\n` +
                          `📊 Real-time updates via WebSocket`;
      
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

  const viewAgentDetails = async (agentId) => {
    try {
      const response = await fetch(`/api/agents/${agentId}/history`);
      const agentData = await response.json();
      setAgentHistory(agentData);
      setSelectedAgent(agentId);
      setShowAgentModal(true);
    } catch (err) {
      console.error('Failed to fetch agent history:', err);
    }
  };

  const getAgentIcon = (agentName) => {
    const icons = {
      monitoring: Monitor, rca: Search, pager: Bell,
      ticketing: Ticket, email: Mail, remediation: Settings, validation: Shield
    };
    return icons[agentName] || Activity;
  };

  const getIncidentTypeIcon = (incidentType) => {
    const icons = {
      database: Database, security: Lock, network: Wifi,
      infrastructure: Server, container: Container, storage: HardDrive,
      api: Activity, dns: Wifi, authentication: Lock
    };
    return icons[incidentType] || AlertTriangle;
  };

  const getIncidentTypeColor = (incidentType) => {
    const colors = {
      database: 'text-blue-400', security: 'text-red-400', network: 'text-green-400',
      infrastructure: 'text-purple-400', container: 'text-cyan-400', storage: 'text-yellow-400',
      api: 'text-pink-400', dns: 'text-indigo-400', authentication: 'text-orange-400'
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
          <h2 className="text-2xl font-bold text-white mb-2">Loading Complete MCP + A2A Enhanced System</h2>
          <p className="text-gray-400">Initializing all 7 agents with Model Context Protocol and Agent-to-Agent Communication...</p>
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
        .agent-glow { box-shadow: 0 0 15px rgba(34, 197, 94, 0.3); }
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
                <h1 className="text-2xl font-bold text-white">OpsIntellect - MCP + A2A Ready AI Monitoring System</h1>
                <p className="text-sm text-gray-300">Multi-Agent • Model Context Protocol • Agent-to-Agent Communication • Real-time Updates</p>
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
                <div className={`w-2 h-2 rounded-full animate-pulse ${isConnected ? 'bg-green-400' : 'bg-red-400'}`}></div>
                <p className="text-sm font-medium text-white">
                  {isConnected ? 'Real-time Connected' : 'Reconnecting...'}
                </p>
              </div>
              <p className="text-xs text-gray-400">Last Updated: {lastUpdate.toLocaleTimeString()}</p>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-6 py-8">
        {/* Enhanced Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4 mb-8">
          <div className="glass agent-glow rounded-xl p-4 hover:bg-green-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-green-300">All 7 Agents</p>
                <p className="text-xl font-bold text-green-400">{Object.keys(agents).length}</p>
                <p className="text-xs text-green-500 mt-1">Ready & Enhanced</p>
              </div>
              <Users className="w-6 h-6 text-green-400" />
            </div>
          </div>

          <div className="glass mcp-glow rounded-xl p-4 hover:bg-purple-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-purple-300">MCP Contexts</p>
                <p className="text-xl font-bold text-purple-400">{dashboardStats.enhanced_features?.mcp?.total_contexts || 0}</p>
                <p className="text-xs text-purple-500 mt-1">Shared Intelligence</p>
              </div>
              <Brain className="w-6 h-6 text-purple-400" />
            </div>
          </div>

          <div className="glass a2a-glow rounded-xl p-4 hover:bg-blue-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-300">A2A Messages</p>
                <p className="text-xl font-bold text-blue-400">{dashboardStats.enhanced_features?.a2a?.total_messages || 0}</p>
                <p className="text-xs text-blue-500 mt-1">Agent Communication</p>
              </div>
              <MessageSquare className="w-6 h-6 text-blue-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-4 hover:bg-orange-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-orange-300">Active Incidents</p>
                <p className="text-xl font-bold text-orange-400">{dashboardStats.incidents?.active || 0}</p>
                <p className="text-xs text-orange-500 mt-1">Live Tracking</p>
              </div>
              <AlertTriangle className="w-6 h-6 text-orange-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-4 hover:bg-yellow-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-yellow-300">Collaborations</p>
                <p className="text-xl font-bold text-yellow-400">{dashboardStats.enhanced_features?.a2a?.active_collaborations || 0}</p>
                <p className="text-xs text-yellow-500 mt-1">Cross-agent</p>
              </div>
              <Share2 className="w-6 h-6 text-yellow-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-4 hover:bg-pink-500/10 transition-all">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-pink-300">Success Rate</p>
                <p className="text-xl font-bold text-pink-400">
                  {Math.round(dashboardStats.system?.overall_success_rate || 95)}%
                </p>
                <p className="text-xs text-pink-500 mt-1">Enhanced</p>
              </div>
              <Target className="w-6 h-6 text-pink-400" />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          {/* ALL 7 AGENTS DASHBOARD - RESTORED */}
          <div className="xl:col-span-2">
            <div className="glass agent-glow rounded-xl p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-semibold text-white">Multi AI Agents</h3>
                <div className="flex items-center space-x-4">
                  <div className="flex items-center space-x-1">
                    <Brain className="w-4 h-4 text-purple-400" />
                    <span className="text-sm text-purple-400">MCP</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <MessageSquare className="w-4 h-4 text-blue-400" />
                    <span className="text-sm text-blue-400">A2A</span>
                  </div>
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-sm text-green-400">All Ready</span>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {Object.entries(agents).map(([agentId, agent]) => {
                  const IconComponent = getAgentIcon(agentId);
                  return (
                    <div 
                      key={agentId} 
                      className="bg-gradient-to-br from-gray-800/50 to-purple-900/20 rounded-lg p-4 border border-purple-600/30 hover:border-purple-500/50 transition-all cursor-pointer transform hover:scale-[1.02]"
                      onClick={() => viewAgentDetails(agentId)}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-3">
                          <div className="p-2 bg-gradient-to-br from-purple-500/20 to-blue-500/20 rounded-lg">
                            <IconComponent className="w-5 h-5 text-purple-400" />
                          </div>
                          <div>
                            <span className="font-medium text-white capitalize">{agentId}</span>
                            <p className="text-xs text-purple-300">Enhanced Agent</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-1">
                          <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                          <span className="text-xs text-green-400 font-medium">Ready</span>
                        </div>
                      </div>
                      
                      <p className="text-sm text-gray-300 mb-3 line-clamp-2">{agent.description}</p>
                      
                      <div className="grid grid-cols-2 gap-2 text-xs mb-3">
                        <div>
                          <span className="text-gray-400">Executions:</span>
                          <span className="text-purple-400 font-medium ml-1">{agent.total_executions}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Success:</span>
                          <span className="text-green-400 font-medium ml-1">{agent.success_rate?.toFixed(1)}%</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Avg Time:</span>
                          <span className="text-blue-400 font-medium ml-1">{agent.average_duration?.toFixed(1)}s</span>
                        </div>
                        <div>
                          <span className="text-gray-400">A2A Msgs:</span>
                          <span className="text-yellow-400 font-medium ml-1">{agent.enhanced_features?.a2a_messages_total || 0}</span>
                        </div>
                      </div>
                      
                      <div className="flex items-center justify-between">
                        <div className="flex space-x-1">
                        {agent.enhanced_features?.mcp_enhanced_executions > 0 && (
                            <Brain className="w-3 h-3 text-purple-400" title="MCP Enhanced" />
                          )}
                          {agent.enhanced_features?.a2a_messages_total > 0 && (
                            <MessageSquare className="w-3 h-3 text-blue-400" title="A2A Active" />
                          )}
                          <Layers className="w-3 h-3 text-green-400" title="Enhanced" />
                        </div>
                        <div className="flex items-center space-x-1">
                          <Eye className="w-3 h-3 text-gray-400" />
                          <span className="text-xs text-gray-400">Click for Details</span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Enhanced Controls & Real-time Feed */}
          <div className="space-y-6">
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
                    <Users className="w-4 h-4" />
                  </div>
                  <span>Check For Incident</span>
                </button>
                <p className="text-xs text-gray-400 text-center">
                  Multi Agents + MCP intelligence + A2A collaboration
                </p>
                
                <div className="grid grid-cols-2 gap-2">
                  <button 
                    onClick={() => {setShowMcpModal(true); fetchMcpContexts();}}
                    className="bg-gradient-to-r from-purple-500/20 to-purple-600/20 border border-purple-500/50 text-purple-300 px-3 py-2 rounded-lg text-sm font-medium hover:bg-purple-500/30 transition-all flex items-center justify-center space-x-1"
                  >
                    <Brain className="w-3 h-3" />
                    <span>MCP Status</span>
                  </button>
                  
                  <button 
                    onClick={() => {setShowA2aModal(true); fetchA2aData();}}
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
                  <span>Refresh All Data</span>
                </button>
              </div>
            </div>

            {/* Real-time Updates Feed */}
            <div className="glass rounded-xl p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-white">Real-time Updates</h3>
                <div className="flex items-center space-x-2">
                  <div className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-400 animate-pulse' : 'bg-red-400'}`}></div>
                  <span className="text-xs text-gray-400">{isConnected ? 'Live' : 'Disconnected'}</span>
                </div>
              </div>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {realTimeUpdates.length > 0 ? (
                  realTimeUpdates.slice(0, 10).map((update, index) => (
                    <div key={index} className="bg-gray-800/30 rounded p-2 text-xs">
                      <div className="flex items-center justify-between mb-1">
                        <span className={`font-medium ${
                          update.type === 'mcp_update' ? 'text-purple-400' :
                          update.type === 'a2a_update' ? 'text-blue-400' :
                          update.type === 'workflow_update' ? 'text-green-400' :
                          'text-gray-400'
                        }`}>
                          {update.type?.replace('_', ' ').toUpperCase()}
                        </span>
                        <span className="text-gray-500">
                          {new Date(update.timestamp).toLocaleTimeString()}
                        </span>
                      </div>
                      <p className="text-gray-300">
                        {update.message || update.incident_id || 'System update'}
                      </p>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-4">
                    <Activity className="w-8 h-8 text-gray-600 mx-auto mb-2" />
                    <p className="text-gray-400 text-sm">Waiting for real-time updates...</p>
                  </div>
                )}
              </div>
            </div>

            {/* Enhanced Incident Feed */}
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Enhanced Incident Feed</h3>
              <div className="space-y-3 max-h-80 overflow-y-auto">
                {incidents.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="flex justify-center space-x-2 mb-4">
                      <Users className="w-8 h-8 text-green-600" />
                      <Brain className="w-8 h-8 text-purple-600" />
                      <MessageSquare className="w-8 h-8 text-blue-600" />
                    </div>
                    <p className="text-gray-400 text-sm mb-2">No enhanced incidents yet!</p>
                    <p className="text-gray-500 text-xs">Generate an incident to see all 7 agents + MCP + A2A in action</p>
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
                              incident.severity === 'medium' ? 'bg-yellow-500' : 'bg-green-500'
                            }`}>
                              {incident.severity?.toUpperCase()}
                            </span>
                            <span className={`text-xs px-2 py-1 rounded-full bg-gray-700 ${typeColor} font-medium`}>
                              {incident.incident_type?.toUpperCase()}
                            </span>
                            <div className="flex space-x-1">
                              <Users className="w-3 h-3 text-green-400" title="All 7 Agents" />
                              <Brain className="w-3 h-3 text-purple-400" title="MCP Enhanced" />
                              <MessageSquare className="w-3 h-3 text-blue-400" title="A2A Enabled" />
                            </div>
                            {activeWorkflows.has(incident.id) && (
                              <Network className="w-4 h-4 text-orange-400 animate-spin" />
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
                            {incident.completed_agents?.length || 0}/7 agents completed
                          </span>
                        </div>
                        
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

      {/* Enhanced MCP Context Modal */}
      {showMcpModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass mcp-glow rounded-xl w-full max-w-5xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-purple-700">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <Brain className="w-6 h-6 text-purple-400" />
                  <h2 className="text-2xl font-bold text-white">Model Context Protocol Status</h2>
                  <span className="bg-purple-500/20 px-2 py-1 rounded text-xs text-purple-300">Real-time</span>
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
                        <div className="flex items-center space-x-2">
                          <span className="text-xs text-gray-400">v{context.context_version}</span>
                          <div className="w-2 h-2 bg-purple-400 rounded-full animate-pulse"></div>
                        </div>
                      </div>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-400">Incident:</span>
                          <span className="text-white font-mono text-xs">{context.incident_id}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Agents:</span>
                          <span className="text-purple-400 font-medium">{context.agent_count}/7</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Confidence:</span>
                          <span className="text-green-400 font-medium">{Math.round(context.confidence_avg * 100)}%</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Knowledge Keys:</span>
                          <span className="text-blue-400">{context.shared_knowledge_keys?.length || 0}</span>
                        </div>
                      </div>
                      
                      {context.agent_insights_summary && Object.keys(context.agent_insights_summary).length > 0 && (
                        <div className="mt-3 pt-3 border-t border-purple-600/30">
                          <p className="text-xs text-purple-300 mb-2">Agent Insights:</p>
                          <div className="flex flex-wrap gap-1">
                            {Object.entries(context.agent_insights_summary).map(([agentId, insight]) => (
                              <span key={agentId} className="text-xs bg-purple-800/30 px-2 py-1 rounded">
                                {agentId}: {Math.round(insight.confidence * 100)}%
                              </span>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  ))
                ) : (
                  <div className="col-span-2 text-center py-8">
                    <Brain className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                    <p className="text-gray-400">No MCP contexts active</p>
                    <p className="text-gray-500 text-sm">Contexts will appear when incidents are triggered</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Enhanced A2A Network Modal */}
      {showA2aModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass a2a-glow rounded-xl w-full max-w-6xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-blue-700">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <MessageSquare className="w-6 h-6 text-blue-400" />
                  <h2 className="text-2xl font-bold text-white">Agent-to-Agent Network</h2>
                  <span className="bg-blue-500/20 px-2 py-1 rounded text-xs text-blue-300">Live Communication</span>
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
                  <h3 className="text-lg font-semibold text-blue-300 mb-4 flex items-center">
                    <MessageSquare className="w-5 h-5 mr-2" />
                    Recent A2A Messages
                    <span className="ml-2 bg-blue-500/20 px-2 py-1 rounded text-xs">{a2aMessages.length}</span>
                  </h3>
                  <div className="space-y-3 max-h-80 overflow-y-auto">
                    {a2aMessages.length > 0 ? (
                      a2aMessages.map((message) => (
                        <div key={message.message_id} className="bg-blue-900/20 border border-blue-600/30 rounded-lg p-3">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center space-x-2">
                              <span className="text-blue-300 text-sm font-medium">{message.sender}</span>
                              <span className="text-gray-400">→</span>
                              <span className="text-green-300 text-sm font-medium">{message.receiver}</span>
                            </div>
                            <span className={`text-xs px-2 py-1 rounded ${
                              message.priority === 'high' ? 'bg-red-500/20 text-red-400' :
                              message.priority === 'critical' ? 'bg-red-600/20 text-red-300' :
                              'bg-blue-500/20 text-blue-400'
                            }`}>
                              {message.priority}
                            </span>
                          </div>
                          <div className="flex items-center justify-between">
                            <span className="text-xs text-purple-400 bg-purple-900/20 px-2 py-1 rounded">
                              {message.type?.replace('_', ' ')}
                            </span>
                            <span className="text-xs text-gray-400">
                              {new Date(message.timestamp).toLocaleTimeString()}
                            </span>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-8">
                        <MessageSquare className="w-8 h-8 text-blue-600 mx-auto mb-2" />
                        <p className="text-gray-400 text-sm">No A2A messages yet</p>
                        <p className="text-gray-500 text-xs">Messages will appear when agents communicate</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Active Collaborations */}
                <div>
                  <h3 className="text-lg font-semibold text-green-300 mb-4 flex items-center">
                    <Share2 className="w-5 h-5 mr-2" />
                    Active Collaborations
                    <span className="ml-2 bg-green-500/20 px-2 py-1 rounded text-xs">{a2aCollaborations.length}</span>
                  </h3>
                  <div className="space-y-3 max-h-80 overflow-y-auto">
                    {a2aCollaborations.length > 0 ? (
                      a2aCollaborations.map((collab) => (
                        <div key={collab.collaboration_id} className="bg-green-900/20 border border-green-600/30 rounded-lg p-3">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-green-300 text-sm font-medium">{collab.task}</span>
                            <span className={`text-xs px-2 py-1 rounded ${
                              collab.status === 'active' ? 'bg-green-500/20 text-green-400' :
                              'bg-gray-500/20 text-gray-400'
                            }`}>
                              {collab.status}
                            </span>
                          </div>
                          <div className="text-xs text-gray-400 mb-2">
                            Initiator: <span className="text-blue-300">{collab.initiator}</span>
                          </div>
                          <div className="flex items-center justify-between">
                            <div className="flex -space-x-1">
                              {collab.participants?.map((participant, idx) => (
                                <div key={idx} className="w-6 h-6 bg-gradient-to-br from-purple-500 to-blue-500 rounded-full border border-gray-600 flex items-center justify-center text-xs text-white">
                                  {participant[0]?.toUpperCase()}
                                </div>
                              ))}
                            </div>
                            <span className="text-xs text-gray-400">
                              {collab.message_count} msgs
                            </span>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-8">
                        <Share2 className="w-8 h-8 text-green-600 mx-auto mb-2" />
                        <p className="text-gray-400 text-sm">No active collaborations</p>
                        <p className="text-gray-500 text-xs">Collaborations will appear during incidents</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Agent Details Modal */}
      {showAgentModal && selectedAgent && agentHistory && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass agent-glow rounded-xl w-full max-w-5xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-green-700">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  {React.createElement(getAgentIcon(selectedAgent), { className: "w-6 h-6 text-green-400" })}
                  <h2 className="text-2xl font-bold text-white capitalize">{selectedAgent} Agent Details</h2>
                  <span className="bg-green-500/20 px-2 py-1 rounded text-xs text-green-300">Enhanced</span>
                </div>
                <button onClick={() => setShowAgentModal(false)}>
                  <X className="w-6 h-6 text-gray-400 hover:text-white" />
                </button>
              </div>
            </div>
            <div className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                <div className="bg-green-900/20 border border-green-600/30 rounded-lg p-4">
                  <h3 className="text-green-300 font-medium mb-2">Total Executions</h3>
                  <p className="text-2xl font-bold text-white">{agentHistory.total_executions}</p>
                </div>
                <div className="bg-blue-900/20 border border-blue-600/30 rounded-lg p-4">
                  <h3 className="text-blue-300 font-medium mb-2">Success Rate</h3>
                  <p className="text-2xl font-bold text-white">
                    {((agentHistory.recent_executions?.filter(e => e.status === 'success').length || 0) / Math.max(agentHistory.recent_executions?.length || 0, 1) * 100).toFixed(1)}%
                  </p>
                </div>
                <div className="bg-purple-900/20 border border-purple-600/30 rounded-lg p-4">
                  <h3 className="text-purple-300 font-medium mb-2">Enhanced Executions</h3>
                  <p className="text-2xl font-bold text-white">
                    {agentHistory.recent_executions?.filter(e => e.mcp_enhanced).length || 0}
                  </p>
                </div>
              </div>
              
              <h3 className="text-lg font-semibold text-white mb-4">Recent Execution History</h3>
              <div className="space-y-3">
                {agentHistory.recent_executions?.length > 0 ? (
                  agentHistory.recent_executions.map((execution) => (
                    <div key={execution.execution_id} className="bg-gray-800/50 border border-gray-600/50 rounded-lg p-3">
                      <div className="flex items-center justify-between mb-2">
                        <span className="font-mono text-sm text-gray-300">{execution.incident_id}</span>
                        <div className="flex items-center space-x-2">
                          {execution.mcp_enhanced && <Brain className="w-4 h-4 text-purple-400" title="MCP Enhanced" />}
                          {execution.a2a_messages > 0 && <MessageSquare className="w-4 h-4 text-blue-400" title="A2A Messages" />}
                          {execution.collaborations > 0 && <Share2 className="w-4 h-4 text-yellow-400" title="Collaborations" />}
                          <span className={`text-xs px-2 py-1 rounded ${
                            execution.status === 'success' ? 'bg-green-500/20 text-green-400' :
                            execution.status === 'running' ? 'bg-blue-500/20 text-blue-400' :
                            'bg-red-500/20 text-red-400'
                          }`}>
                            {execution.status}
                          </span>
                        </div>
                      </div>
                      <div className="grid grid-cols-4 gap-4 text-xs">
                        <div>
                          <span className="text-gray-400">Duration:</span>
                          <span className="text-white ml-1">{execution.duration?.toFixed(1)}s</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Progress:</span>
                          <span className="text-blue-400 ml-1">{execution.progress}%</span>
                        </div>
                        <div>
                          <span className="text-gray-400">A2A Messages:</span>
                          <span className="text-yellow-400 ml-1">{execution.a2a_messages}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Started:</span>
                          <span className="text-gray-300 ml-1">
                            {execution.started_at ? new Date(execution.started_at).toLocaleTimeString() : 'N/A'}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-8">
                    <Activity className="w-8 h-8 text-gray-600 mx-auto mb-2" />
                    <p className="text-gray-400">No execution history yet</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Enhanced Incident Details Modal */}
      {selectedIncident && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="glass rounded-xl w-full max-w-7xl max-h-[90vh] overflow-hidden">
            <div className="p-6 border-b border-gray-700">
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center space-x-3 mb-2">
                    <h2 className="text-2xl font-bold text-white">{selectedIncident.title}</h2>
                    <div className="flex space-x-1">
                      <Users className="w-5 h-5 text-green-400" title="All 7 Agents" />
                      <Brain className="w-5 h-5 text-purple-400" title="MCP Enhanced" />
                      <MessageSquare className="w-5 h-5 text-blue-400" title="A2A Enabled" />
                    </div>
                  </div>
                  <p className="text-gray-400">Enhanced with All 7 Agents + MCP + A2A Architecture</p>
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
                        <span className="text-gray-400">Context ID:</span>
                        <span className="text-purple-400 font-mono text-xs">
                          {selectedIncident.enhanced_features.mcp_context?.context_id?.slice(0,12)}...
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Agent Insights:</span>
                        <span className="text-purple-400">{selectedIncident.enhanced_features.mcp_context?.agent_insights_count || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Confidence:</span>
                        <span className="text-green-400">{Math.round((selectedIncident.enhanced_features.mcp_context?.avg_confidence || 0) * 100)}%</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Version:</span>
                        <span className="text-blue-400">v{selectedIncident.enhanced_features.mcp_context?.context_version}</span>
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
                        <span className="text-gray-400">Messages Sent:</span>
                        <span className="text-blue-400">{selectedIncident.enhanced_features.a2a_protocol?.total_messages_sent || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Messages Received:</span>
                        <span className="text-blue-400">{selectedIncident.enhanced_features.a2a_protocol?.total_messages_received || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Collaborations:</span>
                        <span className="text-green-400">{selectedIncident.enhanced_features.a2a_protocol?.active_collaborations || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Cross Insights:</span>
                        <span className="text-yellow-400">{selectedIncident.enhanced_features.a2a_protocol?.cross_agent_insights || 0}</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* All 7 Enhanced Agent Executions */}
              <h3 className="text-lg font-semibold text-white mb-4">All 7 Enhanced Agent Executions</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
                {Object.entries(selectedIncident.executions || {}).map(([agentId, execution]) => {
                  const IconComponent = getAgentIcon(agentId);
                  return (
                    <div key={agentId} className="bg-gradient-to-br from-gray-800/50 to-purple-900/20 border border-gray-600/50 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          <IconComponent className="w-5 h-5 text-purple-400" />
                          <span className="font-medium text-white capitalize">{agentId}</span>
                        </div>
                        <div className="flex space-x-1">
                          {execution.mcp_enhanced && <Brain className="w-3 h-3 text-purple-400" title="MCP Enhanced" />}
                          {execution.a2a_messages?.sent > 0 && <MessageSquare className="w-3 h-3 text-blue-400" title="A2A Active" />}
                          {execution.collaborations > 0 && <Share2 className="w-3 h-3 text-yellow-400" title="Collaborating" />}
                        </div>
                      </div>
                      
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-400">Status:</span>
                          <span className={`font-medium ${
                            execution.status === 'success' ? 'text-green-400' :
                            execution.status === 'running' ? 'text-blue-400' :
                            execution.status === 'error' ? 'text-red-400' :
                            'text-gray-400'
                          }`}>
                            {execution.status}
                          </span>
                        </div>
                        
                        <div className="flex justify-between">
                          <span className="text-gray-400">Duration:</span>
                          <span className="text-white">{execution.duration?.toFixed(1)}s</span>
                        </div>
                        
                        {execution.a2a_messages && (
                          <div className="flex justify-between">
                            <span className="text-gray-400">A2A Messages:</span>
                            <span className="text-blue-400">{execution.a2a_messages.sent}↑ {execution.a2a_messages.received}↓</span>
                          </div>
                        )}
                        
                        {execution.collaborations > 0 && (
                          <div className="flex justify-between">
                            <span className="text-gray-400">Collaborations:</span>
                            <span className="text-green-400">{execution.collaborations}</span>
                          </div>
                        )}
                        
                        <div className="w-full bg-gray-700 rounded-full h-2">
                          <div 
                            className="bg-gradient-to-r from-purple-500 to-blue-500 h-2 rounded-full transition-all duration-500"
                            style={{ width: `${execution.progress}%` }}
                          />
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Resolution Section */}
              <div className="bg-gray-800/50 rounded-lg p-4">
                <h3 className="text-lg font-semibold text-white mb-4">Enhanced Resolution</h3>
                <p className="text-gray-300">{selectedIncident.resolution || 'Resolution in progress with enhanced intelligence...'}</p>
                
                {selectedIncident.root_cause && (
                  <div className="mt-4 pt-4 border-t border-gray-600">
                    <h4 className="text-md font-medium text-white mb-2">Root Cause Analysis</h4>
                    <p className="text-gray-300 text-sm">{selectedIncident.root_cause}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;

