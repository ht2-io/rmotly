# Rmotly

A privacy-first, self-hosted remote control and notification system. Create custom controls that trigger API actions, and receive notifications from external services through configurable webhooks.

## Features

- **Custom Dashboard Controls** - Buttons, toggles, sliders, inputs, and dropdowns that trigger HTTP actions
- **OpenAPI Integration** - Import API endpoints from OpenAPI/Swagger specifications
- **Webhook Notifications** - Receive notifications from external services (Home Assistant, IFTTT, custom integrations)
- **Self-Hosted Push** - UnifiedPush support with ntfy - no Firebase or Google services required
- **Real-Time Updates** - WebSocket streaming for instant notifications when the app is open
- **Privacy First** - All data stays on your server, no telemetry or third-party services

## Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Flutter App     │────▶│  Serverpod API   │────▶│  External APIs   │
│  (iOS/Android)   │◀────│  (Dart Backend)  │◀────│  (Actions)       │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
              ┌──────────┐ ┌──────────┐ ┌──────────┐
              │PostgreSQL│ │  Redis   │ │   ntfy   │
              │ (Data)   │ │ (Cache)  │ │  (Push)  │
              └──────────┘ └──────────┘ └──────────┘
```

## Quick Start

### Prerequisites

- Docker and Docker Compose
- (Optional) Flutter SDK for app development

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/rmotly.git
cd rmotly
```

### 2. Start Development Services

```bash
cd rmotly_server
docker compose up -d
```

This starts:
- PostgreSQL (port 8090)
- Redis (port 8091)
- ntfy push server (port 8093)

### 3. Start the Server

```bash
cd rmotly_server
dart pub get
dart run bin/main.dart
```

The API will be available at `http://localhost:8080`

### 4. Run the Flutter App

```bash
cd rmotly_app
flutter pub get
flutter run
```

## Production Deployment

See [VPS Deployment Guide](rmotly_server/deploy/vps/README.md) for a complete production setup with:
- Traefik reverse proxy with automatic SSL
- PostgreSQL with automated backups
- Redis for caching and sessions
- ntfy for self-hosted push notifications
- GitHub Actions CI/CD pipeline

### Single Command Deployment

```bash
docker compose -f docker-compose.production.yaml up -d
```

## Project Structure

```
rmotly/
├── rmotly_server/          # Serverpod backend
│   ├── lib/src/
│   │   ├── endpoints/      # API endpoints
│   │   ├── services/       # Business logic
│   │   └── generated/      # Auto-generated code
│   ├── config/             # Environment configs
│   └── deploy/             # Deployment configs
│
├── rmotly_app/             # Flutter mobile app
│   └── lib/
│       ├── core/           # Shared utilities, theme
│       ├── features/       # Feature modules
│       │   ├── dashboard/  # Main control grid
│       │   ├── actions/    # HTTP action management
│       │   ├── topics/     # Notification topics
│       │   ├── settings/   # App settings
│       │   └── openapi/    # OpenAPI import
│       └── shared/         # Shared services, widgets
│
├── rmotly_client/          # Generated Serverpod client
│
└── docs/                   # Documentation
    ├── API.md              # API reference
    ├── ARCHITECTURE.md     # System architecture
    ├── APP.md              # App documentation
    └── DEPLOYMENT.md       # Deployment guide
```

## Core Concepts

### Controls

Controls are UI elements on your dashboard that trigger actions:

| Type | Description | Example Use |
|------|-------------|-------------|
| Button | Single tap trigger | Turn on lights |
| Toggle | On/off switch | Enable/disable a service |
| Slider | Range value | Set brightness/volume |
| Input | Text entry | Send a message |
| Dropdown | Select option | Choose a scene |

### Actions

Actions define HTTP requests to execute when controls are triggered:

```yaml
name: "Toggle Living Room"
method: POST
url: "https://homeassistant.local/api/services/light/toggle"
headers:
  Authorization: "Bearer {{ha_token}}"
body:
  entity_id: "light.living_room"
```

Actions support template variables (`{{variable}}`) that are substituted at execution time.

### Topics

Topics are webhook endpoints for receiving notifications:

```
POST https://api.yourserver.com/webhook/{topic_id}
X-API-Key: your-topic-api-key

{
  "title": "Motion Detected",
  "body": "Front door camera"
}
```

## API Reference

See [API Documentation](docs/API.md) for complete endpoint reference.

### Key Endpoints

| Endpoint | Description |
|----------|-------------|
| `POST /event/sendEvent` | Trigger an action from a control |
| `POST /webhook/{topicId}` | Receive external notifications |
| `GET /control/listControls` | List user's controls |
| `POST /action/createAction` | Create a new action |
| `POST /notification/createTopic` | Create notification topic |

## Push Notifications

Rmotly uses a three-tier notification delivery system:

1. **WebSocket** (Tier 1) - Real-time when app is open
2. **UnifiedPush/WebPush** (Tier 2) - Background notifications via ntfy
3. **SSE** (Tier 3) - Fallback for restricted networks

See [Push Notification Design](docs/PUSH_NOTIFICATION_DESIGN.md) for details.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | - |
| `REDIS_URL` | Redis connection string | - |
| `NTFY_BASE_URL` | ntfy server URL | `http://localhost:8093` |

### Server Configuration

Configuration files in `rmotly_server/config/`:

- `development.yaml` - Local development
- `staging.yaml` - Staging environment
- `production.yaml` - Production settings

## Development

### Generate Code

After modifying Serverpod models:

```bash
cd rmotly_server
serverpod generate
```

### Run Tests

```bash
# Server tests
cd rmotly_server
dart test

# App tests
cd rmotly_app
flutter test
```

### Database Migrations

```bash
cd rmotly_server
serverpod create-migration
serverpod apply-migrations
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance

## Security

- All API endpoints require authentication
- Webhook endpoints use API key authentication
- Sensitive data encrypted at rest (AES-256-GCM)
- Rate limiting on all endpoints
- See [Security Best Practices](docs/SECURITY_BEST_PRACTICES.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Serverpod](https://serverpod.dev/) - Dart backend framework
- [ntfy](https://ntfy.sh/) - Self-hosted push notifications
- [UnifiedPush](https://unifiedpush.org/) - Open push notification standard
