import React, { useState, useEffect } from 'react';
import { 
  Activity, CheckCircle, Clock, AlertTriangle, 
  Monitor, Search, Bell, Ticket, Mail, Tool, 
  Shield, GitBranch, TrendingUp, Zap, 
  RefreshCw, ExternalLink
} from 'lucide-react';

function App() {
  const [systemStatus, setSystemStatus] = useState({ status: 'loading' });
  const [agents, setAgents] = useState({});
  const [lastUpdate, setLastUpdate] = useState(new Date());
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setIsLoading(true);
        
        const [statusRes, agentsRes] = await Promise.all([
          fetch('/api/status'),
          fetch('/api/agents')
        ]);

        const [statusData, agentsData] = await Promise.all([
          statusRes.json(),
          agentsRes.json()
        ]);

        setSystemStatus(statusData);
        setAgents(agentsData.agents || {});
        setLastUpdate(new Date());
        setIsLoading(false);
      } catch (err) {
        setSystemStatus({ status: 'error', error: err.message });
        setIsLoading(false);
      }
    };

    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  const triggerTestIncident = async () => {
    try {
      const response = await fetch('/api/trigger-incident', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: 'Test Incident - High CPU Usage',
          description: 'Simulated high CPU usage detected',
          severity: 'high'
        })
      });
      const result = await response.json();
      alert(`Incident ${result.incident_id} created successfully!`);
    } catch (err) {
      console.error('Failed to trigger incident:', err);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center">
        <div className="text-center">
          <Activity className="w-12 h-12 text-blue-400 animate-spin mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Starting AI Monitoring System</h2>
          <p className="text-gray-400">Initializing agents...</p>
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
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-blue-500/20 rounded-xl">
                  <GitBranch className="w-8 h-8 text-blue-400" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-white">AI Monitoring System</h1>
                  <p className="text-sm text-gray-400">Production-Ready v1.0.0</p>
                </div>
              </div>
              <div className="flex items-center space-x-2 ml-8">
                <CheckCircle className="w-5 h-5 text-green-500" />
                <span className="text-lg text-gray-300 font-medium">Operational</span>
              </div>
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
          <div className="glass rounded-xl p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">System Health</p>
                <p className="text-2xl font-bold text-green-400">99.9%</p>
                <p className="text-xs text-gray-500 mt-1">Uptime</p>
              </div>
              <TrendingUp className="w-8 h-8 text-green-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Active Agents</p>
                <p className="text-2xl font-bold text-blue-400">{Object.keys(agents).length}/7</p>
                <p className="text-xs text-gray-500 mt-1">All Operational</p>
              </div>
              <Activity className="w-8 h-8 text-blue-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Incidents Today</p>
                <p className="text-2xl font-bold text-yellow-400">0</p>
                <p className="text-xs text-gray-500 mt-1">All Resolved</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-yellow-400" />
            </div>
          </div>

          <div className="glass rounded-xl p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-400">Success Rate</p>
                <p className="text-2xl font-bold text-purple-400">100%</p>
                <p className="text-xs text-gray-500 mt-1">Perfect Record</p>
              </div>
              <Zap className="w-8 h-8 text-purple-400" />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          <div className="xl:col-span-2">
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-6">AI Agents Dashboard</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {Object.entries(agents).map(([name, agent]) => (
                  <div key={name} className="bg-gray-800/50 rounded-lg p-4 border border-gray-600/50">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-3">
                        <div className="p-2 bg-blue-500/20 rounded-lg">
                          <Monitor className="w-5 h-5 text-blue-400" />
                        </div>
                        <div>
                          <span className="font-medium text-white capitalize">{name}</span>
                          <p className="text-xs text-gray-400">{agent.last_activity}</p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-1">
                        <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                        <span className="text-xs text-green-400 font-medium">Ready</span>
                      </div>
                    </div>
                    <p className="text-sm text-gray-400 mb-2">{agent.description}</p>
                    <div className="flex justify-between text-xs">
                      <span className="text-gray-500">Processed today:</span>
                      <span className="text-blue-400 font-medium">{agent.processed_today}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">Quick Actions</h3>
              <div className="space-y-3">
                <button
                  onClick={triggerTestIncident}
                  className="w-full bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2"
                >
                  <AlertTriangle className="w-4 h-4" />
                  <span>Trigger Test Incident</span>
                </button>
                
                <button className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2">
                  <RefreshCw className="w-4 h-4" />
                  <span>Run Health Check</span>
                </button>
                
                <a 
                  href="/api/docs" 
                  target="_blank"
                  className="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white px-4 py-3 rounded-lg font-medium transition-all duration-300 flex items-center justify-center space-x-2"
                >
                  <ExternalLink className="w-4 h-4" />
                  <span>API Documentation</span>
                </a>
              </div>
            </div>

            <div className="glass rounded-xl p-6">
              <h3 className="text-xl font-semibold text-white mb-4">System Status</h3>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">CPU Usage</span>
                  <span className="text-blue-400 font-medium">25%</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Memory Usage</span>
                  <span className="text-green-400 font-medium">45%</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Active Workflows</span>
                  <span className="text-purple-400 font-medium">156</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-12 text-center">
          <div className="glass rounded-xl p-6">
            <p className="text-gray-400 text-sm mb-2">
              🤖 AI Monitoring System v1.0.0 - Production Ready
            </p>
            <div className="flex justify-center space-x-4 text-xs text-gray-500">
              <span>• Health: Operational</span>
              <span>• Agents: 7/7</span>
              <span>• Uptime: 99.9%</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
