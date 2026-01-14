# Remotly - Data Models

This document describes the data models used in the Remotly API server.

## Overview

Models are defined in YAML files using Serverpod's model definition syntax. After modifying any model file, run `serverpod generate` to generate the corresponding Dart classes and database migrations.

## Model Files Location

```
remotly_server/lib/src/*.spy.yaml
```

## Available Models

### Control Model

**File:** `lib/src/control.spy.yaml`

**Table:** `controls`

**Description:** Represents a user-defined UI control on the dashboard that can trigger actions.

#### Fields

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `int` | No | Auto-generated primary key |
| `userId` | `int` | No | The ID of the user who owns this control |
| `name` | `String` | No | Display name for the control shown in the UI |
| `controlType` | `String` | No | Type of control: 'button', 'toggle', 'slider', 'input', 'dropdown' |
| `actionId` | `int` | Yes | Optional reference to the action this control triggers |
| `config` | `String` | No | JSON string containing type-specific configuration |
| `position` | `int` | No | Position/order of the control on the dashboard (0-indexed) |
| `createdAt` | `DateTime` | No | Timestamp when the control was created |
| `updatedAt` | `DateTime` | No | Timestamp when the control was last updated |

#### Indexes

- **control_user_idx**: Composite B-tree index on `(userId, position)` for efficient user-specific queries and ordering

#### Control Types

The `controlType` field can have the following values:

##### button
A simple button that sends an event when pressed.

**Config Example:**
```json
{
  "icon": "lightbulb",
  "color": "#FF5722",
  "label": "Toggle Light"
}
```

##### toggle
An on/off switch that maintains state.

**Config Example:**
```json
{
  "onLabel": "On",
  "offLabel": "Off",
  "icon": "power",
  "defaultState": false
}
```

##### slider
A range slider for selecting numeric values.

**Config Example:**
```json
{
  "min": 0,
  "max": 100,
  "step": 1,
  "defaultValue": 50,
  "unit": "%",
  "icon": "tune"
}
```

##### input
A text input field for entering custom values.

**Config Example:**
```json
{
  "placeholder": "Enter value",
  "multiline": false,
  "maxLength": 100,
  "inputType": "text"
}
```

##### dropdown
A dropdown selector for choosing from predefined options.

**Config Example:**
```json
{
  "options": [
    {"value": "option1", "label": "Option 1"},
    {"value": "option2", "label": "Option 2"}
  ],
  "defaultValue": "option1"
}
```

#### Usage Example

```dart
// Create a new control
final control = Control(
  userId: user.id,
  name: 'Living Room Light',
  controlType: 'toggle',
  actionId: lightToggleAction.id,
  config: jsonEncode({
    'onLabel': 'On',
    'offLabel': 'Off',
    'icon': 'lightbulb',
    'defaultState': false,
  }),
  position: 0,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Save to database
final savedControl = await Control.db.insertRow(session, control);

// Find all controls for a user
final userControls = await Control.db.find(
  session,
  where: (t) => t.userId.equals(userId),
  orderBy: (t) => t.position,
);

// Update a control
control.name = 'Updated Name';
control.updatedAt = DateTime.now();
await Control.db.updateRow(session, control);

// Delete a control
await Control.db.deleteRow(session, control);
```

## Database Operations

### Common Queries

#### Get User's Controls (Ordered)
```dart
final controls = await Control.db.find(
  session,
  where: (t) => t.userId.equals(userId),
  orderBy: (t) => t.position,
);
```

#### Get Controls by Type
```dart
final buttonControls = await Control.db.find(
  session,
  where: (t) => t.userId.equals(userId) & t.controlType.equals('button'),
);
```

#### Get Controls with Actions
```dart
final controlsWithActions = await Control.db.find(
  session,
  where: (t) => t.userId.equals(userId) & t.actionId.notEquals(null),
);
```

#### Count User's Controls
```dart
final count = await Control.db.count(
  session,
  where: (t) => t.userId.equals(userId),
);
```

## Code Generation

After modifying any model file:

```bash
cd remotly_server
serverpod generate
```

This generates:
- Model classes in `lib/src/generated/`
- Database access methods
- Client protocol in `remotly_client/`

## Database Migrations

When model changes affect the database schema:

```bash
# Create migration
serverpod create-migration

# Apply migrations
serverpod apply-migrations
```

## Testing

See `test/integration/control_model_test.dart` for comprehensive tests of the Control model's database operations.

Run tests:
```bash
cd remotly_server
dart test
```

## Future Models

The following models are planned (see TASKS.md):

- **User** (Task 2.1.1) - User accounts and authentication
- **Action** (Task 2.1.3) - HTTP action definitions
- **NotificationTopic** (Task 2.1.4) - Notification channel configurations
- **Event** (Task 2.1.5) - Event logging and history

## References

- [Serverpod Model Documentation](https://docs.serverpod.dev/concepts/models)
- [Serverpod Database Operations](https://docs.serverpod.dev/concepts/database)
- Project: `TASKS.md` - Task definitions and progress
- Project: `docs/ARCHITECTURE.md` - System architecture overview
