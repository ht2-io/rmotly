# Remotly Project - GitHub Copilot Instructions

These instructions provide context for all GitHub Copilot interactions in this repository.

## Project Overview

**Remotly** is a bidirectional event-driven system consisting of:

1. **Flutter Android App** (`remotly_app/`) - User-facing mobile application
2. **Serverpod API** (`remotly_server/`) - Dart backend server
3. **Generated Client** (`remotly_client/`) - Auto-generated API client

### Key Features

- **Dashboard Controls**: User-defined controls (buttons, sliders, toggles) that send events to the API
- **Action Execution**: HTTP requests triggered by events, configured via OpenAPI specs
- **Push Notifications**: Firebase Cloud Messaging for receiving notifications from external sources
- **Webhook Endpoint**: REST API for external services to send notifications

## Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Mobile Framework | Flutter | 3.27.4 |
| Language | Dart | 3.6.2 |
| Backend Framework | Serverpod | 2.9.2 |
| Database | PostgreSQL | 17 |
| Cache | Redis | 8 |
| State Management | Riverpod | 2.4+ |
| Navigation | GoRouter | 13+ |
| Testing (Mock) | Mocktail | 1.0+ |

## Directory Structure

```
remotly/
├── remotly_app/           # Flutter mobile app
│   ├── lib/
│   │   ├── core/         # Shared utilities, constants
│   │   ├── features/     # Feature modules (Clean Architecture)
│   │   └── shared/       # Shared widgets, services
│   └── test/             # App tests
├── remotly_server/        # Serverpod backend
│   ├── lib/src/
│   │   ├── endpoints/    # API endpoints
│   │   ├── services/     # Business logic
│   │   └── models/       # YAML model definitions
│   └── test/             # Server tests
├── remotly_client/        # Generated API client
├── docs/                  # Documentation
└── .github/               # GitHub configuration
    ├── agents/           # Custom Copilot agents
    └── skills/           # Copilot skills
```

## Key Documentation

Read these files for full context:

| File | Description |
|------|-------------|
| `TASKS.md` | Task definitions and progress tracking |
| `.claude/CONVENTIONS.md` | Coding standards and patterns |
| `docs/ARCHITECTURE.md` | System architecture |
| `docs/API.md` | API endpoint documentation |
| `docs/TESTING.md` | Testing guide and best practices |
| `docs/GIT.md` | Git and GitHub conventions |

## Architecture Patterns

### Flutter App (Clean Architecture + MVVM)

```
lib/features/{feature}/
├── data/
│   ├── repositories/     # Repository implementations
│   └── data_sources/     # API/local data sources
├── domain/
│   ├── entities/         # Business entities
│   └── repositories/     # Repository interfaces
└── presentation/
    ├── views/            # UI screens
    ├── view_models/      # State management (Riverpod)
    └── widgets/          # Feature-specific widgets
```

### Serverpod API

```
lib/src/
├── endpoints/            # API endpoints (public interface)
├── services/             # Business logic (internal)
├── models/               # YAML model definitions
└── generated/            # Auto-generated code (do not edit)
```

## Coding Conventions

### Dart Style
- Follow [Effective Dart](https://dart.dev/effective-dart)
- Use `lowerCamelCase` for variables, functions, constants
- Use `UpperCamelCase` for classes, enums, types
- Use `snake_case` for file names
- Run `dart format .` before committing

### State Management (Riverpod)
```dart
// Providers suffixed with 'Provider'
final controlRepositoryProvider = Provider<ControlRepository>((ref) => ...);
final dashboardViewModelProvider = StateNotifierProvider<...>((ref) => ...);
```

### Testing
- Use **Mocktail** for mocking (not Mockito)
- Follow **TDD**: Red → Green → Refactor
- Use **AAA pattern**: Arrange-Act-Assert
- Target **80%+ coverage** on new code

### Git
- **Trunk-based development** with short-lived feature branches
- **Conventional Commits**: `type(scope): description`
- **Squash merge** for PRs
- Branch naming: `feat/`, `fix/`, `refactor/`, `docs/`, `test/`, `chore/`

## Common Commands

```bash
# Flutter App
cd remotly_app
flutter run                    # Run app
flutter test                   # Run tests
flutter test --coverage        # Run with coverage
dart format .                  # Format code
dart analyze                   # Static analysis

# Serverpod
cd remotly_server
serverpod generate             # Generate code from models
dart bin/main.dart             # Start server
dart test                      # Run server tests
serverpod create-migration     # Create DB migration
serverpod apply-migrations     # Apply migrations

# Git
git checkout -b feat/name      # New feature branch
git commit -m "type(scope): msg"  # Conventional commit
```

## Custom Agents Available

| Agent | Use For |
|-------|---------|
| `flutter-dev` | Flutter app features, UI, state management |
| `serverpod-dev` | API endpoints, services, database models |
| `docs-specialist` | Documentation updates only |

## Skills Available

| Skill | Use For |
|-------|---------|
| `flutter-testing` | Writing and running Flutter tests |
| `serverpod-generate` | Model changes and code generation |

## Important Notes

- **Do not edit** files in `lib/src/generated/` or `remotly_client/lib/src/protocol/`
- **Run `serverpod generate`** after any model YAML changes
- **Run tests** before committing: `flutter test` and `dart test`
- **Follow existing patterns** in the codebase
- **Update TASKS.md** when completing tasks
