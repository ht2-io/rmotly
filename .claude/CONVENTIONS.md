# Remotly - Coding Conventions

This document defines the coding standards and patterns for the Remotly project.

## Dart Style Guide

Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines.

### Naming Conventions

```dart
// Classes, enums, typedefs, extensions: UpperCamelCase
class NotificationTopic {}
enum EventType { button, slider, toggle }
typedef EventCallback = void Function(Event);

// Variables, parameters, functions: lowerCamelCase
final eventController = EventController();
void sendNotification(String topicId) {}

// Constants: lowerCamelCase (NOT SCREAMING_CAPS)
const defaultTimeout = Duration(seconds: 30);

// Private members: prefix with underscore
class _PrivateClass {}
final _privateVariable = 'secret';

// File names: snake_case
// notification_topic.dart, event_service.dart
```

### Import Organization

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetical)
import 'package:riverpod/riverpod.dart';
import 'package:serverpod_client/serverpod_client.dart';

// 4. Relative imports (alphabetical)
import '../models/event.dart';
import '../services/api_service.dart';
```

## Architecture Patterns

### Clean Architecture Layers

```
lib/
├── core/                      # Shared utilities, constants, extensions
│   ├── constants/
│   ├── extensions/
│   ├── utils/
│   └── errors/
├── features/                  # Feature-first organization
│   ├── dashboard/
│   │   ├── data/             # Repositories, data sources
│   │   ├── domain/           # Entities, use cases
│   │   └── presentation/     # Views, view models, widgets
│   ├── notifications/
│   ├── actions/
│   └── settings/
└── shared/                    # Shared widgets, services
    ├── widgets/
    └── services/
```

### MVVM Pattern

```dart
// View (StatelessWidget or ConsumerWidget)
class DashboardView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    // Only render UI, no business logic
    return state.when(
      loading: () => const LoadingWidget(),
      error: (e) => ErrorWidget(error: e),
      data: (data) => DashboardContent(data: data),
    );
  }
}

// ViewModel (StateNotifier or Notifier)
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardState>> {
  final DashboardRepository _repository;

  DashboardViewModel(this._repository) : super(const AsyncValue.loading()) {
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getDashboard());
  }

  Future<void> sendEvent(String controlId) async {
    await _repository.sendEvent(controlId);
  }
}
```

### Repository Pattern

```dart
// Abstract repository (domain layer)
abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<void> sendEvent(Event event);
  Stream<Event> watchEvents();
}

// Implementation (data layer)
class EventRepositoryImpl implements EventRepository {
  final EventApiService _apiService;
  final EventLocalStorage _localStorage;

  EventRepositoryImpl(this._apiService, this._localStorage);

  @override
  Future<List<Event>> getEvents() async {
    try {
      final events = await _apiService.fetchEvents();
      await _localStorage.cacheEvents(events);
      return events;
    } catch (e) {
      return _localStorage.getCachedEvents();
    }
  }
}
```

## State Management (Riverpod)

### Provider Definitions

```dart
// Service providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: Environment.apiUrl);
});

// Repository providers
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageProvider),
  );
});

// ViewModel providers (StateNotifierProvider)
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardState>>((ref) {
  return DashboardViewModel(ref.watch(dashboardRepositoryProvider));
});

// Simple state providers
final selectedTopicProvider = StateProvider<String?>((ref) => null);
```

### Provider Naming

```dart
// Providers: suffixed with 'Provider'
final userProvider = ...
final authServiceProvider = ...
final dashboardViewModelProvider = ...

// AsyncNotifier/Notifier classes: no suffix
class DashboardViewModel extends AsyncNotifier<DashboardState> {}
class AuthController extends Notifier<AuthState> {}
```

## Serverpod Conventions

### Model Definitions (YAML)

```yaml
# lib/src/models/event.yaml
class: Event
table: events
fields:
  controlId: String
  eventType: String
  payload: String?
  timestamp: DateTime
  userId: String
indexes:
  event_user_idx:
    fields: userId
    type: btree
```

### Endpoint Definitions

```dart
class EventEndpoint extends Endpoint {
  /// Sends an event from a control
  ///
  /// [controlId] - The ID of the control triggering the event
  /// [eventType] - Type of event (button_press, slider_change, etc.)
  /// [payload] - Optional JSON payload
  Future<EventResponse> sendEvent(
    Session session, {
    required String controlId,
    required String eventType,
    String? payload,
  }) async {
    // Validate input
    if (controlId.isEmpty) {
      throw ArgumentError('controlId cannot be empty');
    }

    // Process event
    final event = Event(
      controlId: controlId,
      eventType: eventType,
      payload: payload,
      timestamp: DateTime.now(),
      userId: await session.auth.authenticatedUserId ?? 'anonymous',
    );

    // Save and dispatch
    await Event.db.insertRow(session, event);
    await _dispatchEvent(session, event);

    return EventResponse(success: true, eventId: event.id!);
  }
}
```

## Error Handling

### Custom Exceptions

```dart
// Base exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});
}

// Specific exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
  });
}
```

### Result Pattern (Optional)

```dart
// For operations that can fail
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

// Usage
Future<Result<User>> getUser(String id) async {
  try {
    final user = await _api.fetchUser(id);
    return Success(user);
  } on NetworkException catch (e) {
    return Failure(e);
  }
}
```

## Testing Conventions

**See `docs/TESTING.md` for comprehensive testing guide.**

### Test-Driven Development (TDD)

Follow TDD workflow for all new features:
1. **Red**: Write a failing test first
2. **Green**: Write minimal code to pass the test
3. **Refactor**: Clean up while keeping tests green

### Test Types & Coverage Targets

| Type | Target Coverage | Speed | When to Use |
|------|-----------------|-------|-------------|
| Unit | 80%+ | Fast (ms) | Business logic, ViewModels, utilities |
| Widget | Key widgets | Medium (s) | UI components, interactions |
| Integration | Critical flows | Slow (min) | End-to-end user journeys |
| Golden | UI regression | Medium | Visual consistency |

### Test File Organization

```
test/
├── unit/                          # Unit tests
│   ├── core/
│   │   └── utils/
│   │       └── template_parser_test.dart
│   └── features/
│       └── dashboard/
│           ├── dashboard_viewmodel_test.dart
│           └── control_repository_test.dart
├── widget/                        # Widget tests
│   └── features/
│       └── dashboard/
│           ├── button_control_widget_test.dart
│           └── dashboard_view_test.dart
├── integration/                   # Integration tests
│   ├── dashboard_flow_test.dart
│   └── test_tools/               # Serverpod generated
├── golden/                        # Golden/snapshot tests
│   ├── control_cards_test.dart
│   └── goldens/                  # Golden image files
└── fixtures/                      # Shared test data
    └── test_data.dart
```

### Mocking with Mocktail (Preferred)

```dart
import 'package:mocktail/mocktail.dart';

// Create mock
class MockEventRepository extends Mock implements EventRepository {}

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

  test('sends event successfully', () async {
    // Arrange
    when(() => mockRepo.sendEvent(any()))
        .thenAnswer((_) async => EventResponse(success: true));

    // Act
    final result = await mockRepo.sendEvent(testEvent);

    // Assert
    expect(result.success, isTrue);
    verify(() => mockRepo.sendEvent(any())).called(1);
  });
}
```

### AAA Pattern (Arrange-Act-Assert)

Always structure tests with clear sections:

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

### Serverpod Backend Testing

Use the `withServerpod` helper for integration tests:

```dart
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('EventEndpoint', (sessionBuilder, endpoints) {
    test('creates event successfully', () async {
      // Arrange
      final session = sessionBuilder.build();

      // Act
      final result = await endpoints.event.sendEvent(
        session,
        controlId: 'ctrl_1',
        eventType: 'button_press',
      );

      // Assert
      expect(result.success, isTrue);
    });
  });
}
```

### Testing Riverpod Providers

```dart
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
```

### Test Naming Conventions

```dart
// Group: Class or feature name
group('DashboardViewModel', () {
  // Nested group: Method name (optional)
  group('loadDashboard', () {
    // Test: Describe expected behavior
    test('emits loading state then data on success', () { });
    test('emits error state when repository throws', () { });
    test('retries failed request up to 3 times', () { });
  });
});
```

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific file
flutter test test/unit/features/dashboard/dashboard_viewmodel_test.dart

# By name pattern
flutter test --name "DashboardViewModel"

# Exclude integration tests
flutter test --exclude-tags integration

# Update golden files
flutter test --update-goldens

# Serverpod tests
cd remotly_server && dart test
```

### What NOT to Test

- Trivial code (simple getters/setters)
- Framework code (Flutter widgets' internal behavior)
- Third-party packages
- Implementation details (test behavior, not how)

## Git Conventions

**See `docs/GIT.md` for comprehensive Git/GitHub best practices guide.**

### Branching Strategy

We use **Trunk-Based Development** with short-lived feature branches:

```
main (protected)
  │
  ├── feat/dashboard-controls    → merged back to main
  ├── fix/notification-display   → merged back to main
  └── feat/openapi-import        → merged back to main
```

### Branch Naming

```
<type>/<short-description>
```

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat/user-authentication` |
| `fix` | Bug fix | `fix/login-validation` |
| `refactor` | Code refactoring | `refactor/control-service` |
| `docs` | Documentation | `docs/api-endpoints` |
| `test` | Adding tests | `test/action-executor` |
| `chore` | Maintenance | `chore/update-dependencies` |

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Scopes:** `api`, `app`, `client`, `models`, `auth`, `controls`, `actions`, `notifications`, `openapi`, `deps`, `config`

**Rules:**
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end
- Maximum 50 characters

**Examples:**
```
feat(controls): add slider control widget
fix(api): handle null payload in event endpoint
docs(readme): update installation instructions
refactor(actions): extract template parser to separate service
test(auth): add unit tests for login validation
chore(deps): update serverpod to 2.9.2
```

**Breaking Changes:**
```
feat(api)!: change event endpoint response format

BREAKING CHANGE: The event endpoint now returns a different JSON structure.
```

### Pull Request Workflow

1. **Create feature branch** from `main`
2. **Develop** with small, focused commits
3. **Push** regularly to remote
4. **Open PR** when ready for review
5. **Address feedback** within 24 hours
6. **Merge** after approval (squash preferred)
7. **Delete** branch after merge

### PR Title Format

Follow commit message format:
```
<type>(<scope>): <subject>
```

### Code Review Comment Prefixes

| Prefix | Meaning | Action Required |
|--------|---------|-----------------|
| `blocking:` | Must be fixed | Yes |
| `suggestion:` | Nice to have | Optional |
| `question:` | Clarification | Response needed |
| `nit:` | Minor style | Optional |
| `praise:` | Good work | None |

### Git Commands Quick Reference

```bash
# Start new feature
git checkout main && git pull origin main
git checkout -b feat/new-feature

# Commit changes
git add .
git commit -m "feat(scope): add new feature"

# Push and create PR
git push -u origin feat/new-feature
gh pr create

# After PR merged
git checkout main && git pull origin main
git branch -d feat/new-feature

# Keep branch updated (rebase preferred)
git fetch origin && git rebase origin/main
```

## Documentation

### Code Comments

```dart
/// A control that can be placed on the dashboard.
///
/// Controls send events to the API when interacted with.
/// The [controlType] determines the widget rendered and the
/// event payload structure.
///
/// Example:
/// ```dart
/// final button = Control(
///   id: 'btn_1',
///   controlType: ControlType.button,
///   label: 'Toggle Light',
///   actionId: 'action_toggle_light',
/// );
/// ```
class Control {
  /// Unique identifier for the control.
  final String id;

  /// The type of control (button, slider, toggle, etc.).
  final ControlType controlType;

  // ... rest of class
}
```

### TODO Comments

```dart
// TODO(username): Description of what needs to be done
// TODO(#123): Reference to GitHub issue

// FIXME: Description of bug to fix
// HACK: Explanation of temporary workaround
```

## Development Workflow

### Feature Development Process

Follow this workflow for all new features and bug fixes:

```
1. PLAN        → Understand requirements, design approach
2. TEST (Red)  → Write failing tests first
3. CODE (Green)→ Implement minimal code to pass tests
4. REFACTOR    → Clean up while keeping tests green
5. REVIEW      → Self-review, run all tests, check coverage
6. COMMIT      → Commit with conventional commit message
```

### Step-by-Step Workflow

#### 1. Before Writing Code

```bash
# Create feature branch
git checkout -b feat/feature-name

# Understand the feature requirements
# - Read related documentation
# - Check existing code patterns
# - Identify affected components
```

#### 2. Write Tests First (TDD)

```bash
# Create test file
touch test/unit/features/dashboard/new_feature_test.dart

# Write failing tests that define expected behavior
flutter test test/unit/features/dashboard/new_feature_test.dart
# Expected: Tests FAIL (Red phase)
```

#### 3. Implement the Feature

```dart
// Write minimal code to make tests pass
// Follow existing patterns in the codebase
// Keep it simple - no over-engineering
```

```bash
# Run tests again
flutter test test/unit/features/dashboard/new_feature_test.dart
# Expected: Tests PASS (Green phase)
```

#### 4. Refactor & Clean Up

```bash
# Refactor while keeping tests green
flutter test  # All tests should still pass

# Check code coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Target: 80%+ coverage on new code
```

#### 5. Pre-Commit Checklist

Before committing, verify:

```bash
# 1. All tests pass
flutter test

# 2. Code is formatted
dart format .

# 3. No analysis issues
dart analyze

# 4. Serverpod code generated (if models changed)
cd remotly_server && serverpod generate

# 5. Server tests pass
cd remotly_server && dart test
```

#### 6. Commit & Push

```bash
# Stage changes
git add .

# Commit with conventional message
git commit -m "feat(dashboard): add new control type

- Add slider control widget
- Implement value change handling
- Add unit tests for slider behavior

Closes #123"

# Push to remote
git push -u origin feat/feature-name
```

### Code Review Checklist

When reviewing code (self or others):

- [ ] Tests exist and cover the new functionality
- [ ] Tests follow AAA pattern (Arrange-Act-Assert)
- [ ] Code follows project conventions
- [ ] No unnecessary complexity or over-engineering
- [ ] Error handling is appropriate
- [ ] No security vulnerabilities introduced
- [ ] Documentation updated if needed

### Quick Reference Commands

```bash
# Development
flutter run                          # Run app
flutter build apk                    # Build APK
serverpod generate                   # Generate Serverpod code

# Testing
flutter test                         # All tests
flutter test --coverage              # With coverage
flutter test --update-goldens        # Update golden files
dart test                            # Serverpod tests

# Quality
dart format .                        # Format code
dart analyze                         # Static analysis
dart fix --apply                     # Auto-fix issues

# Git
git checkout -b feat/name            # New feature branch
git commit -m "type(scope): msg"     # Conventional commit
```

### When to Write Which Test Type

| Scenario | Test Type |
|----------|-----------|
| New utility function | Unit test |
| New ViewModel method | Unit test |
| Repository logic | Unit test |
| New widget | Widget test |
| Widget interactions | Widget test |
| Critical user flow | Integration test |
| UI appearance | Golden test |
| API endpoint | Serverpod integration test |

### Continuous Integration

All PRs must pass:
1. `flutter test` - All Flutter tests
2. `dart test` - All Serverpod tests
3. `dart analyze` - No analysis errors
4. Coverage check - No significant decrease
