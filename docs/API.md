# Rmotly API Documentation

## Overview

The Rmotly API is built with Serverpod and provides endpoints for:
- Event management (sending/receiving events)
- Notification topics (creating and managing notification channels)
- Actions (defining and executing HTTP actions)
- Controls (managing dashboard controls)
- OpenAPI integration (parsing specs and creating actions)

## Base URL

```
Production: https://api.rmotly.app
Development: http://localhost:8080
```

## Authentication

Rmotly uses **Serverpod Authentication** for user account management. See [AUTHENTICATION.md](./AUTHENTICATION.md) for detailed documentation.

### App Authentication (Serverpod)

The Flutter app uses Serverpod's built-in authentication with JWT tokens.

#### Sign-Up Flow

**Step 1: Request Account Creation**

```dart
// Client initialization
final client = Client('https://api.rmotly.app/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// Request account creation
final success = await client.modules.auth.email.createAccountRequest(
  userName: 'john',
  email: 'john@example.com', 
  password: 'secure_password',
);

if (success) {
  // Verification code sent to email
  print('Check your email for verification code');
}
```

The server sends a verification code to the provided email address (in development, the code is printed to the console).

**Step 2: Verify Email and Create Account**

```dart
// User enters the verification code received via email
final userInfo = await client.modules.auth.email.createAccount(
  email: 'john@example.com',
  verificationCode: '123456',
);

if (userInfo != null) {
  print('Account created successfully! User ID: ${userInfo.id}');
  // Account is now active and user can sign in
}
```

#### Sign-In Flow

```dart
// Authenticate with email and password
final authResponse = await client.modules.auth.email.authenticate(
  email: 'john@example.com',
  password: 'secure_password',
);

if (authResponse.success) {
  // Authentication successful
  final userInfo = authResponse.userInfo;
  final authToken = authResponse.key;
  
  // Store authentication token for future requests
  await client.authenticationKeyManager?.put(authToken);
  
  print('Signed in as ${userInfo!.email}');
  print('User ID: ${userInfo.id}');
} else {
  print('Authentication failed');
}
```

#### Using Authentication in Requests

Once authenticated, the Serverpod client automatically includes the JWT token in all subsequent requests:

```dart
// All endpoint calls use the stored authentication token automatically
final topics = await client.notification.listTopics();
final actions = await client.action.listActions(userId: userInfo.id);
```

The authentication token is sent in the `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

#### Session Management

```dart
// Check if user is currently authenticated
final isSignedIn = await client.sessionManager.isSignedIn();

if (isSignedIn) {
  // Get current user information
  final userInfo = await client.modules.auth.getUserInfo();
  print('Current user: ${userInfo?.email}');
}

// Refresh authentication status
await client.sessionManager.registerSignedInListener(
  (authenticated) {
    if (authenticated) {
      print('User signed in');
    } else {
      print('User signed out');
    }
  },
);
```

#### Token Refresh

Serverpod automatically handles token refresh when needed. If a token expires, the client will:
1. Attempt to refresh using the stored refresh token
2. If refresh fails, trigger sign-out
3. Notify listeners via `registerSignedInListener`

#### Sign-Out

```dart
// Sign out and invalidate the current session
await client.modules.auth.signOut();

// Clear local authentication state
await client.authenticationKeyManager?.remove();
```

#### Password Reset

```dart
// Step 1: Request password reset
final success = await client.modules.auth.email.initiatePasswordReset(
  email: 'john@example.com',
);

if (success) {
  print('Reset code sent to email');
}

// Step 2: Reset password with verification code
final resetSuccess = await client.modules.auth.email.resetPassword(
  verificationCode: '123456',
  password: 'new_secure_password',
);

if (resetSuccess) {
  print('Password reset successful');
  // User can now sign in with new password
}
```

### External API Authentication

External services (webhooks) use API keys instead of JWT tokens. Each notification topic has a unique API key.

#### Using API Keys in Webhooks

API keys are sent in the `X-API-Key` header:

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmotly_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Alert",
    "message": "Hello from external service!"
  }'
```

#### Obtaining API Keys

API keys are generated when creating a notification topic:

```dart
final topic = await client.notification.createTopic(
  name: 'Server Alerts',
  description: 'Monitoring notifications',
);

print('API Key: ${topic.apiKey}');
print('Webhook URL: https://api.rmotly.app/api/notify/${topic.id}');
```

Store the API key securely - it cannot be retrieved later. If lost, regenerate it using the `regenerateApiKey` endpoint.

#### API Key Security

- **Keep API keys secret** - They grant access to send notifications to your topics
- **Use HTTPS** - Always send API keys over encrypted connections
- **Regenerate if compromised** - Use the regenerate endpoint if a key is exposed
- **One key per topic** - Each topic has its own unique API key
- **No expiration** - API keys remain valid until regenerated or the topic is deleted

### Authentication vs Authorization

| Authentication Type | Use Case | Header | Scope |
|---------------------|----------|--------|-------|
| **JWT Token** (Serverpod Auth) | Flutter app requests | `Authorization: Bearer <jwt_token>` | Full user access to all owned resources |
| **API Key** | External webhook requests | `X-API-Key: <topic_api_key>` | Limited to specific topic only |

## Endpoints

---

### Events

Events track user interactions with controls, webhook triggers, and system actions. Each event can trigger an associated action and logs the result.

#### Send Event

Create an event from a control interaction or external source, process any associated action, and log the result.

**Endpoint:**
```
POST /event/sendEvent
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sourceType | string | Yes | Event source: `control`, `webhook`, or `system` |
| sourceId | string | Yes | Identifier of the source (control ID, topic ID, etc.) |
| eventType | string | Yes | Type of event: `button_press`, `toggle_change`, `slider_change`, etc. |
| payload | string | No | Optional event payload as JSON string |

**Request Example:**

```dart
final event = await client.event.sendEvent(
  sourceType: 'control',
  sourceId: 'ctrl_abc123',
  eventType: 'button_press',
  payload: jsonEncode({
    'value': true,
    'timestamp': DateTime.now().toIso8601String(),
  }),
);
```

**Success Response:**

```dart
Event {
  id: 42,
  userId: 1,
  sourceType: 'control',
  sourceId: 'ctrl_abc123',
  eventType: 'button_press',
  payload: '{"value":true,"timestamp":"2025-01-14T10:30:00Z"}',
  actionResult: '{"statusCode":200,"success":true,"responseBody":"OK"}',
  timestamp: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated

// Throws ArgumentError if validation fails
ArgumentError: Invalid sourceType. Must be one of: control, webhook, system
```

#### List Events

List events for the authenticated user with pagination and filtering.

**Endpoint:**
```
POST /event/listEvents
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | int | No | 50 | Maximum number of events to return (1-100) |
| offset | int | No | 0 | Number of events to skip for pagination |
| sourceType | string | No | null | Filter by source type |
| eventType | string | No | null | Filter by event type |
| since | DateTime | No | null | Filter for events after this timestamp |

**Request Example:**

```dart
// List recent button press events
final events = await client.event.listEvents(
  limit: 20,
  offset: 0,
  sourceType: 'control',
  eventType: 'button_press',
  since: DateTime.now().subtract(Duration(days: 7)),
);
```

**Success Response:**

```dart
[
  Event {
    id: 42,
    userId: 1,
    sourceType: 'control',
    sourceId: 'ctrl_abc123',
    eventType: 'button_press',
    payload: '{"value":true}',
    actionResult: '{"statusCode":200,"success":true}',
    timestamp: DateTime(2025, 1, 14, 10, 30, 0),
  },
  Event {
    id: 41,
    userId: 1,
    sourceType: 'control',
    sourceId: 'ctrl_def456',
    eventType: 'button_press',
    payload: '{"value":false}',
    actionResult: '{"statusCode":200,"success":true}',
    timestamp: DateTime(2025, 1, 14, 10, 15, 0),
  },
  // ... more events
]
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Get Event

Get a specific event by ID.

**Endpoint:**
```
POST /event/getEvent
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| eventId | int | Yes | The ID of the event to retrieve |

**Request Example:**

```dart
final event = await client.event.getEvent(eventId: 42);
```

**Success Response:**

```dart
Event {
  id: 42,
  userId: 1,
  sourceType: 'control',
  sourceId: 'ctrl_abc123',
  eventType: 'button_press',
  payload: '{"value":true}',
  actionResult: '{"statusCode":200,"success":true,"responseBody":"OK"}',
  timestamp: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if event not found or not owned by user
ArgumentError: Event not found: 42

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Delete Event

Delete an event by ID.

**Endpoint:**
```
POST /event/deleteEvent
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| eventId | int | Yes | The ID of the event to delete |

**Request Example:**

```dart
final deleted = await client.event.deleteEvent(eventId: 42);
if (deleted) {
  print('Event deleted successfully');
}
```

**Success Response:**

```dart
true  // Event was deleted
false // Event not found or not owned by user
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Get Event Counts

Get event counts by source type for dashboard statistics.

**Endpoint:**
```
POST /event/getEventCounts
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| since | DateTime | No | Optional filter for events after this timestamp |

**Request Example:**

```dart
// Get event counts for the last 30 days
final counts = await client.event.getEventCounts(
  since: DateTime.now().subtract(Duration(days: 30)),
);
```

**Success Response:**

```dart
{
  'control': 150,
  'webhook': 42,
  'system': 8,
}
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

---

### Notifications

#### Send Notification (External)

Send a notification to a topic. Designed for maximum compatibility.

```
POST /api/notify/{topicId}
Authorization: Bearer {topic_api_key}
```

**Simple Format:**
```json
{
  "title": "Alert Title",
  "message": "This is the notification body"
}
```

**Extended Format:**
```json
{
  "title": "Alert Title",
  "message": "This is the notification body",
  "data": {
    "orderId": "12345",
    "action": "view_order"
  },
  "priority": "high",
  "image": "https://example.com/image.png",
  "actionUrl": "rmotly://orders/12345"
}
```

**Response:**
```json
{
  "success": true,
  "notificationId": "notif_abc123",
  "delivered": true
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "INVALID_API_KEY",
  "message": "The provided API key is invalid or expired"
}
```

#### Create Topic

Create a new notification topic with a unique API key.

**Endpoint:**
```
POST /notification/createTopic
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | Yes | Display name for the topic |
| description | string | No | Optional description |
| config | string | No | Optional configuration as JSON string |

**Request Example:**

```dart
final topic = await client.notification.createTopic(
  name: 'Order Alerts',
  description: 'Notifications for new orders',
  config: jsonEncode({
    'titleTemplate': '{{title}}',
    'bodyTemplate': '{{message}}',
    'priority': 'high',
    'channelId': 'orders'
  }),
);

print('API Key: ${topic.apiKey}');
print('Webhook URL: https://api.rmotly.app/api/notify/${topic.id}');
```

**Success Response:**

```dart
NotificationTopic {
  id: 123,
  userId: 1,
  name: 'Order Alerts',
  description: 'Notifications for new orders',
  apiKey: 'rmotly_xxxxxxxxxxxxxxxxxxxxxxxx',
  enabled: true,
  config: '{"titleTemplate":"{{title}}","bodyTemplate":"{{message}}"}',
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: name cannot be empty

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### List Topics

List all notification topics for the authenticated user.

**Endpoint:**
```
POST /notification/listTopics
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| includeDisabled | bool | No | false | Include disabled topics in results |

**Request Example:**

```dart
// List only enabled topics
final topics = await client.notification.listTopics();

// List all topics including disabled ones
final allTopics = await client.notification.listTopics(
  includeDisabled: true,
);
```

**Success Response:**

```dart
[
  NotificationTopic {
    id: 123,
    userId: 1,
    name: 'Order Alerts',
    description: 'Notifications for new orders',
    apiKey: 'rmotly_xxxxxxxxxxxxxxxxxxxxxxxx',
    enabled: true,
    config: '{}',
    createdAt: DateTime(2025, 1, 14, 10, 30, 0),
    updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
  },
  NotificationTopic {
    id: 124,
    userId: 1,
    name: 'Server Monitoring',
    description: 'Server health alerts',
    apiKey: 'rmotly_yyyyyyyyyyyyyyyyyyyyyyyy',
    enabled: true,
    config: '{}',
    createdAt: DateTime(2025, 1, 13, 15, 20, 0),
    updatedAt: DateTime(2025, 1, 13, 15, 20, 0),
  },
]
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Get Topic

Get a specific notification topic by ID.

**Endpoint:**
```
POST /notification/getTopic
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | The ID of the topic to retrieve |

**Request Example:**

```dart
final topic = await client.notification.getTopic(topicId: 123);
```

**Success Response:**

```dart
NotificationTopic {
  id: 123,
  userId: 1,
  name: 'Order Alerts',
  description: 'Notifications for new orders',
  apiKey: 'rmotly_xxxxxxxxxxxxxxxxxxxxxxxx',
  enabled: true,
  config: '{"titleTemplate":"{{title}}"}',
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if topic not found or not owned by user
ArgumentError: Topic not found: 123

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Update Topic

Update an existing notification topic.

**Endpoint:**
```
POST /notification/updateTopic
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | The ID of the topic to update |
| name | string | No | New name |
| description | string | No | New description (use empty string to clear) |
| enabled | bool | No | New enabled state |
| config | string | No | New configuration as JSON string |

**Request Example:**

```dart
final updatedTopic = await client.notification.updateTopic(
  topicId: 123,
  name: 'Updated Order Alerts',
  description: 'New description',
  enabled: false,
);
```

**Success Response:**

```dart
NotificationTopic {
  id: 123,
  userId: 1,
  name: 'Updated Order Alerts',
  description: 'New description',
  apiKey: 'rmotly_xxxxxxxxxxxxxxxxxxxxxxxx', // Unchanged
  enabled: false,
  config: '{"titleTemplate":"{{title}}"}',
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 11, 45, 0), // Updated timestamp
}
```

**Error Response:**

```dart
// Throws ArgumentError if topic not found or validation fails
ArgumentError: Topic not found: 123
ArgumentError: name cannot be empty

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Delete Topic

Delete a notification topic permanently.

**Endpoint:**
```
POST /notification/deleteTopic
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | The ID of the topic to delete |

**Request Example:**

```dart
final deleted = await client.notification.deleteTopic(topicId: 123);
if (deleted) {
  print('Topic deleted successfully');
}
```

**Success Response:**

```dart
true  // Topic was deleted
false // Topic not found or not owned by user
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Regenerate API Key

Regenerate the API key for a topic. The old API key will immediately stop working.

**Endpoint:**
```
POST /notification/regenerateApiKey
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | The ID of the topic |

**Request Example:**

```dart
final topic = await client.notification.regenerateApiKey(topicId: 123);
print('New API Key: ${topic.apiKey}');
// Old API key is now invalid
```

**Success Response:**

```dart
NotificationTopic {
  id: 123,
  userId: 1,
  name: 'Order Alerts',
  description: 'Notifications for new orders',
  apiKey: 'rmotly_zzzzzzzzzzzzzzzzzzzzzzzz', // New API key
  enabled: true,
  config: '{}',
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 12, 00, 0), // Updated timestamp
}
```

**Error Response:**

```dart
// Throws ArgumentError if topic not found or not owned by user
ArgumentError: Topic not found: 123

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Send Notification (Internal)

Send a notification to a specific user (internal use). External notifications should use the webhook endpoint.

**Endpoint:**
```
POST /notification/sendNotification
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | string | Yes | - | Notification title |
| body | string | Yes | - | Notification body |
| payload | string | No | null | Optional additional data as JSON string |
| priority | string | No | 'normal' | Priority: `low`, `normal`, `high`, `urgent` |

**Request Example:**

```dart
final sent = await client.notification.sendNotification(
  title: 'System Alert',
  body: 'Your backup completed successfully',
  payload: jsonEncode({
    'backupId': '12345',
    'size': '2.3GB',
  }),
  priority: 'high',
);

if (sent) {
  print('Notification queued for delivery');
}
```

**Success Response:**

```dart
true  // Notification was queued for delivery
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: priority must be one of: low, normal, high, urgent

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

---

### Actions

Actions are HTTP request templates that can be triggered by controls or events. They support variable substitution for dynamic requests.

#### Create Action

Create an HTTP action template with template variables.

**Endpoint:**
```
POST /action/createAction
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user creating the action |
| name | string | Yes | Display name for the action |
| httpMethod | string | Yes | HTTP method: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD` |
| urlTemplate | string | Yes | URL template with `{{variable}}` placeholders |
| description | string | No | Optional description of what the action does |
| headersTemplate | string | No | Optional headers template as JSON string |
| bodyTemplate | string | No | Optional body template with `{{variable}}` placeholders |
| parameters | string | No | Optional parameters definition as JSON string |

**Request Example:**

```dart
final action = await client.action.createAction(
  userId: 1,
  name: 'Toggle Living Room Light',
  description: 'Toggles the living room light via Home Assistant',
  httpMethod: 'POST',
  urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
  headersTemplate: jsonEncode({
    'Authorization': 'Bearer {{ha_token}}',
    'Content-Type': 'application/json',
  }),
  bodyTemplate: '{"entity_id": "light.living_room"}',
  parameters: jsonEncode([
    {
      'name': 'ha_token',
      'location': 'header',
      'type': 'string',
      'required': true,
      'description': 'Home Assistant long-lived access token',
    }
  ]),
);
```

**Success Response:**

```dart
Action {
  id: 456,
  userId: 1,
  name: 'Toggle Living Room Light',
  description: 'Toggles the living room light via Home Assistant',
  httpMethod: 'POST',
  urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
  headersTemplate: '{"Authorization":"Bearer {{ha_token}}","Content-Type":"application/json"}',
  bodyTemplate: '{"entity_id": "light.living_room"}',
  parameters: '[{"name":"ha_token","location":"header","type":"string","required":true}]',
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: name cannot be empty
ArgumentError: urlTemplate cannot be empty
ArgumentError: httpMethod must be one of: GET, POST, PUT, DELETE, PATCH, HEAD
ArgumentError: Invalid URL template: FormatException: Invalid URL
ArgumentError: headersTemplate must be valid JSON: FormatException
ArgumentError: parameters must be valid JSON: FormatException
```

#### List Actions

List all actions for a user, ordered by creation date (newest first).

**Endpoint:**
```
POST /action/listActions
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose actions to list |

**Request Example:**

```dart
final actions = await client.action.listActions(userId: 1);
```

**Success Response:**

```dart
[
  Action {
    id: 456,
    userId: 1,
    name: 'Toggle Living Room Light',
    description: 'Toggles the living room light',
    httpMethod: 'POST',
    urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
    headersTemplate: '{"Authorization":"Bearer {{ha_token}}"}',
    bodyTemplate: '{"entity_id": "light.living_room"}',
    parameters: null,
    createdAt: DateTime(2025, 1, 14, 10, 30, 0),
    updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
  },
  Action {
    id: 455,
    userId: 1,
    name: 'Get Weather',
    description: 'Fetch current weather data',
    httpMethod: 'GET',
    urlTemplate: 'https://api.weather.com/v3/wx/conditions/current?apiKey={{api_key}}&location={{location}}',
    headersTemplate: null,
    bodyTemplate: null,
    parameters: null,
    createdAt: DateTime(2025, 1, 13, 15, 20, 0),
    updatedAt: DateTime(2025, 1, 13, 15, 20, 0),
  },
]
```

#### Get Action

Get a single action by ID.

**Endpoint:**
```
POST /action/getAction
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to retrieve |

**Request Example:**

```dart
final action = await client.action.getAction(actionId: 456);
```

**Success Response:**

```dart
Action {
  id: 456,
  userId: 1,
  name: 'Toggle Living Room Light',
  description: 'Toggles the living room light',
  httpMethod: 'POST',
  urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
  headersTemplate: '{"Authorization":"Bearer {{ha_token}}"}',
  bodyTemplate: '{"entity_id": "light.living_room"}',
  parameters: null,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

Returns `null` if action not found.

#### Update Action

Update an action's fields. All fields are optional except actionId. Only provided fields will be updated.

**Endpoint:**
```
POST /action/updateAction
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to update |
| name | string | No | New display name |
| description | string | No | New description |
| httpMethod | string | No | New HTTP method |
| urlTemplate | string | No | New URL template |
| headersTemplate | string | No | New headers template |
| bodyTemplate | string | No | New body template |
| parameters | string | No | New parameters definition |
| clearDescription | bool | No | Set to true to clear description |
| clearHeadersTemplate | bool | No | Set to true to clear headers |
| clearBodyTemplate | bool | No | Set to true to clear body |
| clearParameters | bool | No | Set to true to clear parameters |

**Request Example:**

```dart
// Update name and description
final updated = await client.action.updateAction(
  actionId: 456,
  name: 'Toggle Light (Updated)',
  description: 'Updated description',
);

// Clear optional fields
final cleared = await client.action.updateAction(
  actionId: 456,
  clearDescription: true,
  clearBodyTemplate: true,
);
```

**Success Response:**

```dart
Action {
  id: 456,
  userId: 1,
  name: 'Toggle Light (Updated)',
  description: 'Updated description',
  httpMethod: 'POST',
  urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
  headersTemplate: '{"Authorization":"Bearer {{ha_token}}"}',
  bodyTemplate: '{"entity_id": "light.living_room"}',
  parameters: null,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 11, 45, 0), // Updated timestamp
}
```

**Error Response:**

```dart
// Throws ArgumentError if action not found or validation fails
ArgumentError: Action with ID 456 not found
ArgumentError: name cannot be empty
ArgumentError: httpMethod must be one of: GET, POST, PUT, DELETE, PATCH, HEAD
ArgumentError: Invalid URL template: FormatException
```

#### Delete Action

Permanently delete an action from the database. Note: This will leave any associated controls without an action.

**Endpoint:**
```
POST /action/deleteAction
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to delete |

**Request Example:**

```dart
final deleted = await client.action.deleteAction(actionId: 456);
if (deleted) {
  print('Action deleted successfully');
}
```

**Success Response:**

```dart
true  // Action was deleted
false // Action not found
```

#### Test Action

Execute an action with test parameters and return the execution result. This performs the actual HTTP request.

**Endpoint:**
```
POST /action/testAction
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to test |
| testParameters | Map<String, dynamic> | Yes | Parameters to use for template substitution |

**Request Example:**

```dart
final result = await client.action.testAction(
  actionId: 456,
  testParameters: {
    'ha_token': 'your_home_assistant_token_here',
  },
);

print('Success: ${result['success']}');
print('Status Code: ${result['statusCode']}');
print('Response: ${result['responseBody']}');
print('Execution Time: ${result['executionTimeMs']}ms');
```

**Success Response:**

```dart
{
  'success': true,
  'statusCode': 200,
  'responseBody': '{"result": "ok", "entity_id": "light.living_room"}',
  'responseHeaders': {
    'content-type': 'application/json',
    'content-length': '45',
  },
  'executionTimeMs': 234,
}
```

**Error Response:**

```dart
{
  'success': false,
  'statusCode': null,
  'responseBody': null,
  'responseHeaders': null,
  'executionTimeMs': 0,
  'error': 'Connection timeout',
}

// Throws ArgumentError if action not found
ArgumentError: Action with ID 456 not found
```

---

### Controls

Controls are UI elements on the dashboard that can trigger actions. They support various types like buttons, toggles, sliders, inputs, and dropdowns.

#### Create Control

Create a control that can trigger actions from the dashboard.

**Endpoint:**
```
POST /control/createControl
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user creating the control |
| name | string | Yes | Display name for the control |
| controlType | string | Yes | Type: `button`, `toggle`, `slider`, `input`, `dropdown` |
| config | string | Yes | Control configuration as JSON string |
| position | int | Yes | Position/order in the dashboard (0+) |
| actionId | int | No | Optional ID of the action to trigger |

**Request Example:**

```dart
final control = await client.control.createControl(
  userId: 1,
  name: 'Living Room Light',
  controlType: 'toggle',
  config: jsonEncode({
    'onLabel': 'On',
    'offLabel': 'Off',
    'icon': 'lightbulb',
    'color': '#FFC107',
  }),
  position: 0,
  actionId: 456,
);
```

**Success Response:**

```dart
Control {
  id: 789,
  userId: 1,
  name: 'Living Room Light',
  controlType: 'toggle',
  config: '{"onLabel":"On","offLabel":"Off","icon":"lightbulb","color":"#FFC107"}',
  position: 0,
  actionId: 456,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: name cannot be empty
ArgumentError: controlType cannot be empty
ArgumentError: controlType must be one of: button, toggle, slider, input, dropdown
ArgumentError: config must be valid JSON: FormatException
ArgumentError: position must be non-negative
ArgumentError: Action with ID 456 not found
ArgumentError: Action does not belong to the specified user
```

#### List Controls

List all controls for a user, ordered by position.

**Endpoint:**
```
POST /control/listControls
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose controls to list |

**Request Example:**

```dart
final controls = await client.control.listControls(userId: 1);
```

**Success Response:**

```dart
[
  Control {
    id: 789,
    userId: 1,
    name: 'Living Room Light',
    controlType: 'toggle',
    config: '{"onLabel":"On","offLabel":"Off","icon":"lightbulb"}',
    position: 0,
    actionId: 456,
    createdAt: DateTime(2025, 1, 14, 10, 30, 0),
    updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
  },
  Control {
    id: 790,
    userId: 1,
    name: 'Bedroom Fan',
    controlType: 'slider',
    config: '{"min":0,"max":100,"step":10,"unit":"%"}',
    position: 1,
    actionId: 457,
    createdAt: DateTime(2025, 1, 13, 15, 20, 0),
    updatedAt: DateTime(2025, 1, 13, 15, 20, 0),
  },
]
```

#### Get Control

Get a single control by ID.

**Endpoint:**
```
POST /control/getControl
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to retrieve |

**Request Example:**

```dart
final control = await client.control.getControl(controlId: 789);
```

**Success Response:**

```dart
Control {
  id: 789,
  userId: 1,
  name: 'Living Room Light',
  controlType: 'toggle',
  config: '{"onLabel":"On","offLabel":"Off","icon":"lightbulb"}',
  position: 0,
  actionId: 456,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

Returns `null` if control not found.

#### Update Control

Update a control's fields. All fields are optional except controlId. Only provided fields will be updated.

**Endpoint:**
```
POST /control/updateControl
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to update |
| name | string | No | New display name |
| controlType | string | No | New control type |
| config | string | No | New configuration JSON |
| position | int | No | New position |
| actionId | int | No | New action ID |
| clearActionId | bool | No | Set to true to remove action association |

**Request Example:**

```dart
// Update name and config
final updated = await client.control.updateControl(
  controlId: 789,
  name: 'Living Room Light (Updated)',
  config: jsonEncode({
    'onLabel': 'Turn On',
    'offLabel': 'Turn Off',
    'icon': 'lightbulb',
  }),
);

// Remove action association
final cleared = await client.control.updateControl(
  controlId: 789,
  clearActionId: true,
);
```

**Success Response:**

```dart
Control {
  id: 789,
  userId: 1,
  name: 'Living Room Light (Updated)',
  controlType: 'toggle',
  config: '{"onLabel":"Turn On","offLabel":"Turn Off","icon":"lightbulb"}',
  position: 0,
  actionId: 456,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 11, 45, 0), // Updated timestamp
}
```

**Error Response:**

```dart
// Throws ArgumentError if control not found or validation fails
ArgumentError: Control with ID 789 not found
ArgumentError: name cannot be empty
ArgumentError: controlType must be one of: button, toggle, slider, input, dropdown
ArgumentError: config must be valid JSON: FormatException
ArgumentError: position must be non-negative
ArgumentError: Action with ID 456 not found
ArgumentError: Action does not belong to the same user
```

#### Delete Control

Permanently delete a control from the database.

**Endpoint:**
```
POST /control/deleteControl
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to delete |

**Request Example:**

```dart
final deleted = await client.control.deleteControl(controlId: 789);
if (deleted) {
  print('Control deleted successfully');
}
```

**Success Response:**

```dart
true  // Control was deleted
false // Control not found
```

#### Reorder Controls

Update the position field for multiple controls at once. This is useful for drag-and-drop reordering in the UI.

**Endpoint:**
```
POST /control/reorderControls
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose controls to reorder |
| controlPositions | Map<int, int> | Yes | Map of control ID to new position |

**Request Example:**

```dart
// Reorder controls: move control 789 to position 2, control 790 to position 0
final reordered = await client.control.reorderControls(
  userId: 1,
  controlPositions: {
    789: 2,  // Living Room Light to position 2
    790: 0,  // Bedroom Fan to position 0
    791: 1,  // Kitchen Light to position 1
  },
);

// Returns all controls in new order
for (final control in reordered) {
  print('${control.name} is at position ${control.position}');
}
```

**Success Response:**

```dart
[
  Control {
    id: 790,
    userId: 1,
    name: 'Bedroom Fan',
    controlType: 'slider',
    config: '{"min":0,"max":100}',
    position: 0, // Updated position
    actionId: 457,
    createdAt: DateTime(2025, 1, 13, 15, 20, 0),
    updatedAt: DateTime(2025, 1, 14, 11, 50, 0), // Updated timestamp
  },
  Control {
    id: 791,
    userId: 1,
    name: 'Kitchen Light',
    controlType: 'button',
    config: '{"label":"Toggle"}',
    position: 1, // Updated position
    actionId: 458,
    createdAt: DateTime(2025, 1, 12, 09, 00, 0),
    updatedAt: DateTime(2025, 1, 14, 11, 50, 0), // Updated timestamp
  },
  Control {
    id: 789,
    userId: 1,
    name: 'Living Room Light',
    controlType: 'toggle',
    config: '{"onLabel":"On","offLabel":"Off"}',
    position: 2, // Updated position
    actionId: 456,
    createdAt: DateTime(2025, 1, 14, 10, 30, 0),
    updatedAt: DateTime(2025, 1, 14, 11, 50, 0), // Updated timestamp
  },
]
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: controlPositions cannot be empty
ArgumentError: All positions must be non-negative
ArgumentError: Control with ID 789 not found
ArgumentError: Control 789 does not belong to user 1
```

---

### OpenAPI

The OpenAPI endpoints allow parsing OpenAPI/Swagger specifications to extract API operations for creating actions.

#### Parse OpenAPI Spec

Fetch and parse an OpenAPI specification from a URL. Supports OpenAPI 3.0, 3.1, and Swagger 2.0 in JSON format.

**Endpoint:**
```
POST /openApi/parseSpec
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | The URL of the OpenAPI specification (JSON format) |

**Request Example:**

```dart
final spec = await client.openApi.parseSpec(
  'https://api.example.com/openapi.json',
);

print('API: ${spec.title} v${spec.version}');
print('Base URL: ${spec.baseUrl}');
print('Found ${spec.operations.length} operations');
```

**Success Response:**

```dart
OpenApiSpec {
  title: 'Example API',
  version: '1.0.0',
  description: 'Example API for demonstration',
  baseUrl: 'https://api.example.com',
  specVersion: '3.0.0',
  operations: [
    OpenApiOperation {
      operationId: 'getUsers',
      method: 'GET',
      path: '/users',
      summary: 'List all users',
      description: 'Returns a list of all users in the system',
      parameters: [],
      tags: ['users'],
    },
    OpenApiOperation {
      operationId: 'createUser',
      method: 'POST',
      path: '/users',
      summary: 'Create a user',
      description: 'Creates a new user with the provided data',
      parameters: [
        OpenApiParameter {
          name: 'name',
          location: 'body',
          description: 'User name',
          required: true,
          type: 'string',
          format: null,
        },
        OpenApiParameter {
          name: 'email',
          location: 'body',
          description: 'User email address',
          required: true,
          type: 'string',
          format: 'email',
        },
      ],
      tags: ['users'],
    },
  ],
}
```

**Error Response:**

```dart
// Throws OpenApiParseException if parsing fails
OpenApiParseException: Failed to fetch spec from URL
OpenApiParseException: Invalid OpenAPI specification format
OpenApiParseException: Unsupported OpenAPI version
```

#### List Operations

Fetch an OpenAPI specification and return all operations/endpoints defined in it.

**Endpoint:**
```
POST /openApi/listOperations
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| specUrl | string | Yes | The URL of the OpenAPI specification |

**Request Example:**

```dart
final operations = await client.openApi.listOperations(
  'https://api.example.com/openapi.json',
);

for (final op in operations) {
  print('${op.method} ${op.path} - ${op.summary}');
}
```

**Success Response:**

```dart
[
  OpenApiOperation {
    operationId: 'getUsers',
    method: 'GET',
    path: '/users',
    summary: 'List all users',
    description: 'Returns a list of all users',
    parameters: [
      OpenApiParameter {
        name: 'limit',
        location: 'query',
        description: 'Maximum number of results',
        required: false,
        type: 'integer',
        format: 'int32',
      },
    ],
    tags: ['users'],
  },
  OpenApiOperation {
    operationId: 'getUserById',
    method: 'GET',
    path: '/users/{userId}',
    summary: 'Get user by ID',
    description: 'Returns a single user',
    parameters: [
      OpenApiParameter {
        name: 'userId',
        location: 'path',
        description: 'User ID',
        required: true,
        type: 'string',
        format: null,
      },
    ],
    tags: ['users'],
  },
]
```

**Error Response:**

```dart
// Throws OpenApiParseException if parsing fails
OpenApiParseException: Failed to fetch spec from URL
OpenApiParseException: Invalid OpenAPI specification
```

---

### Push Subscriptions

Push subscription endpoints manage UnifiedPush/WebPush registrations for real-time notification delivery to devices.

#### Register Endpoint

Register a UnifiedPush endpoint URL for push notifications.

**Endpoint:**
```
POST /pushSubscription/registerEndpoint
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| endpoint | string | Yes | The push endpoint URL from UnifiedPush distributor |
| p256dh | string | No | P-256 public key for WebPush encryption (base64url) |
| authSecret | string | No | Authentication secret for WebPush (base64url) |
| subscriptionType | string | Yes | Subscription type: `unifiedpush` or `webpush` |
| deviceId | string | Yes | Unique identifier for the device |
| userAgent | string | No | Optional user agent string |

**Request Example:**

```dart
final subscription = await client.pushSubscription.registerEndpoint(
  endpoint: 'https://ntfy.sh/ABC123DEF456',
  subscriptionType: 'unifiedpush',
  deviceId: 'device_12345',
  userAgent: 'Rmotly/1.0 Android/13',
);

print('Subscription ID: ${subscription.id}');
```

**Success Response:**

```dart
PushSubscription {
  id: 1,
  userId: 1,
  endpoint: 'https://ntfy.sh/ABC123DEF456',
  p256dh: null,
  authSecret: null,
  subscriptionType: 'unifiedpush',
  deviceId: 'device_12345',
  userAgent: 'Rmotly/1.0 Android/13',
  active: true,
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
}
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: Endpoint cannot be empty
ArgumentError: Endpoint must be a valid HTTP(S) URL
ArgumentError: Device ID cannot be empty

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Unregister Endpoint

Remove a device's endpoint from user subscriptions.

**Endpoint:**
```
POST /pushSubscription/unregisterEndpoint
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| deviceId | string | Yes | The device ID to unregister |

**Request Example:**

```dart
final success = await client.pushSubscription.unregisterEndpoint('device_12345');
if (success) {
  print('Device unregistered successfully');
}
```

**Success Response:**

```dart
true  // Endpoint was unregistered
false // Endpoint not found for this user
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: Device ID cannot be empty

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### List Subscriptions

List all push subscriptions for the authenticated user.

**Endpoint:**
```
POST /pushSubscription/listSubscriptions
```

**Authentication:** Required (JWT)

**Request Example:**

```dart
final subscriptions = await client.pushSubscription.listSubscriptions();
for (final sub in subscriptions) {
  print('Device: ${sub.deviceId} - Active: ${sub.active}');
}
```

**Success Response:**

```dart
[
  PushSubscription {
    id: 1,
    userId: 1,
    endpoint: 'https://ntfy.sh/ABC123DEF456',
    p256dh: null,
    authSecret: null,
    subscriptionType: 'unifiedpush',
    deviceId: 'device_12345',
    userAgent: 'Rmotly/1.0 Android/13',
    active: true,
    createdAt: DateTime(2025, 1, 14, 10, 30, 0),
    updatedAt: DateTime(2025, 1, 14, 10, 30, 0),
  },
  PushSubscription {
    id: 2,
    userId: 1,
    endpoint: 'https://fcm.googleapis.com/fcm/send/xyz789',
    p256dh: 'base64-public-key',
    authSecret: 'base64-auth-secret',
    subscriptionType: 'webpush',
    deviceId: 'device_67890',
    userAgent: 'Rmotly/1.0 iOS/16',
    active: true,
    createdAt: DateTime(2025, 1, 13, 15, 20, 0),
    updatedAt: DateTime(2025, 1, 13, 15, 20, 0),
  },
]
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Update Subscription

Toggle a subscription active/inactive without removing it.

**Endpoint:**
```
POST /pushSubscription/updateSubscription
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| subscriptionId | int | Yes | The ID of the subscription to update |
| active | bool | No | Whether the subscription should be active |

**Request Example:**

```dart
// Disable a subscription temporarily
final updated = await client.pushSubscription.updateSubscription(
  1,
  active: false,
);

print('Subscription ${updated.id} is now ${updated.active ? "active" : "inactive"}');
```

**Success Response:**

```dart
PushSubscription {
  id: 1,
  userId: 1,
  endpoint: 'https://ntfy.sh/ABC123DEF456',
  p256dh: null,
  authSecret: null,
  subscriptionType: 'unifiedpush',
  deviceId: 'device_12345',
  userAgent: 'Rmotly/1.0 Android/13',
  active: false, // Updated
  createdAt: DateTime(2025, 1, 14, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 14, 12, 00, 0), // Updated timestamp
}
```

**Error Response:**

```dart
// Throws ArgumentError if validation fails
ArgumentError: At least one parameter must be provided to update

// Throws StateError if subscription not found or not owned by user
StateError: Subscription not found: 1

// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

---

### Notification Streaming

Real-time notification delivery via WebSocket (Tier 1 delivery).

#### Stream Notifications

Establish a WebSocket connection to receive notifications in real-time.

**Endpoint:**
```
POST /notificationStream/streamNotifications
```

**Authentication:** Required (JWT)

**Usage:**

```dart
// Subscribe to notification stream
final stream = client.notificationStream.streamNotifications();

// Listen for notifications
await for (final notification in stream) {
  print('Received: ${notification.title}');
  print('Body: ${notification.body}');
  print('Priority: ${notification.priority}');
  
  if (notification.data != null) {
    final data = jsonDecode(notification.data!);
    print('Data: $data');
  }
}
```

**Stream Data:**

```dart
StreamNotification {
  id: '1705234200000',
  title: 'New Order',
  body: 'Order #12345 received',
  data: '{"orderId":"12345","amount":99.99}',
  priority: 'high',
  timestamp: DateTime(2025, 1, 14, 10, 30, 0),
}
```

The stream remains open until the client disconnects or the server closes the connection.

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Get Connection Count

Get the number of active WebSocket connections for the authenticated user.

**Endpoint:**
```
POST /notificationStream/getConnectionCount
```

**Authentication:** Required (JWT)

**Request Example:**

```dart
final count = await client.notificationStream.getConnectionCount();
print('Active connections: $count');
```

**Success Response:**

```dart
2  // Number of active WebSocket connections
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

#### Send Test Notification

Send a test notification to the authenticated user to verify the stream is working.

**Endpoint:**
```
POST /notificationStream/sendTestNotification
```

**Authentication:** Required (JWT)

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | string | No | 'Test Notification' | Notification title |
| body | string | No | 'This is a test notification from Rmotly.' | Notification body |

**Request Example:**

```dart
final delivered = await client.notificationStream.sendTestNotification(
  title: 'Hello!',
  body: 'Testing notification delivery',
);

print('Delivered to $delivered connections');
```

**Success Response:**

```dart
2  // Number of connections that received the notification
```

**Error Response:**

```dart
// Throws AuthenticationException if not authenticated
AuthenticationException: User not authenticated
```

---

### Server-Sent Events (SSE)

SSE provides a fallback delivery mechanism for restricted networks where WebSocket connections are blocked.

#### Get Connection Info

Get SSE endpoint URL and authentication token for establishing a connection.

**Endpoint:**
```
POST /sse/getConnectionInfo
```

**Authentication:** Required (JWT)

**Request Example:**

```dart
final info = await client.sse.getConnectionInfo();
print('Connect to: ${info['endpoint']}');
print('Token: ${info['token']}');
print('Heartbeat interval: ${info['heartbeatInterval']}s');
```

**Success Response:**

```dart
{
  'endpoint': '/api/sse/notifications',
  'token': '1',  // User ID as token (temporary implementation)
  'heartbeatInterval': 30,
  'reconnectDelay': 5,
}
```

**Note:** The current SSE authentication implementation is simplified for development. In production, it should use signed JWT tokens instead of user IDs.

**Error Response:**

```dart
// Throws StateError if not authenticated
StateError: User not authenticated
```

#### Get Queued Notifications

Get notifications that were queued while the client was disconnected.

**Endpoint:**
```
POST /sse/getQueuedNotifications
```

**Authentication:** Required (JWT)

**Request Example:**

```dart
final queued = await client.sse.getQueuedNotifications();
print('Retrieved ${queued.length} queued notifications');

for (final notif in queued) {
  print('${notif['title']}: ${notif['body']}');
}
```

**Success Response:**

```dart
[
  {
    'title': 'Order Received',
    'body': 'New order #12345',
    'data': {'orderId': '12345'},
    'priority': 'high',
  },
  {
    'title': 'Payment Processed',
    'body': 'Payment of \$99.99 received',
    'data': {'paymentId': 'pay_123'},
    'priority': 'normal',
  },
]
```

**Error Response:**

```dart
// Throws StateError if not authenticated
StateError: User not authenticated
```

---

## Error Handling

### Error Response Format

All Rmotly endpoints return errors in a consistent format. Errors are communicated through Dart exceptions that contain descriptive messages.

### Common Error Types

#### AuthenticationException

Thrown when a user is not authenticated or the authentication token is invalid.

```dart
try {
  final topics = await client.notification.listTopics();
} catch (e) {
  if (e is AuthenticationException) {
    print('Please sign in to continue');
    // Redirect to sign-in screen
  }
}
```

**Common causes:**
- No authentication token provided
- Authentication token expired
- User signed out
- Invalid or malformed token

**Resolution:**
- Call `client.modules.auth.email.authenticate()` to sign in
- Check `client.sessionManager.isSignedIn()` before making requests

#### ArgumentError

Thrown when request parameters fail validation.

```dart
try {
  final action = await client.action.createAction(
    userId: 1,
    name: '',  // Invalid: empty name
    httpMethod: 'POST',
    urlTemplate: 'https://example.com',
  );
} catch (e) {
  if (e is ArgumentError) {
    print('Validation error: ${e.message}');
    // Show error to user
  }
}
```

**Common causes:**
- Required fields missing
- Invalid field values (empty strings, out of range numbers)
- Invalid data format (malformed JSON, invalid URLs)
- Invalid enum values (controlType, httpMethod, priority)
- Resource not found (action ID, control ID, topic ID)
- Permission denied (accessing another user's resources)

**Resolution:**
- Validate input before sending
- Check error message for specific field causing the issue
- Ensure referenced resources (actions, controls) exist and are owned by the user

#### StateError

Thrown when an operation cannot be completed due to invalid state.

```dart
try {
  final updated = await client.pushSubscription.updateSubscription(
    999,  // Non-existent subscription
    active: false,
  );
} catch (e) {
  if (e is StateError) {
    print('State error: ${e.message}');
  }
}
```

**Common causes:**
- Resource does not exist
- Resource in wrong state for operation
- Concurrent modification detected

**Resolution:**
- Refresh data before retrying
- Verify resource still exists
- Handle concurrent modifications gracefully

### Error Codes

The following table lists specific error codes and their meanings:

| Code | Type | Description | Resolution |
|------|------|-------------|------------|
| `INVALID_API_KEY` | ArgumentError | Webhook API key is invalid or expired | Check API key, regenerate if needed |
| `TOPIC_NOT_FOUND` | ArgumentError | Notification topic ID does not exist | Verify topic ID, list topics to find correct ID |
| `ACTION_NOT_FOUND` | ArgumentError | Action ID does not exist | Verify action ID, list actions to find correct ID |
| `CONTROL_NOT_FOUND` | ArgumentError | Control ID does not exist | Verify control ID, list controls to find correct ID |
| `EVENT_NOT_FOUND` | ArgumentError | Event ID does not exist | Verify event ID, check if event was deleted |
| `SUBSCRIPTION_NOT_FOUND` | StateError | Push subscription does not exist | List subscriptions to find correct ID |
| `RATE_LIMITED` | Exception | Too many requests in time window | Wait before retrying, reduce request frequency |
| `VALIDATION_ERROR` | ArgumentError | Request parameter validation failed | Check error message for specific field issue |
| `ACTION_FAILED` | Exception | HTTP action execution failed | Check action configuration, verify target URL is accessible |
| `OPENAPI_PARSE_ERROR` | Exception | Failed to parse OpenAPI specification | Verify spec URL is accessible and valid OpenAPI format |
| `UNAUTHORIZED` | AuthenticationException | Authentication required | Sign in with valid credentials |
| `FORBIDDEN` | AuthenticationException | Insufficient permissions | Verify user has access to requested resource |
| `RESOURCE_NOT_OWNED` | ArgumentError | Resource belongs to another user | Only access your own resources |
| `EMPTY_FIELD` | ArgumentError | Required field is empty | Provide non-empty value for required field |
| `INVALID_JSON` | ArgumentError | JSON parsing failed | Check JSON syntax, ensure valid format |
| `INVALID_URL` | ArgumentError | URL format is invalid | Use valid HTTP(S) URL with proper scheme |
| `INVALID_ENUM` | ArgumentError | Enum value not in allowed list | Use one of the documented allowed values |

### HTTP Status Codes (Webhook Endpoint)

The webhook endpoint (`/api/notify/{topicId}`) returns standard HTTP status codes:

| Status Code | Meaning | Description |
|-------------|---------|-------------|
| `200 OK` | Success | Notification accepted and queued for delivery |
| `400 Bad Request` | Invalid Payload | Empty body, invalid JSON, or missing required fields |
| `401 Unauthorized` | Missing/Invalid API Key | API key header missing, empty, or invalid |
| `404 Not Found` | Topic Not Found | Topic ID does not exist |
| `429 Too Many Requests` | Rate Limited | Exceeded 100 requests per minute for this topic |
| `500 Internal Server Error` | Server Error | Unexpected server error, retry after delay |

**Example error responses:**

```json
// 401 Unauthorized
{
  "error": "Invalid API key",
  "timestamp": "2025-01-14T10:30:00Z"
}

// 400 Bad Request
{
  "error": "Invalid JSON payload",
  "timestamp": "2025-01-14T10:30:00Z"
}

// 429 Too Many Requests
{
  "error": "Rate limit exceeded",
  "timestamp": "2025-01-14T10:30:00Z",
  "retryAfter": 60
}
```

### Error Handling Best Practices

#### 1. Always Handle Authentication Errors

```dart
try {
  final data = await client.action.listActions(userId: userId);
  // Process data
} on AuthenticationException {
  // User not authenticated - redirect to sign in
  Navigator.pushReplacementNamed(context, '/sign-in');
} on ArgumentError catch (e) {
  // Validation error - show to user
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(e.message),
    ),
  );
}
```

#### 2. Retry on Transient Errors

```dart
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await request();
    } catch (e) {
      if (attempt == maxAttempts - 1) rethrow;
      if (e is StateError || e.toString().contains('timeout')) {
        await Future.delayed(delay * (attempt + 1));
        continue;
      }
      rethrow;
    }
  }
  throw StateError('Max retry attempts exceeded');
}

// Usage
final topics = await retryRequest(() => client.notification.listTopics());
```

#### 3. Validate Before Sending

```dart
String? validateActionName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'Name is required';
  }
  if (name.length > 100) {
    return 'Name must be 100 characters or less';
  }
  return null;
}

// Use validation before API call
final nameError = validateActionName(nameController.text);
if (nameError != null) {
  // Show error, don't call API
  return;
}

// Name is valid, proceed with API call
final action = await client.action.createAction(...);
```

#### 4. Handle Rate Limiting

```dart
import 'package:rate_limiter/rate_limiter.dart';

// Limit to 100 requests per minute
final rateLimiter = RateLimiter(
  maxRequests: 100,
  duration: Duration(minutes: 1),
);

Future<void> sendNotification(String title, String body) async {
  await rateLimiter.execute(() async {
    await client.notification.sendNotification(
      title: title,
      body: body,
    );
  });
}
```

#### 5. Log Errors for Debugging

```dart
import 'package:logging/logging.dart';

final _logger = Logger('ApiClient');

try {
  final result = await client.action.testAction(
    actionId: actionId,
    testParameters: params,
  );
} catch (e, stackTrace) {
  _logger.severe('Action test failed', e, stackTrace);
  
  // Report to error tracking service
  // FirebaseCrashlytics.instance.recordError(e, stackTrace);
  
  rethrow;
}
```

---

## Rate Limiting

Rate limiting protects the API from abuse and ensures fair resource allocation among all users. Different endpoints have different rate limits based on their resource intensity and typical usage patterns.

### Rate Limit Policies

| Endpoint Category | Limit | Window | Scope | Description |
|-------------------|-------|--------|-------|-------------|
| **Webhook Notifications** | 100 requests | 1 minute | Per topic | External notification sending to a specific topic |
| **Event Creation** | 1000 requests | 1 minute | Per user | Control interactions and event logging |
| **OpenAPI Parsing** | 10 requests | 1 minute | Per user | Fetching and parsing OpenAPI specifications |
| **Standard CRUD** | 300 requests | 1 minute | Per user | Create, read, update, delete operations for actions, controls, topics |
| **Streaming/SSE** | No limit | - | Per user | Real-time notification delivery (connection-based) |

### How Rate Limiting Works

#### Per-Topic Limits (Webhooks)

Each notification topic has its own rate limit counter. This allows you to have multiple topics with independent rate limits.

```bash
# Topic A can receive 100 notifications per minute
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: key_abc" \
  -d '{"title":"Alert","message":"Message 1"}'

# Topic B has a separate counter - also 100 per minute
curl -X POST https://api.rmotly.app/api/notify/topic_def456 \
  -H "X-API-Key: key_def" \
  -d '{"title":"Alert","message":"Message 1"}'
```

#### Per-User Limits (API Endpoints)

Authenticated API endpoints are rate limited per user. All requests from the same user share the rate limit counter.

```dart
// All these requests count toward the same 300 req/min limit
await client.action.listActions(userId: 1);
await client.control.listControls(userId: 1);
await client.notification.listTopics();
await client.event.listEvents();
```

### Rate Limit Headers

When you exceed a rate limit, the response includes additional information:

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705234260
Retry-After: 60

{
  "error": "Rate limit exceeded",
  "timestamp": "2025-01-14T10:30:00Z",
  "retryAfter": 60
}
```

**Header Meanings:**

- `X-RateLimit-Limit`: Maximum requests allowed in the window
- `X-RateLimit-Remaining`: Number of requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when the rate limit resets
- `Retry-After`: Seconds to wait before retrying

### Handling Rate Limits

#### 1. Check Remaining Requests

```dart
// Pseudo-code - check headers after each request
final response = await makeRequest();
final remaining = int.parse(response.headers['X-RateLimit-Remaining'] ?? '0');
final limit = int.parse(response.headers['X-RateLimit-Limit'] ?? '0');

if (remaining < limit * 0.1) {
  print('Warning: Only $remaining requests remaining');
  // Consider reducing request frequency
}
```

#### 2. Implement Exponential Backoff

```dart
Future<T> requestWithBackoff<T>(
  Future<T> Function() request, {
  int maxAttempts = 5,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  Duration delay = initialDelay;
  
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await request();
    } catch (e) {
      if (e.toString().contains('Rate limit') || 
          e.toString().contains('429')) {
        if (attempt == maxAttempts - 1) rethrow;
        
        print('Rate limited, waiting ${delay.inSeconds}s before retry');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
        continue;
      }
      rethrow;
    }
  }
  throw StateError('Max retry attempts exceeded');
}

// Usage
final topics = await requestWithBackoff(
  () => client.notification.listTopics(),
);
```

#### 3. Batch Requests When Possible

Instead of making many small requests, batch operations when the API supports it:

```dart
// BAD: Multiple separate requests
for (final controlId in controlIds) {
  await client.control.updateControl(
    controlId: controlId,
    position: newPositions[controlId]!,
  );
}

// GOOD: Single batch request
await client.control.reorderControls(
  userId: userId,
  controlPositions: newPositions,
);
```

#### 4. Use Request Queues

For high-volume applications, queue requests to stay within limits:

```dart
import 'dart:collection';

class RequestQueue {
  final Queue<Future<void> Function()> _queue = Queue();
  final int maxRequestsPerMinute;
  bool _processing = false;
  int _requestCount = 0;
  DateTime _windowStart = DateTime.now();

  RequestQueue({required this.maxRequestsPerMinute});

  Future<T> enqueue<T>(Future<T> Function() request) async {
    final completer = Completer<T>();
    
    _queue.add(() async {
      try {
        final result = await request();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    _processQueue();
    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_processing || _queue.isEmpty) return;
    _processing = true;

    while (_queue.isNotEmpty) {
      // Reset counter if window expired
      if (DateTime.now().difference(_windowStart) > Duration(minutes: 1)) {
        _requestCount = 0;
        _windowStart = DateTime.now();
      }

      // Wait if limit reached
      if (_requestCount >= maxRequestsPerMinute) {
        final waitTime = Duration(minutes: 1) - 
                        DateTime.now().difference(_windowStart);
        await Future.delayed(waitTime);
        _requestCount = 0;
        _windowStart = DateTime.now();
      }

      // Process next request
      final request = _queue.removeFirst();
      await request();
      _requestCount++;
    }

    _processing = false;
  }
}

// Usage
final queue = RequestQueue(maxRequestsPerMinute: 100);

for (final notification in notifications) {
  await queue.enqueue(() => sendWebhook(notification));
}
```

### Rate Limit Best Practices

#### 1. Cache Responses When Possible

```dart
class CachedTopicRepository {
  List<NotificationTopic>? _cachedTopics;
  DateTime? _cacheTime;
  final Duration cacheValidity = Duration(minutes: 5);

  Future<List<NotificationTopic>> getTopics() async {
    // Return cached data if still valid
    if (_cachedTopics != null && 
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheValidity) {
      return _cachedTopics!;
    }

    // Fetch fresh data
    _cachedTopics = await client.notification.listTopics();
    _cacheTime = DateTime.now();
    return _cachedTopics!;
  }

  void invalidateCache() {
    _cachedTopics = null;
    _cacheTime = null;
  }
}
```

#### 2. Paginate Large Lists

```dart
// Don't fetch everything at once
final allEvents = <Event>[];
int offset = 0;
const limit = 100;

while (true) {
  final events = await client.event.listEvents(
    limit: limit,
    offset: offset,
  );
  
  if (events.isEmpty) break;
  
  allEvents.addAll(events);
  offset += limit;
  
  // Small delay between pages to avoid rate limiting
  await Future.delayed(Duration(milliseconds: 100));
}
```

#### 3. Use WebSocket Streaming Instead of Polling

```dart
// BAD: Polling for new notifications (wastes rate limit)
Timer.periodic(Duration(seconds: 5), (_) async {
  final notifications = await client.notification.getRecent();
  // Process notifications
});

// GOOD: Use WebSocket streaming (no rate limit)
final stream = client.notificationStream.streamNotifications();
await for (final notification in stream) {
  // Process notification immediately
}
```

#### 4. Monitor Your Usage

```dart
class RateLimitMonitor {
  final Map<String, List<DateTime>> _requestTimestamps = {};

  void recordRequest(String endpoint) {
    _requestTimestamps.putIfAbsent(endpoint, () => []);
    _requestTimestamps[endpoint]!.add(DateTime.now());
    
    // Remove timestamps older than 1 minute
    final cutoff = DateTime.now().subtract(Duration(minutes: 1));
    _requestTimestamps[endpoint]!.removeWhere((t) => t.isBefore(cutoff));
  }

  int getRequestCount(String endpoint, Duration window) {
    if (!_requestTimestamps.containsKey(endpoint)) return 0;
    
    final cutoff = DateTime.now().subtract(window);
    return _requestTimestamps[endpoint]!
        .where((t) => t.isAfter(cutoff))
        .length;
  }

  void printStats() {
    _requestTimestamps.forEach((endpoint, timestamps) {
      final count = timestamps.length;
      print('$endpoint: $count requests in last minute');
    });
  }
}
```

### Increasing Rate Limits

If your application requires higher rate limits:

1. **Contact support** with your use case and expected request volume
2. **Implement caching and batching** to reduce unnecessary requests
3. **Consider using streaming** for real-time data instead of polling
4. **Use multiple topics** if webhook rate limits are the bottleneck
5. **Optimize your integration** to minimize API calls

Enterprise plans with higher rate limits are available for production applications with high volume requirements.

---

## Webhooks

### Overview

Webhooks allow external services and applications to send notifications directly to Rmotly users. When a webhook receives a payload, Rmotly automatically detects the format, extracts notification data, and delivers it to the user's devices in real-time.

Webhooks are ideal for integrating:
- **Home automation systems** (Home Assistant, openHAB)
- **Monitoring services** (Grafana, Prometheus, Uptime Kuma)
- **CI/CD pipelines** (GitHub Actions, GitLab CI, Jenkins)
- **Business applications** (order systems, CRM alerts, custom apps)

Rmotly's webhook endpoint supports multiple popular notification formats out of the box, with automatic format detection and intelligent field mapping. This means you can connect existing services without modifying their payloads.

### Getting Started

Before using webhooks, you need to create a notification topic:

1. **Create a topic** using the [Create Topic](#create-topic) endpoint
2. **Save the API key** from the response - this authenticates webhook requests
3. **Note the topic ID** - this identifies which topic receives notifications
4. **Configure your webhook URL**: `POST https://api.rmotly.app/api/notify/{topicId}`

**Example topic creation:**

```bash
curl -X POST https://api.rmotly.app/api/topics \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Server Alerts",
    "description": "Production server monitoring notifications"
  }'
```

**Response:**

```json
{
  "id": "topic_abc123",
  "name": "Server Alerts",
  "apiKey": "rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx",
  "webhookUrl": "https://api.rmotly.app/api/notify/topic_abc123",
  "createdAt": "2025-01-14T10:30:00Z"
}
```

### Authentication

Webhook requests are authenticated using an API key in the `X-API-Key` header. Each notification topic has its own unique API key.

**Header format:**

```
X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx
```

**Example request:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Server Alert",
    "message": "CPU usage exceeded 90%"
  }'
```

**Security notes:**
- Keep your API keys secure - they grant access to send notifications to your topics
- Regenerate API keys if compromised using the [Regenerate API Key](#regenerate-api-key) endpoint
- API keys are tied to specific topics and cannot be used across topics

### Payload Formats

Rmotly automatically detects and parses multiple notification formats. You can send payloads in any of the supported formats without configuration.

#### Generic Format

The simplest format uses common field names. This is the fallback when no specific format is detected.

**Format detection:**
- Does not match any specific format patterns
- Uses common field name extraction

**JSON structure:**

```json
{
  "title": "Notification Title",
  "message": "Notification body text",
  "priority": "high",
  "image": "https://example.com/image.png",
  "url": "https://example.com/action",
  "data": {
    "customField": "value"
  }
}
```

**Field mapping:**

The generic parser checks multiple field names to extract notification data:

| Rmotly Field | Webhook Fields (checked in order) | Default |
|--------------|-----------------------------------|---------|
| title | `title`, `subject`, `header` | "Notification" |
| body | `body`, `message`, `text`, `content`, `description` | "" |
| priority | `priority` (string or number) | "normal" |
| imageUrl | `image`, `imageUrl`, `image_url` | null |
| actionUrl | `url`, `actionUrl`, `click_url`, `link` | null |
| data | `data`, `payload`, `extras`, `extra` | null |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Order Received",
    "message": "New order #12345 from John Doe",
    "priority": "high",
    "data": {
      "orderId": "12345",
      "customer": "John Doe",
      "amount": 99.99
    }
  }'
```

#### Firebase Cloud Messaging Format

Firebase Cloud Messaging (FCM) format uses a nested `notification` object.

**Format detection:**
- Payload contains a `notification` object
- Notification object has `title` or `body` field

**JSON structure:**

```json
{
  "notification": {
    "title": "Notification Title",
    "body": "Notification body text",
    "image": "https://example.com/image.png",
    "click_action": "https://example.com/action"
  },
  "data": {
    "customField": "value"
  },
  "priority": "high"
}
```

**Field mapping:**

| FCM Field | Rmotly Field |
|-----------|--------------|
| `notification.title` | title |
| `notification.body` | body |
| `notification.image` | imageUrl |
| `notification.click_action` | actionUrl |
| `data` | data |
| `priority` | priority (`high` → high, other → normal) |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "notification": {
      "title": "New Message",
      "body": "You have a new message from Alice",
      "image": "https://example.com/avatar.png"
    },
    "data": {
      "messageId": "msg_123",
      "senderId": "alice"
    },
    "priority": "high"
  }'
```

#### Pushover Format

Pushover API format uses numeric priority values from -2 to 2.

**Format detection:**
- Contains `message` field (not `body`)
- Priority is numeric in range -2 to 2, or has `user`/`token` fields

**JSON structure:**

```json
{
  "title": "Notification Title",
  "message": "Notification body text",
  "priority": 1,
  "url": "https://example.com/action",
  "url_title": "Open",
  "device": "iphone",
  "sound": "pushover"
}
```

**Field mapping:**

| Pushover Field | Rmotly Field |
|----------------|--------------|
| `title` | title |
| `message` | body |
| `priority` | priority (see table below) |
| `url` | actionUrl |
| `device`, `sound` | data |

**Priority mapping:**

| Pushover Priority | Rmotly Priority |
|-------------------|-----------------|
| -2 (lowest) | low |
| -1 (low) | low |
| 0 (normal) | normal |
| 1 (high) | high |
| 2 (emergency) | urgent |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Server Down",
    "message": "Production server is unreachable",
    "priority": 2,
    "url": "https://dashboard.example.com/servers"
  }'
```

#### ntfy Format

ntfy.sh notification format with topic-based routing.

**Format detection:**
- Contains `topic` field (most reliable indicator)

**JSON structure:**

```json
{
  "topic": "server-alerts",
  "title": "Notification Title",
  "message": "Notification body text",
  "priority": 4,
  "tags": ["warning", "server"],
  "click": "https://example.com/action",
  "attach": "https://example.com/image.png",
  "actions": [
    {
      "action": "view",
      "label": "Open Dashboard",
      "url": "https://dashboard.example.com"
    }
  ]
}
```

**Field mapping:**

| ntfy Field | Rmotly Field |
|------------|--------------|
| `title` | title |
| `message` | body |
| `priority` | priority (see table below) |
| `click` | actionUrl |
| `attach` | imageUrl |
| `tags` | tags |
| `topic`, `actions` | data |

**Priority mapping:**

| ntfy Priority | Rmotly Priority |
|---------------|-----------------|
| 1 (min) | low |
| 2 (low) | low |
| 3 (default) | normal |
| 4 (high) | high |
| 5 (max) | urgent |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "deployments",
    "title": "Deploy Complete",
    "message": "Application v2.1.0 deployed successfully",
    "priority": 3,
    "tags": ["deploy", "success"],
    "click": "https://app.example.com"
  }'
```

#### Gotify Format

Gotify self-hosted notification server format.

**Format detection:**
- Contains `message` field
- Contains `extras` or `appid` field

**JSON structure:**

```json
{
  "title": "Notification Title",
  "message": "Notification body text",
  "priority": 8,
  "extras": {
    "customField": "value",
    "client::notification": {
      "click": {
        "url": "https://example.com/action"
      },
      "bigImageUrl": "https://example.com/image.png"
    }
  }
}
```

**Field mapping:**

| Gotify Field | Rmotly Field |
|--------------|--------------|
| `title` | title |
| `message` | body |
| `priority` | priority (see table below) |
| `extras.client::notification.click.url` | actionUrl |
| `extras.client::notification.bigImageUrl` | imageUrl |
| `extras` | data |

**Priority mapping:**

| Gotify Priority | Rmotly Priority |
|-----------------|-----------------|
| 0-3 | low |
| 4-6 | normal |
| 7-8 | high |
| 9-10 | urgent |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Backup Complete",
    "message": "Daily backup completed successfully",
    "priority": 5,
    "extras": {
      "backupSize": "2.3 GB",
      "duration": "45 minutes"
    }
  }'
```

#### Home Assistant Format

Home Assistant notification service format with rich data payload.

**Format detection:**
- Contains `message` field
- Contains `data` object with Home Assistant-specific fields:
  - `data.push` (iOS/Android push configuration)
  - `data.actions` (actionable notifications)
  - `data.entity_id` (entity reference)

**JSON structure:**

```json
{
  "title": "Notification Title",
  "message": "Notification body text",
  "data": {
    "image": "https://example.com/image.png",
    "url": "https://example.com/action",
    "push": {
      "priority": "time-sensitive"
    },
    "actions": [
      {
        "action": "TURN_ON",
        "title": "Turn On Light"
      }
    ],
    "entity_id": "light.living_room"
  }
}
```

**Field mapping:**

| Home Assistant Field | Rmotly Field |
|---------------------|--------------|
| `title` | title |
| `message` | body |
| `data.push.priority` | priority (`time-sensitive`, `critical` → high) |
| `data.url` | actionUrl |
| `data.image` | imageUrl |
| `data` | data (entire object) |

**Example:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Motion Detected",
    "message": "Motion detected in living room",
    "data": {
      "image": "https://homeassistant.local/api/camera_proxy/camera.living_room",
      "push": {
        "priority": "time-sensitive"
      },
      "entity_id": "binary_sensor.living_room_motion"
    }
  }'
```

### Integration Examples

#### Home Assistant

Configure Rmotly as a notification service in Home Assistant:

**configuration.yaml:**

```yaml
notify:
  - name: rmotly
    platform: rest
    resource: https://api.rmotly.app/api/notify/topic_abc123
    method: POST
    headers:
      X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx
      Content-Type: application/json
    message_param_name: message
    title_param_name: title
    data:
      priority: "{{ priority }}"
```

**Usage in automations:**

```yaml
automation:
  - alias: "Notify on door open"
    trigger:
      platform: state
      entity_id: binary_sensor.front_door
      to: 'on'
    action:
      service: notify.rmotly
      data:
        title: "Front Door"
        message: "Front door opened"
        data:
          priority: high
          entity_id: binary_sensor.front_door
```

#### Grafana

Configure a webhook notification channel in Grafana:

1. Navigate to **Alerting** → **Notification channels**
2. Click **Add channel**
3. Set **Type** to **webhook**
4. Configure:
   - **Name**: Rmotly
   - **URL**: `https://api.rmotly.app/api/notify/topic_abc123`
   - **Http Method**: POST
   - **Add header**: `X-API-Key` = `rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx`

**JSON payload template:**

```json
{
  "title": "{{ .Title }}",
  "message": "{{ .Message }}",
  "priority": "{{ if eq .State \"alerting\" }}urgent{{ else }}normal{{ end }}",
  "data": {
    "state": "{{ .State }}",
    "ruleName": "{{ .RuleName }}",
    "ruleUrl": "{{ .RuleUrl }}"
  }
}
```

#### Uptime Kuma

Configure Rmotly webhook in Uptime Kuma:

1. Go to **Settings** → **Notifications**
2. Click **Add Notification**
3. Select **Webhook** as notification type
4. Configure:
   - **Friendly Name**: Rmotly
   - **POST URL**: `https://api.rmotly.app/api/notify/topic_abc123`
   - **Content Type**: application/json
   - **Headers**: `X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx`

**Body template:**

```json
{
  "title": "{{msg}}",
  "message": "Monitor: {{monitor.name}} - Status: {{monitor.status}}",
  "priority": "urgent"
}
```

Note: Uptime Kuma sends different payloads based on status. For dynamic priority, configure separate notification rules for up/down events.

#### Generic curl Examples

**Simple notification:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test",
    "message": "This is a test notification"
  }'
```

**With priority and custom data:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Important Alert",
    "message": "Action required on your account",
    "priority": "urgent",
    "data": {
      "action": "review_account",
      "accountId": "acc_12345"
    }
  }'
```

**With image and action URL:**

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Photo",
    "message": "Alice uploaded a new photo",
    "image": "https://example.com/photos/image123.jpg",
    "url": "https://app.example.com/photos/image123"
  }'
```

### Priority Mapping

Rmotly uses four priority levels internally. External formats map to these levels as follows:

| Format | Low | Normal | High | Urgent |
|--------|-----|--------|------|--------|
| **Generic** | `low`, `min`, `1`, `2` | `normal`, `3` (default) | `high`, `4`, `important` | `urgent`, `critical`, `max`, `5` |
| **Firebase** | — | (default) | `high` | — |
| **Pushover** | `-2`, `-1` | `0` (default) | `1` | `2` |
| **ntfy** | `1`, `2` | `3` (default) | `4` | `5` |
| **Gotify** | `0-3` | `4-6` (default) | `7-8` | `9-10` |
| **Home Assistant** | — | (default) | `time-sensitive`, `critical` | — |

**Priority effects:**
- **low**: Silent notification, no sound or vibration
- **normal**: Default notification sound
- **high**: Priority sound, displayed prominently
- **urgent**: Bypass Do Not Disturb, persistent notification

### Advanced Features

#### Template Variables

Topic configurations support template variables for dynamic content transformation:

```json
{
  "titleTemplate": "Order #{{orderId}}",
  "bodyTemplate": "New {{orderType}} order from {{customerName}}: {{items.length}} items"
}
```

Template variables use JSONPath-like syntax for nested field access. See the [Create Topic](#create-topic) endpoint for configuration details.

#### Custom Data Payloads

The `data` field in webhook payloads is preserved and passed to the mobile app. Use this for:
- Deep linking to specific app screens
- Passing context for notification actions
- Storing metadata for analytics

**Example:**

```json
{
  "title": "Payment Received",
  "message": "Payment of $99.99 received",
  "data": {
    "paymentId": "pay_123",
    "amount": 99.99,
    "currency": "USD",
    "customerId": "cus_456",
    "deepLink": "app://payments/pay_123"
  }
}
```

#### Image Attachments

Rich notifications can include images via the `image` field (or format-specific equivalents). Images are displayed in the notification:

```json
{
  "title": "Security Alert",
  "message": "Motion detected at front door",
  "image": "https://camera.example.com/snapshot.jpg"
}
```

**Image requirements:**
- Must be accessible via HTTPS URL
- Supported formats: JPEG, PNG, GIF
- Recommended size: 1024x512 pixels (2:1 aspect ratio)
- Maximum size: 5 MB

#### Action URLs

Define tap actions for notifications using the `actionUrl` field (or format-specific equivalents):

```json
{
  "title": "New Comment",
  "message": "John commented on your post",
  "actionUrl": "app://posts/123/comments"
}
```

**URL schemes:**
- **HTTPS URLs**: Open in browser
- **Custom app schemes**: Deep link to app features (`app://`, `rmotly://`)
- **Intent URLs** (Android): Launch specific activities

### Error Handling

#### Common Errors

**Missing API Key (401 Unauthorized)**

```json
{
  "error": "Missing API key",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solution**: Include `X-API-Key` header in your request.

**Invalid API Key (401 Unauthorized)**

```json
{
  "error": "Invalid API key",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solutions**:
- Verify the API key is correct (check for copy/paste errors)
- Ensure the API key matches the topic ID in the URL
- Regenerate the API key if it was revoked or expired

**Invalid JSON (400 Bad Request)**

```json
{
  "error": "Invalid JSON payload",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solutions**:
- Validate JSON syntax using a JSON validator
- Ensure `Content-Type: application/json` header is set
- Check for trailing commas or unescaped characters

**Empty Body (400 Bad Request)**

```json
{
  "error": "Empty request body",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solution**: Include a JSON payload with at least a `message` or `title` field.

**Rate Limiting (429 Too Many Requests)**

```json
{
  "error": "Rate limit exceeded",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solution**: Reduce request frequency. Webhook endpoint allows 100 requests per minute per topic.

**Internal Error (500 Internal Server Error)**

```json
{
  "error": "Internal error",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Solutions**:
- Retry the request after a brief delay
- Check the payload size (keep under 100 KB)
- Contact support if the error persists

#### Success Response

Successful webhook requests return a 200 OK status with delivery information:

```json
{
  "status": "queued",
  "deliveryStatus": "success",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Status values:**
- `queued`: Notification accepted and queued for delivery
- `delivered`: Notification successfully delivered to device
- `failed`: Delivery failed (device offline, notification rejected)

### Testing

#### Test with curl

Test your webhook configuration with a simple curl command:

```bash
curl -v -X POST https://api.rmotly.app/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "message": "If you see this, webhooks are working!"
  }'
```

The `-v` flag provides verbose output showing the full request and response.

#### Using the Test Endpoint

Use the authenticated test webhook endpoint to verify topic configuration:

```bash
curl -X POST https://api.rmotly.app/api/webhook/test \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topicId": "topic_abc123",
    "title": "Test",
    "body": "Test notification"
  }'
```

#### Troubleshooting Tips

**Notifications not appearing:**
1. Verify the API key is correct
2. Check the topic ID in the URL matches your topic
3. Ensure your device has an active internet connection
4. Check notification permissions are enabled in the app
5. Verify the topic is not muted in app settings

**Format not detected correctly:**
1. Check the payload structure matches one of the documented formats
2. Use the generic format with explicit `title` and `message` fields
3. Review the response for format detection information

**Priority not working as expected:**
1. Check the priority value matches the format's expected range
2. Verify device notification settings allow high/urgent priorities
3. Test with different priority values to see the effect

**Images not displaying:**
1. Verify the image URL is accessible via HTTPS
2. Check the image file size (must be under 5 MB)
3. Ensure the image format is supported (JPEG, PNG, GIF)
4. Test the URL in a browser to confirm it loads

**Action URLs not working:**
1. Verify the URL scheme is supported by the app
2. Test with a simple HTTPS URL first
3. Check for URL encoding issues (spaces, special characters)

**Getting rate limited:**
1. Reduce request frequency to under 100/minute per topic
2. Use batching if sending multiple notifications
3. Consider using multiple topics for different notification streams
4. Contact support if you need higher rate limits
