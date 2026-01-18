# Rmotly - System Architecture

## Overview

Rmotly is a bidirectional event-driven system that enables users to:
1. Create custom controls in a mobile app that trigger remote actions
2. Receive notifications from external sources through configurable topics
3. Define actions based on OpenAPI specifications

## System Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              External Services                               │
│  (Home Assistant, IFTTT, Webhooks, IoT devices, Custom APIs)                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
            ┌───────────┐     ┌───────────┐     ┌───────────┐
            │  Webhook  │     │   REST    │     │ WebSocket │
            │  Endpoint │     │  Endpoint │     │  Stream   │
            └───────────┘     └───────────┘     └───────────┘
                    │                 │                 │
                    └─────────────────┼─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │         Rmotly API Server        │
                    │           (Serverpod)             │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │      Event Router           │  │
                    │  │  ┌─────┐ ┌─────┐ ┌─────┐   │  │
                    │  │  │Queue│ │Route│ │Exec │   │  │
                    │  │  └─────┘ └─────┘ └─────┘   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │    Notification Service     │  │
                    │  │  ┌─────┐ ┌─────┐ ┌─────┐   │  │
                    │  │  │Topic│ │ FCM │ │Store│   │  │
                    │  │  └─────┘ └─────┘ └─────┘   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌──────────┐  ┌──────────────┐  │
                    │  │PostgreSQL│  │    Redis     │  │
                    │  │  (Data)  │  │   (Cache)    │  │
                    │  └──────────┘  └──────────────┘  │
                    └─────────────────┬─────────────────┘
                                      │
                         ┌────────────┼────────────┐
                         │            │            │
                         ▼            ▼            ▼
                    ┌─────────┐ ┌─────────┐ ┌─────────┐
                    │Serverpod│ │   FCM   │ │WebSocket│
                    │ Client  │ │  Push   │ │ Stream  │
                    └─────────┘ └─────────┘ └─────────┘
                         │            │            │
                         └────────────┼────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │        Rmotly Mobile App         │
                    │            (Flutter)              │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │        Dashboard            │  │
                    │  │   [Btn] [Slider] [Toggle]   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │     Notification Center     │  │
                    │  │   [Topic 1] [Topic 2] ...   │  │
                    │  └─────────────────────────────┘  │
                    │                                   │
                    │  ┌─────────────────────────────┐  │
                    │  │      Action Manager         │  │
                    │  │   [OpenAPI] [HTTP Config]   │  │
                    │  └─────────────────────────────┘  │
                    └───────────────────────────────────┘
```

## Data Flow

### 1. Control Event Flow (App → API → External)

```
User taps button     App sends event      API processes      Action executed
in dashboard    →    to Serverpod    →    and routes    →    (HTTP request)
     │                    │                   │                    │
     ▼                    ▼                   ▼                    ▼
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│ Control │─────────│  Event  │─────────│ Action  │─────────│ External│
│   UI    │         │ Payload │         │Executor │         │   API   │
└─────────┘         └─────────┘         └─────────┘         └─────────┘
```

### 2. Notification Flow (External → API → App)

```
External service    API receives       FCM dispatches     App displays
sends webhook  →    notification  →    to device     →    notification
     │                   │                  │                  │
     ▼                   ▼                  ▼                  ▼
┌─────────┐         ┌─────────┐        ┌─────────┐        ┌─────────┐
│ Webhook │─────────│ Process │────────│Firebase │────────│  Show   │
│ Request │         │ & Route │        │   FCM   │        │Notif UI │
└─────────┘         └─────────┘        └─────────┘        └─────────┘
```

## Core Entities

### Control

A user-defined UI element that triggers events.

```dart
class Control {
  String id;              // Unique identifier
  String name;            // Display name
  ControlType type;       // button, slider, toggle, input
  String actionId;        // Associated action to trigger
  Map<String, dynamic> config;  // Type-specific configuration
  int position;           // Dashboard position/order
}

enum ControlType {
  button,     // Simple tap → event
  toggle,     // On/off state → event with state
  slider,     // Range value → event with value
  input,      // Text input → event with text
  dropdown,   // Selection → event with selected value
}
```

### Action

An HTTP request definition, optionally built from OpenAPI spec.

```dart
class Action {
  String id;
  String name;
  String description;
  HttpMethod method;           // GET, POST, PUT, DELETE, PATCH
  String urlTemplate;          // URL with {{variable}} placeholders
  Map<String, String> headers; // Static headers
  String? bodyTemplate;        // JSON body with {{variable}} placeholders
  String? openApiSpecUrl;      // Source OpenAPI spec (if applicable)
  String? openApiOperationId;  // Operation ID from spec
  List<ActionParameter> parameters;  // Parameter definitions
}

class ActionParameter {
  String name;
  ParameterLocation location;  // path, query, header, body
  String type;                 // string, number, boolean
  bool required;
  dynamic defaultValue;
  String? description;
}
```

### NotificationTopic

A channel for receiving notifications from external sources.

```dart
class NotificationTopic {
  String id;
  String name;
  String description;
  String apiKey;              // For authenticating incoming notifications
  bool enabled;
  NotificationConfig config;  // Display configuration
}

class NotificationConfig {
  String titleTemplate;       // "{{title}}" or static text
  String bodyTemplate;        // "{{message}}" or static text
  String? imageUrlField;      // Field name for image URL in payload
  String? actionUrlField;     // Field name for action URL
  NotificationPriority priority;
  String? soundName;
  String? channelId;          // Android notification channel
}
```

### Event

An occurrence that flows through the system.

```dart
class Event {
  String id;
  String sourceType;          // 'control', 'webhook', 'scheduled'
  String sourceId;            // Control ID, webhook ID, etc.
  String eventType;           // 'button_press', 'value_change', etc.
  Map<String, dynamic> payload;
  DateTime timestamp;
  String? userId;
}
```

## API Endpoints

### Event Endpoints

```
POST   /api/events              Send event from app
GET    /api/events              List recent events (paginated)
GET    /api/events/:id          Get event details
DELETE /api/events/:id          Delete event
```

### Notification Endpoints

```
POST   /api/notify/:topicId     Send notification to topic (external use)
POST   /api/topics              Create notification topic
GET    /api/topics              List user's topics
GET    /api/topics/:id          Get topic details
PUT    /api/topics/:id          Update topic
DELETE /api/topics/:id          Delete topic
```

### Action Endpoints

```
POST   /api/actions             Create action
GET    /api/actions             List actions
GET    /api/actions/:id         Get action details
PUT    /api/actions/:id         Update action
DELETE /api/actions/:id         Delete action
POST   /api/actions/:id/test    Test action execution
POST   /api/actions/from-openapi  Create action from OpenAPI operation
```

### Control Endpoints

```
POST   /api/controls            Create control
GET    /api/controls            List controls
GET    /api/controls/:id        Get control details
PUT    /api/controls/:id        Update control
DELETE /api/controls/:id        Delete control
PUT    /api/controls/reorder    Reorder controls
```

### OpenAPI Endpoints

```
POST   /api/openapi/parse       Parse OpenAPI spec from URL
GET    /api/openapi/operations  List operations from parsed spec
```

## Notification API (External Compatibility)

The notification endpoint is designed for maximum compatibility:

### Basic Usage

```bash
POST /api/notify/{topicId}
Authorization: Bearer {topic_api_key}
Content-Type: application/json

{
  "title": "Alert",
  "message": "Something happened",
  "data": { "custom": "data" }
}
```

### Supported Patterns

#### 1. Simple JSON (Default)
```json
{
  "title": "Title",
  "message": "Body text"
}
```

#### 2. Firebase-style
```json
{
  "notification": {
    "title": "Title",
    "body": "Body text"
  },
  "data": {}
}
```

#### 3. Pushover-style
```json
{
  "title": "Title",
  "message": "Body",
  "priority": 1,
  "sound": "pushover"
}
```

#### 4. Ntfy-style
```json
{
  "topic": "ignored",
  "title": "Title",
  "message": "Body",
  "priority": 3,
  "tags": ["tag1"]
}
```

#### 5. Gotify-style
```json
{
  "title": "Title",
  "message": "Body",
  "priority": 5,
  "extras": {}
}
```

#### 6. Webhook/Generic
The API extracts `title`/`message` from common field names:
- `title`, `subject`, `name`, `header`
- `message`, `body`, `text`, `content`, `description`

## Security

### Authentication

- **App ↔ API**: Serverpod session-based auth with JWT tokens
- **External → API**: Per-topic API keys (Bearer tokens)
- **API → External**: Credentials stored per-action (encrypted)

### Authorization

- Users can only access their own controls, actions, topics
- Topic API keys are scoped to specific topics
- Action credentials are encrypted at rest

### Rate Limiting

- Notification endpoint: 100 requests/minute per topic
- Event endpoint: 1000 requests/minute per user
- OpenAPI parsing: 10 requests/minute per user

## Scalability Considerations

### Horizontal Scaling

- Stateless API servers behind load balancer
- Redis for session storage and caching
- PostgreSQL with read replicas

### Event Processing

- Optional Redis queue for high-volume event processing
- Async action execution with retry logic
- Dead letter queue for failed actions

### Caching Strategy

- Cache OpenAPI specs (24h TTL)
- Cache parsed action templates
- Cache topic configurations

## Service Layer Architecture

Rmotly uses Serverpod's service-oriented architecture to encapsulate business logic. Services are stateless classes that orchestrate operations across multiple entities and provide reusable functionality.

### Service Pattern

Services in Serverpod are instantiated per-request and receive a `Session` object for database access and logging.

```dart
/// Service for handling events from controls and external sources.
class EventService {
  final ActionExecutorService _actionExecutor;

  // Constructor injection for dependencies
  EventService(this._actionExecutor);

  /// Process an event by finding and executing the associated action
  Future<String?> processEvent(
    Session session, {
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
  }) async {
    // Business logic implementation
    // ...
  }
}
```

### Key Services

#### EventService

**Responsibilities:**
- Validate incoming events
- Route control events to associated actions
- Create and persist event records
- Query event history with filtering

**Dependencies:**
- `ActionExecutorService` - Execute actions triggered by events

#### ActionExecutorService

**Responsibilities:**
- Execute HTTP requests with template substitution
- Implement retry logic with exponential backoff
- Handle timeouts and network errors
- Parse and return response data

**Key Features:**
```dart
class ActionExecutorService {
  static const defaultTimeout = Duration(seconds: 30);
  static const maxRetries = 3;
  static const baseRetryDelay = Duration(seconds: 1);

  Future<ActionResult> execute(
    ActionConfig config,
    Map<String, dynamic>? parameters, {
    Session? session,
    Duration timeout = defaultTimeout,
    int retryCount = 0,
  }) async {
    // Template variable substitution
    final url = substituteVariables(config.urlTemplate, parameters ?? {});
    
    // Execute with retry logic
    try {
      // ... HTTP request execution
    } on SocketException catch (e) {
      // Retry on network errors with exponential backoff
      if (retryCount < maxRetries) {
        final delay = baseRetryDelay * (1 << retryCount);
        await Future.delayed(delay);
        return execute(config, parameters, retryCount: retryCount + 1);
      }
    }
  }
}
```

#### NotificationService

**Responsibilities:**
- Orchestrate three-tier notification delivery
- Manage SSE notification queue
- Coordinate WebSocket, WebPush, and SSE channels

**Three-Tier Delivery Strategy:**

```dart
Future<NotificationDeliveryResult> deliver(
  Session session,
  NotificationData notification, {
  List<PushSubscriptionData>? pushSubscriptions,
}) async {
  // Tier 1: Try WebSocket (for foreground apps)
  final wsResult = await _deliverViaWebSocket(session, notification);
  if (wsResult.webSocketDeliveries! > 0) return wsResult;

  // Tier 2: Try WebPush (for background apps)
  final pushResult = await _deliverViaWebPush(session, notification, pushSubscriptions);
  if (pushResult.pushDeliveries! > 0) return pushResult;

  // Tier 3: Queue for SSE (fallback)
  return await _queueForSse(session, notification);
}
```

#### OpenApiParserService

**Responsibilities:**
- Parse OpenAPI 3.0+ specifications
- Extract operation definitions
- Convert OpenAPI parameters to action configurations
- Validate spec structure

#### EncryptionService

**Responsibilities:**
- Encrypt sensitive credentials (API keys, tokens)
- Decrypt credentials for action execution
- Secure storage of action authentication data

### Service Registration

Services are registered in `server.dart` and injected into endpoints:

```dart
void run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    servicesSetup: (session) => {
      'actionExecutor': ActionExecutorService(),
      'eventService': EventService(ActionExecutorService()),
      'notificationService': NotificationService(),
      // ... other services
    },
  );

  await pod.start();
}
```

## State Management Patterns

Rmotly's Flutter app uses **Riverpod** for dependency injection and state management, following clean architecture principles.

### Provider Hierarchy

```
┌─────────────────────────────────────────────────────┐
│              Provider (Stateless)                   │
│  - Services (ErrorHandler, Connectivity, Storage)   │
│  - Repositories (Control, Action, Topic, Event)     │
│  - API Client                                        │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│          StateNotifierProvider (Stateful)           │
│  - ViewModels (ActionsViewModel, etc.)              │
│  - Holds UI state (loading, data, errors)           │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              Widget Layer (UI)                       │
│  - Watches providers with ref.watch()               │
│  - Calls ViewModel methods                          │
└─────────────────────────────────────────────────────┘
```

### Provider Definition

Providers are defined in `lib/providers.dart` and `lib/core/providers/`:

```dart
/// Provider for repository with dependency injection
final actionRepositoryProvider = Provider<ActionRepository?>((ref) {
  // Watch dependencies
  final client = ref.watch(apiClientProvider);
  if (client == null) return null;

  final errorHandler = ref.watch(errorHandlerServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  // Create repository with dependencies
  return ActionRepository(
    client,
    errorHandler,
    localStorage,
    connectivity,
  );
});
```

### StateNotifier Pattern for ViewModels

ViewModels use `StateNotifier<T>` to manage feature state:

```dart
/// State class (immutable)
class ActionsState {
  final List<Action> actions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int? testingActionId;
  final ActionTestResult? lastTestResult;

  const ActionsState({
    this.actions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.testingActionId,
    this.lastTestResult,
  });

  // CopyWith for immutable updates
  ActionsState copyWith({
    List<Action>? actions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    int? testingActionId,
    bool clearTestingAction = false,
    ActionTestResult? lastTestResult,
    bool clearLastTestResult = false,
  }) {
    return ActionsState(
      actions: actions ?? this.actions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      testingActionId: clearTestingAction ? null : (testingActionId ?? this.testingActionId),
      lastTestResult: clearLastTestResult ? null : (lastTestResult ?? this.lastTestResult),
    );
  }
}

/// ViewModel (StateNotifier)
class ActionsViewModel extends StateNotifier<ActionsState> {
  final ActionRepository? _repository;

  ActionsViewModel(ActionRepository repository)
      : _repository = repository,
        super(ActionsState.initial) {
    loadActions();
  }

  /// Load actions from repository
  Future<void> loadActions() async {
    if (_repository == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final actions = await _repository.getActions();
      state = state.copyWith(
        actions: actions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load actions: $e',
      );
    }
  }

  /// Create a new action
  Future<Action?> createAction(Action action) async {
    if (_repository == null) return null;

    try {
      final created = await _repository.createAction(action);
      
      // Update local state immutably
      state = state.copyWith(
        actions: [...state.actions, created],
      );
      
      return created;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create action');
      return null;
    }
  }
}
```

### ViewModel Provider Definition

```dart
/// StateNotifierProvider for ViewModel
final actionsViewModelProvider = 
    StateNotifierProvider<ActionsViewModel, ActionsState>((ref) {
  final repository = ref.watch(actionRepositoryProvider);
  
  if (repository == null) {
    return ActionsViewModel.withError('Server not configured');
  }
  
  return ActionsViewModel(repository);
});
```

### Widget Integration

Widgets consume providers using `ref.watch()` and `ref.read()`:

```dart
class ActionsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state for rebuilds
    final state = ref.watch(actionsViewModelProvider);
    
    if (state.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (state.error != null) {
      return ErrorWidget(state.error!);
    }
    
    return ListView.builder(
      itemCount: state.actions.length,
      itemBuilder: (context, index) {
        final action = state.actions[index];
        return ActionTile(
          action: action,
          onTap: () {
            // Call ViewModel method
            ref.read(actionsViewModelProvider.notifier)
               .testAction(action.id!, {});
          },
        );
      },
    );
  }
}
```

### Provider Overrides for Testing

Riverpod allows easy mocking in tests:

```dart
testWidgets('ActionsListView displays actions', (tester) async {
  final mockRepository = MockActionRepository();
  when(mockRepository.getActions()).thenAnswer((_) async => [testAction]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        actionRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: ActionsListView()),
    ),
  );

  expect(find.text(testAction.name), findsOneWidget);
});
```

### AsyncValue for Async State

For simple async operations without complex state:

```dart
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

// In widget
ref.watch(userProvider).when(
  data: (user) => Text('Hello ${user.name}'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## Repository Pattern

Repositories abstract data access and provide a clean interface between the UI layer and external APIs. They handle caching, offline support, and error mapping.

### Repository Architecture

```
┌──────────────────────────────────────────────────────┐
│              Repository Interface                    │
│          (lib/features/*/domain/)                    │
│  - Abstract methods (e.g., getActions())             │
│  - Domain-focused API                                │
└──────────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│         Repository Implementation                    │
│           (lib/core/repositories/)                   │
│  - API client calls                                  │
│  - Offline caching                                   │
│  - Error handling and mapping                        │
└──────────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│              Data Sources                            │
│  - Serverpod Client (remote)                         │
│  - Local Storage (cache)                             │
│  - Offline Queue (pending operations)                │
└──────────────────────────────────────────────────────┘
```

### Repository Structure

```dart
/// Repository for managing Control entities
class ControlRepository {
  final Client _client;
  final ErrorHandlerService _errorHandler;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivityService;

  ControlRepository(
    this._client,
    this._errorHandler,
    this._localStorage,
    this._connectivityService,
  );

  /// Lists all controls for the current user
  Future<List<Control>> listControls() async {
    try {
      // Primary: Fetch from API
      final controls = await _client.control.listControls();
      
      // Cache for offline use
      await _localStorage.cacheControls(controls);
      
      return controls;
    } catch (error) {
      // Fallback: Return cached data if offline or retryable error
      if (!_connectivityService.isOnline || _errorHandler.isRetryable(error)) {
        try {
          final cachedControls = await _localStorage.getCachedControls();
          if (cachedControls.isNotEmpty) {
            return cachedControls;
          }
        } catch (_) {
          // Cache read failed, fall through to error handling
        }
      }
      
      // Map to user-friendly exception
      throw _errorHandler.mapToAppException(error);
    }
  }

  /// Creates a new control
  Future<Control> createControl(Control control) async {
    return await _client.control.createControl(control);
  }

  /// Updates an existing control
  Future<Control> updateControl(Control control) async {
    return await _client.control.updateControl(control);
  }

  /// Deletes a control
  Future<void> deleteControl(int controlId) async {
    await _client.control.deleteControl(controlId);
  }
}
```

### Caching Strategy

**Read-through Cache:**
1. Try to fetch from API
2. On success, update cache
3. On failure, return cached data (if offline/retryable)
4. If no cache available, throw error

**Write-through Queue:**
1. For mutating operations (create/update/delete)
2. If offline, queue operation
3. When online, replay queued operations
4. Update cache with results

### Error Handling in Repositories

Repositories map low-level errors to domain exceptions:

```dart
try {
  return await _client.action.createAction(action);
} catch (error) {
  // Map to AppException hierarchy
  throw _errorHandler.mapToAppException(error);
}
```

### ActionRepository Example

```dart
class ActionRepository {
  final Client _client;
  final ErrorHandlerService _errorHandler;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivityService;

  /// Get all actions
  Future<List<Action>> getActions() async {
    try {
      final actions = await _client.action.listActions();
      await _localStorage.cacheActions(actions);
      return actions;
    } catch (error) {
      if (!_connectivityService.isOnline) {
        return await _localStorage.getCachedActions();
      }
      throw _errorHandler.mapToAppException(error);
    }
  }

  /// Test an action
  Future<ActionTestResult> testAction(
    int actionId,
    Map<String, dynamic> parameters,
  ) async {
    try {
      return await _client.action.testAction(actionId, parameters);
    } catch (error) {
      throw _errorHandler.mapToAppException(error);
    }
  }

  /// Create action from OpenAPI operation
  Future<Action> createFromOpenApi(
    String specUrl,
    String operationId,
  ) async {
    try {
      return await _client.action.createFromOpenApi(specUrl, operationId);
    } catch (error) {
      throw _errorHandler.mapToAppException(error);
    }
  }
}
```

## Event Flow Sequences

### Control Button Press → Action Execution

```
User                App (Flutter)           Serverpod API           External Service
 │                        │                       │                        │
 │  Tap Button            │                       │                        │
 │───────────────────────>│                       │                        │
 │                        │                       │                        │
 │                        │  POST /api/events     │                        │
 │                        │  {sourceType: 'control',                       │
 │                        │   sourceId: '123',    │                        │
 │                        │   eventType: 'press', │                        │
 │                        │   payload: {...}}     │                        │
 │                        │──────────────────────>│                        │
 │                        │                       │                        │
 │                        │                       │ EventService.processEvent()
 │                        │                       │  - Validate event      │
 │                        │                       │  - Look up Control     │
 │                        │                       │  - Get associated Action
 │                        │                       │                        │
 │                        │                       │ ActionExecutorService.execute()
 │                        │                       │  - Substitute variables│
 │                        │                       │  - Build HTTP request  │
 │                        │                       │                        │
 │                        │                       │  HTTP POST/GET/etc     │
 │                        │                       │───────────────────────>│
 │                        │                       │                        │
 │                        │                       │        200 OK          │
 │                        │                       │<───────────────────────│
 │                        │                       │                        │
 │                        │                       │ EventService.createEvent()
 │                        │                       │  - Save to database    │
 │                        │                       │                        │
 │                        │    200 OK             │                        │
 │                        │  {success: true,      │                        │
 │                        │   statusCode: 200,    │                        │
 │                        │   executionTimeMs: 450}                        │
 │                        │<──────────────────────│                        │
 │                        │                       │                        │
 │  Show Success Toast    │                       │                        │
 │<───────────────────────│                       │                        │
 │                        │                       │                        │
```

### Webhook Notification → Push Delivery

```
External Service    Serverpod API          NotificationService     Firebase FCM        App
      │                  │                        │                      │              │
      │  POST /api/notify/:topicId                │                      │              │
      │  Authorization: Bearer {apiKey}           │                      │              │
      │  {title: "Alert",                         │                      │              │
      │   message: "Event occurred"}              │                      │              │
      │─────────────────>│                        │                      │              │
      │                  │                        │                      │              │
      │                  │ Authenticate request   │                      │              │
      │                  │  - Verify API key      │                      │              │
      │                  │  - Check rate limits   │                      │              │
      │                  │                        │                      │              │
      │                  │ NotificationService.deliver()                 │              │
      │                  │───────────────────────>│                      │              │
      │                  │                        │                      │              │
      │                  │                        │ Tier 1: WebSocket    │              │
      │                  │                        │  - Check active connections          │
      │                  │                        │  - Send if connected │              │
      │                  │                        │─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ >│
      │                  │                        │                      │   (if foreground)
      │                  │                        │                      │              │
      │                  │                        │ Tier 2: FCM Push     │              │
      │                  │                        │  - Get user subscriptions            │
      │                  │                        │  - Send to FCM       │              │
      │                  │                        │─────────────────────>│              │
      │                  │                        │                      │              │
      │                  │                        │                      │  Push Notif  │
      │                  │                        │                      │─────────────>│
      │                  │                        │                      │              │
      │                  │                        │ Tier 3: SSE Queue    │              │
      │                  │                        │  - Queue for pickup  │              │
      │                  │                        │   (if FCM failed)    │              │
      │                  │                        │                      │              │
      │                  │  200 OK                │                      │              │
      │                  │  {delivered: true,     │                      │              │
      │                  │   method: 'fcm'}       │                      │              │
      │<─────────────────│<───────────────────────│                      │              │
      │                  │                        │                      │              │
```

### OpenAPI Spec Import → Action Creation

```
User          App (Flutter)        Serverpod API       OpenApiParserService    Database
 │                 │                     │                     │                  │
 │  Enter Spec URL │                     │                     │                  │
 │────────────────>│                     │                     │                  │
 │                 │                     │                     │                  │
 │  Tap Import     │                     │                     │                  │
 │────────────────>│                     │                     │                  │
 │                 │                     │                     │                  │
 │                 │ POST /api/openapi/parse                   │                  │
 │                 │ {specUrl: "https://..."}                  │                  │
 │                 │────────────────────>│                     │                  │
 │                 │                     │                     │                  │
 │                 │                     │ OpenApiParserService.parseSpec()       │
 │                 │                     │────────────────────>│                  │
 │                 │                     │                     │                  │
 │                 │                     │                     │ Fetch spec       │
 │                 │                     │                     │  - HTTP GET      │
 │                 │                     │                     │  - Validate JSON │
 │                 │                     │                     │                  │
 │                 │                     │                     │ Parse operations │
 │                 │                     │                     │  - Extract paths │
 │                 │                     │                     │  - Parse params  │
 │                 │                     │                     │  - Build schema  │
 │                 │                     │                     │                  │
 │                 │                     │  OpenApiSpec object │                  │
 │                 │                     │<────────────────────│                  │
 │                 │                     │                     │                  │
 │                 │                     │ Cache spec (24h TTL)                   │
 │                 │                     │─ ─ ─ ─ ─ ─ ─ ─ ─ ─>│                  │
 │                 │                     │                     │                  │
 │                 │  200 OK             │                     │                  │
 │                 │  {operations: [     │                     │                  │
 │                 │    {operationId: "getUser",               │                  │
 │                 │     method: "GET",  │                     │                  │
 │                 │     path: "/users/{id}"}                  │                  │
 │                 │   ]}                │                     │                  │
 │                 │<────────────────────│                     │                  │
 │                 │                     │                     │                  │
 │  Show Operations│                     │                     │                  │
 │<────────────────│                     │                     │                  │
 │                 │                     │                     │                  │
 │  Select "getUser"                     │                     │                  │
 │────────────────>│                     │                     │                  │
 │                 │                     │                     │                  │
 │                 │ POST /api/actions/from-openapi           │                  │
 │                 │ {specUrl: "...",    │                     │                  │
 │                 │  operationId: "getUser"}                  │                  │
 │                 │────────────────────>│                     │                  │
 │                 │                     │                     │                  │
 │                 │                     │ Build Action from spec                 │
 │                 │                     │  - Create urlTemplate                  │
 │                 │                     │  - Extract parameters                  │
 │                 │                     │  - Set method & headers                │
 │                 │                     │                     │                  │
 │                 │                     │ Action.db.insertRow()                  │
 │                 │                     │────────────────────────────────────────>│
 │                 │                     │                     │                  │
 │                 │                     │                Created Action          │
 │                 │                     │<────────────────────────────────────────│
 │                 │                     │                     │                  │
 │                 │  201 Created        │                     │                  │
 │                 │  {action: {...}}    │                     │                  │
 │                 │<────────────────────│                     │                  │
 │                 │                     │                     │                  │
 │  Show Success   │                     │                     │                  │
 │<────────────────│                     │                     │                  │
 │                 │                     │                     │                  │
```

## Error Handling Architecture

Rmotly implements a hierarchical exception system with consistent error propagation and user-friendly messages.

### Exception Hierarchy

```
AppException (abstract)
├── NetworkException
│   - Connection timeouts
│   - DNS resolution failures
│   - Network unreachable
│
├── ValidationException
│   - Field validation errors
│   - Invalid input data
│   - Form validation
│
├── AuthException
│   - Login failures
│   - Token expiration
│   - Insufficient permissions
│
├── ServerException
│   - HTTP 5xx errors
│   - Server unavailable
│   - Database errors
│
├── ActionExecutionException
│   - Action HTTP failures
│   - Template substitution errors
│   - External API errors
│
└── OfflineException
    - No internet connection
    - Operation requires connectivity
```

### Exception Definition

```dart
/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (originalError != null) buffer.write('\nOriginal error: $originalError');
    return buffer.toString();
  }
}

/// Network-specific exception
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Action execution exception with additional context
class ActionExecutionException extends AppException {
  final String? actionId;
  final int? statusCode;
  final String? responseBody;

  const ActionExecutionException(
    super.message, {
    this.actionId,
    this.statusCode,
    this.responseBody,
    super.code,
    super.originalError,
  });
}
```

### Error Propagation Through Layers

```
┌─────────────────────────────────────────────────────┐
│                 External API                         │
│  - HTTP errors (404, 500, timeout)                  │
│  - Network failures                                 │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ Catch & wrap
┌─────────────────────────────────────────────────────┐
│              Repository Layer                        │
│  - Catch low-level errors                           │
│  - Map to AppException hierarchy                    │
│  - Try cache/offline fallback                       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ Propagate
┌─────────────────────────────────────────────────────┐
│               ViewModel Layer                        │
│  - Catch AppException                               │
│  - Update state with error message                  │
│  - Log for debugging                                │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ Display
┌─────────────────────────────────────────────────────┐
│                 UI Layer                             │
│  - Show error message to user                       │
│  - Display retry button (if retryable)              │
│  - Show offline indicator                           │
└─────────────────────────────────────────────────────┘
```

### Error Handler Service

```dart
class ErrorHandlerService {
  /// Map any error to AppException
  AppException mapToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    // Socket/HTTP errors
    if (error is SocketException || error is TimeoutException) {
      return NetworkException(
        'Network connection failed',
        originalError: error,
      );
    }
    
    // HTTP response errors
    if (error is HttpException) {
      final statusCode = error.statusCode;
      if (statusCode >= 500) {
        return ServerException(
          'Server error occurred',
          statusCode: statusCode,
          originalError: error,
        );
      }
      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          'Authentication failed',
          code: statusCode.toString(),
          originalError: error,
        );
      }
    }
    
    // Generic fallback
    return ServerException(
      'An unexpected error occurred',
      originalError: error,
    );
  }
  
  /// Check if error is retryable
  bool isRetryable(dynamic error) {
    return error is NetworkException || 
           error is OfflineException ||
           (error is ServerException && error.statusCode != null && error.statusCode! >= 500);
  }
  
  /// Get user-friendly message
  String getUserMessage(AppException exception) {
    if (exception is NetworkException) {
      return 'Please check your internet connection and try again.';
    }
    if (exception is OfflineException) {
      return 'You are offline. This operation will be retried when connected.';
    }
    if (exception is ValidationException) {
      return exception.message; // Already user-friendly
    }
    if (exception is AuthException) {
      return 'Please log in again to continue.';
    }
    if (exception is ServerException) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    return exception.message;
  }
}
```

### User-Facing Error Messages

**ViewModel Error Handling:**
```dart
try {
  final actions = await _repository.getActions();
  state = state.copyWith(actions: actions, isLoading: false);
} catch (e) {
  // Map to user-friendly message
  final errorMessage = _errorHandler.getUserMessage(
    e is AppException ? e : _errorHandler.mapToAppException(e)
  );
  
  state = state.copyWith(
    isLoading: false,
    error: errorMessage,
  );
  
  // Log detailed error for debugging
  debugPrint('Failed to load actions: $e');
}
```

**UI Error Display:**
```dart
if (state.error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text(state.error!, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => ref.read(viewModelProvider.notifier).retry(),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

### Logging Strategy

**Server-Side (Serverpod):**
```dart
// In service methods
session.log('Processing event: $eventType from $sourceType', level: LogLevel.info);
session.log('Action executed: ${action.name} -> ${result.success}', level: LogLevel.info);
session.log('Failed to execute action: $error', level: LogLevel.warning);
session.log('Critical error in notification service: $error', level: LogLevel.error);
```

**Client-Side (Flutter):**
```dart
// In ViewModels and Repositories
debugPrint('ActionsViewModel: Failed to load actions: $e');
debugPrint('ControlRepository: Cache hit for controls');
debugPrint('EventRepository: Queued event for offline processing');
```

**Log Levels:**
- `debug` - Detailed information for debugging
- `info` - Normal operation events (action executed, user logged in)
- `warning` - Recoverable errors (retryable failures, missing optional data)
- `error` - Critical errors (unrecoverable failures, security issues)

## Data Persistence

### Database Schema Overview

Rmotly uses PostgreSQL through Serverpod's ORM for data persistence. The schema follows normalized relational design with foreign key constraints.

**Core Tables:**

```
users
├── id (PK)
├── email
├── name
├── created_at
└── updated_at

controls
├── id (PK)
├── user_id (FK -> users.id)
├── name
├── control_type (enum: button, toggle, slider, input, dropdown)
├── action_id (FK -> actions.id, nullable)
├── config (jsonb)
├── position
└── created_at

actions
├── id (PK)
├── user_id (FK -> users.id)
├── name
├── description
├── http_method (enum: GET, POST, PUT, DELETE, PATCH)
├── url_template
├── headers_template (jsonb)
├── body_template (text)
├── openapi_spec_url
├── openapi_operation_id
└── created_at

notification_topics
├── id (PK)
├── user_id (FK -> users.id)
├── name
├── description
├── api_key (unique, indexed)
├── enabled
├── config (jsonb)
└── created_at

events
├── id (PK)
├── user_id (FK -> users.id)
├── source_type (enum: control, webhook, system)
├── source_id
├── event_type
├── payload (jsonb)
├── action_result (jsonb)
└── timestamp

push_subscriptions
├── id (PK)
├── user_id (FK -> users.id)
├── endpoint (unique)
├── p256dh_key
├── auth_key
├── created_at
└── expires_at
```

### Serverpod Model Relationships

Models are defined in YAML and code-generated by Serverpod:

```yaml
# action.yaml
class: Action
table: actions
fields:
  userId: int
  name: String
  description: String?
  httpMethod: String
  urlTemplate: String
  headersTemplate: String?
  bodyTemplate: String?
  openApiSpecUrl: String?
  openApiOperationId: String?
  createdAt: DateTime, default=now

indexes:
  action_user_idx:
    fields: userId
```

**Relationships in Code:**

```dart
class Control {
  int userId;
  String name;
  int? actionId;  // Foreign key to Action
  
  // Lazy-loaded relationship
  Action? get action => actionId != null 
      ? Action.db.findById(session, actionId!) 
      : null;
}
```

**Cascade Deletes:**
- Deleting a user deletes all their controls, actions, topics, events
- Deleting an action nullifies `control.actionId` (nullable FK)
- Deleting a topic does not delete related events (for audit trail)

### Migration Strategy

Serverpod uses automatic migrations based on model changes:

**1. Update Model YAML:**
```yaml
# Add new field
class: Action
fields:
  # ... existing fields
  retryCount: int, default=0  # New field
```

**2. Regenerate Code:**
```bash
serverpod generate
```

**3. Create Migration:**
```bash
serverpod create-migration
```

**4. Apply Migration:**
```bash
serverpod migrate --apply
```

**Migration Best Practices:**
- Always provide default values for new non-nullable fields
- Test migrations on development database first
- Back up production database before migration
- Use `nullable` fields when adding columns to existing tables
- Document breaking changes in migration notes

**Example Migration:**
```sql
-- Generated by Serverpod
ALTER TABLE actions ADD COLUMN retry_count integer DEFAULT 0 NOT NULL;
CREATE INDEX action_retry_idx ON actions(retry_count);
```

### Data Validation

**Server-Side Validation:**

```dart
class EventService {
  void validateEvent({
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
  }) {
    if (sourceType.isEmpty) {
      throw ArgumentError('sourceType cannot be empty');
    }
    if (sourceId.isEmpty) {
      throw ArgumentError('sourceId cannot be empty');
    }
    if (eventType.isEmpty) {
      throw ArgumentError('eventType cannot be empty');
    }
    
    // Validate enum values
    const allowedSourceTypes = ['control', 'webhook', 'system'];
    if (!allowedSourceTypes.contains(sourceType)) {
      throw ArgumentError(
        'sourceType must be one of: ${allowedSourceTypes.join(', ')}',
      );
    }
  }
}
```

**Database Constraints:**
```sql
-- Enum constraints
ALTER TABLE controls ADD CONSTRAINT control_type_check 
  CHECK (control_type IN ('button', 'toggle', 'slider', 'input', 'dropdown'));

-- URL validation
ALTER TABLE actions ADD CONSTRAINT url_template_valid 
  CHECK (url_template ~* '^https?://');

-- Positive integer
ALTER TABLE controls ADD CONSTRAINT position_positive 
  CHECK (position >= 0);

-- Unique constraint
ALTER TABLE notification_topics ADD CONSTRAINT api_key_unique 
  UNIQUE (api_key);
```

**Client-Side Validation:**
```dart
class ActionFormValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }
  
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Invalid URL (must be http or https)';
    }
    return null;
  }
}
```

**Validation Flow:**
```
User Input
    │
    ▼
┌─────────────────────┐
│  Client Validation  │  <- Immediate feedback
│  (Form validators)  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│  Server Validation  │  <- Security boundary
│  (Service methods)  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Database Constraints│  <- Final enforcement
│  (CHECK, UNIQUE)    │
└─────────────────────┘
```
