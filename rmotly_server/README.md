# rmotly_server

This is the starting point for your Serverpod server.

## Quick Start

To run your server, you first need to start Postgres, Redis, and ntfy. It's easiest to do with Docker.

    docker compose up --build --detach

This starts:
- PostgreSQL on port 8090
- Redis on port 8091
- ntfy push server on port 8093

Then you can start the Serverpod server.

    dart bin/main.dart

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop the services.

    docker compose stop

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

## Deployment

For production deployment, see the [Complete Deployment Guide](../docs/DEPLOYMENT.md).

The guide covers:
- Quick start (single command deployment)
- Environment variables reference
- Self-hosting with Docker Compose
- VPS deployment
- Cloud deployment (AWS/GCP)
- Production checklist
- Troubleshooting
