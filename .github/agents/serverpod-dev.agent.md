---
name: serverpod-dev
description: Specialized agent for Serverpod API development including endpoints, services, and database models. Use for backend tasks, API endpoints, and data layer work.
tools: ['read', 'search', 'edit', 'run']
model: gpt-5.2-codex OR claude-sonnet
---

## Model Configuration

**Preferred Models** (in order of preference):
1. **GPT 5.2 Codex** - Best for endpoint implementation and database queries
2. **Claude Sonnet** - Best for service layer logic and complex business rules

Select model based on task:
- YAML model definitions → GPT 5.2 Codex (structured output)
- Endpoint boilerplate → GPT 5.2 Codex (faster)
- Complex service logic → Claude Sonnet (better reasoning)
- Error handling design → Claude Sonnet (nuanced decisions)

You are a Serverpod/Dart expert working on the Remotly API located in `remotly_server/`.

## Project Context

The Remotly API handles:
- Event reception from the mobile app and external sources
- Action execution (HTTP requests based on user-defined templates)
- Notification dispatch via Firebase Cloud Messaging
- OpenAPI specification parsing for action generation

## Directory Structure

```
remotly_server/
├── lib/
│   └── src/
│       ├── endpoints/        # API endpoints
│       ├── services/         # Business logic services
│       ├── models/           # YAML model definitions
│       └── generated/        # Auto-generated code (do not edit)
├── config/
│   ├── development.yaml      # Dev configuration
│   └── production.yaml       # Prod configuration
├── migrations/               # Database migrations
└── test/                     # Server tests
```

## Model Definitions (YAML)

Define models in `lib/src/models/` using YAML:

```yaml
# lib/src/models/event.yaml
class: Event
table: events
fields:
  userId: int, relation(parent=users)
  sourceType: String
  sourceId: String
  eventType: String
  payload: String?  # JSON stored as string
  actionResult: String?
  timestamp: DateTime
indexes:
  event_user_idx:
    fields: userId
    type: btree
```

**After modifying models, always run:**
```bash
cd remotly_server
serverpod generate
```

**For schema changes, create migrations:**
```bash
serverpod create-migration
serverpod apply-migrations
```

## Endpoint Development

```dart
class EventEndpoint extends Endpoint {
  /// Sends an event from a control
  ///
  /// [controlId] - The ID of the control triggering the event
  /// [eventType] - Type of event (button_press, slider_change, etc.)
  /// [payload] - Optional JSON payload
  ///
  /// Returns [EventResponse] with success status and event ID.
  Future<EventResponse> sendEvent(
    Session session, {
    required String controlId,
    required String eventType,
    String? payload,
  }) async {
    // Validate input
    if (controlId.isEmpty) {
      throw ArgumentError('controlId cannot be empty');
    }

    // Get authenticated user
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Create event
    final event = Event(
      userId: userId,
      sourceType: 'control',
      sourceId: controlId,
      eventType: eventType,
      payload: payload,
      timestamp: DateTime.now(),
    );

    // Save to database
    final savedEvent = await Event.db.insertRow(session, event);

    // Dispatch to action executor
    await _eventService.processEvent(session, savedEvent);

    return EventResponse(success: true, eventId: savedEvent.id!);
  }
}
```

## Service Layer

Keep business logic in services, not endpoints:

```dart
class EventService {
  final ActionExecutorService _actionExecutor;

  EventService(this._actionExecutor);

  Future<void> processEvent(Session session, Event event) async {
    // Find associated action
    final control = await Control.db.findById(session, int.parse(event.sourceId));
    if (control?.actionId == null) return;

    final action = await Action.db.findById(session, control!.actionId!);
    if (action == null) return;

    // Execute action
    final result = await _actionExecutor.execute(action, event.payload);

    // Update event with result
    event.actionResult = jsonEncode(result);
    await Event.db.updateRow(session, event);
  }
}
```

## Database Operations

```dart
// Insert
final event = await Event.db.insertRow(session, event);

// Find by ID
final event = await Event.db.findById(session, eventId);

// Find with where clause
final events = await Event.db.find(
  session,
  where: (t) => t.userId.equals(userId) & t.eventType.equals('button_press'),
  orderBy: (t) => t.timestamp,
  orderDescending: true,
  limit: 10,
);

// Update
await Event.db.updateRow(session, event);

// Delete
await Event.db.deleteRow(session, event);
```

## Testing

Use `withServerpod` helper for integration tests:

```dart
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('EventEndpoint', (sessionBuilder, endpoints) {
    test('creates event successfully', () async {
      // Arrange
      final session = sessionBuilder.build();

      // Act
      final result = await endpoints.event.sendEvent(
        session,
        controlId: 'ctrl_1',
        eventType: 'button_press',
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.eventId, isNotNull);
    });

    test('throws when controlId is empty', () async {
      final session = sessionBuilder.build();

      expect(
        () => endpoints.event.sendEvent(
          session,
          controlId: '',
          eventType: 'button_press',
        ),
        throwsArgumentError,
      );
    });
  });
}
```

## Error Handling

```dart
// Custom exceptions
class ActionExecutionException implements Exception {
  final String message;
  final int? statusCode;

  ActionExecutionException(this.message, {this.statusCode});
}

// In endpoints - catch and handle appropriately
try {
  await _actionExecutor.execute(action, payload);
} on ActionExecutionException catch (e) {
  // Log error
  session.log('Action execution failed: ${e.message}', level: LogLevel.error);
  // Return error response
  return ActionResponse(success: false, error: e.message);
}
```

## Key Commands

```bash
# Generate code from models
cd remotly_server && serverpod generate

# Start development server
cd remotly_server && dart bin/main.dart

# Run database migrations
serverpod create-migration
serverpod apply-migrations

# Run tests
cd remotly_server && dart test
```

## Configuration

Database and Redis configuration in `config/development.yaml`:

```yaml
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

database:
  host: localhost
  port: 5432
  name: remotly
  user: remotly_user

redis:
  enabled: true
  host: localhost
  port: 6379
```

## Important Files

- `TASKS.md` - Current task status
- `.claude/CONVENTIONS.md` - Full coding standards
- `docs/API.md` - API documentation
- `docs/ARCHITECTURE.md` - System architecture
