# rmotly_server

This is the starting point for your Serverpod server.

## Quick Start

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

    docker compose up --build --detach

Then you can start the Serverpod server.

    dart bin/main.dart

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.

    docker compose stop

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
