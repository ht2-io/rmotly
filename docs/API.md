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

### App Authentication (Serverpod)

The Flutter app uses Serverpod's built-in authentication with JWT tokens.

```dart
// Client initialization
final client = Client('https://api.rmotly.app/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// Authentication
await client.auth.signIn(email, password);
```

### External API Authentication

External services use Bearer tokens (topic API keys):

```bash
curl -X POST https://api.rmotly.app/api/notify/topic_123 \
  -H "Authorization: Bearer your_topic_api_key" \
  -H "Content-Type: application/json" \
  -d '{"title": "Alert", "message": "Hello!"}'
```

## Endpoints

---

### Events

#### Send Event

Sends an event from a control to trigger an action.

```
POST /api/events
```

**Request Body:**
```json
{
  "controlId": "ctrl_abc123",
  "eventType": "button_press",
  "payload": {
    "value": true,
    "timestamp": "2025-01-14T10:30:00Z"
  }
}
```

**Response:**
```json
{
  "success": true,
  "eventId": "evt_xyz789",
  "actionTriggered": true,
  "actionResult": {
    "status": 200,
    "body": { "result": "ok" }
  }
}
```

#### List Events

```
GET /api/events?limit=50&offset=0
```

**Response:**
```json
{
  "events": [
    {
      "id": "evt_xyz789",
      "controlId": "ctrl_abc123",
      "eventType": "button_press",
      "payload": {},
      "timestamp": "2025-01-14T10:30:00Z",
      "actionResult": { "status": 200 }
    }
  ],
  "total": 150,
  "limit": 50,
  "offset": 0
}
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

```
POST /api/topics
```

**Request Body:**
```json
{
  "name": "Order Alerts",
  "description": "Notifications for new orders",
  "config": {
    "titleTemplate": "{{title}}",
    "bodyTemplate": "{{message}}",
    "priority": "high",
    "channelId": "orders"
  }
}
```

**Response:**
```json
{
  "id": "topic_abc123",
  "name": "Order Alerts",
  "apiKey": "rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx",
  "webhookUrl": "https://api.rmotly.app/api/notify/topic_abc123",
  "createdAt": "2025-01-14T10:30:00Z"
}
```

#### List Topics

```
GET /api/topics
```

#### Get Topic

```
GET /api/topics/{topicId}
```

#### Update Topic

```
PUT /api/topics/{topicId}
```

#### Delete Topic

```
DELETE /api/topics/{topicId}
```

#### Regenerate API Key

```
POST /api/topics/{topicId}/regenerate-key
```

---

### Actions

#### Create Action

```
POST /api/actions
```

**Request Body:**
```json
{
  "name": "Toggle Light",
  "description": "Toggles the living room light",
  "method": "POST",
  "urlTemplate": "https://homeassistant.local/api/services/light/toggle",
  "headers": {
    "Authorization": "Bearer {{ha_token}}",
    "Content-Type": "application/json"
  },
  "bodyTemplate": "{\"entity_id\": \"light.living_room\"}",
  "parameters": [
    {
      "name": "ha_token",
      "location": "header",
      "type": "string",
      "required": true,
      "description": "Home Assistant long-lived token"
    }
  ]
}
```

**Response:**
```json
{
  "id": "action_abc123",
  "name": "Toggle Light",
  "createdAt": "2025-01-14T10:30:00Z"
}
```

#### Create Action from OpenAPI

```
POST /api/actions/from-openapi
```

**Request Body:**
```json
{
  "specUrl": "https://api.example.com/openapi.json",
  "operationId": "toggleDevice",
  "name": "Toggle Device",
  "parameterDefaults": {
    "deviceId": "device_123"
  }
}
```

#### List Actions

```
GET /api/actions
```

#### Get Action

```
GET /api/actions/{actionId}
```

#### Update Action

```
PUT /api/actions/{actionId}
```

#### Delete Action

```
DELETE /api/actions/{actionId}
```

#### Test Action

Execute an action without a control trigger (for testing).

```
POST /api/actions/{actionId}/test
```

**Request Body:**
```json
{
  "parameters": {
    "ha_token": "your_token_here"
  }
}
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "responseBody": { "result": "ok" },
  "executionTime": 234
}
```

---

### Controls

#### Create Control

```
POST /api/controls
```

**Request Body:**
```json
{
  "name": "Living Room Light",
  "type": "toggle",
  "actionId": "action_abc123",
  "config": {
    "onLabel": "On",
    "offLabel": "Off",
    "icon": "lightbulb"
  }
}
```

#### List Controls

```
GET /api/controls
```

#### Update Control

```
PUT /api/controls/{controlId}
```

#### Delete Control

```
DELETE /api/controls/{controlId}
```

#### Reorder Controls

```
PUT /api/controls/reorder
```

**Request Body:**
```json
{
  "order": ["ctrl_1", "ctrl_3", "ctrl_2", "ctrl_4"]
}
```

---

### OpenAPI

#### Parse OpenAPI Spec

```
POST /api/openapi/parse
```

**Request Body:**
```json
{
  "url": "https://api.example.com/openapi.json"
}
```

**Response:**
```json
{
  "title": "Example API",
  "version": "1.0.0",
  "servers": ["https://api.example.com"],
  "operations": [
    {
      "operationId": "getUsers",
      "method": "GET",
      "path": "/users",
      "summary": "List all users",
      "parameters": []
    },
    {
      "operationId": "createUser",
      "method": "POST",
      "path": "/users",
      "summary": "Create a user",
      "parameters": [
        {
          "name": "name",
          "in": "body",
          "required": true,
          "type": "string"
        }
      ]
    }
  ]
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| `INVALID_API_KEY` | API key is invalid or expired |
| `TOPIC_NOT_FOUND` | Topic ID does not exist |
| `ACTION_NOT_FOUND` | Action ID does not exist |
| `CONTROL_NOT_FOUND` | Control ID does not exist |
| `RATE_LIMITED` | Too many requests |
| `VALIDATION_ERROR` | Request body validation failed |
| `ACTION_FAILED` | HTTP action execution failed |
| `OPENAPI_PARSE_ERROR` | Failed to parse OpenAPI spec |
| `UNAUTHORIZED` | Authentication required |
| `FORBIDDEN` | Insufficient permissions |

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| `POST /api/notify/*` | 100/min per topic |
| `POST /api/events` | 1000/min per user |
| `POST /api/openapi/parse` | 10/min per user |
| All other endpoints | 300/min per user |

## Webhooks

### Incoming Webhook Format

The notification endpoint accepts various formats. The API attempts to extract title and message from common field names.

**Priority of field extraction:**

Title fields (first match wins):
1. `title`
2. `subject`
3. `name`
4. `header`
5. `notification.title`

Message fields (first match wins):
1. `message`
2. `body`
3. `text`
4. `content`
5. `description`
6. `notification.body`

### Template Variables

Topic configurations support template variables using `{{fieldName}}` syntax:

```json
{
  "titleTemplate": "Order #{{orderId}}",
  "bodyTemplate": "New order from {{customerName}}: {{items.length}} items"
}
```

The API uses JSONPath-like syntax for nested fields.
