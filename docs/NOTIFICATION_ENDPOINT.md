# NotificationEndpoint Usage Guide

This document describes how to use the NotificationEndpoint for managing notification topics.

## Overview

The NotificationEndpoint provides CRUD operations for notification topics. Topics are used to receive webhook notifications from external services.

## Authentication

All endpoint methods require user authentication. Requests will throw `AuthenticationException` if the user is not authenticated.

## API Methods

### 1. Create Topic

Creates a new notification topic with an auto-generated API key.

```dart
final topic = await client.notification.createTopic(
  name: 'My Alert Topic',
  description: 'Receives alerts from monitoring system',
  config: '{"priority": "high"}',
);

print('Topic created with API key: ${topic.apiKey}');
```

**Parameters:**
- `name` (required): Display name for the topic
- `description` (optional): Description of the topic's purpose
- `config` (optional): JSON configuration string (defaults to '{}')

**Returns:** `NotificationTopic` with generated API key

### 2. List Topics

Lists all topics owned by the authenticated user.

```dart
final topics = await client.notification.listTopics();

for (final topic in topics) {
  print('${topic.name}: ${topic.enabled ? "Enabled" : "Disabled"}');
}
```

**Returns:** `List<NotificationTopic>` ordered by creation date (newest first)

### 3. Get Topic

Retrieves a single topic by ID.

```dart
final topic = await client.notification.getTopic(topicId: 123);

if (topic != null) {
  print('Found topic: ${topic.name}');
} else {
  print('Topic not found or access denied');
}
```

**Parameters:**
- `topicId` (required): The ID of the topic to retrieve

**Returns:** `NotificationTopic?` (null if not found or access denied)

### 4. Update Topic

Updates topic properties. Only provided fields will be updated.

```dart
final updatedTopic = await client.notification.updateTopic(
  topicId: 123,
  name: 'Updated Topic Name',
  enabled: false,
);

print('Topic updated: ${updatedTopic.name}');
```

**Parameters:**
- `topicId` (required): The ID of the topic to update
- `name` (optional): New name for the topic
- `description` (optional): New description (pass empty string to clear)
- `config` (optional): New JSON configuration string
- `enabled` (optional): Enable/disable the topic

**Returns:** `NotificationTopic` with updated values

**Throws:** `StateError` if topic not found or access denied

### 5. Delete Topic

Permanently deletes a notification topic.

```dart
final deleted = await client.notification.deleteTopic(topicId: 123);

if (deleted) {
  print('Topic deleted successfully');
} else {
  print('Topic not found or access denied');
}
```

**Parameters:**
- `topicId` (required): The ID of the topic to delete

**Returns:** `bool` (true if deleted, false if not found)

### 6. Regenerate API Key

Generates a new API key for a topic, invalidating the old one.

```dart
final newApiKey = await client.notification.regenerateApiKey(topicId: 123);

print('New API key: $newApiKey');
```

**Parameters:**
- `topicId` (required): The ID of the topic

**Returns:** `String` containing the new API key

**Throws:** `StateError` if topic not found or access denied

## API Key Format

API keys are generated in the format: `remotly_{32_base64url_chars}`

Example: `remotly_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`

## Webhook Usage

Once you have created a topic and obtained its API key, you can send notifications to it via webhook:

```bash
curl -X POST https://api.remotly.app/api/notify/123 \
  -H "X-API-Key: remotly_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Alert",
    "body": "Something happened!",
    "priority": "high"
  }'
```

See `webhook_endpoint.dart` for supported payload formats.

## Error Handling

```dart
try {
  final topic = await client.notification.createTopic(
    name: 'My Topic',
  );
} on AuthenticationException catch (e) {
  print('Not authenticated: $e');
} on ArgumentError catch (e) {
  print('Invalid input: $e');
} on StateError catch (e) {
  print('Topic not found or access denied: $e');
}
```

## Security Notes

1. **API Key Security**: Keep API keys secure. Regenerate if compromised.
2. **Ownership Verification**: All operations verify topic ownership.
3. **Authentication Required**: All methods require user authentication.
4. **Audit Logging**: Security events are logged for monitoring.

## Testing

Example integration test (requires `serverpod generate` to be run first):

```dart
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('NotificationEndpoint', (sessionBuilder, endpoints) {
    test('creates topic successfully', () async {
      // Arrange
      final session = sessionBuilder.build();

      // Act
      final topic = await endpoints.notification.createTopic(
        session,
        name: 'Test Topic',
        description: 'Test description',
      );

      // Assert
      expect(topic.name, 'Test Topic');
      expect(topic.apiKey, startsWith('remotly_'));
      expect(topic.enabled, isTrue);
    });

    test('lists topics for user', () async {
      final session = sessionBuilder.build();

      // Create a topic first
      await endpoints.notification.createTopic(
        session,
        name: 'Topic 1',
      );

      // List topics
      final topics = await endpoints.notification.listTopics(session);

      expect(topics.length, greaterThan(0));
      expect(topics.first.name, 'Topic 1');
    });

    test('throws when updating non-existent topic', () async {
      final session = sessionBuilder.build();

      expect(
        () => endpoints.notification.updateTopic(
          session,
          999999,
          name: 'New Name',
        ),
        throwsStateError,
      );
    });
  });
}
```

## Next Steps

After the pre-existing syntax errors in other endpoints are fixed:

1. Run `serverpod generate` to generate client code
2. Run `serverpod create-migration` if needed
3. Run integration tests
4. Deploy to production
