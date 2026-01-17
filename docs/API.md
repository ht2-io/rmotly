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

```dart
// Client initialization
final client = Client('https://api.rmotly.app/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// Sign up
await client.modules.auth.email.createAccountRequest(
  userName: 'john',
  email: 'john@example.com', 
  password: 'secure_password',
);

// Verify email with code
await client.modules.auth.email.createAccount(
  email: 'john@example.com',
  verificationCode: '123456',
);

// Sign in
final authResponse = await client.modules.auth.email.authenticate(
  email: 'john@example.com',
  password: 'secure_password',
);

// Sign out
await client.modules.auth.signOut();
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
