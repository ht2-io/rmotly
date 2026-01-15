# Remotly - Push Notification System Design

## Executive Summary

This document outlines a self-hosted push notification architecture for Remotly that avoids dependency on Firebase Cloud Messaging (FCM) while supporting modern protocols and techniques.

### Key Requirements

- **Fully self-hostable** - No mandatory cloud dependencies
- **Single docker-compose deployment** - Entire stack (API, database, cache, push server) deployable with one command
- **User choice** - Users can choose their notification delivery method
- **Privacy-first** - End-to-end encrypted notifications

## Research Findings

### Protocol Comparison

| Protocol | Direction | Background Support | Complexity | 2025 Status |
|----------|-----------|-------------------|------------|-------------|
| **WebPush** (RFC8030/8291/8292) | Server→Client | Yes (via distributor) | Medium | Standard for UnifiedPush |
| **SSE** (Server-Sent Events) | Server→Client | Limited | Low | [Comeback in 2025](https://dev.to/haraf/server-sent-events-sse-vs-websockets-vs-long-polling-whats-best-in-2025-5ep8) |
| **WebSocket** | Bidirectional | Limited | Medium | Mature, built into Serverpod |
| **WebTransport** (HTTP/3+QUIC) | Bidirectional | No | High | [Still evolving](https://www.videosdk.live/developer-hub/webtransport/what-is-webtransport) |

### Self-Hosted Solutions Evaluated

| Solution | Protocol | Complexity | UnifiedPush | Notes |
|----------|----------|------------|-------------|-------|
| **[ntfy](https://ntfy.sh/)** | HTTP pub/sub | Low | Yes | Simple, battle-tested |
| **[Gotify](https://gotify.net/)** | WebSocket | Low | No | Good UI, Go-based |
| **Custom (Serverpod)** | WebSocket/SSE | Medium | Possible | No additional infra |

### Flutter Libraries Available

| Package | Purpose | Updated |
|---------|---------|---------|
| [`unifiedpush`](https://pub.dev/packages/unifiedpush) | UnifiedPush connector | Active |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | Display notifications | Active |
| [`flutter_client_sse`](https://pub.dev/packages/flutter_client_sse) | SSE client | Active |
| Serverpod Streaming | WebSocket streams | Built-in |

### Android Background Challenges

Per [Tutanota's implementation](https://f-droid.org/en/2018/09/03/replacing-gcm-in-tutanota.html):
- **Doze mode** (Android M+) prevents background network access
- Requires battery optimization exemption from user
- SSE proven efficient for push (used by Tuta, converges faster than WebSocket)

---

## Recommended Architecture

### Design Principles

1. **Self-hosted first** - No mandatory third-party dependencies
2. **User choice** - Support multiple delivery methods via UnifiedPush
3. **Graceful degradation** - Fall back to simpler protocols when needed
4. **Built on standards** - WebPush (RFC8030/8291/8292) for interoperability

### Three-Tier Notification Delivery

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        REMOTLY NOTIFICATION SYSTEM                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │   TIER 1: LIVE   │    │  TIER 2: PUSH    │    │ TIER 3: FALLBACK │  │
│  │   (Foreground)   │    │  (Background)    │    │   (Restricted)   │  │
│  ├──────────────────┤    ├──────────────────┤    ├──────────────────┤  │
│  │                  │    │                  │    │                  │  │
│  │  Serverpod       │    │  UnifiedPush     │    │  SSE Polling     │  │
│  │  Streaming       │    │  + WebPush       │    │  (HTTP/2)        │  │
│  │  (WebSocket)     │    │                  │    │                  │  │
│  │                  │    │  Distributors:   │    │  For:            │  │
│  │  For:            │    │  • ntfy (self)   │    │  • China/blocked │  │
│  │  • Real-time     │    │  • ntfy.sh       │    │  • Enterprise    │  │
│  │  • Low latency   │    │  • FCM (opt-in)  │    │  • Firewalls     │  │
│  │  • Bidirectional │    │  • NextPush      │    │                  │  │
│  │                  │    │                  │    │                  │  │
│  │  Latency: <100ms │    │  Latency: 1-5s   │    │  Latency: 5-30s  │  │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Tier 1: Live Streaming (Serverpod WebSocket)

**When**: App is in foreground or recently backgrounded

**How**: [Serverpod 2.1+ Streaming Methods](https://docs.serverpod.dev/concepts/streams)

```dart
// Server: remotly_server/lib/src/endpoints/notification_stream_endpoint.dart
class NotificationStreamEndpoint extends Endpoint {
  /// Stream notifications to connected client
  Stream<NotificationEvent> streamNotifications(Session session) async* {
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) throw AuthenticationException();

    // Subscribe to user's notification channel
    await for (final notification in NotificationService.subscribe(userId)) {
      yield notification;
    }
  }
}

// Client: remotly_app
final stream = client.notificationStream.streamNotifications();
await for (final notification in stream) {
  _showLocalNotification(notification);
}
```

**Advantages**:
- Already built into Serverpod (no additional infrastructure)
- Bidirectional communication
- Automatic WebSocket management
- Integrated authentication

### Tier 2: Background Push (UnifiedPush + WebPush)

**When**: App is closed or in deep background

**How**: [UnifiedPush](https://unifiedpush.org/) with WebPush encryption

```
External Webhook                    Remotly API                      User's Device
      │                                  │                                │
      │ POST /api/notify/{topicId}       │                                │
      │─────────────────────────────────>│                                │
      │                                  │                                │
      │                                  │ 1. Validate API key            │
      │                                  │ 2. Encrypt with WebPush        │
      │                                  │ 3. Send to user's push endpoint│
      │                                  │                                │
      │                                  │  POST (encrypted payload)      │
      │                                  │───────────────────────────────>│
      │                                  │           (via ntfy/FCM/etc)   │
      │                                  │                                │
      │                                  │                     4. Decrypt │
      │                                  │                     5. Display │
```

**Server Implementation**:

```dart
// remotly_server/lib/src/services/push_service.dart
import 'package:web_push/web_push.dart';

class PushService {
  final VapidKey _vapidKey;

  /// Send push notification using WebPush protocol (RFC8030)
  Future<void> sendPush({
    required String endpoint,
    required String p256dh,
    required String auth,
    required NotificationPayload payload,
  }) async {
    final webPush = WebPush(
      vapidKeys: _vapidKey,
      subject: 'mailto:noreply@remotly.app',
    );

    await webPush.sendNotification(
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      payload: jsonEncode(payload.toJson()),
      ttl: 3600,
    );
  }
}
```

**Flutter Client Implementation**:

```dart
// remotly_app/lib/core/services/push_service.dart
import 'package:unifiedpush/unifiedpush.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize local notifications
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Register UnifiedPush handlers
    UnifiedPush.initialize(
      onNewEndpoint: _onNewEndpoint,
      onMessage: _onMessage,
      onUnregistered: _onUnregistered,
    );
  }

  static Future<void> register() async {
    // Register with UnifiedPush (user chooses distributor)
    await UnifiedPush.registerApp(
      'remotly-notifications',
      features: ['webpush'], // Request WebPush support
    );
  }

  static void _onNewEndpoint(String endpoint, String instance) async {
    // Send endpoint to server for WebPush delivery
    await ApiClient.registerPushEndpoint(
      endpoint: endpoint,
      // Keys for WebPush encryption
      p256dh: await UnifiedPush.getPublicKey(),
      auth: await UnifiedPush.getAuthSecret(),
    );
  }

  static void _onMessage(Uint8List message, String instance) {
    final payload = NotificationPayload.fromBytes(message);
    _showNotification(payload);
  }

  static Future<void> _showNotification(NotificationPayload payload) async {
    await _notifications.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'remotly_notifications',
          'Remotly Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
```

### Tier 3: SSE Fallback

**When**: WebSocket blocked, UnifiedPush unavailable, or restricted networks

**How**: Server-Sent Events over HTTP/2

```dart
// Server: Add SSE endpoint
class NotificationSseEndpoint extends Endpoint {
  @override
  Future<void> handleRequest(Session session, HttpRequest request) async {
    final userId = await session.auth.authenticatedUserId;

    request.response.headers
      ..set('Content-Type', 'text/event-stream')
      ..set('Cache-Control', 'no-cache')
      ..set('Connection', 'keep-alive');

    await for (final notification in NotificationService.subscribe(userId)) {
      request.response.write('data: ${jsonEncode(notification)}\n\n');
      await request.response.flush();
    }
  }
}

// Client: flutter_client_sse
final client = SSEClient();
client.subscribeToSSE(
  url: '$apiUrl/notifications/sse',
  headers: {'Authorization': 'Bearer $token'},
).listen((event) {
  final notification = NotificationPayload.fromJson(jsonDecode(event.data));
  _showNotification(notification);
});
```

---

## Data Models

### Push Subscription (Server)

```yaml
# remotly_server/lib/src/models/push_subscription.yaml
class: PushSubscription
table: push_subscriptions
fields:
  userId: int, relation(parent=users)

  # UnifiedPush/WebPush endpoint
  endpoint: String

  # WebPush encryption keys (RFC8291)
  p256dh: String?
  authSecret: String?

  # Subscription metadata
  userAgent: String?
  deliveryMethod: String  # 'webpush', 'sse', 'websocket'

  # Status
  enabled: bool
  lastUsed: DateTime?
  failureCount: int

  createdAt: DateTime
  updatedAt: DateTime

indexes:
  push_user_idx:
    fields: userId
  push_endpoint_idx:
    fields: endpoint
    unique: true
```

### Notification Queue (Server)

```yaml
# remotly_server/lib/src/models/notification_queue.yaml
class: NotificationQueue
table: notification_queue
fields:
  userId: int, relation(parent=users)
  topicId: int?, relation(parent=notification_topics)

  # Payload
  title: String
  body: String
  data: String?  # JSON
  imageUrl: String?
  actionUrl: String?

  # Delivery tracking
  status: String  # 'pending', 'sent', 'delivered', 'failed'
  attempts: int
  lastAttempt: DateTime?
  error: String?

  # Metadata
  priority: String  # 'low', 'normal', 'high'
  ttl: int  # seconds
  collapseKey: String?  # for notification grouping

  createdAt: DateTime
  expiresAt: DateTime

indexes:
  queue_user_status_idx:
    fields: userId, status
  queue_expires_idx:
    fields: expiresAt
```

---

## Complete Self-Hosted Deployment

The entire Remotly stack is deployable with a single `docker-compose up -d` command.

### Full docker-compose.yml

```yaml
# docker-compose.yml
# Deploy entire Remotly stack: docker-compose up -d

version: '3.8'

services:
  # ===================
  # Core Infrastructure
  # ===================

  postgres:
    image: postgres:17-alpine
    container_name: remotly-postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-remotly}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-remotly}
      POSTGRES_DB: ${POSTGRES_DB:-remotly}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U remotly"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:8-alpine
    container_name: remotly-redis
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # ===================
  # Remotly API Server
  # ===================

  remotly-api:
    build:
      context: ./remotly_server
      dockerfile: Dockerfile
    container_name: remotly-api
    environment:
      SERVERPOD_DATABASE_HOST: postgres
      SERVERPOD_DATABASE_PORT: 5432
      SERVERPOD_DATABASE_NAME: ${POSTGRES_DB:-remotly}
      SERVERPOD_DATABASE_USER: ${POSTGRES_USER:-remotly}
      SERVERPOD_DATABASE_PASSWORD: ${POSTGRES_PASSWORD:-remotly}
      SERVERPOD_REDIS_HOST: redis
      SERVERPOD_REDIS_PORT: 6379
      VAPID_PUBLIC_KEY: ${VAPID_PUBLIC_KEY}
      VAPID_PRIVATE_KEY: ${VAPID_PRIVATE_KEY}
      NTFY_SERVER: http://ntfy:80
    ports:
      - "8080:8080"   # API
      - "8081:8081"   # Insights (optional)
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      ntfy:
        condition: service_started
    restart: unless-stopped

  # ===================
  # Push Notification Server
  # ===================

  ntfy:
    image: binwiederhier/ntfy
    container_name: remotly-ntfy
    command: serve
    environment:
      NTFY_BASE_URL: ${NTFY_BASE_URL:-http://localhost:8093}
      NTFY_CACHE_FILE: /var/cache/ntfy/cache.db
      NTFY_ATTACHMENT_CACHE_DIR: /var/cache/ntfy/attachments
      NTFY_ENABLE_LOGIN: "false"
      NTFY_BEHIND_PROXY: "true"
    volumes:
      - ntfy-cache:/var/cache/ntfy
      - ntfy-data:/var/lib/ntfy
    ports:
      - "8093:80"
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:80/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

volumes:
  postgres-data:
  redis-data:
  ntfy-cache:
  ntfy-data:

networks:
  default:
    name: remotly-network
```

### Deployment Commands

```bash
# Generate VAPID keys (one-time)
npx web-push generate-vapid-keys

# Create .env file with keys
cat > .env << EOF
POSTGRES_USER=remotly
POSTGRES_PASSWORD=your-secure-password
POSTGRES_DB=remotly
VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key
NTFY_BASE_URL=https://push.yourdomain.com
EOF

# Deploy entire stack
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Production Deployment with Traefik (Optional)

```yaml
# docker-compose.prod.yml
# Adds Traefik reverse proxy with automatic HTTPS

services:
  traefik:
    image: traefik:v3.0
    container_name: remotly-traefik
    command:
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-certs:/letsencrypt

  remotly-api:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.${DOMAIN}`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"

  ntfy:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ntfy.rule=Host(`push.${DOMAIN}`)"
      - "traefik.http.routers.ntfy.entrypoints=websecure"
      - "traefik.http.routers.ntfy.tls.certresolver=letsencrypt"

volumes:
  traefik-certs:
```

```bash
# Production deployment with HTTPS
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Server Configuration

```yaml
# remotly_server/config/development.yaml
push:
  # Self-hosted ntfy server (optional)
  ntfyServer: http://localhost:8093

  # VAPID keys for WebPush (generate once)
  vapidPublicKey: ${VAPID_PUBLIC_KEY}
  vapidPrivateKey: ${VAPID_PRIVATE_KEY}
  vapidSubject: mailto:noreply@remotly.app

  # Fallback options
  enableSseFallback: true
  sseHeartbeatInterval: 30  # seconds
```

---

## Security Considerations

### WebPush Encryption (RFC8291)

All push notifications use end-to-end encryption:

1. **Client generates keys**: ECDH P-256 key pair + 16-byte auth secret
2. **Server encrypts**: Using client's public key, payload is encrypted
3. **Distributor cannot read**: ntfy/FCM only sees encrypted blob
4. **Client decrypts**: Using private key

```dart
// Encryption happens automatically with web_push package
// Distributor (ntfy, FCM) cannot read notification content
```

### API Key Security

- Topic API keys stored hashed (bcrypt)
- Rate limiting per topic: 100 req/min
- Keys rotatable without downtime

---

## Implementation Phases

### Phase 1: WebSocket Streaming (Built-in)
- Implement `NotificationStreamEndpoint` using Serverpod streaming
- Add `NotificationService` for pub/sub
- Works immediately for foreground notifications

### Phase 2: UnifiedPush Integration
- Add `unifiedpush` Flutter package
- Implement WebPush server (VAPID + encryption)
- Add `PushSubscription` model
- User can choose distributor (ntfy, etc.)

### Phase 3: SSE Fallback
- Add SSE endpoint for restricted networks
- Implement reconnection logic
- Add to notification delivery pipeline

### Phase 4: Self-Hosted ntfy (Optional)
- Docker compose integration
- Admin configuration UI
- Documentation for self-hosting

---

## Dependencies

### Server (pubspec.yaml additions)

```yaml
dependencies:
  web_push: ^1.0.0      # WebPush RFC8030/8291/8292 implementation
  pointycastle: ^3.7.0  # Cryptography for encryption
```

### Client (pubspec.yaml additions)

```yaml
dependencies:
  unifiedpush: ^5.0.0                    # UnifiedPush connector
  flutter_local_notifications: ^17.0.0  # Display notifications
  flutter_client_sse: ^2.0.0            # SSE fallback
```

---

## References

- [UnifiedPush Specification](https://unifiedpush.org/)
- [WebPush RFC8030](https://datatracker.ietf.org/doc/html/rfc8030)
- [Serverpod Streaming Methods](https://docs.serverpod.dev/concepts/streams)
- [ntfy Documentation](https://docs.ntfy.sh/)
- [SSE's Comeback in 2025](https://dev.to/haraf/server-sent-events-sse-vs-websockets-vs-long-polling-whats-best-in-2025-5ep8)
- [Tutanota's FCM Replacement](https://f-droid.org/en/2018/09/03/replacing-gcm-in-tutanota.html)
