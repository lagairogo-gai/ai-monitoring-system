"""
System Configuration
"""
import os
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class SystemConfig:
    """System configuration with all necessary settings"""
    
    # LLM Configuration
    llm_provider: str = "openai"  # openai, google, azure
    openai_api_key: str = ""
    google_api_key: str = ""
    azure_endpoint: str = ""
    azure_api_key: str = ""
    model_name: str = "gpt-4"
    
    # Integration endpoints
    datadog_api_key: str = ""
    datadog_app_key: str = ""
    datadog_site: str = "datadoghq.eu"
    
    pagerduty_api_key: str = ""
    pagerduty_service_id: str = ""
    
    servicenow_instance: str = "dev221843.service-now.com"
    servicenow_username: str = ""
    servicenow_password: str = ""
    
    # Email configuration
    smtp_server: str = "smtp.gmail.com"
    smtp_port: int = 587
    email_username: str = ""
    email_password: str = ""
    
    # Database and caching
    redis_url: str = "redis://localhost:6379/0"
    database_url: str = "sqlite:///monitoring_system.db"
    
    @classmethod
    def from_env(cls) -> 'SystemConfig':
        """Load configuration from environment variables"""
        return cls(
            openai_api_key=os.getenv("OPENAI_API_KEY", ""),
            datadog_api_key=os.getenv("DATADOG_API_KEY", ""),
            datadog_app_key=os.getenv("DATADOG_APP_KEY", ""),
            pagerduty_api_key=os.getenv("PAGERDUTY_API_KEY", ""),
            servicenow_username=os.getenv("SERVICENOW_USERNAME", ""),
            servicenow_password=os.getenv("SERVICENOW_PASSWORD", ""),
            email_username=os.getenv("EMAIL_USERNAME", ""),
            email_password=os.getenv("EMAIL_PASSWORD", ""),
            redis_url=os.getenv("REDIS_URL", "redis://localhost:6379/0"),
            database_url=os.getenv("DATABASE_URL", "sqlite:///monitoring_system.db")
        )
