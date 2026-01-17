# Contributing to Rmotly

Thank you for your interest in contributing to Rmotly! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.5+
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24+
- [Docker](https://docs.docker.com/get-docker/)
- [Serverpod CLI](https://docs.serverpod.dev/installation)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rmotly.git
   cd rmotly
   ```

2. **Start development services**
   ```bash
   cd rmotly_server
   docker compose up -d
   ```

3. **Install server dependencies**
   ```bash
   cd rmotly_server
   dart pub get
   ```

4. **Generate Serverpod code**
   ```bash
   serverpod generate
   ```

5. **Apply database migrations**
   ```bash
   serverpod apply-migrations
   ```

6. **Start the server**
   ```bash
   dart run bin/main.dart
   ```

7. **Install app dependencies**
   ```bash
   cd rmotly_app
   flutter pub get
   ```

8. **Run the app**
   ```bash
   flutter run
   ```

## Project Architecture

### Server (`rmotly_server`)

The backend uses [Serverpod](https://serverpod.dev/), a Dart backend framework.

```
rmotly_server/
├── bin/main.dart           # Server entry point
├── lib/src/
│   ├── endpoints/          # API endpoints
│   ├── services/           # Business logic
│   └── generated/          # Auto-generated (don't edit)
├── config/                 # Environment configs
└── migrations/             # Database migrations
```

### App (`rmotly_app`)

The mobile app uses Flutter with Clean Architecture.

```
rmotly_app/
└── lib/
    ├── core/               # Shared code
    │   ├── providers/      # Riverpod providers
    │   ├── theme/          # App theming
    │   └── services/       # Core services
    ├── features/           # Feature modules
    │   ├── dashboard/      # Dashboard feature
    │   │   ├── data/       # Data layer
    │   │   ├── domain/     # Domain layer
    │   │   └── presentation/# UI layer
    │   └── ...
    └── shared/             # Shared widgets/services
```

## Code Style

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Run `dart analyze` to check for issues
- Keep functions small and focused
- Use meaningful variable names

### File Naming

- Use snake_case for file names: `user_repository.dart`
- Use PascalCase for class names: `UserRepository`
- Use camelCase for variables and functions: `getUserById`

### Imports

Order imports as:
1. Dart SDK
2. Flutter SDK
3. External packages
4. Local imports

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/api_client_provider.dart';
import 'user_model.dart';
```

## Git Workflow

### Branch Naming

- `feat/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/documentation-topic` - Documentation
- `refactor/area` - Code refactoring
- `test/test-area` - Adding tests

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style (formatting, semicolons)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks

Examples:
```
feat(dashboard): add slider control widget
fix(auth): handle expired session tokens
docs(api): document webhook payload formats
refactor(actions): extract template parser to service
```

### Pull Requests

1. Create a feature branch from `main`
2. Make your changes
3. Run tests: `dart test` and `flutter test`
4. Run linter: `dart analyze`
5. Push and create a PR
6. Fill in the PR template
7. Request review

## Testing

### Server Tests

```bash
cd rmotly_server
dart test
```

### App Tests

```bash
cd rmotly_app
flutter test
```

### Writing Tests

- Place tests in `test/` directory
- Mirror the `lib/` structure
- Name test files with `_test.dart` suffix
- Use descriptive test names

```dart
void main() {
  group('UserRepository', () {
    test('returns user when found', () async {
      // Arrange
      final repository = UserRepository(mockClient);

      // Act
      final user = await repository.getUser(1);

      // Assert
      expect(user, isNotNull);
      expect(user.id, equals(1));
    });
  });
}
```

## Documentation

### Code Comments

- Use `///` for doc comments on public APIs
- Explain "why", not "what"
- Keep comments up to date

```dart
/// Executes an HTTP action with the given parameters.
///
/// Template variables in the URL, headers, and body are replaced
/// with values from [parameters].
///
/// Throws [ActionExecutionException] if the request fails after
/// all retry attempts.
Future<ActionResult> execute(Action action, Map<String, dynamic> parameters);
```

### Updating Documentation

- Update `docs/*.md` for major changes
- Keep README.md current
- Add JSDoc-style comments to new endpoints

## Database Changes

### Creating Migrations

1. Modify model files in `lib/src/models/`
2. Generate code: `serverpod generate`
3. Create migration: `serverpod create-migration`
4. Review the generated migration
5. Apply: `serverpod apply-migrations`

### Migration Guidelines

- Never modify existing migrations
- Test migrations on a copy of production data
- Include rollback considerations

## Security

- Never commit secrets or credentials
- Use environment variables for sensitive data
- Follow the principle of least privilege
- Validate all user input
- See `docs/SECURITY_BEST_PRACTICES.md`

## Getting Help

- Open an issue for bugs or feature requests
- Use discussions for questions
- Check existing issues before creating new ones

## Code of Conduct

Be respectful and inclusive. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
