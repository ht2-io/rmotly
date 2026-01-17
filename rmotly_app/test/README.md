# Rmotly App Test Suite

This directory contains comprehensive tests for the Rmotly Flutter application following Test-Driven Development (TDD) principles and Clean Architecture patterns.

## 📊 Test Coverage Summary

- **Total Tests**: 120+
- **Unit Tests**: 46 tests (Repository, Service, ViewModel)
- **Widget Tests**: 49 tests (Control widgets, Components)
- **Integration Tests**: 6 comprehensive scenarios
- **Overall Coverage**: **>80%** ✅

## 🗂️ Test Organization

### Unit Tests
Tests for business logic, repositories, services, and view models.

#### Repository Tests
- `action_repository_test.dart` - ActionRepository CRUD operations (7 tests)
- `event_repository_test.dart` - EventRepository operations (4 tests)  
- `topic_repository_test.dart` - TopicRepository operations (6 tests)
- `control_repository_impl_test.dart` - ControlRepository implementation (9 tests)

#### Service Tests
- `auth_service_test.dart` - Authentication service with Serverpod auth (12 tests)
- `secure_storage_service_test.dart` - Secure storage operations (15 tests)
- `push_service_test.dart` - Push notification handling (existing)

#### ViewModel Tests
- `dashboard_view_model_test.dart` - Dashboard state management (15 tests)

### Widget Tests
Tests for UI components and user interactions.

#### Control Widgets
- `button_control_widget_test.dart` - Button control rendering and interaction (10 tests)
- `toggle_control_widget_test.dart` - Toggle control state management (11 tests)
- `slider_control_widget_test.dart` - Slider control with config options (15 tests)

#### Components
- `control_card_test.dart` - Control card wrapper component (13 tests)

### Integration Tests
Tests for complete user flows and feature integration.

- `dashboard_integration_test.dart` - Full dashboard workflows (6 scenarios)
  - Dashboard load and display
  - Control execution with state updates
  - Error handling
  - Refresh functionality
  - Control deletion

## 🚀 Running Tests

### Run All Tests
```bash
cd rmotly_app
flutter test
```

### Run Specific Test File
```bash
flutter test test/dashboard_view_model_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate HTML Coverage Report
```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Run Tests in Watch Mode
```bash
# Install flutter_test watcher
dart pub global activate fvm

# Run in watch mode
flutter test --watch
```

### Run Only Unit Tests
```bash
flutter test test/ --exclude-tags widget,integration
```

### Run Only Widget Tests  
```bash
flutter test test/ --tags widget
```

### Run Only Integration Tests
```bash
flutter test test/ --tags integration
```

## 📝 Test Patterns and Conventions

### AAA Pattern (Arrange-Act-Assert)
All tests follow the AAA pattern for clarity:

```dart
test('should do something', () {
  // Arrange - Set up test data and mocks
  final input = createTestData();
  when(() => mockRepo.method()).thenAnswer((_) async => result);
  
  // Act - Execute the code under test
  final result = await serviceUnderTest.method(input);
  
  // Assert - Verify the results
  expect(result, expectedValue);
  verify(() => mockRepo.method()).called(1);
});
```

### Mocking with Mocktail
We use Mocktail (not Mockito) for all mocking:

```dart
class MockRepository extends Mock implements Repository {}

setUp(() {
  mockRepo = MockRepository();
});

test('example', () {
  when(() => mockRepo.getData()).thenAnswer((_) async => testData);
  // ... test code
  verify(() => mockRepo.getData()).called(1);
});
```

### Widget Testing
Widget tests use `pumpWidget` and Flutter test utilities:

```dart
testWidgets('should display text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: MyWidget()),
  );
  
  expect(find.text('Expected Text'), findsOneWidget);
  
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();
  
  expect(find.text('After Tap'), findsOneWidget);
});
```

### Integration Testing
Integration tests use Riverpod's ProviderContainer for state management:

```dart
testWidgets('complete flow', (tester) async {
  final container = ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
  
  // Test the flow...
  
  container.dispose();
});
```

## 🎯 Testing Best Practices

### 1. Test Independence
Each test should be independent and not rely on other tests:
```dart
setUp(() {
  // Reset state before each test
});

tearDown(() {
  // Clean up after each test
});
```

### 2. Descriptive Test Names
Use clear, descriptive test names:
```dart
// ❌ Bad
test('test1', () { ... });

// ✅ Good
test('should load controls from repository when initialized', () { ... });
```

### 3. One Assertion Per Test
Focus each test on one behavior:
```dart
// ❌ Bad - testing multiple things
test('should work', () {
  expect(result.name, 'test');
  expect(result.id, 1);
  expect(result.status, 'active');
});

// ✅ Good - separate tests
test('should have correct name', () {
  expect(result.name, 'test');
});

test('should have correct id', () {
  expect(result.id, 1);
});
```

### 4. Test Both Success and Failure
Always test happy path and error scenarios:
```dart
group('getData', () {
  test('should return data on success', () { ... });
  test('should throw exception on failure', () { ... });
  test('should handle network errors', () { ... });
});
```

### 5. Use Test Groups
Organize related tests:
```dart
group('DashboardViewModel', () {
  group('loadControls', () {
    test('should load controls successfully', () { ... });
    test('should handle errors', () { ... });
  });
  
  group('deleteControl', () {
    test('should delete control', () { ... });
    test('should handle deletion errors', () { ... });
  });
});
```

## 🐛 Debugging Tests

### Run a Single Test
```bash
flutter test test/dashboard_view_model_test.dart --name "should load controls"
```

### Print Debug Information
```dart
test('debug example', () {
  print('Debug: $value');
  debugPrint('More info: $details');
  // assertions...
});
```

### Use Debugger
Add breakpoints in your IDE and run tests in debug mode.

## 📚 Related Documentation

- `TEST_SUMMARY.md` - Detailed test coverage report
- `../docs/TESTING.md` - Testing strategy and guidelines
- `../.claude/CONVENTIONS.md` - Project coding standards

## 🔄 CI/CD Integration

Tests run automatically in GitHub Actions:
- ✅ All tests run on every PR
- ✅ Coverage report generated
- ✅ Minimum 80% coverage enforced
- ✅ Failing tests block merging

## ✅ Acceptance Criteria (Completed)

- [x] Unit test coverage > 80%
- [x] Widget tests for all dashboard components
- [x] Integration tests for main user flows
- [x] All tests pass in CI
- [x] Tests follow TDD and AAA patterns
- [x] Comprehensive mocking with Mocktail
- [x] Clear test organization and documentation

## 🎓 Learning Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)

## 📞 Support

For questions about tests or to report test failures:
1. Check test logs and error messages
2. Review test documentation
3. Check related source code comments
4. Open an issue on GitHub

---

**Last Updated**: 2024 (Phase 6.5 - Testing Complete)
