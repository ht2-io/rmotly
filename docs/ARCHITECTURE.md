# Rmotly - System Architecture

## Overview

Rmotly is a bidirectional event-driven system that enables users to:
1. Create custom controls in a mobile app that trigger remote actions
2. Receive notifications from external sources through configurable topics
3. Define actions based on OpenAPI specifications

## System Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              External Services                               │
│  (Home Assistant, IFTTT, Webhooks, IoT devices, Custom APIs)                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
            ┌───────────┐     ┌───────────┐     ┌───────────┐
            │  Webhook  │     │   REST    │     │ WebSocket │
            │  Endpoint │     │  Endpoint │     │  Stream   │
            └───────────┘     └───────────┘     └───────────┘
                    │                 │                 │
                    └─────────────────┼─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │         Rmotly API Server        │
                    │           (Serverpod)             │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │      Event Router           │  │
                    │  │  ┌─────┐ ┌─────┐ ┌─────┐   │  │
                    │  │  │Queue│ │Route│ │Exec │   │  │
                    │  │  └─────┘ └─────┘ └─────┘   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │    Notification Service     │  │
                    │  │  ┌─────┐ ┌─────┐ ┌─────┐   │  │
                    │  │  │Topic│ │ FCM │ │Store│   │  │
                    │  │  └─────┘ └─────┘ └─────┘   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌──────────┐  ┌──────────────┐  │
                    │  │PostgreSQL│  │    Redis     │  │
                    │  │  (Data)  │  │   (Cache)    │  │
                    │  └──────────┘  └──────────────┘  │
                    └─────────────────┬─────────────────┘
                                      │
                         ┌────────────┼────────────┐
                         │            │            │
                         ▼            ▼            ▼
                    ┌─────────┐ ┌─────────┐ ┌─────────┐
                    │Serverpod│ │   FCM   │ │WebSocket│
                    │ Client  │ │  Push   │ │ Stream  │
                    └─────────┘ └─────────┘ └─────────┘
                         │            │            │
                         └────────────┼────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │        Rmotly Mobile App         │
                    │            (Flutter)              │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │        Dashboard            │  │
                    │  │   [Btn] [Slider] [Toggle]   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │     Notification Center     │  │
                    │  │   [Topic 1] [Topic 2] ...   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │      Action Manager         │  │
                    │  │   [OpenAPI] [HTTP Config]   │  │
                    │  └─────────────────────────────┘  │
                    └───────────────────────────────────┘
```

## Data Flow

### 1. Control Event Flow (App → API → External)

```
User taps button     App sends event      API processes      Action executed
in dashboard    →    to Serverpod    →    and routes    →    (HTTP request)
     │                    │                   │                    │
     ▼                    ▼                   ▼                    ▼
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│ Control │─────────│  Event  │─────────│ Action  │─────────│ External│
│   UI    │         │ Payload │         │Executor │         │   API   │
└─────────┘         └─────────┘         └─────────┘         └─────────┘
```

### 2. Notification Flow (External → API → App)

```
External service    API receives       FCM dispatches     App displays
sends webhook  →    notification  →    to device     →    notification
     │                   │                  │                  │
     ▼                   ▼                  ▼                  ▼
┌─────────┐         ┌─────────┐        ┌─────────┐        ┌─────────┐
│ Webhook │─────────│ Process │────────│Firebase │────────│  Show   │
│ Request │         │ & Route │        │   FCM   │        │Notif UI │
└─────────┘         └─────────┘        └─────────┘        └─────────┘
```

## Core Entities

### Control

A user-defined UI element that triggers events.

```dart
class Control {
  String id;              // Unique identifier
  String name;            // Display name
  ControlType type;       // button, slider, toggle, input
  String actionId;        // Associated action to trigger
  Map<String, dynamic> config;  // Type-specific configuration
  int position;           // Dashboard position/order
}

enum ControlType {
  button,     // Simple tap → event
  toggle,     // On/off state → event with state
  slider,     // Range value → event with value
  input,      // Text input → event with text
  dropdown,   // Selection → event with selected value
}
```

### Action

An HTTP request definition, optionally built from OpenAPI spec.

```dart
class Action {
  String id;
  String name;
  String description;
  HttpMethod method;           // GET, POST, PUT, DELETE, PATCH
  String urlTemplate;          // URL with {{variable}} placeholders
  Map<String, String> headers; // Static headers
  String? bodyTemplate;        // JSON body with {{variable}} placeholders
  String? openApiSpecUrl;      // Source OpenAPI spec (if applicable)
  String? openApiOperationId;  // Operation ID from spec
  List<ActionParameter> parameters;  // Parameter definitions
}

class ActionParameter {
  String name;
  ParameterLocation location;  // path, query, header, body
  String type;                 // string, number, boolean
  bool required;
  dynamic defaultValue;
  String? description;
}
```

### NotificationTopic

A channel for receiving notifications from external sources.

```dart
class NotificationTopic {
  String id;
  String name;
  String description;
  String apiKey;              // For authenticating incoming notifications
  bool enabled;
  NotificationConfig config;  // Display configuration
}

class NotificationConfig {
  String titleTemplate;       // "{{title}}" or static text
  String bodyTemplate;        // "{{message}}" or static text
  String? imageUrlField;      // Field name for image URL in payload
  String? actionUrlField;     // Field name for action URL
  NotificationPriority priority;
  String? soundName;
  String? channelId;          // Android notification channel
}
```

### Event

An occurrence that flows through the system.

```dart
class Event {
  String id;
  String sourceType;          // 'control', 'webhook', 'scheduled'
  String sourceId;            // Control ID, webhook ID, etc.
  String eventType;           // 'button_press', 'value_change', etc.
  Map<String, dynamic> payload;
  DateTime timestamp;
  String? userId;
}
```

## API Endpoints

### Event Endpoints

```
POST   /api/events              Send event from app
GET    /api/events              List recent events (paginated)
GET    /api/events/:id          Get event details
DELETE /api/events/:id          Delete event
```

### Notification Endpoints

```
POST   /api/notify/:topicId     Send notification to topic (external use)
POST   /api/topics              Create notification topic
GET    /api/topics              List user's topics
GET    /api/topics/:id          Get topic details
PUT    /api/topics/:id          Update topic
DELETE /api/topics/:id          Delete topic
```

### Action Endpoints

```
POST   /api/actions             Create action
GET    /api/actions             List actions
GET    /api/actions/:id         Get action details
PUT    /api/actions/:id         Update action
DELETE /api/actions/:id         Delete action
POST   /api/actions/:id/test    Test action execution
POST   /api/actions/from-openapi  Create action from OpenAPI operation
```

### Control Endpoints

```
POST   /api/controls            Create control
GET    /api/controls            List controls
GET    /api/controls/:id        Get control details
PUT    /api/controls/:id        Update control
DELETE /api/controls/:id        Delete control
PUT    /api/controls/reorder    Reorder controls
```

### OpenAPI Endpoints

```
POST   /api/openapi/parse       Parse OpenAPI spec from URL
GET    /api/openapi/operations  List operations from parsed spec
```

## Notification API (External Compatibility)

The notification endpoint is designed for maximum compatibility:

### Basic Usage

```bash
POST /api/notify/{topicId}
Authorization: Bearer {topic_api_key}
Content-Type: application/json

{
  "title": "Alert",
  "message": "Something happened",
  "data": { "custom": "data" }
}
```

### Supported Patterns

#### 1. Simple JSON (Default)
```json
{
  "title": "Title",
  "message": "Body text"
}
```

#### 2. Firebase-style
```json
{
  "notification": {
    "title": "Title",
    "body": "Body text"
  },
  "data": {}
}
```

#### 3. Pushover-style
```json
{
  "title": "Title",
  "message": "Body",
  "priority": 1,
  "sound": "pushover"
}
```

#### 4. Ntfy-style
```json
{
  "topic": "ignored",
  "title": "Title",
  "message": "Body",
  "priority": 3,
  "tags": ["tag1"]
}
```

#### 5. Gotify-style
```json
{
  "title": "Title",
  "message": "Body",
  "priority": 5,
  "extras": {}
}
```

#### 6. Webhook/Generic
The API extracts `title`/`message` from common field names:
- `title`, `subject`, `name`, `header`
- `message`, `body`, `text`, `content`, `description`

## Security

### Authentication

- **App ↔ API**: Serverpod session-based auth with JWT tokens
- **External → API**: Per-topic API keys (Bearer tokens)
- **API → External**: Credentials stored per-action (encrypted)

### Authorization

- Users can only access their own controls, actions, topics
- Topic API keys are scoped to specific topics
- Action credentials are encrypted at rest

### Rate Limiting

- Notification endpoint: 100 requests/minute per topic
- Event endpoint: 1000 requests/minute per user
- OpenAPI parsing: 10 requests/minute per user

## Scalability Considerations

### Horizontal Scaling

- Stateless API servers behind load balancer
- Redis for session storage and caching
- PostgreSQL with read replicas

### Event Processing

- Optional Redis queue for high-volume event processing
- Async action execution with retry logic
- Dead letter queue for failed actions

### Caching Strategy

- Cache OpenAPI specs (24h TTL)
- Cache parsed action templates
- Cache topic configurations
