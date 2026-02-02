#!/bin/bash
set -e

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Detect base path
if [ -d "/app/dispatcher" ]; then
  BASE_PATH="/app"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BASE_PATH="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

log "Base path: $BASE_PATH"
log "Luxia unified stack starting..."

# Flags (default safe for Azure)
: "${ENABLE_DISPATCHER:=false}"
: "${ENABLE_WORKER:=true}"

# Set HTTP fallback URL for socket-hub to call worker directly (same container)
export WORKER_HTTP_URL="${WORKER_HTTP_URL:-http://localhost:8002}"
log "Worker HTTP fallback URL: $WORKER_HTTP_URL"

start_dispatcher() {
  log "Starting dispatcher (background)..."
  cd "$BASE_PATH/dispatcher"
  # If dispatcher is FastAPI, we can still run it, but no need to expose ports publicly.
  # Keeping it on 8001 internally is fine; remove if not needed.
  python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 &
  log "Dispatcher PID=$!"
}

start_worker() {
  log "Starting worker (background)..."
  cd "$BASE_PATH/worker"
  # Avoid binding 8002 unless absolutely required
  # If worker is also FastAPI only for internal metrics, keep; otherwise prefer: python -m app.main (no uvicorn)
  python -m uvicorn app.main:app --host 0.0.0.0 --port 8002 &
  log "Worker PID=$!"
}

# Start optional services only if enabled
if [ "$ENABLE_DISPATCHER" = "true" ]; then
  start_dispatcher
else
  log "Dispatcher disabled (ENABLE_DISPATCHER=false)."
fi

if [ "$ENABLE_WORKER" = "true" ]; then
  start_worker
else
  log "Worker disabled (ENABLE_WORKER=false)."
fi

log "Starting socket-hub (foreground on :8000)..."
cd "$BASE_PATH/socket-hub"
exec python -m uvicorn app.main:asgi_app --host 0.0.0.0 --port ${PORT:-8000}
