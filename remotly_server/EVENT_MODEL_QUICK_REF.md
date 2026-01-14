# Event Model Quick Reference

## Model Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | int | Auto | Primary key (auto-generated) |
| `userId` | int | ✓ | Owner of the event |
| `sourceType` | String | ✓ | Source category: 'control', 'webhook', 'scheduled' |
| `sourceId` | String | ✓ | Specific source identifier |
| `eventType` | String | ✓ | Event type: 'button_press', 'slider_change', etc. |
| `payload` | String? | - | JSON data (optional) |
| `actionResult` | String? | - | JSON result from action (optional) |
| `timestamp` | DateTime | ✓ | When event occurred |

## Common Operations

### Create Event
```dart
final event = Event(
  userId: 1,
  sourceType: 'control',
  sourceId: 'ctrl_123',
  eventType: 'button_press',
  payload: '{"value": true}',
  timestamp: DateTime.now(),
);
await Event.db.insertRow(session, event);
```

### Find by ID
```dart
final event = await Event.db.findById(session, eventId);
```

### Query by User
```dart
final events = await Event.db.find(
  session,
  where: (t) => t.userId.equals(userId),
  orderBy: (t) => t.timestamp,
  orderDescending: true,
  limit: 50,
);
```

### Update Result
```dart
event.actionResult = '{"status": 200}';
await Event.db.updateRow(session, event);
```

### Delete
```dart
await Event.db.deleteRow(session, event);
```

## Setup Commands

```bash
# 0. Fix file location (REQUIRED FIRST)
cd remotly_server/lib/src && mkdir -p models && mv event.spy.yaml models/event.yaml

# 1. Generate code
cd remotly_server && serverpod generate

# 2. Create migration
serverpod create-migration

# 3. Apply migration
serverpod apply-migrations

# 4. Run tests
dart test test/integration/event_model_test.dart
```

## Files

- **Definition:** `remotly_server/lib/src/models/event.yaml`
- **Tests:** `remotly_server/test/integration/event_model_test.dart`
- **Generated:** `remotly_server/lib/src/generated/event.dart` (after generate)
- **Docs:** `remotly_server/EVENT_MODEL.md`

## Example Payloads

**Button:**
```json
{"value": true, "timestamp": "2025-01-14T10:30:00Z"}
```

**Slider:**
```json
{"value": 75, "min": 0, "max": 100}
```

**Toggle:**
```json
{"state": true, "previousState": false}
```

## Index

- `event_user_idx` on `userId` - Optimizes user event queries

## Related

- Task 2.1.5 in TASKS.md
- See COMPLETION_SUMMARY.md for full details
- See MANUAL_STEPS.md for setup instructions
