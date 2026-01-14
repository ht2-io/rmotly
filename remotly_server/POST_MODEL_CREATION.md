# Post-Model Creation Steps

## Action Model Created

The Action model has been successfully created in `lib/src/action.spy.yaml`.

## Next Steps Required

To complete the model integration, run the following commands:

### 1. Generate Code from Models

```bash
cd remotly_server
serverpod generate
```

This will:
- Generate server-side model classes in `lib/src/generated/`
- Generate client-side protocol files in `../remotly_client/lib/src/protocol/`
- Update endpoint bindings

### 2. Create Database Migration

```bash
cd remotly_server
serverpod create-migration
```

This creates a new migration file in `migrations/` directory.

**Important**: The Action model has a foreign key reference to the `users` table (field: `userId`). Before applying this migration, ensure that:
- The User model (task 2.1.1 from TASKS.md) has been created
- The User model migration has been applied
- OR temporarily comment out the userId field if testing without User model

### 3. Apply Migrations

```bash
serverpod apply-migrations
```

This applies pending migrations to the database.

### 4. Verify Server Starts

```bash
dart bin/main.dart
```

Expected output:
```
Server starting...
Serverpod listening on port 8080
```

### 5. Run Tests

```bash
dart test
```

## Model Specification

The Action model includes the following fields:
- `userId` (int): Foreign key to users table
- `name` (String): Name of the action
- `description` (String?): Optional description
- `httpMethod` (String): HTTP method (GET, POST, PUT, DELETE, PATCH)
- `urlTemplate` (String): URL with {{variable}} placeholders
- `headersTemplate` (String?): JSON string for headers
- `bodyTemplate` (String?): Request body template
- `openApiSpecUrl` (String?): Source OpenAPI spec URL
- `openApiOperationId` (String?): OpenAPI operation ID
- `parameters` (String?): JSON string for parameter definitions
- `createdAt` (DateTime): Creation timestamp
- `updatedAt` (DateTime): Last update timestamp

## Dependencies

- **User Model**: Task 2.1.1 must be completed before applying Action model migrations
- **PostgreSQL**: Must be running (see docker-compose.yaml)
- **Redis**: Must be running (optional for basic functionality)

## Troubleshooting

If you encounter errors:

**"Table 'users' does not exist"**
- Create the User model first (task 2.1.1)
- Or temporarily modify action.spy.yaml to make userId nullable or remove the relation

**"serverpod: command not found"**
```bash
dart pub global activate serverpod_cli
```

**"Database connection failed"**
- Start PostgreSQL: `docker compose up --detach`
- Check `config/development.yaml` for correct database credentials
