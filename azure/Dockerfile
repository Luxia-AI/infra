# =============================================================================
# Luxia Research Project - Unified Dev Container for Azure App Service
# =============================================================================
# This Dockerfile builds a single container that runs ALL backend services:
#   - socket-hub (FastAPI + Socket.IO) - exposed on port 8000
#   - dispatcher (Kafka consumer/router)
#   - worker (RAG processing worker)
#
# Purpose: Development/Research deployment on Azure App Service (Linux)
# Note: This is NOT a production microservices setup - all services run in one container
# =============================================================================

FROM python:3.11-slim

# Prevent Python from buffering stdout/stderr (important for container logs)
ENV PYTHONUNBUFFERED=1
# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Set working directory
WORKDIR /app

# Install system dependencies required by some Python packages
# - gcc, g++: Required for compiling some Python packages
# - curl: Useful for health checks
# - playwright deps will be installed separately if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better Docker layer caching
COPY infra/azure/requirements.txt /app/requirements.txt

# Install Python dependencies
# Using --no-cache-dir to reduce image size
RUN pip install --no-cache-dir -r requirements.txt

# Install playwright browsers (required by worker for web scraping)
# This is done after pip install to leverage caching
RUN playwright install --with-deps chromium

# =============================================================================
# Copy application code
# These folders are checked out by GitHub Actions into the build context root
# =============================================================================

# Copy socket-hub service
COPY socket-hub/ /app/socket-hub/

# Copy dispatcher service
COPY dispatcher/ /app/dispatcher/

# Copy worker service
COPY worker/ /app/worker/

# Copy shared library (internal imports)
COPY shared/ /app/shared/

# Copy the startup script
COPY infra/azure/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# =============================================================================
# Environment setup
# =============================================================================

# Add all service directories to PYTHONPATH so imports work correctly
# This allows each service to import from its own 'app' module
ENV PYTHONPATH="/app/socket-hub:/app/dispatcher:/app/worker:/app/shared:${PYTHONPATH}"

# Azure App Service expects the app to listen on port 8000
# WEBSITES_PORT is configured in Azure, but we also set it here for clarity
EXPOSE 8000

# =============================================================================
# Startup
# =============================================================================

# Use the startup script to launch all services
CMD ["/bin/bash", "/app/start.sh"]
