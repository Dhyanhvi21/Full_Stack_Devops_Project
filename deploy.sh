#!/usr/bin/env bash
# ==============================================================================
# Automated Local & Server Deployment Script for DevOps Full-Stack Application
# ==============================================================================
set -euo pipefail

# Configuration
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
PROJECT_NAME="${PROJECT_NAME:-fullstack-devops}"
BACKEND_HEALTH_URL="${BACKEND_HEALTH_URL:-http://localhost:8000/api/health/}"
FRONTEND_HEALTH_URL="${FRONTEND_HEALTH_URL:-http://localhost:3000}"
MAX_RETRIES="${MAX_RETRIES:-12}"
RETRY_INTERVAL="${RETRY_INTERVAL:-5}"

echo "=========================================================="
echo "🚀 Starting Deployment for ${PROJECT_NAME}"
echo "=========================================================="
echo "Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Step 1: Pre-flight checks
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Error: Docker daemon is not running."
    exit 1
fi

if [ ! -f "${COMPOSE_FILE}" ]; then
    echo "❌ Error: Docker Compose configuration '${COMPOSE_FILE}' not found."
    exit 1
fi

# Step 2: Pull latest images if registry is configured, otherwise build locally
echo "📦 Preparing container images..."
if [ "${PULL_IMAGES:-false}" = "true" ]; then
    echo "📥 Pulling latest images from registry..."
    docker compose -f "${COMPOSE_FILE}" pull || {
        echo "⚠️  Image pull failed or registry unauthenticated, falling back to local build..."
        docker compose -f "${COMPOSE_FILE}" build
    }
else
    echo "🔨 Building containers locally..."
    docker compose -f "${COMPOSE_FILE}" build
fi

# Step 3: Gracefully stop and remove outdated containers
echo "🛑 Stopping existing containers..."
docker compose -f "${COMPOSE_FILE}" down --remove-orphans || true

# Step 4: Start updated services in detached mode
echo "🚀 Starting services with Docker Compose..."
docker compose -f "${COMPOSE_FILE}" up -d

# Step 5: Verify service health
echo "🔍 Performing health checks..."

echo -n "Waiting for Django backend (${BACKEND_HEALTH_URL})..."
backend_healthy=false
for i in $(seq 1 "${MAX_RETRIES}"); do
    if curl -s -f -o /dev/null "${BACKEND_HEALTH_URL}"; then
        backend_healthy=true
        echo " ✅ Healthy!"
        break
    fi
    echo -n "."
    sleep "${RETRY_INTERVAL}"
done

if [ "${backend_healthy}" != "true" ]; then
    echo " ❌ Failed!"
    echo "⚠️  Backend failed health check. Displaying logs:"
    docker compose -f "${COMPOSE_FILE}" logs backend --tail=50
    exit 1
fi

echo -n "Waiting for React frontend (${FRONTEND_HEALTH_URL})..."
frontend_healthy=false
for i in $(seq 1 "${MAX_RETRIES}"); do
    if curl -s -f -o /dev/null "${FRONTEND_HEALTH_URL}"; then
        frontend_healthy=true
        echo " ✅ Healthy!"
        break
    fi
    echo -n "."
    sleep "${RETRY_INTERVAL}"
done

if [ "${frontend_healthy}" != "true" ]; then
    echo " ❌ Failed!"
    echo "⚠️  Frontend failed health check. Displaying logs:"
    docker compose -f "${COMPOSE_FILE}" logs frontend --tail=50
    exit 1
fi

echo "=========================================================="
echo "🎉 Deployment Completed Successfully!"
echo "=========================================================="
docker compose -f "${COMPOSE_FILE}" ps
echo ""
echo "🌐 Frontend URL: ${FRONTEND_HEALTH_URL}"
echo "🌐 Backend API:  ${BACKEND_HEALTH_URL}"
