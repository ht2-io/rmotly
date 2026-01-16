# rmotly_server

This is the Rmotly Serverpod API server.

## Quick Start

### 1. Start Database Services

Start PostgreSQL and Redis using Docker:

```bash
docker compose up --build --detach
```

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

Stop the Serverpod server with `Ctrl-C`, then stop the database services:

```bash
docker compose stop
```

## Configuration

- **Development**: `config/development.yaml`
- **Production**: `config/production.yaml.template`
- **VAPID Keys**: See [docs/VAPID_KEYS.md](../docs/VAPID_KEYS.md)

## Documentation

- [API Documentation](../docs/API.md)
- [Push Notifications](../docs/PUSH_NOTIFICATION_DESIGN.md)
- [VAPID Keys Management](../docs/VAPID_KEYS.md)
