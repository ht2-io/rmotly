# rmotly_server

This is the starting point for your Serverpod server.

## Getting Started

### 1. Start Database Services

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

```bash
docker compose up --build --detach
```

### 2. Generate VAPID Keys (First Time Setup)

For push notifications, you need to generate VAPID (Voluntary Application Server Identification) keys:

```bash
dart run bin/generate_vapid_keys.dart
```

This will output keys that you can:
- Copy to `config/development.yaml` for local development
- Set as environment variables for production:
  ```bash
  export VAPID_SUBJECT="mailto:admin@yourdomain.com"
  export VAPID_PUBLIC_KEY="<generated-public-key>"
  export VAPID_PRIVATE_KEY="<generated-private-key>"
  ```

**Note**: Development keys are already configured in `config/development.yaml`. Only regenerate if you need different keys for testing or if existing keys need to be rotated for security reasons.

For more details, see [docs/PUSH_NOTIFICATION_DESIGN.md](../docs/PUSH_NOTIFICATION_DESIGN.md).

### 3. Start the Server

Then you can start the Serverpod server.

```bash
dart bin/main.dart
```

### 4. Shutdown

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.

```bash
docker compose stop
```

## Configuration Files

- `config/development.yaml` - Local development configuration (includes development VAPID keys)
- `config/production.yaml.template` - Template for production configuration
- `config/staging.yaml` - Staging environment configuration
- `config/test.yaml` - Test environment configuration
