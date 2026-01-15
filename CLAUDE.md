# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Rmotly** is a bidirectional event-driven system with three components:

| Component | Location | Description |
|-----------|----------|-------------|
| Flutter App | `rmotly_app/` | Android mobile application |
| Serverpod API | `rmotly_server/` | Dart backend server |
| Generated Client | `rmotly_client/` | Auto-generated API client (DO NOT EDIT) |

The system enables users to create custom controls (buttons, sliders, toggles) that trigger remote HTTP actions, and receive notifications from external sources through configurable webhook topics.

## Commands

### Flutter App

```bash
cd rmotly_app
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
cd rmotly_server
serverpod generate           # Generate code from YAML models
dart analyze                 # Static analysis
dart test                    # Run server tests
dart bin/main.dart           # Start development server
```

### After Modifying Model YAML Files

```bash
cd rmotly_server
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
rmotly_app/lib/
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
rmotly_server/lib/src/
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

**Model YAML files MUST be in `rmotly_server/lib/src/models/` with `.yaml` extension:**

```
✅ rmotly_server/lib/src/models/user.yaml
✅ rmotly_server/lib/src/models/control.yaml

❌ rmotly_server/lib/src/user.yaml (WRONG - missing models/ directory)
❌ rmotly_server/lib/src/models/user.spy.yaml (WRONG - bad extension)
```

### Do NOT Edit

- `rmotly_server/lib/src/generated/` - Serverpod generated code
- `rmotly_client/lib/src/protocol/` - Auto-generated client protocol

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

## GitHub Copilot Coding Agent

This repository uses GitHub Copilot coding agent for automated task implementation.

### Assigning Copilot to Issues

**Correct syntax** (use GitHub CLI):
```bash
gh issue edit <issue_number> --add-assignee "@copilot"
```

**Example:**
```bash
gh issue edit 123 --add-assignee "@copilot"
```

**Automated assignment:** Issues labeled `copilot` are automatically assigned via `.github/workflows/assign-copilot.yml`

### Copilot Environment Setup

The `.github/workflows/copilot-setup-steps.yml` configures Copilot's environment:
- Flutter 3.24.0 SDK
- Dart SDK
- All project dependencies
- Serverpod CLI

This runs **before** the firewall is enabled, allowing external downloads from `storage.googleapis.com`.

### Firewall Allowlist

If Copilot is blocked from accessing URLs, either:
1. Add the host to `copilot-setup-steps.yml` (preferred)
2. Add to custom allowlist: **Repository Settings → Copilot → Coding agent → Custom allowlist**

### What NOT to Use

```bash
# These do NOT work:
gh api /repos/.../assignees -f "assignees[]=copilot-swe-agent"  # Wrong assignee name
gh api /repos/.../assignees -f "assignees[]=Copilot"            # API doesn't support this
```

## Documentation

| File | Purpose |
|------|---------|
| `TASKS.md` | Task definitions and progress tracking |
| `.claude/CONVENTIONS.md` | Detailed coding standards |
| `docs/ARCHITECTURE.md` | System architecture diagrams |
| `docs/TESTING.md` | Testing patterns and examples |
