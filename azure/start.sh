#!/bin/bash
set -euo pipefail

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

BASE_PATH="/app"
export APP_ENV="${APP_ENV:-prod}"
export SERVICE_VERSION="${SERVICE_VERSION:-1.0.0}"
export WEBSITES_PORT="${WEBSITES_PORT:-80}"

# Ensure shared package imports resolve for all services.
export PYTHONPATH="${BASE_PATH}:${BASE_PATH}/socket-hub:${BASE_PATH}/dispatcher:${BASE_PATH}/worker:${BASE_PATH}/shared:${PYTHONPATH:-}"

mkdir -p /tmp/prometheus/socket-hub /tmp/prometheus/dispatcher /tmp/prometheus/worker
rm -f /tmp/prometheus/socket-hub/* /tmp/prometheus/dispatcher/* /tmp/prometheus/worker/* || true

log "Base path: ${BASE_PATH}"
log "APP_ENV=${APP_ENV} SERVICE_VERSION=${SERVICE_VERSION} WEBSITES_PORT=${WEBSITES_PORT}"
log "Starting Nginx + socket-hub + dispatcher + worker via supervisord"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
