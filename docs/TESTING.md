# Remotly - Testing Guide

This document outlines testing frameworks, patterns, and best practices for the Remotly project.

## Testing Philosophy

**Test Pyramid Approach:**
- Many **unit tests** (fast, isolated, cheap)
- Moderate **widget tests** (test UI components)
- Few **integration tests** (slow, expensive, but comprehensive)

## Test Types

### 1. Unit Tests

Test single functions, methods, or classes in isolation.

**Characteristics:**
- Fast execution (milliseconds)
- No external dependencies (mocked)
- High code coverage target (80%+)

**When to use:**
- Business logic
- Data transformations
- Utility functions
- Repository logic
- ViewModel state management

```dart
// Example: Testing a template parser
void main() {
  group('TemplateParser', () {
    late TemplateParser parser;

    setUp(() {
      parser = TemplateParser();
    });

    test('replaces single variable', () {
      // Arrange
      const template = 'Hello, {{name}}!';
      final variables = {'name': 'World'};

      // Act
      final result = parser.parse(template, variables);

      // Assert
      expect(result, 'Hello, World!');
    });

    test('handles missing variable gracefully', () {
      // Arrange
      const template = 'Value: {{missing}}';
      final variables = <String, String>{};

      // Act
      final result = parser.parse(template, variables);

      // Assert
      expect(result, 'Value: {{missing}}');
    });
  });
}
```

### 2. Widget Tests

Test individual widgets and their behavior.

**Characteristics:**
- Medium speed (seconds)
- Test rendering, interactions, state changes
- Use `WidgetTester` for simulating user interactions

**When to use:**
- Custom widgets
- Form validation UI
- Navigation flows within a widget
- Widget state changes

```dart
// Example: Testing a control button widget
void main() {
  group('ButtonControlWidget', () {
    testWidgets('displays label correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ButtonControlWidget(
            control: Control(
              id: 'test',
              name: 'Test Button',
              type: ControlType.button,
            ),
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      // Arrange
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ButtonControlWidget(
            control: Control(
              id: 'test',
              name: 'Test',
              type: ControlType.button,
            ),
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when processing', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ButtonControlWidget(
            control: Control(id: 'test', name: 'Test', type: ControlType.button),
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### 3. Integration Tests

Test complete features or user flows.

**Characteristics:**
- Slow execution (minutes)
- Run on real device or emulator
- Test real API interactions (or mocked server)

**When to use:**
- Critical user flows (login, sending events)
- End-to-end feature verification
- Performance testing

```dart
// Example: Integration test for dashboard flow
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard Flow', () {
    testWidgets('user can create and trigger a control', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to add control
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(Key('control_name')), 'Test Button');
      await tester.tap(find.byKey(Key('control_type_button')));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert - Control appears on dashboard
      expect(find.text('Test Button'), findsOneWidget);

      // Act - Trigger the control
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      // Assert - Success feedback shown
      expect(find.text('Event sent'), findsOneWidget);
    });
  });
}
```

### 4. Golden Tests (Visual Regression)

Capture and compare widget screenshots.

**Characteristics:**
- Detect unintended visual changes
- Require controlled environment (fonts, themes)
- Generate baseline "golden" images

```dart
// Example: Golden test for a control card
void main() {
  group('ControlCard Golden Tests', () {
    testWidgets('button control matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 100,
                child: ControlCard(
                  control: Control(
                    id: 'test',
                    name: 'Light Switch',
                    type: ControlType.button,
                    config: {'icon': 'lightbulb'},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ControlCard),
        matchesGoldenFile('goldens/control_card_button.png'),
      );
    });
  });
}
```

**Update goldens:**
```bash
flutter test --update-goldens
```

## Serverpod Backend Testing

### Using withServerpod Helper

Serverpod 2.2+ provides a testing framework with automatic transaction rollback.

```dart
// test/integration/event_endpoint_test.dart
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('EventEndpoint', (sessionBuilder, endpoints) {
    group('sendEvent', () {
      test('creates event and triggers action', () async {
        // Arrange - Seed database
        final session = sessionBuilder.build();
        final action = await Action.db.insertRow(session, Action(
          userId: 1,
          name: 'Test Action',
          httpMethod: 'POST',
          urlTemplate: 'https://example.com/api',
        ));

        final control = await Control.db.insertRow(session, Control(
          userId: 1,
          name: 'Test Control',
          controlType: 'button',
          actionId: action.id,
          position: 0,
        ));

        // Act
        final result = await endpoints.event.sendEvent(
          session,
          controlId: control.id.toString(),
          eventType: 'button_press',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.eventId, isNotNull);
      });

      test('returns error for non-existent control', () async {
        final session = sessionBuilder.build();

        expect(
          () => endpoints.event.sendEvent(
            session,
            controlId: 'non_existent',
            eventType: 'button_press',
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });
  });
}
```

### Mocking External Services

```dart
// test/unit/action_executor_test.dart
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('ActionExecutor', () {
    late ActionExecutor executor;
    late MockHttpClient mockClient;

    setUp(() {
      mockClient = MockHttpClient();
      executor = ActionExecutor(httpClient: mockClient);
    });

    test('executes POST request with correct body', () async {
      // Arrange
      final action = Action(
        httpMethod: 'POST',
        urlTemplate: 'https://api.example.com/toggle',
        bodyTemplate: '{"state": {{value}}}',
      );
      final variables = {'value': 'true'};

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      // Act
      final result = await executor.execute(action, variables);

      // Assert
      expect(result.statusCode, 200);
      verify(() => mockClient.post(
        Uri.parse('https://api.example.com/toggle'),
        headers: any(named: 'headers'),
        body: '{"state": true}',
      )).called(1);
    });
  });
}
```

## Mocking Libraries

### Mocktail (Recommended for Remotly)

No code generation required, simpler API.

```dart
// Setup
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

// Usage
void main() {
  late MockEventRepository mockRepo;

  setUpAll(() {
    // Register fallback values for custom types
    registerFallbackValue(Event(
      sourceType: '',
      sourceId: '',
      eventType: '',
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepo = MockEventRepository();
  });

  test('example with mocktail', () async {
    // Stub
    when(() => mockRepo.sendEvent(any()))
        .thenAnswer((_) async => EventResponse(success: true));

    // Use mock
    final result = await mockRepo.sendEvent(testEvent);

    // Verify
    verify(() => mockRepo.sendEvent(any())).called(1);
  });
}
```

### Mockito (Alternative)

Requires code generation but offers more features.

```dart
// pubspec.yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0

// Generate mocks
@GenerateMocks([EventRepository])
import 'event_repository_test.mocks.dart';

void main() {
  late MockEventRepository mockRepo;

  setUp(() {
    mockRepo = MockEventRepository();
  });

  test('example with mockito', () async {
    when(mockRepo.sendEvent(any))
        .thenAnswer((_) async => EventResponse(success: true));

    final result = await mockRepo.sendEvent(testEvent);

    verify(mockRepo.sendEvent(any)).called(1);
  });
}
```

## Test Organization

### Directory Structure

```
test/
├── unit/                          # Unit tests
│   ├── core/
│   │   └── utils/
│   │       ├── template_parser_test.dart
│   │       └── validators_test.dart
│   └── features/
│       ├── dashboard/
│       │   ├── control_repository_test.dart
│       │   └── dashboard_viewmodel_test.dart
│       ├── actions/
│       │   ├── action_executor_test.dart
│       │   └── openapi_parser_test.dart
│       └── notifications/
│           └── topic_repository_test.dart
├── widget/                        # Widget tests
│   └── features/
│       ├── dashboard/
│       │   ├── button_control_widget_test.dart
│       │   ├── toggle_control_widget_test.dart
│       │   └── dashboard_view_test.dart
│       └── common/
│           └── loading_widget_test.dart
├── integration/                   # Integration tests
│   ├── dashboard_flow_test.dart
│   ├── notification_flow_test.dart
│   └── test_tools/               # Serverpod generated
│       └── serverpod_test_tools.dart
├── golden/                        # Golden tests
│   ├── control_cards_test.dart
│   └── goldens/                  # Golden image files
│       ├── control_card_button.png
│       └── control_card_toggle.png
└── fixtures/                      # Test data
    ├── controls.json
    ├── actions.json
    └── openapi_spec.json
```

### Naming Conventions

```dart
// Test file: {class_name}_test.dart
// control_repository_test.dart
// dashboard_viewmodel_test.dart

// Group names: Describe the class/feature
group('ControlRepository', () { ... });
group('DashboardViewModel', () { ... });

// Test names: Describe expected behavior
test('returns empty list when no controls exist', () { ... });
test('throws NotFoundException when control not found', () { ... });
test('emits loading state then data on success', () { ... });
```

## Test Patterns

### AAA Pattern (Arrange-Act-Assert)

```dart
test('calculates total correctly', () {
  // Arrange - Set up test data and dependencies
  final calculator = PriceCalculator();
  final items = [Item(price: 10), Item(price: 20)];

  // Act - Execute the code under test
  final total = calculator.calculateTotal(items);

  // Assert - Verify the results
  expect(total, 30);
});
```

### Given-When-Then (BDD Style)

```dart
test('given valid credentials, when login called, then returns user', () async {
  // Given
  final authService = AuthService(mockApi);
  when(() => mockApi.login(any(), any()))
      .thenAnswer((_) async => UserResponse(id: '1', email: 'test@test.com'));

  // When
  final user = await authService.login('test@test.com', 'password');

  // Then
  expect(user.email, 'test@test.com');
});
```

### Testing Async Code

```dart
test('emits states in correct order', () async {
  // Arrange
  final viewModel = DashboardViewModel(mockRepository);

  // Act & Assert with expectLater for streams
  expectLater(
    viewModel.stateStream,
    emitsInOrder([
      isA<AsyncLoading>(),
      isA<AsyncData<DashboardState>>(),
    ]),
  );

  await viewModel.loadDashboard();
});
```

### Testing Riverpod Providers

```dart
void main() {
  group('DashboardViewModel', () {
    test('loads controls on initialization', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          controlRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      when(() => mockRepository.getControls())
          .thenAnswer((_) async => [testControl]);

      // Act
      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadDashboard();

      // Assert
      final state = container.read(dashboardViewModelProvider);
      expect(state.valueOrNull?.controls.length, 1);
    });
  });
}
```

## Running Tests

### Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/features/dashboard/dashboard_viewmodel_test.dart

# Run tests matching pattern
flutter test --name "DashboardViewModel"

# Run only unit tests (exclude integration)
flutter test --exclude-tags integration

# Run only integration tests
flutter test --tags integration

# Update golden files
flutter test --update-goldens

# Run with verbose output
flutter test --reporter expanded
```

### Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Serverpod Tests

```bash
cd remotly_server

# Run all tests
dart test

# Run only integration tests
dart test -t integration

# Run only unit tests
dart test -x integration
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  integration-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:17
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
      redis:
        image: redis:8
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - uses: dart-lang/setup-dart@v1

      - name: Run Serverpod tests
        working-directory: remotly_server
        run: dart test
```

## Best Practices Summary

### Do's

- Write tests before or alongside code (TDD)
- Keep tests focused and small (one assertion per concept)
- Use descriptive test names that explain expected behavior
- Mock external dependencies (APIs, databases, platform plugins)
- Run tests in CI/CD pipeline
- Maintain 80%+ code coverage for critical paths
- Use `setUp` and `tearDown` for common setup/cleanup

### Don'ts

- Don't test implementation details, test behavior
- Don't over-mock (leads to brittle tests)
- Don't ignore flaky tests (fix or remove them)
- Don't test trivial code (getters, setters, simple constructors)
- Don't couple tests to each other
- Don't make network calls in unit tests

## Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Mocking
  mocktail: ^1.0.0
  # OR
  mockito: ^5.4.0
  build_runner: ^2.4.0

  # Golden tests
  golden_toolkit: ^0.15.0

  # Additional utilities
  fake_async: ^1.3.0
  clock: ^1.1.0
```

## Resources

- [Flutter Testing Overview](https://docs.flutter.dev/testing/overview)
- [Serverpod Testing Guide](https://docs.serverpod.dev/concepts/testing/get-started)
- [Serverpod Testing Best Practices](https://docs.serverpod.dev/concepts/testing/best-practises)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)
- [Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
