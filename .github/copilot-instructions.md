# Rmotly Project - GitHub Copilot Instructions

## Model Preferences

Use the following AI models for Copilot tasks:

| Task Type | Preferred Model | Alternative |
|-----------|-----------------|-------------|
| Code generation | **GPT 5.2 Codex** | Claude Sonnet |
| Complex reasoning | **Claude Sonnet** | GPT 5.2 Codex |
| Documentation | **Claude Sonnet** | GPT 5.2 Codex |
| Simple edits | **GPT 5.2 Codex** | Claude Sonnet |

**Selection Guidelines:**
- Use **GPT 5.2 Codex** for: boilerplate code, YAML models, simple widgets, database queries
- Use **Claude Sonnet** for: architecture decisions, complex business logic, documentation prose, nuanced error handling

## Project Overview

**Rmotly** is a bidirectional event-driven system:

| Component | Location | Description |
|-----------|----------|-------------|
| Flutter App | `rmotly_app/` | Android mobile application |
| Serverpod API | `rmotly_server/` | Dart backend server |
| Generated Client | `rmotly_client/` | Auto-generated API client (DO NOT EDIT) |

## Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Mobile Framework | Flutter | 3.27.4 |
| Language | Dart | 3.6.2 |
| Backend | Serverpod | 2.9.2 |
| Database | PostgreSQL | 17 |
| Cache | Redis | 8 |
| State Management | Riverpod | 2.4+ |
| Testing | Mocktail | 1.0+ |

## Critical File Locations

### Serverpod Models

**IMPORTANT**: Model YAML files MUST be in `rmotly_server/lib/src/models/`

```
✅ rmotly_server/lib/src/models/user.yaml
✅ rmotly_server/lib/src/models/control.yaml
✅ rmotly_server/lib/src/models/action.yaml

❌ rmotly_server/lib/src/user.yaml (WRONG - missing models/ directory)
❌ rmotly_server/lib/src/models/user.spy.yaml (WRONG - bad extension)
```

### Flutter App Structure

```
rmotly_app/lib/
├── core/              # Utilities, constants, exceptions
├── features/          # Feature modules (Clean Architecture)
│   └── {feature}/
│       ├── data/      # Repositories, data sources
│       ├── domain/    # Entities, interfaces
│       └── presentation/  # Views, view models, widgets
└── shared/            # Shared widgets, services
```

## Build & Validation Commands

### Flutter App

```bash
cd rmotly_app
flutter pub get              # Install dependencies
dart format .                # Format code (REQUIRED before commit)
dart analyze                 # Static analysis (must pass)
flutter test                 # Run tests (must pass)
flutter test --coverage      # Run with coverage report
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

### Database Migrations

After modifying model YAML files:

```bash
cd rmotly_server
serverpod generate           # Step 1: Generate code
serverpod create-migration   # Step 2: Create migration
serverpod apply-migrations   # Step 3: Apply to database
dart bin/main.dart           # Step 4: Verify server starts
```

## Coding Standards

### Dart Style
- Follow [Effective Dart](https://dart.dev/effective-dart)
- `lowerCamelCase`: variables, functions, constants
- `UpperCamelCase`: classes, enums, types
- `snake_case`: file names

### Testing
- Use **Mocktail** for mocking (NOT Mockito)
- Follow TDD: write tests first
- AAA pattern: Arrange-Act-Assert
- Target 80%+ coverage

### Git Commits
- Conventional Commits: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Scopes: `app`, `api`, `models`, `controls`, `actions`, `notifications`

## Key Documentation

| File | Purpose |
|------|---------|
| `AGENTS.md` | Custom agents overview and usage |
| `TASKS.md` | Task definitions and progress |
| `.claude/CONVENTIONS.md` | Detailed coding standards |
| `docs/ARCHITECTURE.md` | System architecture |
| `docs/TESTING.md` | Testing guide |
| `docs/GIT.md` | Git conventions |
| `docs/CI_CD.md` | CI/CD workflows |

## Custom Agents

See `AGENTS.md` for detailed information on how to use custom agents.

| Agent | Purpose | Location |
|-------|---------|----------|
| `flutter-dev` | Flutter app development | `.github/agents/flutter-dev.agent.md` |
| `serverpod-dev` | Serverpod API development | `.github/agents/serverpod-dev.agent.md` |
| `docs-specialist` | Documentation only | `.github/agents/docs-specialist.agent.md` |

## Common Errors & Solutions

### "serverpod command not found"
```bash
dart pub global activate serverpod_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### "Database connection failed"
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify credentials in `rmotly_server/config/development.yaml`

### "Model not generating"
- Ensure YAML file is in `lib/src/models/` directory
- Ensure file has `.yaml` extension (not `.spy.yaml`)
- Run `serverpod generate` from `rmotly_server/` directory

### Flutter analyze errors
```bash
cd rmotly_app
dart fix --apply    # Auto-fix issues
dart format .       # Format code
```

## Do NOT

- Edit files in `rmotly_server/lib/src/generated/`
- Edit files in `rmotly_client/lib/src/protocol/`
- Use Mockito (use Mocktail)
- Skip running tests before committing
- Create model files outside `lib/src/models/`
- Use file extensions other than `.yaml` for models
- Commit without running `dart format .`

## Validation Checklist

Before completing any task:

- [ ] Code formatted: `dart format .`
- [ ] Analysis passes: `dart analyze`
- [ ] Tests pass: `flutter test` or `dart test`
- [ ] Server starts (if models changed): `dart bin/main.dart`
- [ ] TASKS.md updated (if completing a task)
