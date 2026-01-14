# remotly_server

This is the Serverpod API server for Remotly.

## Quick Start

### 1. Start Dependencies

Start Postgres and Redis using Docker:

```bash
docker compose up --build --detach
```

### 2. Generate Code

After modifying any model files (`.spy.yaml`), generate the Dart classes:

```bash
serverpod generate
```

### 3. Database Migrations

If the model changes affect the database schema:

```bash
# Create migration
serverpod create-migration

# Apply migrations
serverpod apply-migrations
```

### 4. Start Server

Start the Serverpod server:

```bash
dart bin/main.dart
```

### 5. Run Tests

Run the test suite:

```bash
dart test
```

### 6. Cleanup

When finished, stop Serverpod with `Ctrl-C`, then stop dependencies:

```bash
docker compose stop
```

## Models

Data models are defined in `.spy.yaml` files in `lib/src/`. See [docs/MODELS.md](../docs/MODELS.md) for detailed model documentation.

Current models:
- **Control** - Dashboard control definitions

## Development Workflow

1. Modify or create `.spy.yaml` model files in `lib/src/`
2. Run `serverpod generate` to generate code
3. Create database migrations if needed
4. Write tests in `test/integration/`
5. Run tests to verify functionality

## Documentation

- [Models Documentation](../docs/MODELS.md)
- [API Documentation](../docs/API.md)
- [Architecture Overview](../docs/ARCHITECTURE.md)
- [Serverpod Documentation](https://docs.serverpod.dev)
