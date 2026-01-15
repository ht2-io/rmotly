# Rmotly App Documentation

## Overview

The Rmotly Flutter app provides a mobile interface for:
- Creating and managing dashboard controls
- Configuring actions based on OpenAPI specifications
- Managing notification topics
- Receiving push notifications

## Features

### Dashboard

The main screen displays user-configured controls in a customizable grid/list layout.

#### Control Types

| Type | Description | Event Payload |
|------|-------------|---------------|
| **Button** | Single tap trigger | `{ "pressed": true }` |
| **Toggle** | On/off switch | `{ "state": true/false }` |
| **Slider** | Range value selector | `{ "value": 0.0-1.0 }` |
| **Input** | Text input with submit | `{ "text": "user input" }` |
| **Dropdown** | Selection from options | `{ "selected": "option_id" }` |

#### Control Configuration

```dart
// Button control
Control(
  name: 'Toggle Light',
  type: ControlType.button,
  actionId: 'action_toggle_light',
  config: {
    'icon': 'lightbulb',
    'color': '#FFD700',
    'confirmationRequired': false,
  },
)

// Slider control
Control(
  name: 'Brightness',
  type: ControlType.slider,
  actionId: 'action_set_brightness',
  config: {
    'min': 0,
    'max': 100,
    'step': 5,
    'unit': '%',
    'showValue': true,
  },
)

// Toggle control
Control(
  name: 'Alarm',
  type: ControlType.toggle,
  actionId: 'action_toggle_alarm',
  config: {
    'onLabel': 'Armed',
    'offLabel': 'Disarmed',
    'onColor': '#FF0000',
    'offColor': '#00FF00',
  },
)
```

### Actions

Actions define HTTP requests that are executed when controls are triggered.

#### Manual Action Creation

Users can manually configure:
- HTTP method (GET, POST, PUT, DELETE, PATCH)
- URL (with variable placeholders)
- Headers
- Request body (JSON)
- Parameter definitions

#### OpenAPI Import

Users can import actions from OpenAPI specifications:

1. Enter OpenAPI spec URL
2. App parses and displays available operations
3. User selects an operation
4. App pre-fills action configuration
5. User customizes parameters and defaults

#### Variable Substitution

Actions support `{{variable}}` placeholders:

```json
{
  "url": "https://api.example.com/devices/{{deviceId}}/state",
  "headers": {
    "Authorization": "Bearer {{apiToken}}"
  },
  "body": {
    "state": "{{controlValue}}"
  }
}
```

**Built-in variables:**
- `{{controlValue}}` - Value from control (toggle state, slider value, etc.)
- `{{controlId}}` - ID of the triggering control
- `{{timestamp}}` - ISO timestamp of the event
- `{{userId}}` - Current user ID

### Notification Topics

Topics are channels for receiving notifications from external sources.

#### Topic Configuration

```dart
NotificationTopic(
  name: 'Server Alerts',
  description: 'Critical server notifications',
  config: NotificationConfig(
    titleTemplate: '{{title}}',
    bodyTemplate: '{{message}}',
    priority: NotificationPriority.high,
    channelId: 'alerts',
    soundName: 'alert',
  ),
)
```

#### Webhook URL

Each topic generates a unique webhook URL:
```
https://api.rmotly.app/api/notify/{topicId}
```

And an API key for authentication:
```
rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx
```

### Settings

- **Account**: Login, logout, profile management
- **Notifications**: Enable/disable, quiet hours
- **Appearance**: Theme, control size, layout
- **Security**: API key management, action credentials
- **Data**: Export/import configuration

## App Architecture

### Project Structure

```
rmotly_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── api_constants.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   └── string_extensions.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   └── template_parser.dart
│   │   ├── errors/
│   │   │   └── app_exceptions.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── app_colors.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository_impl.dart
│   │   │   │   └── auth_local_storage.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── user.dart
│   │   │   └── presentation/
│   │   │       ├── login_view.dart
│   │   │       ├── login_viewmodel.dart
│   │   │       └── widgets/
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   ├── control_repository_impl.dart
│   │   │   │   └── control_local_storage.dart
│   │   │   ├── domain/
│   │   │   │   ├── control_repository.dart
│   │   │   │   ├── control.dart
│   │   │   │   └── control_type.dart
│   │   │   └── presentation/
│   │   │       ├── dashboard_view.dart
│   │   │       ├── dashboard_viewmodel.dart
│   │   │       ├── control_editor_view.dart
│   │   │       └── widgets/
│   │   │           ├── button_control_widget.dart
│   │   │           ├── toggle_control_widget.dart
│   │   │           ├── slider_control_widget.dart
│   │   │           └── control_card.dart
│   │   ├── actions/
│   │   │   ├── data/
│   │   │   │   ├── action_repository_impl.dart
│   │   │   │   └── openapi_service.dart
│   │   │   ├── domain/
│   │   │   │   ├── action_repository.dart
│   │   │   │   ├── action.dart
│   │   │   │   └── openapi_operation.dart
│   │   │   └── presentation/
│   │   │       ├── actions_view.dart
│   │   │       ├── actions_viewmodel.dart
│   │   │       ├── action_editor_view.dart
│   │   │       ├── openapi_import_view.dart
│   │   │       └── widgets/
│   │   ├── notifications/
│   │   │   ├── data/
│   │   │   │   ├── topic_repository_impl.dart
│   │   │   │   └── fcm_service.dart
│   │   │   ├── domain/
│   │   │   │   ├── topic_repository.dart
│   │   │   │   ├── notification_topic.dart
│   │   │   │   └── notification_config.dart
│   │   │   └── presentation/
│   │   │       ├── topics_view.dart
│   │   │       ├── topics_viewmodel.dart
│   │   │       ├── topic_editor_view.dart
│   │   │       └── widgets/
│   │   └── settings/
│   │       └── ...
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── empty_state_widget.dart
│   │   └── services/
│   │       ├── api_client.dart
│   │       └── local_storage_service.dart
│   └── providers/
│       └── providers.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
└── README.md
```

### State Management

Using Riverpod for dependency injection and state management:

```dart
// Providers
final apiClientProvider = Provider<Client>((ref) {
  return Client('https://api.rmotly.app/');
});

final controlRepositoryProvider = Provider<ControlRepository>((ref) {
  return ControlRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
  );
});

final dashboardViewModelProvider = StateNotifierProvider<
    DashboardViewModel, AsyncValue<DashboardState>>((ref) {
  return DashboardViewModel(ref.watch(controlRepositoryProvider));
});
```

### Navigation

Using go_router for declarative navigation:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/actions',
      builder: (context, state) => const ActionsView(),
    ),
    GoRoute(
      path: '/actions/new',
      builder: (context, state) => const ActionEditorView(),
    ),
    GoRoute(
      path: '/topics',
      builder: (context, state) => const TopicsView(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
);
```

### Push Notifications

Using Firebase Cloud Messaging:

```dart
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();

    // Get token
    final token = await _messaging.getToken();
    await _registerToken(token);

    // Handle token refresh
    _messaging.onTokenRefresh.listen(_registerToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    _showLocalNotification(message);
  }
}
```

## Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Network
  serverpod_flutter: ^2.0.0
  dio: ^5.4.0

  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0

  # Notifications
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0

  # OpenAPI
  openapi_parser: ^1.0.0  # or swagger_parser

  # UI
  flutter_slidable: ^3.0.0
  reorderable_grid_view: ^2.2.0

  # Utilities
  uuid: ^4.2.0
  intl: ^0.18.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

## Screens

### Dashboard Screen
- Grid/list of controls
- Drag-and-drop reordering
- Quick actions (edit, delete)
- Pull-to-refresh
- FAB to add new control

### Control Editor Screen
- Control type selector
- Name and icon configuration
- Action selector/creator
- Type-specific settings
- Preview

### Actions Screen
- List of configured actions
- Test action button
- OpenAPI import button

### Action Editor Screen
- HTTP method selector
- URL input with variable hints
- Headers editor
- Body editor (JSON)
- Parameter definitions
- Test panel

### OpenAPI Import Screen
- URL input for spec
- Operation browser
- Parameter mapping
- Preview and import

### Topics Screen
- List of notification topics
- Webhook URL copy button
- API key management
- Enable/disable toggle

### Topic Editor Screen
- Name and description
- Notification template configuration
- Priority and sound settings
- Test notification

### Settings Screen
- Account management
- Notification preferences
- Theme selection
- Data export/import
- About
