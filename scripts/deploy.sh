#!/bin/bash
set -e

# Rmotly Deployment Script
# This script deploys the Rmotly server using Docker Compose

APP_DIR="/opt/rmotly"
SERVER_DIR="$APP_DIR/rmotly_server"

echo "=== Rmotly Deployment Script ==="
echo "Deploying at $(date)"

cd "$APP_DIR"

# Pull latest changes
echo "Pulling latest changes..."
git fetch origin
git reset --hard origin/master

# Navigate to server directory
cd "$SERVER_DIR"

# Create passwords file if it doesn't exist
if [ ! -f config/passwords.yaml ]; then
    echo "Creating passwords.yaml..."
    cat > config/passwords.yaml << 'EOF'
shared:
development:
  database: '${POSTGRES_PASSWORD:-rmotly_dev_pass}'
  redis: '${REDIS_PASSWORD:-rmotly_redis_pass}'
production:
  database: '${POSTGRES_PASSWORD:-rmotly_dev_pass}'
  redis: '${REDIS_PASSWORD:-rmotly_redis_pass}'
EOF
fi

# Stop existing containers
echo "Stopping existing containers..."
docker compose down --remove-orphans 2>/dev/null || true

# Build and start infrastructure services first (postgres, redis, ntfy)
echo "Starting infrastructure services..."
docker compose up -d postgres redis ntfy

# Wait for postgres to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "Waiting for PostgreSQL... ($i/30)"
    sleep 2
done

# Apply database migrations
echo "Applying database migrations..."
for migration_dir in migrations/*/; do
    if [ -d "$migration_dir" ]; then
        migration_file="$migration_dir/migration.sql"
        if [ -f "$migration_file" ]; then
            migration_name=$(basename "$migration_dir")
            echo "Checking migration: $migration_name"
            # Check if migration was already applied
            already_applied=$(docker compose exec -T postgres psql -U postgres -d rmotly -tAc \
                "SELECT COUNT(*) FROM serverpod_migrations WHERE version = '$migration_name'" 2>/dev/null || echo "0")
            if [ "$already_applied" = "0" ] || [ "$already_applied" = "" ]; then
                echo "Applying migration: $migration_name"
                docker compose exec -T postgres psql -U postgres -d rmotly < "$migration_file"
            else
                echo "Migration already applied: $migration_name"
            fi
        fi
    fi
done

# Build and start the server
echo "Building and starting Rmotly server..."
docker compose up -d --build server

# Show status
echo "=== Deployment Complete ==="
docker compose ps
echo ""
echo "Server logs (last 20 lines):"
docker compose logs --tail=20 server
