# Security Best Practices - Rmotly

This document outlines security best practices for developing and deploying Rmotly.

## Table of Contents

1. [Credential Management](#credential-management)
2. [API Security](#api-security)
3. [Data Protection](#data-protection)
4. [Development Practices](#development-practices)
5. [Deployment Security](#deployment-security)

---

## Credential Management

### Encryption Keys

**Server-Side Encryption:**

The Rmotly server uses AES-256-GCM encryption for sensitive credentials. The encryption key MUST be:

1. **Stored as an environment variable:**
   ```bash
   export RMOTLY_ENCRYPTION_KEY="your-base64-encoded-key"
   ```

2. **Generated securely:**
   ```dart
   // Generate a new key
   final key = EncryptionService.generateKey();
   print('Store this securely: $key');
   ```

3. **Never committed to version control:**
   ```bash
   # Add to .gitignore
   echo "*.env" >> .gitignore
   echo ".env.local" >> .gitignore
   ```

4. **Rotated periodically:**
   ```dart
   // Key rotation example
   final oldService = EncryptionService();
   final newKey = EncryptionService.generateKey();
   final newService = EncryptionService.withKey(newKey);
   
   // Re-encrypt all credentials
   for (final action in actions) {
     if (action.encryptedCredentials != null) {
       action.encryptedCredentials = oldService.reencrypt(
         action.encryptedCredentials!,
         newService,
       );
       await action.save();
     }
   }
   ```

### Action Credentials

**Storing Credentials:**

```dart
// Encrypt credentials before storing
final credentials = {
  'apiKey': 'secret-api-key',
  'token': 'bearer-token',
};

final encryptionService = EncryptionService();
final encrypted = encryptionService.encryptMap(credentials);

final action = Action(
  name: 'API Call',
  encryptedCredentials: encrypted,
  // ... other fields
);
await action.save(session);
```

**Using Credentials:**

```dart
// Decrypt credentials when executing action
final encryptionService = EncryptionService();
final credentials = encryptionService.decryptMap(
  action.encryptedCredentials!,
);

// Use in headers
final headers = {
  'Authorization': 'Bearer ${credentials['token']}',
  'X-API-Key': credentials['apiKey'],
};
```

### API Keys

**Generation:**

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

String generateApiKey() {
  final random = Random.secure();
  final bytes = Uint8List.fromList(
    List<int>.generate(32, (i) => random.nextInt(256)),
  );
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return 'rmotly_$hex';
}
```

**Validation:**

```dart
// Use constant-time comparison
bool validateApiKey(String provided, String stored) {
  if (provided.length != stored.length) return false;
  
  var result = 0;
  for (var i = 0; i < provided.length; i++) {
    result |= provided.codeUnitAt(i) ^ stored.codeUnitAt(i);
  }
  return result == 0;
}
```

---

## API Security

### Rate Limiting

**Server Implementation:**

```dart
import 'package:rmotly_server/src/services/rate_limit_service.dart';

class MyEndpoint extends Endpoint {
  final rateLimiter = RateLimitService(RateLimitConfig.userEvents);
  
  Future<Response> createEvent(Session session, Event event) async {
    final userId = await session.authenticated();
    
    // Check rate limit
    if (rateLimiter.isRateLimited('user:$userId')) {
      final info = rateLimiter.getRateLimitInfo('user:$userId');
      throw RateLimitException(
        'Too many requests',
        info: RateLimitInfo(
          limit: info['limit'] as int,
          remaining: info['remaining'] as int,
        ),
      );
    }
    
    // Process request
    return await processEvent(event);
  }
}
```

**Rate Limit Headers:**

Always include rate limit information in responses:

```dart
Response buildResponse(dynamic data, String userId, RateLimitService limiter) {
  final info = limiter.getRateLimitInfo('user:$userId');
  
  return Response(
    200,
    data,
    headers: {
      'X-RateLimit-Limit': '${info['limit']}',
      'X-RateLimit-Remaining': '${info['remaining']}',
      'X-RateLimit-Reset': '${info['reset']}',
    },
  );
}
```

### Input Validation

**URL Validation:**

```dart
bool isValidUrl(String url, {bool allowLocal = false}) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  
  // Check scheme
  if (!uri.isScheme('http') && !uri.isScheme('https')) {
    return false;
  }
  
  // Block private networks in production
  if (!allowLocal) {
    if (uri.host == 'localhost' ||
        uri.host.startsWith('127.') ||
        uri.host.startsWith('192.168.') ||
        uri.host.startsWith('10.') ||
        uri.host.startsWith('172.')) {
      return false;
    }
  }
  
  // Length limit
  if (url.length > 2048) {
    return false;
  }
  
  return true;
}
```

**Payload Size Limits:**

```dart
Future<void> validatePayload(HttpRequest request) async {
  const maxSize = 1024 * 1024; // 1MB
  
  var size = 0;
  await for (final chunk in request) {
    size += chunk.length;
    if (size > maxSize) {
      throw PayloadTooLargeException('Maximum payload size is 1MB');
    }
  }
}
```

**JSON Depth Limit:**

```dart
int getJsonDepth(dynamic json, [int current = 0]) {
  if (json is Map) {
    var maxDepth = current;
    for (final value in json.values) {
      final depth = getJsonDepth(value, current + 1);
      if (depth > maxDepth) maxDepth = depth;
    }
    return maxDepth;
  } else if (json is List) {
    var maxDepth = current;
    for (final value in json) {
      final depth = getJsonDepth(value, current + 1);
      if (depth > maxDepth) maxDepth = depth;
    }
    return maxDepth;
  }
  return current;
}

void validateJsonDepth(dynamic json) {
  const maxDepth = 20;
  if (getJsonDepth(json) > maxDepth) {
    throw ValidationException('JSON nesting too deep');
  }
}
```

---

## Data Protection

### Encryption at Rest

**Database Encryption:**

For PostgreSQL, enable transparent data encryption:

```sql
-- Enable encryption
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_cert_file = '/path/to/server.crt';
ALTER SYSTEM SET ssl_key_file = '/path/to/server.key';
```

**Field-Level Encryption:**

```dart
// Encrypt before storing
final encryption = EncryptionService();
final encrypted = encryption.encrypt(sensitiveData);
model.encryptedField = encrypted;
await model.save();

// Decrypt when retrieving
final decrypted = encryption.decrypt(model.encryptedField);
```

### Encryption in Transit

**HTTPS Configuration:**

```yaml
# docker-compose.yml
services:
  traefik:
    image: traefik:v2.10
    command:
      - --providers.docker
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.email=admin@example.com
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
    labels:
      # Redirect HTTP to HTTPS
      - traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https
      - traefik.http.routers.redirs.rule=hostregexp(`{host:.+}`)
      - traefik.http.routers.redirs.entrypoints=web
      - traefik.http.routers.redirs.middlewares=redirect-to-https
```

**Security Headers:**

```dart
Response addSecurityHeaders(Response response) {
  return response.copyWith(
    headers: {
      ...response.headers,
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Content-Security-Policy': "default-src 'self'",
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    },
  );
}
```

### Secure Storage (Mobile)

**Flutter Implementation:**

```dart
import 'package:rmotly_app/shared/services/secure_storage_service.dart';

// Store sensitive data
final storage = SecureStorageService();
await storage.saveAuthToken(token);
await storage.write('user_api_key', apiKey);

// Retrieve sensitive data
final token = await storage.getAuthToken();
final apiKey = await storage.read('user_api_key');

// Clear on logout
await storage.clearAuthData();
```

---

## Development Practices

### Code Review Checklist

Before merging, verify:

- [ ] No hardcoded credentials
- [ ] Input validation on all user inputs
- [ ] Rate limiting on public endpoints
- [ ] Sensitive data encrypted
- [ ] Error messages don't leak information
- [ ] SQL queries use ORM (no raw SQL)
- [ ] User isolation enforced
- [ ] HTTPS enforced
- [ ] Dependencies updated

### Secret Scanning

**Pre-commit Hook:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for potential secrets
if git diff --cached | grep -E "(password|secret|api[_-]?key|token)" -i; then
  echo "⚠️  Warning: Potential secret detected in commit"
  echo "Review the changes and use environment variables instead"
  exit 1
fi
```

### Dependency Updates

```bash
# Server
cd rmotly_server
dart pub outdated
dart pub upgrade

# App
cd rmotly_app
flutter pub outdated
flutter pub upgrade
```

---

## Deployment Security

### Environment Variables

**Development (.env.development):**

```bash
DATABASE_URL=postgresql://dev:dev@localhost/rmotly_dev
REDIS_URL=redis://localhost:6379
RMOTLY_ENCRYPTION_KEY=dev-key-only
```

**Production (.env.production):**

```bash
DATABASE_URL=postgresql://user:pass@db.example.com/rmotly
REDIS_URL=redis://redis.example.com:6379
RMOTLY_ENCRYPTION_KEY=${SECRET_ENCRYPTION_KEY}
```

### Docker Security

**Best Practices:**

```dockerfile
# Use specific versions
FROM dart:3.6.2 AS build

# Don't run as root
RUN useradd -m -s /bin/bash rmotly
USER rmotly

# Copy only necessary files
COPY --chown=rmotly:rmotly pubspec.* ./
RUN dart pub get

# Use multi-stage build
FROM scratch
COPY --from=build /app /app
```

### Monitoring

**Security Events to Log:**

```dart
class SecurityLogger {
  static void logAuthAttempt(String username, bool success) {
    log(
      'AUTH_ATTEMPT',
      data: {'username': username, 'success': success},
      level: success ? LogLevel.info : LogLevel.warning,
    );
  }
  
  static void logRateLimitHit(String key) {
    log('RATE_LIMIT_HIT', data: {'key': key}, level: LogLevel.warning);
  }
  
  static void logInvalidApiKey(String apiKey) {
    log(
      'INVALID_API_KEY',
      data: {'key': apiKey.substring(0, 8)}, // Only log prefix
      level: LogLevel.warning,
    );
  }
}
```

---

## Incident Response

### If Credentials are Compromised

1. **Immediate Actions:**
   - Rotate compromised credentials immediately
   - Revoke affected API keys
   - Force logout all sessions if auth token compromised

2. **Investigation:**
   - Check access logs for unauthorized access
   - Identify scope of compromise
   - Document timeline of events

3. **Notification:**
   - Notify affected users
   - Document in security incident log
   - Update security measures

### Reporting Vulnerabilities

**Internal:** Contact security team or team lead

**External:** Email security@rmotly.io (to be set up)

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (optional)

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Dart Security Guidelines](https://dart.dev/guides/security)
- [Flutter Security](https://flutter.dev/docs/deployment/security)
- [Serverpod Documentation](https://docs.serverpod.dev/)

---

**Document Version:** 1.0  
**Last Updated:** January 15, 2026
