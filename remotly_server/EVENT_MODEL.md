# Event Model

## Overview

The Event model represents events in the Remotly system. Events are triggered by user actions on controls (buttons, sliders, toggles) or by external sources (webhooks, scheduled tasks). Events can trigger actions and store the results of those actions.

## Model Definition

**Location:** `remotly_server/lib/src/event.spy.yaml`

```yaml
class: Event
table: events

fields:
  userId: int                  # ID of the user who owns this event
  sourceType: String           # Type of source ('control', 'webhook', 'scheduled')
  sourceId: String             # ID of the specific source (e.g., control ID)
  eventType: String            # Type of event ('button_press', 'slider_change', etc.)
  payload: String?             # Optional JSON payload containing event data
  actionResult: String?        # Optional JSON result from action execution
  timestamp: DateTime          # When the event occurred

indexes:
  event_user_idx:
    fields: userId
    type: btree
```

## Fields Explanation

### userId (int, required)
The ID of the user who owns this event. Links to the User model (relation to be added when User model is created).

**Example:** `1`, `42`, `123`

### sourceType (String, required)
Identifies the category of source that generated the event.

**Possible values:**
- `'control'` - Event from a dashboard control (button, slider, toggle)
- `'webhook'` - Event from an external webhook
- `'scheduled'` - Event from a scheduled task
- `'system'` - Event from system operations

### sourceId (String, required)
The unique identifier of the specific source instance.

**Examples:**
- `'ctrl_abc123'` - Control ID
- `'webhook_xyz789'` - Webhook ID
- `'schedule_daily'` - Scheduled task ID

### eventType (String, required)
Describes the specific type of event that occurred.

**Examples:**
- `'button_press'` - User pressed a button control
- `'slider_change'` - User moved a slider
- `'toggle_switch'` - User toggled a switch
- `'input_submit'` - User submitted text input
- `'notification_received'` - External notification received

### payload (String?, optional)
JSON-encoded string containing event-specific data. The structure depends on the eventType.

**Examples:**

Button press:
```json
{"value": true, "timestamp": "2025-01-14T10:30:00Z"}
```

Slider change:
```json
{"value": 75, "min": 0, "max": 100}
```

Toggle switch:
```json
{"state": true, "previousState": false}
```

Webhook notification:
```json
{"title": "Alert", "message": "System down", "priority": "high"}
```

### actionResult (String?, optional)
JSON-encoded string containing the result of action execution triggered by this event.

**Examples:**

Successful HTTP action:
```json
{"status": 200, "body": {"result": "ok"}, "duration_ms": 145}
```

Failed action:
```json
{"status": 500, "error": "Connection timeout", "retries": 3}
```

No action configured:
```json
null
```

### timestamp (DateTime, required)
The exact date and time when the event occurred. Automatically set on event creation.

**Format:** ISO 8601 DateTime

**Example:** `2025-01-14T15:30:00.000Z`

## Indexes

### event_user_idx (btree on userId)
Optimizes queries that filter events by user, which is a common access pattern for:
- Listing a user's event history
- Analytics and reporting per user
- Event cleanup for specific users

## Database Operations

### Insert Event

```dart
final event = Event(
  userId: 1,
  sourceType: 'control',
  sourceId: 'ctrl_abc123',
  eventType: 'button_press',
  payload: '{"value": true}',
  timestamp: DateTime.now(),
);
final savedEvent = await Event.db.insertRow(session, event);
```

### Find Event by ID

```dart
final event = await Event.db.findById(session, eventId);
```

### Find Events by User

```dart
final userEvents = await Event.db.find(
  session,
  where: (t) => t.userId.equals(userId),
  orderBy: (t) => t.timestamp,
  orderDescending: true,
  limit: 50,
);
```

### Update Event with Action Result

```dart
event.actionResult = '{"status": 200, "response": "OK"}';
await Event.db.updateRow(session, event);
```

### Delete Old Events

```dart
final cutoffDate = DateTime.now().subtract(Duration(days: 30));
await Event.db.deleteWhere(
  session,
  where: (t) => t.timestamp.lessThan(cutoffDate),
);
```

## Usage in Endpoints

Events will be created by the EventEndpoint (Task 2.3.1):

```dart
class EventEndpoint extends Endpoint {
  Future<EventResponse> sendEvent(
    Session session, {
    required String controlId,
    required String eventType,
    String? payload,
  }) async {
    final userId = await session.auth.authenticatedUserId;
    
    final event = Event(
      userId: userId!,
      sourceType: 'control',
      sourceId: controlId,
      eventType: eventType,
      payload: payload,
      timestamp: DateTime.now(),
    );
    
    final savedEvent = await Event.db.insertRow(session, event);
    
    // Process event and trigger action
    await _eventService.processEvent(session, savedEvent);
    
    return EventResponse(success: true, eventId: savedEvent.id!);
  }
}
```

## Event Flow

1. **Event Creation**
   - User interacts with control in mobile app
   - App sends event data to EventEndpoint
   - Event is saved to database

2. **Event Processing**
   - EventService looks up associated action
   - ActionExecutorService executes HTTP request
   - Action result is stored in event

3. **Event History**
   - Events are queryable by user
   - Used for debugging and analytics
   - Can be filtered by type, source, date range

## Related Models (Future)

- **User** (Task 2.1.1) - Owner of events
- **Control** (Task 2.1.2) - Source of control events
- **Action** (Task 2.1.3) - Actions triggered by events

## Testing

Comprehensive integration tests are provided in:
`remotly_server/test/integration/event_model_test.dart`

Tests cover:
- Event creation and persistence
- Event retrieval by ID
- Event updates
- Querying by userId
- Event deletion
- Null optional fields

To run tests:
```bash
cd remotly_server
dart test test/integration/event_model_test.dart
```

## Migration

After running `serverpod generate`, create and apply migration:

```bash
cd remotly_server
serverpod create-migration
serverpod apply-migrations
```

This will create the `events` table with the specified schema and indexes.

## Best Practices

1. **Always set timestamp** - Use `DateTime.now()` when creating events
2. **Keep payload concise** - Store only essential data in JSON
3. **Update actionResult** - Set after action execution for debugging
4. **Index considerations** - The userId index optimizes common queries
5. **Event retention** - Consider implementing cleanup of old events

## Next Steps

1. Create User model (Task 2.1.1)
2. Add relation: `userId: int, relation(parent=users)`
3. Create EventEndpoint (Task 2.3.1)
4. Create EventService (Task 2.2.1)
5. Implement event processing logic

## References

- TASKS.md - Task 2.1.5
- [Serverpod Documentation](https://docs.serverpod.dev)
- docs/ARCHITECTURE.md - System architecture
- docs/API.md - API documentation
