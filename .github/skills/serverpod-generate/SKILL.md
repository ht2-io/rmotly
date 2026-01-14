---
name: serverpod-generate
description: Use when Serverpod models are changed and code generation is needed. Also covers migrations and server startup verification.
---

# Serverpod Code Generation Skill

## When to Run Generation

Run `serverpod generate` after:
- Creating a new model YAML file
- Modifying fields in an existing model
- Adding or changing indexes
- Modifying relations between models

## Model File Location

Models are defined in YAML files at:
```
remotly_server/lib/src/models/*.yaml
```

## Model Definition Syntax

### Basic Model

```yaml
# lib/src/models/control.yaml
class: Control
table: controls
fields:
  name: String
  controlType: String
  config: String
  position: int
  createdAt: DateTime
  updatedAt: DateTime
```

### With Relations

```yaml
# lib/src/models/control.yaml
class: Control
table: controls
fields:
  userId: int, relation(parent=users)
  name: String
  controlType: String
  actionId: int?, relation(parent=actions)
  config: String
  position: int
  createdAt: DateTime
  updatedAt: DateTime
```

### With Indexes

```yaml
class: Event
table: events
fields:
  userId: int, relation(parent=users)
  sourceType: String
  sourceId: String
  eventType: String
  payload: String?
  timestamp: DateTime
indexes:
  event_user_idx:
    fields: userId
    type: btree
  event_timestamp_idx:
    fields: timestamp
    type: btree
```

### Field Types

| Type | Description |
|------|-------------|
| `String` | Text field |
| `int` | Integer |
| `double` | Floating point |
| `bool` | Boolean |
| `DateTime` | Date and time |
| `ByteData` | Binary data |
| `Duration` | Time duration |
| `UuidValue` | UUID |
| `List<T>` | List of type T |
| `Map<K,V>` | Map with key K and value V |

### Optional Fields

Add `?` suffix for nullable fields:
```yaml
fields:
  description: String?    # Optional
  payload: String?        # Optional
  actionId: int?          # Optional foreign key
```

## Generation Commands

### Basic Generation

```bash
cd remotly_server
serverpod generate
```

This generates:
- Model classes in `lib/src/generated/`
- Client code in `remotly_client/`
- Protocol files

### Full Workflow After Model Changes

```bash
# 1. Navigate to server directory
cd remotly_server

# 2. Generate code
serverpod generate

# 3. If database schema changed, create migration
serverpod create-migration

# 4. Apply migrations to database
serverpod apply-migrations

# 5. Verify server starts correctly
dart bin/main.dart
```

## Database Migrations

### Create Migration

After changing model fields that affect the database:

```bash
cd remotly_server
serverpod create-migration
```

This creates a migration file in `migrations/` directory.

### Apply Migrations

```bash
serverpod apply-migrations
```

### Migration Options

```bash
# Apply migrations (default)
serverpod apply-migrations

# Repair migration state (if needed)
serverpod repair-migrations

# List pending migrations
serverpod list-migrations
```

## Verification Steps

After running generation:

### 1. Check Generated Files

```bash
# Verify model was generated
ls remotly_server/lib/src/generated/

# Verify client was updated
ls remotly_client/lib/src/protocol/
```

### 2. Start Server

```bash
cd remotly_server
dart bin/main.dart
```

Expected output:
```
Server starting...
Serverpod listening on port 8080
```

### 3. Run Server Tests

```bash
cd remotly_server
dart test
```

### 4. Update Flutter App Dependencies

```bash
cd remotly_app
flutter pub get
```

## Troubleshooting

### Generation Errors

**"Could not find model file"**
- Check YAML file is in `lib/src/models/`
- Verify YAML syntax is correct

**"Invalid field type"**
- Check field type is supported
- Ensure proper relation syntax

### Migration Errors

**"Migration already applied"**
- Don't modify existing migrations
- Create new migration for changes

**"Database connection failed"**
- Check PostgreSQL is running
- Verify `config/development.yaml` credentials

### Server Won't Start

```bash
# Check database is accessible
psql -U remotly_user -d remotly -h localhost

# Check Redis is running
redis-cli ping

# Check port is not in use
lsof -i :8080
```

## Common Model Patterns

### User Model with Auth

```yaml
class: User
table: users
fields:
  email: String
  displayName: String?
  fcmToken: String?
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  user_email_idx:
    fields: email
    unique: true
```

### Event Logging Model

```yaml
class: Event
table: events
fields:
  userId: int, relation(parent=users)
  sourceType: String
  sourceId: String
  eventType: String
  payload: String?
  actionResult: String?
  timestamp: DateTime
indexes:
  event_user_time_idx:
    fields: userId, timestamp
```

### Many-to-Many Relation

```yaml
# Junction table for many-to-many
class: ControlAction
table: control_actions
fields:
  controlId: int, relation(parent=controls)
  actionId: int, relation(parent=actions)
indexes:
  control_action_unique_idx:
    fields: controlId, actionId
    unique: true
```

## Quick Reference

```bash
# Generate code
cd remotly_server && serverpod generate

# Create migration
serverpod create-migration

# Apply migrations
serverpod apply-migrations

# Start server
dart bin/main.dart

# Run tests
dart test
```
