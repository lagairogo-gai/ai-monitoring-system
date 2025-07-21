"""
Base Agent Class
"""
import logging
import json
from datetime import datetime
from enum import Enum
from typing import Dict, List, Any, Optional
from abc import ABC, abstractmethod

class AgentStatus(Enum):
    IDLE = "idle"
    RUNNING = "running"
    SUCCESS = "success"
    ERROR = "error"
    WAITING = "waiting"

class BaseAgent(ABC):
    """Base class for all agents"""
    
    def __init__(self, name: str):
        self.name = name
        self.status = AgentStatus.IDLE
        self.logs = []
        
    def log(self, message: str, level: str = "INFO"):
        """Log message with timestamp"""
        timestamp = datetime.now().isoformat()
        log_entry = f"[{timestamp}] [{level}] {self.name}: {message}"
        self.logs.append(log_entry)
        
        # Also log to Python logger
        logger = logging.getLogger(self.name)
        if level == "ERROR":
            logger.error(message)
        elif level == "WARNING":
            logger.warning(message)
        else:
            logger.info(message)
    
    def update_status(self, status: AgentStatus):
        """Update agent status"""
        self.status = status
        self.log(f"Status updated to: {status.value}")
    
    @abstractmethod
    async def process(self, data: Any) -> Any:
        """Process incoming data"""
        pass
