# Rmotly Flutter App

A Flutter mobile application for Rmotly - a bidirectional event-driven system with configurable controls and notifications.

## Features

- **Dashboard Controls**: User-defined controls (buttons, sliders, toggles) that send events to the API
- **Action Execution**: HTTP requests triggered by events, configured via OpenAPI specs
- **Push Notifications**: Firebase Cloud Messaging for receiving notifications from external sources
- **Webhook Endpoint**: REST API for external services to send notifications

## Project Structure

```
lib/
├── core/
│   ├── exceptions.dart      # Custom exception classes
│   ├── template_parser.dart # Template string parsing utility
│   ├── utils.dart           # Utility exports
│   └── providers/           # Riverpod providers
├── features/                # Feature modules (Clean Architecture)
└── shared/                  # Shared widgets and services
```

## Core Utilities

### Custom Exceptions

The app uses custom exception classes for consistent error handling:

- **`AppException`** - Base exception class with message, code, and originalError
- **`NetworkException`** - Network-related failures (HTTP errors, timeouts, etc.)
- **`ValidationException`** - Form and data validation errors with field-level details
- **`AuthException`** - Authentication and authorization failures
- **`ActionExecutionException`** - Action execution failures with HTTP details

Example usage:

```dart
import 'package:rmotly_app/core/exceptions.dart';

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

### TemplateParser

A utility class for parsing template strings with `{{variable}}` substitution. Supports:
- Simple variable replacement: `{{name}}`
- Nested object access: `{{user.name}}`
- Array operations: `{{items.0}}`, `{{items.length}}`

See [TEMPLATE_PARSER.md](../docs/TEMPLATE_PARSER.md) for detailed documentation and examples.

## Getting Started

### Prerequisites

- Flutter 3.27.4+
- Dart 3.6.2+
- Serverpod API server running

### Running the App

1. Ensure the Serverpod server is running:
   ```bash
   cd rmotly_server
   dart bin/main.dart
   ```

2. Run the Flutter app:
   ```bash
   cd rmotly_app
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
flutter test test/template_parser_test.dart
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

## Documentation

- [Architecture](../docs/ARCHITECTURE.md) - System architecture overview
- [API Documentation](../docs/API.md) - API endpoints and usage
- [Testing Guide](../docs/TESTING.md) - Testing patterns and best practices
- [TemplateParser](../docs/TEMPLATE_PARSER.md) - Template parsing utility documentation
- [Deployment Guide](../docs/DEPLOYMENT.md) - Complete deployment guide for the backend API

### Google Play Store Submission

- [Play Store Submission Guide](../docs/PLAY_STORE_SUBMISSION.md) - Complete guide for submitting to Google Play Store
- [Store Assets Guide](../docs/STORE_ASSETS_GUIDE.md) - How to create screenshots, icons, and graphics
- [Play Store Checklist](../docs/PLAY_STORE_CHECKLIST.md) - Step-by-step checklist for submission
- [Store Listing Content](../docs/STORE_LISTING.md) - App descriptions and metadata

### Building for Release

```bash
# Build Android App Bundle (for Play Store)
cd rmotly_app
flutter build appbundle --release

# Build APK (for direct installation)
flutter build apk --release

# Or use the build script
./scripts/build-release.sh
```

**Note**: Release builds require signing configuration. See [Play Store Submission Guide](../docs/PLAY_STORE_SUBMISSION.md) for setup instructions.

## Contributing

1. Follow the coding conventions in `.claude/CONVENTIONS.md`
2. Write tests for new features (TDD approach)
3. Run tests and ensure they pass before committing
4. Use conventional commit messages: `type(scope): description`

## Learn More

A great starting point for learning Serverpod is the documentation site:
[https://docs.serverpod.dev](https://docs.serverpod.dev).
