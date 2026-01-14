# Remotly - Claude Code Project Context

This directory contains context and documentation for Claude Code sessions working on the Remotly project.

## Project Overview

**Remotly** is a bidirectional event-driven system consisting of:
1. **Flutter Android App** - User-facing mobile application
2. **Dart API (Serverpod)** - Backend server handling events and actions

## Key Features

### App Features
- **Dashboard Controls**: User-defined controls (buttons, sliders, etc.) that send events to the API
- **Notification Topics**: Subscribe to topics and receive push notifications from the API
- **OpenAPI Integration**: Point to OpenAPI specs to build HTTP request definitions
- **Action Definitions**: Configure HTTP requests as actions triggered by events

### API Features
- **Event Reception**: Receive events from the app and external sources
- **Action Execution**: Execute HTTP requests based on action definitions
- **Notification Dispatch**: REST endpoint for sending notifications to topics
- **Multi-pattern Support**: Compatible with webhooks, polling, SSE, and WebSockets

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                               │
├─────────────────────────────────────────────────────────────────┤
│  Presentation Layer (Views + ViewModels)                        │
│  ├── Dashboard Screen (controls)                                │
│  ├── Notifications Screen (topics)                              │
│  ├── Actions Screen (OpenAPI config)                            │
│  └── Settings Screen                                            │
├─────────────────────────────────────────────────────────────────┤
│  Domain Layer (Use Cases + Entities)                            │
│  ├── Control entities                                           │
│  ├── Notification topic entities                                │
│  ├── Action/Event entities                                      │
│  └── OpenAPI spec entities                                      │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer (Repositories + Services)                           │
│  ├── API service (Serverpod client)                             │
│  ├── Local storage (SQLite/Hive)                                │
│  ├── FCM service                                                │
│  └── OpenAPI parser service                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Serverpod API                             │
├─────────────────────────────────────────────────────────────────┤
│  Endpoints Layer                                                │
│  ├── EventEndpoint (receive/send events)                        │
│  ├── NotificationEndpoint (send to topics)                      │
│  ├── ActionEndpoint (execute HTTP actions)                      │
│  └── ConfigEndpoint (sync app config)                           │
├─────────────────────────────────────────────────────────────────┤
│  Services Layer                                                 │
│  ├── EventService (event routing/processing)                    │
│  ├── NotificationService (FCM integration)                      │
│  ├── ActionExecutor (HTTP client)                               │
│  └── WebhookService (external integrations)                     │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer                                                     │
│  ├── PostgreSQL (persistent storage)                            │
│  ├── Redis (caching, pub/sub)                                   │
│  └── Models (auto-generated from YAML)                          │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
remotly/
├── .claude/                    # Claude Code context (this directory)
│   ├── README.md              # This file
│   ├── settings.json          # Project settings
│   └── CONVENTIONS.md         # Coding conventions & development workflow
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md        # Detailed architecture
│   ├── API.md                 # API documentation
│   ├── APP.md                 # App documentation
│   ├── TESTING.md             # Testing guide & best practices
│   └── DEPLOYMENT.md          # Deployment guide
├── TASKS.md                    # Task definitions and progress
├── remotly_app/               # Flutter app (to be created)
│   └── test/                  # App tests
│       ├── unit/              # Unit tests
│       ├── widget/            # Widget tests
│       ├── integration/       # Integration tests
│       └── golden/            # Golden/snapshot tests
├── remotly_server/            # Serverpod server (to be created)
│   └── test/                  # Server tests
│       ├── unit/              # Unit tests
│       └── integration/       # Integration tests
├── remotly_client/            # Serverpod client (to be created)
└── remotly_flutter/           # Serverpod Flutter integration (to be created)
```

## Key Files for Context

When starting a new session, read these files first:
1. `TASKS.md` - Current task status and definitions
2. `.claude/CONVENTIONS.md` - Coding standards, patterns, and development workflow
3. `docs/ARCHITECTURE.md` - System architecture details
4. `docs/TESTING.md` - Testing frameworks, patterns, and best practices

## Technology Stack

### App
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod
- **Local Storage**: Hive or SQLite
- **Notifications**: Firebase Cloud Messaging (FCM)
- **HTTP Client**: Dio
- **OpenAPI Parsing**: openapi_parser or swagger_parser

### API
- **Framework**: Serverpod
- **Language**: Dart 3.x
- **Database**: PostgreSQL
- **Cache**: Redis
- **HTTP Client**: http or dio (for action execution)

## Conventions Summary

- Clean Architecture with MVVM pattern
- Feature-first folder organization
- Riverpod for dependency injection and state
- YAML model definitions for Serverpod
- Test-Driven Development (TDD) workflow
- Comprehensive testing (unit, widget, integration, golden)
- Mocktail for mocking (preferred over Mockito)
- 80%+ code coverage target for critical paths
- Git conventional commits

See `CONVENTIONS.md` for detailed coding standards and development workflow.
See `docs/TESTING.md` for testing guide and best practices.

## Development Workflow Summary

```
1. PLAN        → Understand requirements
2. TEST (Red)  → Write failing tests first
3. CODE (Green)→ Implement to pass tests
4. REFACTOR    → Clean up, keep tests green
5. REVIEW      → Run all tests, check coverage
6. COMMIT      → Conventional commit message
```

### Pre-Commit Checklist

```bash
flutter test              # All tests pass
dart format .             # Code formatted
dart analyze              # No analysis issues
# For server changes:
cd remotly_server && serverpod generate && dart test
```
