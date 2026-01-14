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

### Test File Naming

```
test/
├── unit/
│   ├── features/
│   │   └── dashboard/
│   │       ├── dashboard_viewmodel_test.dart
│   │       └── dashboard_repository_test.dart
│   └── core/
│       └── utils/
│           └── validators_test.dart
├── widget/
│   └── features/
│       └── dashboard/
│           └── dashboard_view_test.dart
└── integration/
    └── app_test.dart
```

### Test Structure

```dart
void main() {
  group('DashboardViewModel', () {
    late MockDashboardRepository mockRepository;
    late DashboardViewModel viewModel;

    setUp(() {
      mockRepository = MockDashboardRepository();
      viewModel = DashboardViewModel(mockRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('loadDashboard', () {
      test('emits loading then data on success', () async {
        // Arrange
        when(() => mockRepository.getDashboard())
            .thenAnswer((_) async => mockDashboard);

        // Act
        await viewModel.loadDashboard();

        // Assert
        expect(viewModel.state, isA<AsyncData<DashboardState>>());
      });

      test('emits loading then error on failure', () async {
        // Arrange
        when(() => mockRepository.getDashboard())
            .thenThrow(NetworkException('No connection'));

        // Act
        await viewModel.loadDashboard();

        // Assert
        expect(viewModel.state, isA<AsyncError<DashboardState>>());
      });
    });
  });
}
```

## Git Conventions

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Build process, dependencies, etc.

Examples:
```
feat(dashboard): add drag-and-drop control reordering
fix(notifications): resolve FCM token refresh issue
docs(api): update notification endpoint documentation
refactor(events): extract event validation to separate service
test(actions): add unit tests for HTTP action executor
chore(deps): upgrade serverpod to 2.1.0
```

### Branch Naming

```
<type>/<short-description>

Examples:
feat/dashboard-controls
fix/notification-delivery
refactor/event-service
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
