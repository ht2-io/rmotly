# Rmotly Authentication

This document describes the authentication system in Rmotly, which uses Serverpod's built-in authentication module.

## Overview

Rmotly uses **Serverpod Auth** for user authentication with email/password credentials. The authentication system provides:

- User registration with email verification
- Email/password sign-in
- Session management with JWT tokens
- Password reset functionality
- Secure password hashing (bcrypt)
- Session invalidation on logout

## Architecture

```
┌─────────────────────┐
│   Flutter App       │
│   (rmotly_app)      │
└──────────┬──────────┘
           │ JWT Token in Headers
           │
┌──────────▼──────────┐
│  Serverpod Server   │
│  (rmotly_server)    │
├─────────────────────┤
│  serverpod_auth     │
│  module             │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│   PostgreSQL        │
│   Auth Tables:      │
│   - user_info       │
│   - email_auth      │
│   - auth_key        │
└─────────────────────┘
```

## Database Tables

The auth module creates the following tables:

### serverpod_user_info
Main user information table.
- `id` - Primary key
- `userIdentifier` - Unique user identifier (UUID)
- `userName` - Optional username
- `fullName` - User's full name
- `email` - User's email address
- `created` - Account creation timestamp
- `imageUrl` - Optional profile image URL
- `scopeNames` - JSON array of user scopes/permissions
- `blocked` - Whether the user is blocked

### serverpod_email_auth
Email/password authentication data.
- `id` - Primary key
- `userId` - Foreign key to serverpod_user_info
- `email` - Email address (unique)
- `hash` - Bcrypt password hash

### serverpod_email_create_request
Pending account creation requests.
- `id` - Primary key
- `userName` - Requested username
- `email` - Email address
- `hash` - Password hash
- `verificationCode` - Email verification code

### serverpod_email_reset
Password reset requests.
- `id` - Primary key
- `userId` - Foreign key to serverpod_user_info
- `verificationCode` - Reset verification code
- `expiration` - Code expiration timestamp

### serverpod_email_failed_sign_in
Failed sign-in attempts (for rate limiting).
- `id` - Primary key
- `email` - Email address
- `time` - Attempt timestamp
- `ipAddress` - IP address of attempt

### serverpod_auth_key
Authentication keys/tokens for sessions.
- `id` - Primary key
- `userId` - Foreign key to serverpod_user_info
- `hash` - Token hash
- `scopeNames` - JSON array of scopes
- `method` - Authentication method

## Authentication Endpoints

Serverpod Auth provides the following endpoints automatically:

### Registration

```dart
// Create account
await client.modules.auth.email.createAccountRequest(
  userName: 'john',
  email: 'john@example.com',
  password: 'secure_password',
);

// Verify email with code sent to email
await client.modules.auth.email.createAccount(
  email: 'john@example.com',
  verificationCode: '123456',
);
```

### Sign In

```dart
// Sign in with email/password
final authResponse = await client.modules.auth.email.authenticate(
  email: 'john@example.com',
  password: 'secure_password',
);

if (authResponse.success) {
  // User is now authenticated
  final userInfo = authResponse.userInfo;
  final authToken = authResponse.key;
  
  // Store token for future requests
  await client.authenticationKeyManager?.put(authToken);
}
```

### Session Management

```dart
// Check if user is authenticated
final isAuthenticated = await client.sessionManager.isSignedIn();

// Get current user info
final userInfo = await client.modules.auth.getUserInfo();

// Sign out
await client.modules.auth.signOut();
```

### Password Reset

```dart
// Request password reset
await client.modules.auth.email.initiatePasswordReset(
  email: 'john@example.com',
);

// Reset password with code sent to email
await client.modules.auth.email.resetPassword(
  verificationCode: '123456',
  password: 'new_secure_password',
);
```

## Server Configuration

### AuthConfig (lib/server.dart)

```dart
auth.AuthConfig.set(auth.AuthConfig(
  // Send validation email when users sign up
  sendValidationEmail: (session, email, validationCode) async {
    // TODO: Implement email sending via SMTP or email service
    print('Validation code for $email: $validationCode');
    return true;
  },
  
  // Send password reset email
  sendPasswordResetEmail: (session, userInfo, validationCode) async {
    // TODO: Implement password reset email
    print('Password reset code for ${userInfo.email}: $validationCode');
    return true;
  },
  
  // Callback when user is created
  onUserCreated: (session, userInfo) async {
    session.log('New user created: ${userInfo.id} (${userInfo.email})');
  },
  
  // Callback when user signs in
  onUserUpdated: (session, userInfo) async {
    session.log('User updated: ${userInfo.id}');
  },
  
  // Password constraints
  maxPasswordLength: 128,
  minPasswordLength: 8,
));
```

## Security Features

### Password Hashing
- Uses **bcrypt** with automatic salt generation
- Configurable cost factor (default: 10)
- Passwords are never stored in plain text

### Rate Limiting
- Failed sign-in attempts are tracked per email/IP
- Prevents brute force attacks
- Configurable lockout thresholds

### Session Tokens
- JWT-based authentication tokens
- Tokens include user ID and scopes
- Configurable expiration times
- Tokens are invalidated on sign-out

### Email Verification
- Verification codes are time-limited
- Codes are single-use
- Accounts cannot sign in until verified

## Protected Endpoints

All Rmotly endpoints that require authentication check for a valid session:

```dart
Future<Result> someProtectedEndpoint(Session session) async {
  // Get authenticated user ID
  final authInfo = await session.authenticated;
  final userId = authInfo?.userId;
  
  if (userId == null) {
    throw AuthenticationException('User not authenticated');
  }
  
  // User is authenticated, proceed with operation
  // ...
}
```

### Currently Protected Endpoints

- **PushSubscriptionEndpoint**: All methods require authentication
  - `registerEndpoint` - Register push notification endpoint
  - `unregisterEndpoint` - Remove push endpoint
  - `listSubscriptions` - List user's subscriptions
  - `updateSubscription` - Enable/disable subscription

- **NotificationStreamEndpoint**: Streaming methods require authentication
  - `streamNotifications` - Real-time WebSocket notifications

- **SSEEndpoint**: Server-sent events require authentication
  - `getConnectionInfo` - Get SSE connection status
  - `getQueuedNotifications` - Retrieve queued notifications

## Email Service Integration

Currently, the server **prints validation codes to the console** for development. For production, you must integrate an email service:

### Recommended Email Services

1. **SendGrid** - Transactional email API
2. **Mailgun** - Email sending service
3. **Amazon SES** - AWS Simple Email Service
4. **SMTP** - Any SMTP server

### Example Integration (SendGrid)

Add dependency to `pubspec.yaml`:
```yaml
dependencies:
  mailer: ^6.0.0
```

Update `lib/server.dart`:
```dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

auth.AuthConfig.set(auth.AuthConfig(
  sendValidationEmail: (session, email, validationCode) async {
    final smtpServer = SmtpServer(
      'smtp.sendgrid.net',
      username: 'apikey',
      password: env['SENDGRID_API_KEY'],
      port: 587,
    );
    
    final message = Message()
      ..from = Address('noreply@rmotly.app', 'Rmotly')
      ..recipients.add(email)
      ..subject = 'Verify your Rmotly account'
      ..text = 'Your verification code is: $validationCode'
      ..html = '<p>Your verification code is: <strong>$validationCode</strong></p>';
    
    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      session.log('Failed to send email: $e', level: LogLevel.error);
      return false;
    }
  },
  // ... rest of config
));
```

## Testing Authentication

### Manual Testing

1. Start the server:
```bash
cd rmotly_server
dart bin/main.dart --apply-migrations
```

2. Use the Serverpod client to test registration:
```dart
final client = Client('http://localhost:8080/');

// Create account
await client.modules.auth.email.createAccountRequest(
  userName: 'testuser',
  email: 'test@example.com',
  password: 'password123',
);

// Check console for verification code
// Then verify:
await client.modules.auth.email.createAccount(
  email: 'test@example.com',
  verificationCode: 'CODE_FROM_CONSOLE',
);

// Sign in
final authResponse = await client.modules.auth.email.authenticate(
  email: 'test@example.com',
  password: 'password123',
);

print('Authenticated: ${authResponse.success}');
print('User ID: ${authResponse.userInfo?.id}');
```

### Integration Tests

See `rmotly_server/test/integration/auth_test.dart` for authentication integration tests.

## Next Steps

1. **Email Service**: Integrate a production email service (SendGrid, Mailgun, etc.)
2. **Custom User Fields**: Extend the user model with app-specific fields (link `serverpod_user_info.id` to `users.id`)
3. **OAuth Providers**: Add Google/Apple sign-in support
4. **Two-Factor Authentication**: Add 2FA for enhanced security
5. **User Profiles**: Implement user profile management endpoints

## References

- [Serverpod Authentication Documentation](https://docs.serverpod.dev/concepts/authentication)
- [Serverpod Email Auth Setup](https://docs.serverpod.dev/concepts/authentication/providers/email/setup)
- [Serverpod Security Best Practices](https://docs.serverpod.dev/concepts/authentication/setup#security)
