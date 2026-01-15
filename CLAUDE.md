# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Remotly** is a bidirectional event-driven system with three components:

| Component | Location | Description |
|-----------|----------|-------------|
| Flutter App | `remotly_app/` | Android mobile application |
| Serverpod API | `remotly_server/` | Dart backend server |
| Generated Client | `remotly_client/` | Auto-generated API client (DO NOT EDIT) |

The system enables users to create custom controls (buttons, sliders, toggles) that trigger remote HTTP actions, and receive notifications from external sources through configurable webhook topics.

## Commands

### Flutter App

```bash
cd remotly_app
flutter pub get              # Install dependencies
dart format .                # Format code (REQUIRED before commit)
dart analyze                 # Static analysis (must pass)
flutter test                 # Run all tests
flutter test test/unit/features/dashboard/dashboard_viewmodel_test.dart  # Single test file
flutter test --name "TemplateParser"   # Tests matching pattern
flutter test --coverage      # With coverage report
flutter build apk            # Build Android APK
```

### Serverpod Server

```bash
cd remotly_server
serverpod generate           # Generate code from YAML models
dart analyze                 # Static analysis
dart test                    # Run server tests
dart bin/main.dart           # Start development server
```

### After Modifying Model YAML Files

```bash
cd remotly_server
serverpod generate           # Step 1: Generate code
serverpod create-migration   # Step 2: Create migration
serverpod apply-migrations   # Step 3: Apply to database
dart bin/main.dart           # Step 4: Verify server starts
```

### If serverpod command not found

```bash
dart pub global activate serverpod_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## Architecture

### System Data Flow

```
Control Event Flow (App → API → External):
User taps control → App sends event → API routes to action → HTTP request executed

Notification Flow (External → API → App):
External webhook → API processes → FCM dispatches → App displays notification
```

### Flutter App (Clean Architecture + MVVM)

```
remotly_app/lib/
├── core/              # Utilities, constants, exceptions, providers
├── features/          # Feature modules
│   └── {feature}/
│       ├── data/      # Repository implementations, data sources
│       ├── domain/    # Entities, repository interfaces
│       └── presentation/  # Views, view models, widgets
└── shared/            # Shared widgets, services
```

### Serverpod Server

```
remotly_server/lib/src/
├── endpoints/         # API endpoint classes
├── services/          # Business logic services
├── models/            # YAML model definitions (*.yaml)
└── generated/         # Auto-generated code (DO NOT EDIT)
```

### State Management

Uses **Riverpod** with StateNotifier pattern:
- Service providers → Repository providers → ViewModel providers
- Views use `ConsumerWidget` and `ref.watch()`

## Critical Rules

### Serverpod Models

**Model YAML files MUST be in `remotly_server/lib/src/models/` with `.yaml` extension:**

```
✅ remotly_server/lib/src/models/user.yaml
✅ remotly_server/lib/src/models/control.yaml

❌ remotly_server/lib/src/user.yaml (WRONG - missing models/ directory)
❌ remotly_server/lib/src/models/user.spy.yaml (WRONG - bad extension)
```

### Do NOT Edit

- `remotly_server/lib/src/generated/` - Serverpod generated code
- `remotly_client/lib/src/protocol/` - Auto-generated client protocol

### Testing

- Use **Mocktail** for mocking (NOT Mockito)
- Follow AAA pattern: Arrange-Act-Assert
- Test file structure mirrors source: `test/unit/features/dashboard/` for `lib/features/dashboard/`

### Git Commits

Conventional Commits format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Scopes: `app`, `api`, `models`, `controls`, `actions`, `notifications`

## Key Entities

- **Control**: Dashboard UI element (button, slider, toggle) that triggers events
- **Action**: HTTP request definition with URL/header/body templates using `{{variable}}` placeholders
- **NotificationTopic**: Webhook channel with API key authentication
- **Event**: Occurrence flowing through the system (from controls or webhooks)

## Documentation

| File | Purpose |
|------|---------|
| `TASKS.md` | Task definitions and progress tracking |
| `.claude/CONVENTIONS.md` | Detailed coding standards |
| `docs/ARCHITECTURE.md` | System architecture diagrams |
| `docs/TESTING.md` | Testing patterns and examples |
