---
name: flutter-testing
description: Use when writing, running, or debugging Flutter tests. Provides testing patterns, commands, and best practices for the Rmotly app.
---

# Flutter Testing Skill

## Test Directory Structure

```
rmotly_app/test/
├── unit/                          # Unit tests (fast, isolated)
│   ├── core/
│   │   └── utils/
│   │       └── template_parser_test.dart
│   └── features/
│       └── dashboard/
│           ├── dashboard_viewmodel_test.dart
│           └── control_repository_test.dart
├── widget/                        # Widget tests (UI components)
│   └── features/
│       └── dashboard/
│           ├── button_control_widget_test.dart
│           └── dashboard_view_test.dart
├── integration/                   # Integration tests (full flows)
│   └── dashboard_flow_test.dart
├── golden/                        # Golden/snapshot tests
│   ├── control_cards_test.dart
│   └── goldens/                  # Golden image files
└── fixtures/                      # Shared test data
    └── test_data.dart
```

## Test Commands

```bash
# Run all tests
cd rmotly_app && flutter test

# Run with coverage report
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific test file
flutter test test/unit/features/dashboard/dashboard_viewmodel_test.dart

# Run tests matching a pattern
flutter test --name "DashboardViewModel"

# Run tests with tags
flutter test --tags unit
flutter test --exclude-tags integration

# Update golden files
flutter test --update-goldens

# Run with verbose output
flutter test --reporter expanded
```

## Mocking with Mocktail

Mocktail is the preferred mocking library (not Mockito).

### Creating Mocks

```dart
import 'package:mocktail/mocktail.dart';

// Create mock class
class MockControlRepository extends Mock implements ControlRepository {}
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockControlRepository mockRepo;

  // Register fallback values for custom types (required for any())
  setUpAll(() {
    registerFallbackValue(Control(
      id: 0,
      name: '',
      controlType: ControlType.button,
      position: 0,
    ));
  });

  setUp(() {
    mockRepo = MockControlRepository();
  });
}
```

### Stubbing Methods

```dart
// Return a value
when(() => mockRepo.getControls())
    .thenReturn([testControl]);

// Return async value
when(() => mockRepo.getControls())
    .thenAnswer((_) async => [testControl]);

// Throw an exception
when(() => mockRepo.getControls())
    .thenThrow(NetworkException('Connection failed'));

// Use any() for flexible matching
when(() => mockRepo.saveControl(any()))
    .thenAnswer((_) async => testControl);

// Capture arguments
when(() => mockRepo.saveControl(captureAny()))
    .thenAnswer((_) async => testControl);
final captured = verify(() => mockRepo.saveControl(captureAny())).captured;
```

### Verifying Calls

```dart
// Verify called
verify(() => mockRepo.getControls()).called(1);

// Verify never called
verifyNever(() => mockRepo.deleteControl(any()));

// Verify call order
verifyInOrder([
  () => mockRepo.getControls(),
  () => mockRepo.saveControl(any()),
]);
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

### Testing Async Code

```dart
test('loads data asynchronously', () async {
  // Arrange
  when(() => mockRepo.fetchData())
      .thenAnswer((_) async => testData);

  // Act
  final result = await service.loadData();

  // Assert
  expect(result, testData);
});
```

### Testing Streams

```dart
test('emits values in order', () {
  final stream = controller.stream;

  expectLater(
    stream,
    emitsInOrder([1, 2, 3, emitsDone]),
  );

  controller.add(1);
  controller.add(2);
  controller.add(3);
  controller.close();
});
```

### Testing Riverpod Providers

```dart
test('loads controls on initialization', () async {
  // Create container with overrides
  final container = ProviderContainer(
    overrides: [
      controlRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  addTearDown(container.dispose);

  // Stub the mock
  when(() => mockRepository.getControls())
      .thenAnswer((_) async => [testControl]);

  // Read the provider
  final viewModel = container.read(dashboardViewModelProvider.notifier);
  await viewModel.loadDashboard();

  // Verify state
  final state = container.read(dashboardViewModelProvider);
  expect(state.valueOrNull?.controls.length, 1);
});
```

## Widget Testing

```dart
testWidgets('button displays label', (tester) async {
  // Arrange & Act
  await tester.pumpWidget(
    MaterialApp(
      home: ButtonControlWidget(
        control: testControl,
        onPressed: () {},
      ),
    ),
  );

  // Assert
  expect(find.text('Test Button'), findsOneWidget);
});

testWidgets('button triggers callback on tap', (tester) async {
  var tapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: ButtonControlWidget(
        control: testControl,
        onPressed: () => tapped = true,
      ),
    ),
  );

  // Act
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Assert
  expect(tapped, isTrue);
});
```

## Golden Testing

```dart
testWidgets('control card matches golden', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ControlCard(control: testControl),
    ),
  );

  await expectLater(
    find.byType(ControlCard),
    matchesGoldenFile('goldens/control_card.png'),
  );
});
```

## Test Data Fixtures

Create reusable test data in `test/fixtures/test_data.dart`:

```dart
final testControl = Control(
  id: 1,
  name: 'Test Button',
  controlType: ControlType.button,
  position: 0,
  config: '{}',
);

final testAction = Action(
  id: 1,
  name: 'Test Action',
  httpMethod: 'POST',
  urlTemplate: 'https://api.example.com/test',
);

final testUser = User(
  id: 1,
  email: 'test@example.com',
  displayName: 'Test User',
);
```

## Coverage Targets

| Component | Target |
|-----------|--------|
| ViewModels | 90%+ |
| Repositories | 80%+ |
| Services | 80%+ |
| Utilities | 90%+ |
| Widgets (critical) | 70%+ |

## What NOT to Test

- Trivial getters/setters
- Flutter framework internals
- Third-party package behavior
- Generated code
