# rmotly_server

This is the Rmotly Serverpod API server.

## Quick Start

### 1. Start Database Services

To run your server, you first need to start Postgres, Redis, and ntfy. It's easiest to do with Docker.

```bash
docker compose up --build --detach
```

This starts:
- PostgreSQL on port 8090
- Redis on port 8091
- ntfy push server on port 8093

### 2. Generate VAPID Keys (First Time Setup)

VAPID keys are required for WebPush notifications:

```bash
dart run bin/generate_vapid_keys.dart
```

Copy the generated keys to `config/development.yaml` or set as environment variables. See [docs/VAPID_KEYS.md](../docs/VAPID_KEYS.md) for detailed instructions.

### 3. Start the Server

```bash
dart bin/main.dart
```

### 4. Shutdown

Stop the Serverpod server with `Ctrl-C`, then stop the services:

```bash
docker compose stop
```

## Services

### PostgreSQL Database
- **Port**: 8090 (mapped to 5432 internally)
- **Database**: rmotly
- **User**: postgres

### Redis Cache
- **Port**: 8091 (mapped to 6379 internally)
- **Password**: Set in docker-compose.yaml

### ntfy Push Server
- **Port**: 8093 (mapped to 80 internally)
- **Health Check**: http://localhost:8093/v1/health
- **Base URL**: http://localhost:8093

#### ntfy Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | UTC | Timezone for ntfy server |
| `NTFY_BASE_URL` | http://localhost:8093 | Base URL for ntfy server |
| `NTFY_CACHE_FILE` | /var/cache/ntfy/cache.db | Location of cache database |
| `NTFY_CACHE_DURATION` | 24h | How long to cache messages |
| `NTFY_ATTACHMENT_CACHE_DIR` | /var/cache/ntfy/attachments | Directory for attachment cache |
| `NTFY_ENABLE_LOGIN` | false | Enable authentication (disabled for development) |
| `NTFY_UPSTREAM_BASE_URL` | https://ntfy.sh | Upstream ntfy server for forwarding |

### Testing ntfy

To verify ntfy is working correctly:

```bash
# Check health status (should return {"healthy":true})
curl http://localhost:8093/v1/health

# Send a test notification
curl -d "Test notification from Rmotly" http://localhost:8093/rmotly-test

# Subscribe to notifications (in another terminal)
curl -s http://localhost:8093/rmotly-test/json
```

**Expected health check response:**
```json
{"healthy":true}
```

## Configuration

- **Development**: `config/development.yaml`
- **Production**: `config/production.yaml.template`
- **VAPID Keys**: See [docs/VAPID_KEYS.md](../docs/VAPID_KEYS.md)

## Documentation

- [API Documentation](../docs/API.md)
- [Push Notifications](../docs/PUSH_NOTIFICATION_DESIGN.md)
- [VAPID Keys Management](../docs/VAPID_KEYS.md)
- [Complete Deployment Guide](../docs/DEPLOYMENT.md)
