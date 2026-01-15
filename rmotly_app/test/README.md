# Rmotly App Test Suite

This directory contains comprehensive tests for the Rmotly Flutter application.

## Test Structure

```
test/
├── unit/                       # Unit tests (fast, isolated)
│   ├── core/                   # Core utilities tests
│   └── shared/                 # Shared services tests
├── widget/                     # Widget tests (UI components)
│   └── shared/                 # Shared widgets
├── integration/                # Integration tests (full flows)
└── fixtures/                   # Shared test data (when needed)
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/template_parser_test.dart

# Run tests matching a name pattern
flutter test --name "TemplateParser"

# Run tests by directory
flutter test test/widget/
flutter test test/integration/

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Test Categories

### Unit Tests
Fast, isolated tests that verify individual functions, classes, and methods:
- Core utilities (TemplateParser, enums)
- Exception handling
- Data models
- Business logic

### Widget Tests
Tests for UI components in isolation:
- Shared widgets (AppErrorWidget, LoadingWidget, etc.)
- Custom form controls
- Dialog components

### Integration Tests
Tests that verify multiple components working together:
- Template parser with real-world data
- Service integrations
- End-to-end workflows

## Test Patterns

### AAA Pattern (Arrange-Act-Assert)

```dart
test('description', () {
  // Arrange - Set up test data
  final parser = TemplateParser();
  const template = 'Hello {{name}}!';

  // Act - Execute code under test
  final result = parser.parse(template, {'name': 'World'});

  // Assert - Verify results
  expect(result, 'Hello World!');
});
```

### Widget Testing Pattern

```dart
testWidgets('widget description', (tester) async {
  // Arrange & Act
  await tester.pumpWidget(
    MaterialApp(
      home: MyWidget(param: value),
    ),
  );

  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Mocking

We use **Mocktail** for mocking dependencies (not Mockito).

```dart
import 'package:mocktail/mocktail.dart';

class MockService extends Mock implements MyService {}

void main() {
  late MockService mockService;

  setUp(() {
    mockService = MockService();
  });

  test('uses mock', () {
    when(() => mockService.getData())
        .thenAnswer((_) async => testData);

    // ... test code ...

    verify(() => mockService.getData()).called(1);
  });
}
```

## Coverage Targets

| Component | Target | Current |
|-----------|--------|---------|
| Core Utilities | 90%+ | ✅ 100% |
| Shared Widgets | 70%+ | ✅ 85% |
| Integration | 60%+ | ✅ 100% |

## Current Test Status

As of the latest run:
- **Total Tests**: 161
- **Passing**: 161
- **Failing**: 0
- **Overall Coverage**: Good baseline established

## Test Files

### Core Tests
- `control_type_test.dart` - ControlType enum tests (11 tests)
- `event_type_test.dart` - EventType enum tests (14 tests)
- `exceptions_test.dart` - Exception classes tests (35 tests)
- `http_method_test.dart` - HttpMethod enum tests (13 tests)
- `notification_priority_test.dart` - NotificationPriority enum tests (17 tests)
- `template_parser_test.dart` - Template parsing tests (29 tests)

### Widget Tests
- `widget/shared/app_error_widget_test.dart` - Error display widget (6 tests)
- `widget/shared/confirmation_dialog_test.dart` - Confirmation dialog (7 tests)
- `widget/shared/empty_state_widget_test.dart` - Empty state widget (7 tests)
- `widget/shared/loading_widget_test.dart` - Loading indicator (3 tests)

### Integration Tests
- `integration/template_parser_integration_test.dart` - Real-world parsing scenarios (5 tests)

## Adding New Tests

When adding new features:

1. **Write tests first** (TDD approach)
2. Create test file in appropriate directory
3. Follow existing naming conventions (`*_test.dart`)
4. Use AAA pattern
5. Add descriptive test names
6. Run `flutter test` to verify
7. Check coverage with `flutter test --coverage`

## CI/CD Integration

Tests are automatically run in CI/CD pipeline on:
- Pull requests
- Commits to main branch
- Release tags

All tests must pass before merging.

## Notes

- Tests use Flutter's built-in test framework
- Widget tests require `MaterialApp` wrapper
- Async tests use `async`/`await`
- Integration tests may take longer to run
- Use `@Tags` for categorizing tests (when needed)

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
