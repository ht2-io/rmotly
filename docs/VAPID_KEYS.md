# VAPID Keys for WebPush

## Overview

VAPID (Voluntary Application Server Identification) keys are used to identify your application server when sending WebPush notifications. They are based on ECDSA P-256 elliptic curve cryptography and are required for the WebPush protocol as defined in [RFC 8292](https://datatracker.ietf.org/doc/html/rfc8292).

## Why VAPID Keys?

- **Server Identification**: Allows push services to identify which server is sending notifications
- **Security**: Cryptographically signs push messages to prevent spoofing
- **Accountability**: Push services can contact the server operator if needed
- **Privacy**: Enables end-to-end encryption of push notification payloads

## Generating VAPID Keys

Rmotly provides two methods for generating VAPID keys:

### Method 1: Using Dart Script (Recommended)

The Dart script is included in the repository and requires no additional dependencies:

```bash
cd rmotly_server
dart run bin/generate_vapid_keys.dart
```

**Output:**
```
Generating VAPID keys for WebPush...

Add these to your configuration:

vapid:
  subject: 'mailto:admin@yourdomain.com'
  publicKey: 'BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4'
  privateKey: '-QdC8-Sj3MS-s2wRUOnz-C2d-ZizkEL9046CPxVQAzA'

Or set as environment variables:
  export VAPID_SUBJECT="mailto:admin@yourdomain.com"
  export VAPID_PUBLIC_KEY="BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4"
  export VAPID_PRIVATE_KEY="-QdC8-Sj3MS-s2wRUOnz-C2d-ZizkEL9046CPxVQAzA"

Public key for client apps (safe to share):
  BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4
```

### Method 2: Using web-push npm Package

If you have Node.js installed, you can also use the `web-push` npm package:

```bash
npx web-push generate-vapid-keys
```

**Output:**
```
=======================================

Public Key:
BB0pFU-5hSh2uahTCg3KbIPKtYg4uOxXiOphe65kXgkGBiWYC191-HgLcswEWamzGjA4PI1YsN_Z3DyySQuMolc

Private Key:
lgSTc_VjOMO0TLWWX7orkAytoLwNVtge2ohSMzCCTSU

=======================================
```

## Configuration

### Development Environment

For local development, keys are stored directly in the configuration file:

**File:** `rmotly_server/config/development.yaml`

```yaml
vapid:
  subject: 'mailto:admin@localhost'
  publicKey: 'BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkrxZJjSgSnfckjBJuBkr3qBUYIHBQFLXYp5Nksh8U'
  privateKey: 'UUxI4O8-FbRouADVXGXRV1Nv7bQZwA7UcL1QQXDJ3Gg'
```

⚠️ **Note:** The development keys are public and should **NEVER** be used in production.

### Production Environment

For production, keys should be stored as environment variables for security:

**File:** `rmotly_server/config/production.yaml.template`

```yaml
vapid:
  subject: ${VAPID_SUBJECT}
  publicKey: ${VAPID_PUBLIC_KEY}
  privateKey: ${VAPID_PRIVATE_KEY}
```

**Set environment variables:**

```bash
export VAPID_SUBJECT="mailto:admin@yourdomain.com"
export VAPID_PUBLIC_KEY="your_generated_public_key"
export VAPID_PRIVATE_KEY="your_generated_private_key"
```

### Docker Deployment

When deploying with Docker, add VAPID keys to your `.env` file:

**File:** `.env`

```bash
# VAPID keys for WebPush (generate with: dart run bin/generate_vapid_keys.dart)
VAPID_SUBJECT=mailto:admin@yourdomain.com
VAPID_PUBLIC_KEY=BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4
VAPID_PRIVATE_KEY=-QdC8-Sj3MS-s2wRUOnz-C2d-ZizkEL9046CPxVQAzA
```

Then reference them in `docker-compose.yaml`:

```yaml
services:
  rmotly-api:
    environment:
      VAPID_PUBLIC_KEY: ${VAPID_PUBLIC_KEY}
      VAPID_PRIVATE_KEY: ${VAPID_PRIVATE_KEY}
      VAPID_SUBJECT: ${VAPID_SUBJECT}
```

## Key Rotation

You should rotate VAPID keys periodically or immediately if they are compromised.

### When to Rotate Keys

- **Scheduled rotation**: Every 6-12 months as a security best practice
- **Security breach**: Immediately if keys are exposed or compromised
- **Key loss**: If private key is lost (public key is useless without private key)
- **Personnel changes**: When team members with key access leave

### How to Rotate Keys

1. **Generate new keys:**
   ```bash
   cd rmotly_server
   dart run bin/generate_vapid_keys.dart
   ```

2. **Update configuration:**
   - Development: Update `config/development.yaml`
   - Production: Update environment variables

3. **Restart services:**
   ```bash
   # Docker deployment
   docker-compose restart rmotly-api
   
   # Manual deployment
   systemctl restart rmotly-api
   ```

4. **Update client apps:**
   - The public key needs to be distributed to client applications
   - Update the public key in your Flutter app configuration
   - Push an app update to users

5. **Invalidate old subscriptions:**
   - Existing push subscriptions will fail with the old key
   - Users will need to re-register for push notifications
   - This is automatic when they open the app

### Zero-Downtime Rotation (Advanced)

For large-scale deployments, you can implement a grace period:

1. Add the new key alongside the old key
2. Start issuing notifications with the new key
3. Wait for the grace period (e.g., 30 days)
4. Remove the old key

This requires code changes to support multiple VAPID keys simultaneously.

## Security Best Practices

### Key Storage

✅ **DO:**
- Store private keys as environment variables in production
- Use secrets management systems (AWS Secrets Manager, HashiCorp Vault, etc.)
- Restrict access to production keys to authorized personnel only
- Keep keys out of version control
- Use different keys for development, staging, and production

❌ **DON'T:**
- Commit private keys to git
- Share private keys via email or chat
- Use development keys in production
- Store keys in plain text files on production servers
- Reuse keys across different projects

### Subject Field

The `subject` field must be a valid `mailto:` or `https:` URL:

```yaml
# Email (recommended)
subject: 'mailto:admin@yourdomain.com'

# HTTPS URL
subject: 'https://yourdomain.com'
```

This allows push services to contact you if there are issues.

### Key Format

VAPID keys are base64url-encoded (without padding):

- **Public key**: 65 bytes (uncompressed ECDSA P-256 point)
- **Private key**: 32 bytes (ECDSA P-256 scalar)

Example public key:
```
BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4
```

Example private key:
```
-QdC8-Sj3MS-s2wRUOnz-C2d-ZizkEL9046CPxVQAzA
```

## Troubleshooting

### "Invalid VAPID key" error

**Symptom:** Push notifications fail with authentication errors

**Solutions:**
1. Verify keys are correctly copied (no extra spaces or line breaks)
2. Ensure private key matches public key
3. Check that keys are base64url-encoded (no padding `=` characters)
4. Regenerate keys if corrupted

### Push subscriptions not working after key rotation

**Symptom:** Existing users stop receiving notifications

**Expected behavior:** This is normal. Users need to re-subscribe.

**Solution:**
- Users will automatically re-subscribe when they open the app
- Optionally, show a one-time prompt asking users to enable notifications again

### "Subject must be a valid URL" error

**Symptom:** Server fails to start with VAPID configuration error

**Solution:**
```yaml
# Correct formats:
subject: 'mailto:admin@example.com'
subject: 'https://example.com'

# Incorrect formats:
subject: 'admin@example.com'      # Missing mailto:
subject: 'http://example.com'     # Must use https (not http)
```

## Testing VAPID Keys

### Verify Keys are Loaded

Check server logs on startup:

```bash
docker-compose logs rmotly-api | grep -i vapid
```

Expected output:
```
[INFO] VAPID configuration loaded successfully
[INFO] VAPID subject: mailto:admin@yourdomain.com
[INFO] VAPID public key: BEnFt...
```

### Test Push Notification

Use the API to send a test notification:

```bash
curl -X POST http://localhost:8080/push/test \
  -H "Authorization: Bearer your_token" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "body": "Testing VAPID keys"
  }'
```

### Validate Key Pair

You can verify that a public and private key pair match:

```dart
// In rmotly_server, create a test script
import 'package:pointycastle/export.dart';
import 'dart:convert';

void main() {
  final publicKeyBase64 = 'your_public_key';
  final privateKeyBase64 = 'your_private_key';
  
  // Decode keys
  final publicKeyBytes = base64Url.decode(publicKeyBase64);
  final privateKeyBytes = base64Url.decode(privateKeyBase64);
  
  // Verify lengths
  print('Public key length: ${publicKeyBytes.length} bytes'); // Should be 65
  print('Private key length: ${privateKeyBytes.length} bytes'); // Should be 32
  
  if (publicKeyBytes.length == 65 && privateKeyBytes.length == 32) {
    print('✓ Keys appear valid');
  } else {
    print('✗ Keys have incorrect length');
  }
}
```

## Client Configuration

The public key needs to be shared with client applications:

### Flutter App

**File:** `rmotly_app/lib/core/push_constants.dart` (create if needed)

```dart
/// VAPID public key for WebPush subscription
/// Safe to commit to version control
const String vapidPublicKey = 
    'BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4';
```

### Web Application

```javascript
// public/sw.js or app/push-config.js
const VAPID_PUBLIC_KEY = 'BEnFtxXWRZq26wFWBYvQj1W5AVGU8a567Bq5apKwlZhFw5ZHgAlGXEi9-ioCiIbJSWZtT38c6Ai9pULBqSSP5Q4';
```

## References

- [RFC 8292: VAPID for WebPush](https://datatracker.ietf.org/doc/html/rfc8292)
- [RFC 8030: Generic Event Delivery Using HTTP Push](https://datatracker.ietf.org/doc/html/rfc8030)
- [RFC 8291: Message Encryption for Web Push](https://datatracker.ietf.org/doc/html/rfc8291)
- [WebPush Protocol Overview](https://developers.google.com/web/fundamentals/push-notifications/web-push-protocol)
- [UnifiedPush Specification](https://unifiedpush.org/spec/definitions/)
- [Push Notification Design](./PUSH_NOTIFICATION_DESIGN.md)

## Quick Reference

```bash
# Generate new keys
cd rmotly_server && dart run bin/generate_vapid_keys.dart

# Or with npm
npx web-push generate-vapid-keys

# Set environment variables (production)
export VAPID_SUBJECT="mailto:admin@yourdomain.com"
export VAPID_PUBLIC_KEY="your_public_key"
export VAPID_PRIVATE_KEY="your_private_key"

# Restart server
docker-compose restart rmotly-api

# Test notification
curl -X POST http://localhost:8080/push/test \
  -H "Authorization: Bearer token" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "body": "Testing"}'
```
