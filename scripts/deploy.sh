#!/bin/bash
set -e

# Rmotly Deployment Script
# This script deploys the Rmotly server using Docker Compose

APP_DIR="/opt/rmotly"

echo "=== Rmotly Deployment Script ==="
echo "Deploying at $(date)"

cd "$APP_DIR"

# Pull latest changes
echo "Pulling latest changes..."
git fetch origin
git reset --hard origin/master

# Navigate to server directory
cd rmotly_server

# Stop existing containers
echo "Stopping existing containers..."
docker compose down --remove-orphans 2>/dev/null || true

# Build and start containers
echo "Building and starting containers..."
docker compose up -d --build

# Show status
echo "=== Deployment Complete ==="
docker compose ps
echo ""
echo "Logs (last 20 lines):"
docker compose logs --tail=20
