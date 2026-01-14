# Next Steps: Serverpod Code Generation

This PR creates the User and NotificationTopic models for the Remotly API.

## Models Created

1. **User Model** (`user.spy.yaml`)
   - Basic user information
   - Email with unique index
   - FCM token for push notifications
   - Timestamps (createdAt, updatedAt)

2. **NotificationTopic Model** (`notification_topic.spy.yaml`)
   - Notification channel management
   - Relation to User model
   - Unique API key for webhook authentication
   - JSON config for notification templates
   - Enable/disable flag
   - Indexed on userId and apiKey

## Required Actions

### 1. Run Serverpod Code Generation

```bash
cd remotly_server
serverpod generate
```

This will:
- Generate model classes in `lib/src/generated/`
- Update client code in `remotly_client/`
- Create protocol files

### 2. Create Database Migration

Since these models have database tables, create a migration:

```bash
cd remotly_server
serverpod create-migration
```

### 3. Apply Migration

```bash
cd remotly_server
serverpod apply-migrations
```

### 4. Verify Server Starts

```bash
cd remotly_server
dart bin/main.dart
```

Expected output:
```
Server starting...
Serverpod listening on port 8080
```

### 5. Run Tests

```bash
cd remotly_server
dart test
```

### 6. Update Flutter App Dependencies

```bash
cd remotly_app
flutter pub get
```

## Model Structure

### User
```dart
class User {
  int? id;
  String email;
  String? displayName;
  String? fcmToken;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### NotificationTopic
```dart
class NotificationTopic {
  int? id;
  int userId;              // Foreign key to users
  String name;
  String? description;
  String apiKey;           // Unique API key for webhooks
  bool enabled;
  String config;           // JSON configuration
  DateTime createdAt;
  DateTime updatedAt;
}
```

## Troubleshooting

If generation fails:
1. Check YAML syntax in model files
2. Ensure PostgreSQL is running
3. Verify config/development.yaml has correct DB credentials
4. Check that serverpod CLI is installed: `dart pub global activate serverpod_cli`

## Related Tasks

This PR addresses:
- TASKS.md Task 2.1.1: Create User model
- TASKS.md Task 2.1.4: Create NotificationTopic model
- GitHub Issue #4: Create NotificationTopic model for Serverpod
