---
applyTo: "rmotly_server/**"
---

# Serverpod Development Instructions

## Model File Requirements

**CRITICAL**: Serverpod model files MUST follow these rules:

### File Location
Models MUST be placed in `rmotly_server/lib/src/models/` directory.

```
✅ CORRECT: rmotly_server/lib/src/models/user.yaml
✅ CORRECT: rmotly_server/lib/src/models/control.yaml
✅ CORRECT: rmotly_server/lib/src/models/action.yaml

❌ WRONG: rmotly_server/lib/src/user.yaml
❌ WRONG: rmotly_server/lib/src/models/user.spy.yaml
❌ WRONG: rmotly_server/user.yaml
```

### File Extension
Models MUST use `.yaml` extension (NOT `.spy.yaml`, `.model.yaml`, or any other variant).

```
✅ CORRECT: user.yaml
✅ CORRECT: notification_topic.yaml

❌ WRONG: user.spy.yaml
❌ WRONG: user.model.yaml
❌ WRONG: user.yml
```

### Model YAML Structure

```yaml
# Example: rmotly_server/lib/src/models/user.yaml
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
    type: btree
    unique: true
```

## After Creating/Modifying Models

ALWAYS run these commands after model changes:

```bash
cd rmotly_server
serverpod generate
```

If database schema changed:
```bash
serverpod create-migration
serverpod apply-migrations
```

Verify server starts:
```bash
dart bin/main.dart
```

## Directory Structure

```
rmotly_server/
├── lib/
│   └── src/
│       ├── endpoints/        # API endpoint classes
│       ├── services/         # Business logic services
│       ├── models/           # YAML model definitions ← Models go HERE
│       └── generated/        # Auto-generated (DO NOT EDIT)
├── config/
│   ├── development.yaml
│   └── production.yaml
└── test/
```

## Common Field Types

| Type | Example |
|------|---------|
| `String` | `name: String` |
| `String?` | `description: String?` (nullable) |
| `int` | `count: int` |
| `int?` | `actionId: int?` (nullable) |
| `double` | `price: double` |
| `bool` | `enabled: bool` |
| `DateTime` | `createdAt: DateTime` |
| `List<String>` | `tags: List<String>` |

## Relations

```yaml
# Foreign key to another table
userId: int, relation(parent=users)

# Optional foreign key
actionId: int?, relation(parent=actions)
```

## Do NOT

- Edit files in `lib/src/generated/`
- Use file extensions other than `.yaml`
- Place models outside `lib/src/models/`
- Skip running `serverpod generate` after changes
