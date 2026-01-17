# Rmotly API Documentation

## Overview

The Rmotly API is built with Serverpod and provides endpoints for:
- **Controls**: Managing dashboard UI elements (buttons, toggles, sliders)
- **Actions**: Defining and executing HTTP action templates
- **Events**: Tracking control interactions and webhook triggers
- **Notification Topics**: Managing notification channels for external webhooks
- **Push Subscriptions**: Registering UnifiedPush/WebPush endpoints
- **Real-time Streaming**: WebSocket and SSE notification delivery
- **OpenAPI Integration**: Parsing specs and creating actions from OpenAPI definitions

## Base URL

```
Production: https://api.rmotly.app
Development: http://localhost:8080
```

## Authentication

### App Authentication (Serverpod)

The Flutter app uses Serverpod's built-in authentication with JWT tokens. All Serverpod endpoints require authentication unless otherwise noted.

```dart
// Client initialization
final client = Client('https://api.rmotly.app/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// Authentication
await client.auth.signIn(email, password);
```

### External API Authentication

External services (webhooks) use API keys in the `X-API-Key` header:

```bash
curl -X POST https://api.rmotly.app/api/notify/{topicId} \
  -H "X-API-Key: your_topic_api_key" \
  -H "Content-Type: application/json" \
  -d '{"title": "Alert", "message": "Hello!"}'
```

## API Endpoints

All Serverpod endpoints are accessed via the client library. External HTTP routes (webhooks) are noted separately.

---

## Control Endpoints

Manage dashboard UI elements (buttons, toggles, sliders, inputs, dropdowns).

### Create Control

`ControlEndpoint.createControl()`

Creates a new dashboard control that can trigger actions.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user creating the control |
| name | String | Yes | Display name for the control |
| controlType | String | Yes | Type: `button`, `toggle`, `slider`, `input`, `dropdown` |
| config | String | Yes | Control configuration as JSON string |
| position | int | Yes | Position/order in the dashboard (0-indexed) |
| actionId | int | No | Optional ID of the action to trigger |

**Response:** `Control` object

```dart
final control = await client.control.createControl(
  userId: 1,
  name: 'Living Room Light',
  controlType: 'toggle',
  config: '{"onLabel":"On","offLabel":"Off","icon":"lightbulb"}',
  position: 0,
  actionId: 5,
);
```

**Example Response:**
```json
{
  "id": 1,
  "userId": 1,
  "name": "Living Room Light",
  "controlType": "toggle",
  "config": "{\"onLabel\":\"On\",\"offLabel\":\"Off\"}",
  "position": 0,
  "actionId": 5,
  "createdAt": "2025-01-14T10:30:00Z",
  "updatedAt": "2025-01-14T10:30:00Z"
}
```

**Errors:**
- `ArgumentError`: Invalid parameters (empty name, invalid controlType, invalid JSON config, negative position)
- `ArgumentError`: Action not found or doesn't belong to user

---

### List Controls

`ControlEndpoint.listControls()`

Returns all controls for a user, ordered by position.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose controls to list |

**Response:** `List<Control>`

```dart
final controls = await client.control.listControls(userId: 1);
```

---

### Get Control

`ControlEndpoint.getControl()`

Retrieves a single control by ID.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to retrieve |

**Response:** `Control?` (null if not found)

```dart
final control = await client.control.getControl(controlId: 1);
```

---

### Update Control

`ControlEndpoint.updateControl()`

Updates specified fields of a control. All parameters except `controlId` are optional.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to update |
| name | String | No | New display name |
| controlType | String | No | New control type |
| config | String | No | New configuration JSON |
| position | int | No | New position |
| actionId | int | No | New action ID |
| clearActionId | bool | No | Set to true to remove action association |

**Response:** `Control` (updated)

```dart
final updated = await client.control.updateControl(
  controlId: 1,
  name: 'Kitchen Light',
  position: 2,
);
```

**Errors:**
- `ArgumentError`: Control not found
- `ArgumentError`: Invalid parameters
- `ArgumentError`: Action not found or doesn't belong to user

---

### Delete Control

`ControlEndpoint.deleteControl()`

Permanently deletes a control.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| controlId | int | Yes | ID of the control to delete |

**Response:** `bool` (true if deleted, false if not found)

```dart
final deleted = await client.control.deleteControl(controlId: 1);
```

---

### Reorder Controls

`ControlEndpoint.reorderControls()`

Updates positions for multiple controls at once. Useful for drag-and-drop reordering.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose controls to reorder |
| controlPositions | Map<int, int> | Yes | Map of control ID to new position |

**Response:** `List<Control>` (all user's controls, ordered by position)

```dart
final reordered = await client.control.reorderControls(
  userId: 1,
  controlPositions: {1: 0, 2: 2, 3: 1},
);
```

**Errors:**
- `ArgumentError`: Empty controlPositions map
- `ArgumentError`: Negative positions
- `ArgumentError`: Control not found or doesn't belong to user

---

## Action Endpoints

Define and execute HTTP action templates that can be triggered by controls.

### Create Action

`ActionEndpoint.createAction()`

Creates an HTTP action template with variable substitution support.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user creating the action |
| name | String | Yes | Display name for the action |
| httpMethod | String | Yes | HTTP method: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD` |
| urlTemplate | String | Yes | URL with `{{variable}}` placeholders |
| description | String | No | Description of what the action does |
| headersTemplate | String | No | Headers as JSON string with `{{variable}}` support |
| bodyTemplate | String | No | Request body with `{{variable}}` placeholders |
| parameters | String | No | Parameter definitions as JSON string |

**Response:** `Action` object

```dart
final action = await client.action.createAction(
  userId: 1,
  name: 'Toggle Smart Light',
  httpMethod: 'POST',
  urlTemplate: 'https://api.smartlight.com/v1/lights/{{lightId}}/toggle',
  description: 'Toggles the specified light on/off',
  headersTemplate: '{"Authorization":"Bearer {{apiToken}}","Content-Type":"application/json"}',
  bodyTemplate: '{"transition":{{transitionTime}}}',
  parameters: '{"lightId":{"type":"string","required":true},"apiToken":{"type":"string","required":true},"transitionTime":{"type":"int","default":300}}',
);
```

**Errors:**
- `ArgumentError`: Invalid parameters (empty name/urlTemplate)
- `ArgumentError`: Invalid HTTP method
- `ArgumentError`: Invalid URL template format
- `ArgumentError`: Invalid JSON in headersTemplate or parameters

---

### List Actions

`ActionEndpoint.listActions()`

Returns all actions for a user, ordered by creation date (newest first).

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | int | Yes | ID of the user whose actions to list |

**Response:** `List<Action>`

```dart
final actions = await client.action.listActions(userId: 1);
```

---

### Get Action

`ActionEndpoint.getAction()`

Retrieves a single action by ID.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to retrieve |

**Response:** `Action?` (null if not found)

```dart
final action = await client.action.getAction(actionId: 1);
```

---

### Update Action

`ActionEndpoint.updateAction()`

Updates specified fields of an action. All parameters except `actionId` are optional.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to update |
| name | String | No | New display name |
| description | String | No | New description |
| httpMethod | String | No | New HTTP method |
| urlTemplate | String | No | New URL template |
| headersTemplate | String | No | New headers template |
| bodyTemplate | String | No | New body template |
| parameters | String | No | New parameters definition |
| clearDescription | bool | No | Set to true to remove description |
| clearHeadersTemplate | bool | No | Set to true to remove headers |
| clearBodyTemplate | bool | No | Set to true to remove body |
| clearParameters | bool | No | Set to true to remove parameters |

**Response:** `Action` (updated)

```dart
final updated = await client.action.updateAction(
  actionId: 1,
  name: 'Toggle Light (Updated)',
  description: 'New description',
);
```

**Errors:**
- `ArgumentError`: Action not found
- `ArgumentError`: Invalid parameters

---

### Delete Action

`ActionEndpoint.deleteAction()`

Permanently deletes an action. Associated controls will no longer trigger an action.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to delete |

**Response:** `bool` (true if deleted, false if not found)

```dart
final deleted = await client.action.deleteAction(actionId: 1);
```

---

### Test Action

`ActionEndpoint.testAction()`

Executes an action with test parameters to verify it works correctly. Performs the actual HTTP request.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| actionId | int | Yes | ID of the action to test |
| testParameters | Map<String, dynamic> | Yes | Parameters for variable substitution |

**Response:** `Map<String, dynamic>` with execution result

```dart
final result = await client.action.testAction(
  actionId: 1,
  testParameters: {
    'lightId': 'living_room_1',
    'apiToken': 'sk_test_123...',
    'transitionTime': 500,
  },
);
```

**Example Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "responseBody": "{\"status\":\"success\",\"state\":\"on\"}",
  "responseHeaders": {
    "content-type": "application/json",
    "x-request-id": "req_abc123"
  },
  "executionTimeMs": 234,
  "error": null
}
```

**Errors:**
- `ArgumentError`: Action not found

---

## Event Endpoints

Track control interactions and webhook triggers.

### Send Event

`EventEndpoint.sendEvent()`

Creates an event from a control interaction or external source, processes any associated action, and logs the result.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sourceType | String | Yes | Event source: `control`, `webhook`, `system` |
| sourceId | String | Yes | Identifier of the source (control ID, topic ID, etc.) |
| eventType | String | Yes | Type of event (e.g., `button_press`, `toggle_change`, `slider_moved`) |
| payload | String | No | Optional event payload as JSON string |

**Response:** `Event` object

```dart
final event = await client.event.sendEvent(
  sourceType: 'control',
  sourceId: '1',
  eventType: 'button_press',
  payload: '{"value":true,"timestamp":"2025-01-14T10:30:00Z"}',
);
```

**Example Response:**
```json
{
  "id": 1,
  "userId": 1,
  "sourceType": "control",
  "sourceId": "1",
  "eventType": "button_press",
  "payload": "{\"value\":true}",
  "actionResult": "{\"status\":200,\"body\":\"ok\"}",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Errors:**
- `AuthenticationException`: User not authenticated

---

### List Events

`EventEndpoint.listEvents()`

Lists events for the authenticated user with filtering and pagination support.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | int | No | 50 | Max events to return (1-100) |
| offset | int | No | 0 | Events to skip for pagination |
| sourceType | String | No | null | Filter by source type |
| eventType | String | No | null | Filter by event type |
| since | DateTime | No | null | Filter events after timestamp |

**Response:** `List<Event>`

```dart
final events = await client.event.listEvents(
  limit: 20,
  offset: 0,
  sourceType: 'control',
  since: DateTime.now().subtract(Duration(days: 7)),
);
```

---

### Get Event

`EventEndpoint.getEvent()`

Retrieves a specific event by ID.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| eventId | int | Yes | ID of the event to retrieve |

**Response:** `Event`

```dart
final event = await client.event.getEvent(eventId: 1);
```

**Errors:**
- `ArgumentError`: Event not found or not owned by user
- `AuthenticationException`: User not authenticated

---

### Delete Event

`EventEndpoint.deleteEvent()`

Deletes an event by ID.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| eventId | int | Yes | ID of the event to delete |

**Response:** `bool` (true if deleted, false if not found)

```dart
final deleted = await client.event.deleteEvent(eventId: 1);
```

---

### Get Event Counts

`EventEndpoint.getEventCounts()`

Returns event counts by source type for dashboard statistics.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| since | DateTime | No | Optional filter for events after timestamp |

**Response:** `Map<String, int>`

```dart
final counts = await client.event.getEventCounts(
  since: DateTime.now().subtract(Duration(days: 30)),
);
// Returns: {"control": 245, "webhook": 12, "system": 3}
```

---

## Notification Topic Endpoints

Manage notification channels for receiving external webhooks.

### Create Topic

`NotificationEndpoint.createTopic()`

Creates a notification topic and generates a unique API key for webhook authentication.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | String | Yes | Display name for the topic |
| description | String | No | Optional description of the notification source |
| config | String | No | Optional configuration as JSON string |

**Response:** `NotificationTopic` object

```dart
final topic = await client.notification.createTopic(
  name: 'Order Alerts',
  description: 'Notifications for new orders',
  config: '{"titleTemplate":"Order #{{orderId}}","bodyTemplate":"New order from {{customerName}}","priority":"high"}',
);
```

**Example Response:**
```json
{
  "id": 1,
  "userId": 1,
  "name": "Order Alerts",
  "description": "Notifications for new orders",
  "apiKey": "rmotly_a1b2c3d4e5f6g7h8i9j0k1l2m3n4",
  "enabled": true,
  "config": "{\"titleTemplate\":\"Order #{{orderId}}\"}",
  "createdAt": "2025-01-14T10:30:00Z",
  "updatedAt": "2025-01-14T10:30:00Z"
}
```

**Errors:**
- `AuthenticationException`: User not authenticated
- `ArgumentError`: Empty name

**Webhook URL:** `/api/notify/{topicId}` (see Webhook Endpoints section)

---

### List Topics

`NotificationEndpoint.listTopics()`

Returns all notification topics for the authenticated user.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| includeDisabled | bool | No | false | Include disabled topics |

**Response:** `List<NotificationTopic>`

```dart
final topics = await client.notification.listTopics(includeDisabled: true);
```

---

### Get Topic

`NotificationEndpoint.getTopic()`

Retrieves a specific notification topic by ID.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | ID of the topic to retrieve |

**Response:** `NotificationTopic`

```dart
final topic = await client.notification.getTopic(topicId: 1);
```

**Errors:**
- `ArgumentError`: Topic not found or not owned by user
- `AuthenticationException`: User not authenticated

---

### Update Topic

`NotificationEndpoint.updateTopic()`

Updates specified fields of a notification topic.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | ID of the topic to update |
| name | String | No | New display name |
| description | String | No | New description |
| enabled | bool | No | Enable/disable the topic |
| config | String | No | New configuration JSON |

**Response:** `NotificationTopic` (updated)

```dart
final updated = await client.notification.updateTopic(
  topicId: 1,
  name: 'Updated Orders',
  enabled: false,
);
```

**Errors:**
- `ArgumentError`: Topic not found or not owned by user
- `AuthenticationException`: User not authenticated

---

### Delete Topic

`NotificationEndpoint.deleteTopic()`

Permanently deletes a notification topic. The API key will immediately stop working.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | ID of the topic to delete |

**Response:** `bool` (true if deleted, false if not found)

```dart
final deleted = await client.notification.deleteTopic(topicId: 1);
```

---

### Regenerate API Key

`NotificationEndpoint.regenerateApiKey()`

Generates a new API key for a topic. The old key will immediately stop working.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | ID of the topic |

**Response:** `NotificationTopic` with new API key

```dart
final topic = await client.notification.regenerateApiKey(topicId: 1);
print('New API key: ${topic.apiKey}');
```

**Errors:**
- `ArgumentError`: Topic not found or not owned by user
- `AuthenticationException`: User not authenticated

---

### Send Notification (Internal)

`NotificationEndpoint.sendNotification()`

Sends a notification internally (for system notifications). External notifications should use the webhook endpoint.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | String | Yes | - | Notification title |
| body | String | Yes | - | Notification body/message |
| payload | String | No | null | Additional data as JSON string |
| priority | String | No | "normal" | Priority: `low`, `normal`, `high`, `urgent` |

**Response:** `bool` (true if queued successfully)

```dart
final queued = await client.notification.sendNotification(
  title: 'System Alert',
  body: 'Your subscription is expiring soon.',
  priority: 'high',
);
```

**Errors:**
- `ArgumentError`: Invalid priority value
- `AuthenticationException`: User not authenticated

---

## Webhook Endpoints

External HTTP routes for receiving notifications from third-party services.

### Send Notification (External Webhook)

`POST /api/notify/{topicId}`

Receives notifications from external services and queues them for delivery to users.

**Authentication:** API Key in `X-API-Key` header (NOT Serverpod JWT)

**Path Parameters:**

| Parameter | Description |
|-----------|-------------|
| topicId | ID of the notification topic |

**Headers:**

| Header | Required | Description |
|--------|----------|-------------|
| X-API-Key | Yes | Topic API key from `createTopic()` |
| Content-Type | Yes | `application/json` |

**Request Body (Simple Format):**

```json
{
  "title": "Alert Title",
  "message": "This is the notification body"
}
```

**Request Body (Extended Format):**

```json
{
  "title": "Order Alert",
  "message": "New order received",
  "data": {
    "orderId": "12345",
    "customerId": "67890",
    "amount": 99.99
  },
  "priority": "high",
  "image": "https://example.com/image.png",
  "actionUrl": "rmotly://orders/12345"
}
```

**Field Extraction Priority:**

The webhook parser attempts to extract title and message from various field names:

**Title fields** (first match wins):
1. `title`
2. `subject`
3. `name`
4. `header`
5. `notification.title`

**Message fields** (first match wins):
1. `message`
2. `body`
3. `text`
4. `content`
5. `description`
6. `notification.body`

**Response (Success):**

```json
{
  "status": "queued",
  "deliveryStatus": "websocket",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Response (Error):**

```json
{
  "error": "Invalid API key",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

**Error Codes:**

| Status | Description |
|--------|-------------|
| 400 | Bad Request - Invalid JSON or missing required fields |
| 401 | Unauthorized - Missing or invalid API key |
| 405 | Method Not Allowed - Only POST is accepted |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

**Example with curl:**

```bash
curl -X POST https://api.rmotly.app/api/notify/1 \
  -H "X-API-Key: rmotly_a1b2c3d4e5f6g7h8i9j0k1l2m3n4" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Server Alert",
    "message": "High CPU usage detected",
    "data": {
      "server": "web-01",
      "cpu": 95
    },
    "priority": "urgent"
  }'
```

**Template Variables:**

Topic configurations support template variables using `{{fieldName}}` syntax with JSONPath-like access for nested fields:

```json
{
  "titleTemplate": "Order #{{orderId}}",
  "bodyTemplate": "New order from {{customerName}}: {{items.length}} items for ${{amount}}"
}
```

---

### Get Webhook URL

`WebhookEndpoint.getWebhookUrl()`

Returns the webhook URL for a topic.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| topicId | int | Yes | ID of the topic |

**Response:** `String` (webhook URL)

```dart
final url = await client.webhook.getWebhookUrl(topicId: 1);
// Returns: "/api/notify/1"
```

---

### Test Webhook

`WebhookEndpoint.testWebhook()`

Sends a test notification to verify webhook delivery.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| topicId | int | Yes | - | ID of the topic to test |
| title | String | No | "Test Notification" | Test notification title |
| body | String | No | "This is a test..." | Test notification body |

**Response:** `Map<String, dynamic>`

```dart
final result = await client.webhook.testWebhook(
  topicId: 1,
  title: 'Test Alert',
  body: 'Testing webhook delivery',
);
```

---

## Push Subscription Endpoints

Manage UnifiedPush/WebPush subscriptions for push notification delivery.

### Register Endpoint

`PushSubscriptionEndpoint.registerEndpoint()`

Registers a push endpoint from a UnifiedPush distributor (ntfy, FCM, NextPush, etc.).

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| endpoint | String | Yes | Push endpoint URL from UnifiedPush distributor |
| p256dh | String | No | P-256 public key for WebPush encryption (base64url) |
| authSecret | String | No | Authentication secret for WebPush (base64url) |
| deliveryMethod | String | Yes | Delivery method: `webpush`, `sse`, `websocket` |

**Response:** `PushSubscriptionInfo` object

```dart
final subscription = await client.pushSubscription.registerEndpoint(
  endpoint: 'https://ntfy.sh/ABC123',
  p256dh: 'BDd3_h...base64url-encoded-key',
  authSecret: 'BTB...base64url-encoded-secret',
  deliveryMethod: 'webpush',
);
```

**Example Response:**
```json
{
  "id": 1,
  "userId": 1,
  "endpoint": "https://ntfy.sh/ABC123",
  "p256dh": "BDd3_h...",
  "authSecret": "BTB...",
  "deliveryMethod": "webpush",
  "enabled": true,
  "lastUsed": null,
  "failureCount": 0,
  "createdAt": "2025-01-14T10:30:00Z",
  "updatedAt": "2025-01-14T10:30:00Z"
}
```

**Errors:**
- `ArgumentError`: Invalid endpoint (empty or invalid URL format)
- `ArgumentError`: Invalid deliveryMethod
- `AuthenticationException`: User not authenticated

---

### Unregister Endpoint

`PushSubscriptionEndpoint.unregisterEndpoint()`

Removes a push endpoint subscription. Call when notifications are disabled or the distributor is uninstalled.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| endpoint | String | Yes | The endpoint URL to unregister |

**Response:** `bool` (true if removed, false if not found)

```dart
final removed = await client.pushSubscription.unregisterEndpoint(
  endpoint: 'https://ntfy.sh/ABC123',
);
```

**Errors:**
- `ArgumentError`: Empty endpoint
- `AuthenticationException`: User not authenticated

---

### List Subscriptions

`PushSubscriptionEndpoint.listSubscriptions()`

Returns all push subscriptions for the authenticated user.

**Authentication:** Required

**Response:** `List<PushSubscriptionInfo>`

```dart
final subscriptions = await client.pushSubscription.listSubscriptions();
```

**Errors:**
- `AuthenticationException`: User not authenticated

---

### Update Subscription

`PushSubscriptionEndpoint.updateSubscription()`

Updates a subscription (currently supports enabling/disabling).

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| subscriptionId | int | Yes | ID of the subscription to update |
| enabled | bool | Yes | Enable or disable the subscription |

**Response:** `PushSubscriptionInfo` (updated)

```dart
final updated = await client.pushSubscription.updateSubscription(
  subscriptionId: 1,
  enabled: false,
);
```

**Errors:**
- `StateError`: Subscription not found or not owned by user
- `ArgumentError`: No parameters provided
- `AuthenticationException`: User not authenticated

**Note:** This method requires the PushSubscription model to be fully generated.

---

## Real-time Streaming Endpoints

### WebSocket Notification Stream

`NotificationStreamEndpoint.streamNotifications()`

Establishes a WebSocket connection for real-time notification delivery (Tier 1 delivery - highest priority).

**Authentication:** Required

**Response:** `Stream<StreamNotification>`

```dart
final stream = client.notificationStream.streamNotifications();
await for (final notification in stream) {
  print('${notification.title}: ${notification.body}');
  // Process notification...
}
```

**StreamNotification Structure:**
```json
{
  "id": "1705234200000",
  "title": "Order Alert",
  "body": "New order #12345",
  "data": {"orderId": "12345"},
  "priority": "high"
}
```

**Errors:**
- `AuthenticationException`: User not authenticated

---

### Get Connection Count

`NotificationStreamEndpoint.getConnectionCount()`

Returns the number of active WebSocket connections for the authenticated user.

**Authentication:** Required

**Response:** `int` (connection count)

```dart
final count = await client.notificationStream.getConnectionCount();
print('Active connections: $count');
```

---

### Send Test Notification

`NotificationStreamEndpoint.sendTestNotification()`

Sends a test notification to all active WebSocket connections for the user.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | String | No | "Test Notification" | Test notification title |
| body | String | No | "This is a test..." | Test notification body |

**Response:** `int` (number of connections that received the notification)

```dart
final delivered = await client.notificationStream.sendTestNotification(
  title: 'Connection Test',
  body: 'Testing WebSocket delivery',
);
print('Delivered to $delivered connections');
```

---

## SSE (Server-Sent Events) Endpoints

Fallback delivery mechanism for restricted networks where WebSocket is blocked.

### Get Connection Info

`SseEndpoint.getConnectionInfo()`

Returns SSE connection details including endpoint URL and authentication token.

**Authentication:** Required

**Response:** `Map<String, dynamic>`

```dart
final info = await client.sse.getConnectionInfo();
print('SSE endpoint: ${info['endpoint']}');
print('Token: ${info['token']}');
```

**Example Response:**
```json
{
  "endpoint": "/api/sse/notifications",
  "token": "temp_token_1",
  "heartbeatInterval": 30,
  "reconnectDelay": 5
}
```

---

### Get Queued Notifications

`SseEndpoint.getQueuedNotifications()`

Retrieves notifications queued for SSE pickup while disconnected.

**Authentication:** Required

**Response:** `List<Map<String, dynamic>>`

```dart
final queued = await client.sse.getQueuedNotifications();
for (final notification in queued) {
  print('${notification['title']}: ${notification['body']}');
}
```

---

### SSE Connection (External HTTP)

`GET /api/sse/notifications`

Establishes an SSE connection for notification streaming.

**Authentication:** Token in query parameter or Authorization header

**Query Parameters:**

| Parameter | Description |
|-----------|-------------|
| token | Authentication token from `getConnectionInfo()` |

**Headers (Alternative):**

| Header | Description |
|--------|-------------|
| Authorization | Bearer {token} |
| Last-Event-ID | For resuming from specific event (optional) |

**Response Headers:**
```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

**Event Format:**

```
id: 1
event: connected
data: {"userId":1,"timestamp":"2025-01-14T10:30:00Z"}

id: 2
event: notification
data: {"title":"Alert","body":"Test message","data":{},"priority":"normal","timestamp":"2025-01-14T10:30:01Z"}

:heartbeat
```

**Example with EventSource (JavaScript):**

```javascript
const token = 'your_token_here';
const eventSource = new EventSource(`/api/sse/notifications?token=${token}`);

eventSource.addEventListener('connected', (event) => {
  console.log('Connected:', JSON.parse(event.data));
});

eventSource.addEventListener('notification', (event) => {
  const notification = JSON.parse(event.data);
  console.log(`${notification.title}: ${notification.body}`);
});

eventSource.onerror = (error) => {
  console.error('SSE error:', error);
};
```

---

## OpenAPI Integration Endpoints

Parse OpenAPI specifications and extract operation information.

### Parse OpenAPI Spec

`OpenApiEndpoint.parseSpec()`

Fetches and parses an OpenAPI specification from a URL. Supports OpenAPI 3.0, 3.1, and Swagger 2.0 in JSON format.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | String | Yes | URL of the OpenAPI specification (JSON) |

**Response:** `OpenApiSpec` object

```dart
final spec = await client.openapi.parseSpec(
  url: 'https://api.example.com/openapi.json',
);

print('API: ${spec.title} v${spec.version}');
print('Operations: ${spec.operations.length}');
```

**Example Response:**
```json
{
  "title": "Example API",
  "version": "1.0.0",
  "description": "An example REST API",
  "baseUrl": "https://api.example.com",
  "specVersion": "3.0.0",
  "operations": [
    {
      "operationId": "getUsers",
      "method": "GET",
      "path": "/users",
      "summary": "List all users",
      "description": "Returns a paginated list of users",
      "parameters": [
        {
          "name": "limit",
          "location": "query",
          "description": "Max items to return",
          "required": false,
          "type": "integer",
          "format": "int32"
        }
      ],
      "tags": ["users"]
    }
  ]
}
```

**Errors:**
- `OpenApiParseException`: Failed to parse specification (invalid URL, unsupported format, network error)

---

### List Operations

`OpenApiEndpoint.listOperations()`

Fetches an OpenAPI spec and returns all operations (endpoints) defined in it.

**Authentication:** Required

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| specUrl | String | Yes | URL of the OpenAPI specification |

**Response:** `List<OpenApiOperation>`

```dart
final operations = await client.openapi.listOperations(
  specUrl: 'https://api.example.com/openapi.json',
);

for (final op in operations) {
  print('${op.method} ${op.path} - ${op.summary}');
}
```

**Example Response:**
```json
[
  {
    "operationId": "createUser",
    "method": "POST",
    "path": "/users",
    "summary": "Create a user",
    "description": "Creates a new user account",
    "parameters": [
      {
        "name": "email",
        "location": "body",
        "description": "User email address",
        "required": true,
        "type": "string",
        "format": "email"
      },
      {
        "name": "name",
        "location": "body",
        "description": "User full name",
        "required": true,
        "type": "string",
        "format": null
      }
    ],
    "tags": ["users"]
  }
]
```

**Errors:**
- `OpenApiParseException`: Failed to parse specification

---

## Error Handling

### Error Types

All Serverpod endpoints may throw these exceptions:

| Exception | Description |
|-----------|-------------|
| `AuthenticationException` | User not authenticated or session expired |
| `ArgumentError` | Invalid parameters or validation failed |
| `StateError` | Resource not found or operation not allowed |
| `OpenApiParseException` | Failed to parse OpenAPI specification |

### HTTP Status Codes (External Routes)

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid JSON or missing required fields |
| 401 | Unauthorized - Missing, invalid, or expired credentials |
| 404 | Not Found - Resource doesn't exist |
| 405 | Method Not Allowed - Incorrect HTTP method |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

### Error Response Format (Webhooks)

```json
{
  "error": "Error description",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

### Serverpod Error Handling

```dart
try {
  final control = await client.control.createControl(
    userId: 1,
    name: '',  // Invalid: empty name
    controlType: 'button',
    config: '{}',
    position: 0,
  );
} on ArgumentError catch (e) {
  print('Validation error: $e');
} on AuthenticationException catch (e) {
  print('Auth error: $e');
  // Redirect to login
} catch (e) {
  print('Unexpected error: $e');
}
```

---

## Rate Limits

### Webhook Endpoints

| Endpoint | Limit |
|----------|-------|
| `POST /api/notify/{topicId}` | 100 requests/minute per topic |

### Serverpod Endpoints

Rate limits are managed per authenticated user:

| Operation Type | Limit |
|----------------|-------|
| Event creation | 1000 requests/minute |
| OpenAPI parsing | 10 requests/minute |
| All other operations | 300 requests/minute |

### Rate Limit Headers (Webhooks)

When rate limited, the webhook endpoint returns:

```
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "error": "Rate limit exceeded",
  "timestamp": "2025-01-14T10:30:00Z"
}
```

---

## Data Models

### Control

```dart
class Control {
  int? id;
  int userId;
  String name;
  String controlType;  // button, toggle, slider, input, dropdown
  int? actionId;
  String config;  // JSON string
  int position;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Action

```dart
class Action {
  int? id;
  int userId;
  String name;
  String? description;
  String httpMethod;  // GET, POST, PUT, DELETE, PATCH, HEAD
  String urlTemplate;
  String? headersTemplate;  // JSON string
  String? bodyTemplate;
  String? openApiSpecUrl;
  String? openApiOperationId;
  String? parameters;  // JSON string
  String? encryptedCredentials;  // Encrypted JSON
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Event

```dart
class Event {
  int? id;
  int userId;
  String sourceType;  // control, webhook, system
  String sourceId;
  String eventType;
  String? payload;  // JSON string
  String? actionResult;  // JSON string
  DateTime timestamp;
}
```

### NotificationTopic

```dart
class NotificationTopic {
  int? id;
  int userId;
  String name;
  String? description;
  String apiKey;
  bool enabled;
  String config;  // JSON string
  DateTime createdAt;
  DateTime updatedAt;
}
```

### PushSubscriptionInfo

```dart
class PushSubscriptionInfo {
  int id;
  int userId;
  String endpoint;
  String? p256dh;
  String? authSecret;
  String deliveryMethod;  // webpush, sse, websocket
  bool enabled;
  DateTime? lastUsed;
  int failureCount;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### StreamNotification

```dart
class StreamNotification {
  String id;
  String title;
  String body;
  Map<String, dynamic>? data;
  String priority;  // low, normal, high, urgent
}
```

### OpenApiSpec

```dart
class OpenApiSpec {
  String title;
  String version;
  String? description;
  String baseUrl;
  String specVersion;
  List<OpenApiOperation> operations;
}
```

### OpenApiOperation

```dart
class OpenApiOperation {
  String operationId;
  String method;
  String path;
  String? summary;
  String? description;
  List<OpenApiParameter> parameters;
  List<String> tags;
}
```

### OpenApiParameter

```dart
class OpenApiParameter {
  String name;
  String location;  // query, header, path, body
  String? description;
  bool required;
  String type;
  String? format;
}
```

---

## Common Workflows

### 1. Creating a Dashboard Control

```dart
// 1. Create an action
final action = await client.action.createAction(
  userId: currentUserId,
  name: 'Toggle Living Room Light',
  httpMethod: 'POST',
  urlTemplate: 'https://homeassistant.local/api/services/light/toggle',
  headersTemplate: '{"Authorization":"Bearer {{token}}","Content-Type":"application/json"}',
  bodyTemplate: '{"entity_id":"light.living_room"}',
);

// 2. Create a control linked to the action
final control = await client.control.createControl(
  userId: currentUserId,
  name: 'Living Room',
  controlType: 'toggle',
  config: '{"onLabel":"On","offLabel":"Off","icon":"lightbulb"}',
  position: 0,
  actionId: action.id,
);

// 3. Test the action
final testResult = await client.action.testAction(
  actionId: action.id!,
  testParameters: {'token': 'your_ha_token'},
);
print('Test result: ${testResult['success']}');
```

### 2. Setting Up Webhook Notifications

```dart
// 1. Create a notification topic
final topic = await client.notification.createTopic(
  name: 'Server Alerts',
  description: 'Notifications from monitoring system',
  config: '{"priority":"high"}',
);

print('Webhook URL: /api/notify/${topic.id}');
print('API Key: ${topic.apiKey}');

// 2. Configure external service to POST to webhook
// Use topic.apiKey in X-API-Key header

// 3. Register for push notifications
final subscription = await client.pushSubscription.registerEndpoint(
  endpoint: 'https://ntfy.sh/YOUR_TOPIC',
  deliveryMethod: 'webpush',
);

// 4. Start listening for real-time notifications
final stream = client.notificationStream.streamNotifications();
await for (final notification in stream) {
  showNotification(notification.title, notification.body);
}
```

### 3. Importing Actions from OpenAPI

```dart
// 1. Parse OpenAPI spec
final spec = await client.openapi.parseSpec(
  url: 'https://api.stripe.com/openapi.json',
);

print('Found ${spec.operations.length} operations');

// 2. List operations to find the one you want
final operations = await client.openapi.listOperations(
  specUrl: 'https://api.stripe.com/openapi.json',
);

for (final op in operations) {
  if (op.operationId == 'CreateCharge') {
    print('Found operation: ${op.method} ${op.path}');
    
    // 3. Create action from operation
    final action = await client.action.createAction(
      userId: currentUserId,
      name: 'Create Stripe Charge',
      httpMethod: op.method,
      urlTemplate: '${spec.baseUrl}${op.path}',
      description: op.description,
      // ... configure headers and body from operation parameters
    );
  }
}
```

### 4. Handling Events

```dart
// Send an event when user interacts with control
Future<void> onControlTriggered(int controlId, Map<String, dynamic> value) async {
  final event = await client.event.sendEvent(
    sourceType: 'control',
    sourceId: controlId.toString(),
    eventType: 'button_press',
    payload: jsonEncode(value),
  );
  
  print('Event sent: ${event.id}');
  if (event.actionResult != null) {
    final result = jsonDecode(event.actionResult!);
    print('Action result: ${result['statusCode']}');
  }
}

// List recent events for dashboard
final events = await client.event.listEvents(
  limit: 20,
  since: DateTime.now().subtract(Duration(days: 1)),
);

// Get event statistics
final counts = await client.event.getEventCounts(
  since: DateTime.now().subtract(Duration(days: 7)),
);
print('Events this week: ${counts['control']} from controls');
```

---

## Best Practices

### Security

1. **Never expose API keys in client code** - Store topic API keys securely on the server
2. **Use HTTPS only** - Always use HTTPS in production
3. **Rotate API keys regularly** - Use `regenerateApiKey()` periodically
4. **Validate user ownership** - All endpoints verify resource ownership
5. **Encrypt sensitive data** - Action credentials are encrypted at rest

### Performance

1. **Batch operations** - Use `reorderControls()` instead of multiple `updateControl()` calls
2. **Cache static data** - Cache control and action lists locally
3. **Use WebSocket for real-time** - Prefer WebSocket over polling for notifications
4. **Paginate large lists** - Use limit/offset for event listings
5. **Rate limit awareness** - Implement exponential backoff for rate-limited requests

### Reliability

1. **Handle disconnections gracefully** - Implement reconnection logic for WebSocket/SSE
2. **Test actions before deployment** - Always use `testAction()` before linking to controls
3. **Monitor webhook delivery** - Check notification queue status regularly
4. **Implement fallback delivery** - Support SSE fallback when WebSocket unavailable
5. **Log events for debugging** - Events provide audit trail for troubleshooting

### Client Implementation

```dart
// Singleton client instance
class RmotlyClient {
  static final instance = RmotlyClient._();
  RmotlyClient._();
  
  late final Client client;
  
  Future<void> initialize(String baseUrl) async {
    client = Client(baseUrl)
      ..connectivityMonitor = FlutterConnectivityMonitor();
  }
  
  // Auto-reconnecting notification stream
  Stream<StreamNotification> get notificationStream async* {
    while (true) {
      try {
        await for (final notification in client.notificationStream.streamNotifications()) {
          yield notification;
        }
      } catch (e) {
        print('Stream error: $e');
        await Future.delayed(Duration(seconds: 5));  // Backoff
      }
    }
  }
  
  // Retry logic for critical operations
  Future<T> retry<T>(Future<T> Function() operation, {int maxAttempts = 3}) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxAttempts - 1) rethrow;
        await Future.delayed(Duration(seconds: math.pow(2, i).toInt()));
      }
    }
    throw Exception('Retry failed');
  }
}
```

---

## Changelog

### v0.1.0 (Current)

- Initial API implementation
- Control management endpoints
- Action creation and execution
- Event tracking
- Notification topics and webhooks
- Push subscription management
- Real-time WebSocket streaming
- SSE fallback delivery
- OpenAPI integration

---

## Support

For issues, questions, or feature requests, please see:

- **Documentation**: `/docs/` directory
- **Architecture**: `docs/ARCHITECTURE.md`
- **Deployment**: `docs/DEPLOYMENT.md`
- **Testing**: `docs/TESTING.md`
