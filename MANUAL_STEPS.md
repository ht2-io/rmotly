# Manual Steps Required for Event Model Completion

This file documents the manual steps that need to be executed to complete the Event model implementation.

## Steps to Complete

### 1. Generate Serverpod Code

Navigate to the server directory and run code generation:

```bash
cd remotly_server
serverpod generate
```

This will:
- Generate the `Event` class in `lib/src/generated/event.dart`
- Update the protocol files
- Update the client code in `remotly_client/`
- Update test tools

**Expected Output:**
```
Generating code...
Generated:
  - lib/src/generated/event.dart
  - lib/src/generated/protocol.dart
  - test/integration/test_tools/serverpod_test_tools.dart
Code generation completed successfully.
```

### 2. Create Database Migration

After generation succeeds, create a migration for the new events table:

```bash
cd remotly_server
serverpod create-migration
```

**Expected Output:**
```
Creating migration...
Migration created: migrations/0001_create_events_table.sql
```

### 3. Apply Database Migration

Apply the migration to create the events table in the database:

```bash
serverpod apply-migrations
```

**Expected Output:**
```
Applying migrations...
Applied migration: 0001_create_events_table
Database is up to date.
```

### 4. Run Tests

Verify the Event model works correctly:

```bash
dart test test/integration/event_model_test.dart
```

**Expected Output:**
```
00:01 +6: All tests passed!
```

### 5. Verify Server Starts

Ensure the server starts without errors:

```bash
dart bin/main.dart
```

**Expected Output:**
```
Server starting...
Serverpod listening on port 8080
```

Press `Ctrl+C` to stop the server after verification.

## Troubleshooting

### Issue: "Could not find class definition for Event"

**Solution:** Run `serverpod generate` again. Ensure the YAML file is valid.

### Issue: "Database connection failed"

**Solution:** 
1. Check PostgreSQL is running: `pg_isready`
2. Verify credentials in `config/development.yaml`
3. Ensure database exists: `psql -U remotly_user -d remotly -h localhost`

### Issue: "Migration already exists"

**Solution:** Don't create duplicate migrations. Use `serverpod list-migrations` to see existing migrations.

### Issue: Tests fail with "Table events does not exist"

**Solution:** Run `serverpod apply-migrations` to create the events table.

## Files Created

- `remotly_server/lib/src/event.spy.yaml` - Event model definition
- `remotly_server/test/integration/event_model_test.dart` - Integration tests

## Files Generated (after serverpod generate)

- `remotly_server/lib/src/generated/event.dart` - Generated Event class
- `remotly_server/lib/src/generated/protocol.dart` - Updated protocol
- `remotly_client/lib/src/protocol/event.dart` - Client-side Event class
- Migration files in `migrations/` directory

## Next Steps After Completion

Once the Event model is working:

1. Create User model (Task 2.1.1) - Required for userId relation
2. Update Event model to add relation: `userId: int, relation(parent=users)`
3. Create EventEndpoint (Task 2.3.1) for event operations
4. Create EventService (Task 2.2.1) for business logic

## Notes

- Event model currently has `userId` as a plain integer (no foreign key relation)
- Relation will be added after User model is created
- Model follows TASKS.md specification (task 2.1.5)
- All indexes defined as specified
