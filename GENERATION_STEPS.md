# Serverpod Code Generation Required

This PR creates the User and NotificationTopic models for the Remotly API.

⚠️ **IMPORTANT**: Generated files are gitignored. You must run `serverpod generate` locally or in CI before the code will compile.

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

## Quick Start (Automated)

Run the provided script from the repository root:

```bash
chmod +x generate_models.sh
./generate_models.sh
```

## Manual Steps

### 1. Run Serverpod Code Generation

```bash
cd remotly_server
serverpod generate
```

This generates (not committed to git):
- Model classes in `lib/src/generated/`
- Client code in `remotly_client/lib/src/protocol/`
- Test tools in `test/integration/test_tools/`

### 2. Create Database Migration

Since these models have database tables, create a migration:

```bash
cd remotly_server
serverpod create-migration
```

This creates a migration file in `migrations/` (this SHOULD be committed).

### 3. Apply Migration to Database

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

## Model Structure Reference

### User

After generation, the User model will have these properties:

```dart
class User {
  int? id;                  // Auto-generated primary key
  String email;             // Unique email address
  String? displayName;      // Optional display name
  String? fcmToken;         // Firebase Cloud Messaging token
  DateTime createdAt;       // Creation timestamp
  DateTime updatedAt;       // Last update timestamp
}
```

**Database Table**: `users`  
**Indexes**: 
- `user_email_idx` - Unique index on email

### NotificationTopic

After generation, the NotificationTopic model will have these properties:

```dart
class NotificationTopic {
  int? id;                  // Auto-generated primary key
  int userId;               // Foreign key to users table
  String name;              // Topic name
  String? description;      // Optional description
  String apiKey;            // Unique API key for webhook auth
  bool enabled;             // Whether topic is active
  String config;            // JSON configuration string
  DateTime createdAt;       // Creation timestamp
  DateTime updatedAt;       // Last update timestamp
}
```

**Database Table**: `notification_topics`  
**Indexes**:
- `notification_topic_user_idx` - Index on userId for fast user lookups
- `notification_topic_api_key_idx` - Unique index on apiKey for authentication

**Relations**:
- `userId` → `users.id` (many-to-one)

## Configuration JSON Structure

The `config` field in NotificationTopic stores JSON with this structure:

```json
{
  "titleTemplate": "{{title}}",
  "bodyTemplate": "{{message}}",
  "imageUrlField": "image",
  "actionUrlField": "url",
  "priority": "high",
  "soundName": "default",
  "channelId": "notifications"
}
```

Template variables use `{{fieldName}}` syntax for dynamic content extraction from webhook payloads.

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
