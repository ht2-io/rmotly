# Remotly Flutter App

A Flutter mobile application for Remotly - a bidirectional event-driven system with user-defined controls and push notifications.

## Project Structure

```
lib/
├── core/
│   ├── exceptions.dart      # Custom exception classes
│   └── providers/           # Riverpod providers
├── features/                # Feature modules (Clean Architecture)
└── shared/                  # Shared widgets and services
```

## Custom Exceptions

The app uses custom exception classes for consistent error handling:

- **`AppException`** - Base exception class with message, code, and originalError
- **`NetworkException`** - Network-related failures (HTTP errors, timeouts, etc.)
- **`ValidationException`** - Form and data validation errors with field-level details
- **`AuthException`** - Authentication and authorization failures
- **`ActionExecutionException`** - Action execution failures with HTTP details

Example usage:

```dart
import 'package:remotly_app/core/exceptions.dart';

try {
  await apiService.fetchData();
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on AuthException catch (e) {
  print('Auth error: ${e.message}');
} on AppException catch (e) {
  print('App error: ${e.message}');
}
```

## Getting Started

This project uses Serverpod for the backend API.

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Serverpod server running

### Documentation

- Serverpod docs: [https://docs.serverpod.dev](https://docs.serverpod.dev)
- Project tasks: See `TASKS.md` in the root directory
- Coding conventions: See `.claude/CONVENTIONS.md` in the root directory
- Testing guide: See `docs/TESTING.md` in the root directory

### Running the App

1. Make sure the Serverpod server is running
2. Run the Flutter app:

```bash
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/exceptions_test.dart
```

### Code Quality

```bash
# Format code
dart format .

# Analyze code
dart analyze
```

## Architecture

This app follows Clean Architecture with MVVM pattern:

- **Presentation Layer**: Views and ViewModels (Riverpod state management)
- **Domain Layer**: Entities and repository interfaces
- **Data Layer**: Repository implementations and data sources

## State Management

The app uses **Riverpod** for state management. All providers are defined with the `Provider` suffix.

## Contributing

1. Follow the coding conventions in `.claude/CONVENTIONS.md`
2. Write tests for new features (TDD approach)
3. Run tests and ensure they pass before committing
4. Use conventional commit messages: `type(scope): description`
