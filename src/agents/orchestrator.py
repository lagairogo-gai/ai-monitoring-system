"""
Orchestrator Agent - Coordinates all other agents
"""
from .base import BaseAgent, AgentStatus
from typing import Dict, Any, List
import asyncio

class OrchestratorAgent(BaseAgent):
    """Main orchestrator agent that coordinates all other agents"""
    
    def __init__(self):
        super().__init__("Orchestrator Agent")
        self.agents = {}
        self.workflows = {}
    
    def register_agent(self, name: str, agent: BaseAgent):
        """Register an agent with the orchestrator"""
        self.agents[name] = agent
        self.log(f"Registered agent: {name}")
    
    async def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process the complete workflow"""
        self.update_status(AgentStatus.RUNNING)
        
        try:
            self.log(f"Starting workflow for: {data.get('title', 'Unknown incident')}")
            
            workflow_results = {}
            
            # Basic workflow: monitoring -> rca -> alerts -> tickets
            workflow_steps = ['monitoring', 'rca', 'pager', 'ticketing', 'email']
            
            for step in workflow_steps:
                if step in self.agents:
                    self.log(f"Executing step: {step}")
                    result = await self.agents[step].process(data)
                    workflow_results[step] = result
                    
                    if result.get('status') == 'error':
                        self.log(f"Workflow failed at step: {step}", "ERROR")
                        break
            
            self.update_status(AgentStatus.SUCCESS)
            return {
                "status": "success",
                "workflow_results": workflow_results
            }
            
        except Exception as e:
            self.update_status(AgentStatus.ERROR)
            self.log(f"Workflow error: {str(e)}", "ERROR")
            return {"status": "error", "error": str(e)}
