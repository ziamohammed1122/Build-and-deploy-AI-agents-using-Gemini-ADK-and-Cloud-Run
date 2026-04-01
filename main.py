"""
Main entry point for the ADK Text Summarizer Agent.

This FastAPI application serves the ADK agent on Cloud Run.
It uses the ADK's built-in get_fast_api_app() utility to handle
agent routing, session management, and API endpoints.
"""

import os

import uvicorn
from google.adk.cli.fast_api import get_fast_api_app

# Get the directory where main.py is located
AGENT_DIR = os.path.dirname(os.path.abspath(__file__))

# Use SQLite with async driver for session persistence
SESSION_SERVICE_URI = "sqlite+aiosqlite:///./sessions.db"

# Allow all origins for CORS (adjust for production)
ALLOWED_ORIGINS = [
    "http://localhost",
    "http://localhost:8080",
    "http://localhost:3000",
    "*",
]

# Set web=True to include the ADK web UI for testing
SERVE_WEB_INTERFACE = True

# Create the FastAPI app using ADK's utility
# The 'summarizer_agent' directory name must match the agent folder
app = get_fast_api_app(
    agents_dir=AGENT_DIR,
    session_service_uri=SESSION_SERVICE_URI,
    allow_origins=ALLOWED_ORIGINS,
    web=SERVE_WEB_INTERFACE,
)

if __name__ == "__main__":
    # Use the PORT environment variable provided by Cloud Run, default to 8080
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
