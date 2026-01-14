# Control Model - Generation and Migration Guide

This guide walks through generating code and applying database migrations for the Control model.

## Prerequisites

- Docker (for PostgreSQL and Redis)
- Dart SDK
- Serverpod CLI installed (`dart pub global activate serverpod_cli`)

## Step-by-Step Instructions

### 1. Start Database Services

```bash
cd remotly_server
docker compose up --build --detach
```

Verify services are running:
```bash
docker ps
```

You should see PostgreSQL and Redis containers running.

### 2. Generate Code from Model

```bash
cd remotly_server
serverpod generate
```

**Expected Output:**
```
Analyzing project...
Generating protocol...
  ✓ Generated Control model
  ✓ Updated protocol files
  ✓ Updated client code
Done!
```

**Generated Files:**
- `lib/src/generated/control.dart` - Control entity class
- `lib/src/generated/protocol.dart` - Protocol aggregator
- `remotly_client/lib/src/protocol/control.dart` - Client-side Control class
- Database table definitions

### 3. Create Database Migration

```bash
serverpod create-migration
```

This creates a migration file in `migrations/` directory that includes the SQL to create the `controls` table.

**Migration Contents:**
- CREATE TABLE `controls` with all fields
- CREATE INDEX `control_user_idx` on (userId, position)

### 4. Apply Migration to Database

```bash
serverpod apply-migrations
```

**Expected Output:**
```
Applying migrations...
  ✓ Applied migration: 0001_create_controls_table.sql
Done!
```

### 5. Verify Database Schema

Connect to the database and verify the table was created:

```bash
docker exec -it remotly-postgres psql -U remotly_user -d remotly
```

Then in the PostgreSQL shell:
```sql
-- List all tables
\dt

-- Describe the controls table
\d controls

-- Should show:
-- Column      | Type                   | Nullable
-- -----------|------------------------|----------
-- id         | bigint                 | not null
-- userId     | bigint                 | not null
-- name       | text                   | not null
-- controlType| text                   | not null
-- actionId   | bigint                 | 
-- config     | text                   | not null
-- position   | bigint                 | not null
-- createdAt  | timestamp              | not null
-- updatedAt  | timestamp              | not null

-- Exit PostgreSQL shell
\q
```

### 6. Run Tests

Verify the model works correctly:

```bash
cd remotly_server
dart test
```

**Expected Results:**
- All tests in `test/integration/control_model_test.dart` should pass
- Tests verify CRUD operations, queries, and ordering

### 7. Start the Server

```bash
dart bin/main.dart
```

**Expected Output:**
```
Serverpod version 2.9.2
Starting server...
✓ PostgreSQL connected
✓ Redis connected
✓ Server listening on port 8080
```

Server is now ready to accept requests!

### 8. Test API Endpoint (Optional)

Once you create a ControlEndpoint, you can test it:

```bash
curl -X POST http://localhost:8080/controls \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "name": "Test Button",
    "controlType": "button",
    "config": "{\"icon\":\"lightbulb\"}",
    "position": 0
  }'
```

## Troubleshooting

### "Could not connect to database"

**Problem:** PostgreSQL is not running or connection settings are wrong.

**Solution:**
```bash
# Check if PostgreSQL container is running
docker ps | grep postgres

# If not running, start it
docker compose up --build --detach

# Check connection settings in config/development.yaml
```

### "Migration already applied"

**Problem:** Trying to apply the same migration twice.

**Solution:**
```bash
# List migration status
serverpod list-migrations

# If needed, repair migration state
serverpod repair-migrations
```

### "Generated code not found"

**Problem:** Code generation didn't complete successfully.

**Solution:**
```bash
# Clean generated files
rm -rf lib/src/generated

# Run generation again with verbose output
serverpod generate --verbose
```

### Tests fail with "Table does not exist"

**Problem:** Migrations haven't been applied.

**Solution:**
```bash
# Apply migrations
serverpod apply-migrations

# Verify table exists
docker exec -it remotly-postgres psql -U remotly_user -d remotly -c "\dt"
```

## Cleanup

When you're done:

```bash
# Stop the server (Ctrl+C)

# Stop Docker services
docker compose stop

# Or remove containers entirely
docker compose down
```

## Next Steps

After the Control model is working:

1. **Create ControlEndpoint** (Task 2.3.4)
   - CRUD endpoints for controls
   - Reorder controls endpoint

2. **Create User Model** (Task 2.1.1)
   - Add relations between User and Control

3. **Create Action Model** (Task 2.1.3)
   - Add relations between Action and Control

4. **Implement Event Processing** (Task 2.2.1)
   - Connect controls to action execution

## Reference

- [Serverpod Code Generation](https://docs.serverpod.dev/concepts/models)
- [Database Migrations](https://docs.serverpod.dev/concepts/database/migrations)
- [Testing Guide](https://docs.serverpod.dev/concepts/testing)
- Project: `docs/MODELS.md` - Complete model documentation
- Project: `TASKS.md` - All project tasks and progress
