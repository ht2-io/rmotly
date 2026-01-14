# Remotly - Task Definitions

This document defines all tasks required to build the Remotly system. Tasks are organized by phase and component.

## Project Status

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Project Setup | Complete | 100% |
| Phase 2: API Core | Not Started | 0% |
| Phase 3: App Core | Not Started | 0% |
| Phase 4: Features | Not Started | 0% |
| Phase 5: Integration | Not Started | 0% |
| Phase 6: Polish | Not Started | 0% |

---

## Phase 1: Project Setup

### 1.1 Serverpod Project Initialization

- [x] **1.1.1** Install Serverpod CLI
  ```bash
  dart pub global activate serverpod_cli
  ```

- [x] **1.1.2** Create Serverpod project
  ```bash
  serverpod create remotly
  ```

- [x] **1.1.3** Configure PostgreSQL database
  - Create database and user
  - Update `config/development.yaml`
  - Update `config/production.yaml`

- [x] **1.1.4** Configure Redis
  - Set up Redis instance
  - Update configuration files

- [x] **1.1.5** Verify Serverpod setup
  - Run `serverpod generate`
  - Start server and confirm connection

### 1.2 Flutter App Initialization

- [x] **1.2.1** Create Flutter project
  ```bash
  flutter create remotly_app
  ```

- [x] **1.2.2** Set up project structure (Clean Architecture)
  - Create `lib/core/` directories
  - Create `lib/features/` directories
  - Create `lib/shared/` directories

- [x] **1.2.3** Add core dependencies to `pubspec.yaml`
  - flutter_riverpod
  - go_router
  - serverpod_flutter
  - dio
  - hive_flutter

- [x] **1.2.4** Configure Riverpod
  - Set up ProviderScope in main.dart
  - Create base providers file

- [x] **1.2.5** Configure go_router
  - Define route structure
  - Set up navigation service

### 1.3 Firebase Setup (Deferred)

- [ ] **1.3.1** Create Firebase project
  - Go to Firebase Console
  - Create new project "Remotly"

- [ ] **1.3.2** Configure Android app in Firebase
  - Register Android app
  - Download `google-services.json`
  - Add to `android/app/`

- [ ] **1.3.3** Enable Cloud Messaging
  - Enable FCM in Firebase Console
  - Note server key for API

- [ ] **1.3.4** Add Firebase dependencies to Flutter
  - firebase_core
  - firebase_messaging
  - flutter_local_notifications

- [ ] **1.3.5** Initialize Firebase in app
  - Add initialization code to main.dart
  - Configure notification channels (Android)

> **Note:** Firebase setup requires manual configuration in Firebase Console. This will be done when implementing notifications in Phase 4.

---

## Phase 2: API Core

### 2.1 Data Models

- [ ] **2.1.1** Create User model
  ```yaml
  # lib/src/models/user.yaml
  class: User
  table: users
  fields:
    email: String
    displayName: String?
    fcmToken: String?
    createdAt: DateTime
    updatedAt: DateTime
  ```

- [ ] **2.1.2** Create Control model
  ```yaml
  # lib/src/models/control.yaml
  class: Control
  table: controls
  fields:
    userId: int, relation(parent=users)
    name: String
    controlType: String
    actionId: int?, relation(parent=actions)
    config: String  # JSON
    position: int
    createdAt: DateTime
    updatedAt: DateTime
  ```

- [ ] **2.1.3** Create Action model
  ```yaml
  # lib/src/models/action.yaml
  class: Action
  table: actions
  fields:
    userId: int, relation(parent=users)
    name: String
    description: String?
    httpMethod: String
    urlTemplate: String
    headersTemplate: String?  # JSON
    bodyTemplate: String?
    openApiSpecUrl: String?
    openApiOperationId: String?
    parameters: String?  # JSON
    createdAt: DateTime
    updatedAt: DateTime
  ```

- [ ] **2.1.4** Create NotificationTopic model
  ```yaml
  # lib/src/models/notification_topic.yaml
  class: NotificationTopic
  table: notification_topics
  fields:
    userId: int, relation(parent=users)
    name: String
    description: String?
    apiKey: String
    enabled: bool
    config: String  # JSON
    createdAt: DateTime
    updatedAt: DateTime
  ```

- [ ] **2.1.5** Create Event model
  ```yaml
  # lib/src/models/event.yaml
  class: Event
  table: events
  fields:
    userId: int, relation(parent=users)
    sourceType: String
    sourceId: String
    eventType: String
    payload: String?  # JSON
    actionResult: String?  # JSON
    timestamp: DateTime
  indexes:
    event_user_idx:
      fields: userId
  ```

- [ ] **2.1.6** Run code generation
  ```bash
  serverpod generate
  ```

### 2.2 Core Services

- [ ] **2.2.1** Create EventService
  - Event validation
  - Event routing to actions
  - Event logging

- [ ] **2.2.2** Create ActionExecutorService
  - Template variable substitution
  - HTTP request execution
  - Response handling
  - Error handling and retries

- [ ] **2.2.3** Create NotificationService
  - FCM integration
  - Notification payload building
  - Topic-based delivery

- [ ] **2.2.4** Create OpenApiParserService
  - Fetch and parse OpenAPI specs
  - Extract operations
  - Generate action templates

- [ ] **2.2.5** Create ApiKeyService
  - Generate secure API keys
  - Validate API keys
  - Key rotation

### 2.3 Endpoints

- [ ] **2.3.1** Create EventEndpoint
  - `sendEvent(controlId, eventType, payload)`
  - `listEvents(limit, offset)`
  - `getEvent(eventId)`

- [ ] **2.3.2** Create NotificationEndpoint
  - `sendNotification(topicId, payload)` - external webhook
  - `createTopic(name, config)`
  - `listTopics()`
  - `getTopic(topicId)`
  - `updateTopic(topicId, updates)`
  - `deleteTopic(topicId)`
  - `regenerateApiKey(topicId)`

- [ ] **2.3.3** Create ActionEndpoint
  - `createAction(action)`
  - `listActions()`
  - `getAction(actionId)`
  - `updateAction(actionId, updates)`
  - `deleteAction(actionId)`
  - `testAction(actionId, parameters)`
  - `createFromOpenApi(specUrl, operationId)`

- [ ] **2.3.4** Create ControlEndpoint
  - `createControl(control)`
  - `listControls()`
  - `getControl(controlId)`
  - `updateControl(controlId, updates)`
  - `deleteControl(controlId)`
  - `reorderControls(order)`

- [ ] **2.3.5** Create OpenApiEndpoint
  - `parseSpec(url)`
  - `listOperations(specUrl)`

### 2.4 Webhook Route

- [ ] **2.4.1** Create webhook route handler
  - Route: `POST /api/notify/{topicId}`
  - API key authentication
  - Payload normalization
  - Rate limiting

- [ ] **2.4.2** Implement payload format detection
  - Firebase format
  - Pushover format
  - Ntfy format
  - Gotify format
  - Generic extraction

### 2.5 Authentication

- [ ] **2.5.1** Set up Serverpod authentication module
  - Email/password authentication
  - Session management

- [ ] **2.5.2** Implement FCM token registration
  - Token storage per user
  - Token refresh handling

---

## Phase 3: App Core

### 3.1 Core Setup

- [ ] **3.1.1** Create app constants
  - API URLs
  - Default values
  - Control types enum

- [ ] **3.1.2** Create custom exceptions
  - NetworkException
  - ValidationException
  - AuthException
  - ActionExecutionException

- [ ] **3.1.3** Create utility classes
  - TemplateParser (for {{variable}} substitution)
  - Validators
  - DateFormatters

- [ ] **3.1.4** Create base widgets
  - LoadingWidget
  - ErrorWidget
  - EmptyStateWidget
  - ConfirmationDialog

### 3.2 Theme and Styling

- [ ] **3.2.1** Define color palette
  - Primary, secondary, accent colors
  - Light theme colors
  - Dark theme colors

- [ ] **3.2.2** Create ThemeData
  - Light theme
  - Dark theme

- [ ] **3.2.3** Create reusable text styles

- [ ] **3.2.4** Create reusable button styles

### 3.3 API Client Setup

- [ ] **3.3.1** Configure Serverpod client
  - Initialize with base URL
  - Set up connectivity monitor

- [ ] **3.3.2** Create API client provider

- [ ] **3.3.3** Create repository providers

### 3.4 Local Storage

- [ ] **3.4.1** Set up Hive
  - Initialize in main.dart
  - Register adapters

- [ ] **3.4.2** Create local storage service
  - Cache controls
  - Cache actions
  - Cache topics
  - Store user preferences

---

## Phase 4: Features

### 4.1 Authentication Feature

- [ ] **4.1.1** Create auth repository
  - signIn(email, password)
  - signUp(email, password)
  - signOut()
  - getCurrentUser()

- [ ] **4.1.2** Create auth view model
  - Login state management
  - Error handling

- [ ] **4.1.3** Create login view
  - Email/password form
  - Validation
  - Error display

- [ ] **4.1.4** Create registration view
  - Registration form
  - Email verification (optional)

- [ ] **4.1.5** Implement auth guard
  - Redirect to login if not authenticated
  - Persist session

### 4.2 Dashboard Feature

- [ ] **4.2.1** Create control entity
  - Control class
  - ControlType enum
  - Control configuration classes

- [ ] **4.2.2** Create control repository
  - CRUD operations
  - Sync with API
  - Local caching

- [ ] **4.2.3** Create dashboard view model
  - Load controls
  - Handle control interactions
  - Reorder controls

- [ ] **4.2.4** Create dashboard view
  - Grid/list layout
  - Pull-to-refresh
  - FAB for adding controls

- [ ] **4.2.5** Create control widgets
  - ButtonControlWidget
  - ToggleControlWidget
  - SliderControlWidget
  - InputControlWidget
  - DropdownControlWidget

- [ ] **4.2.6** Create control editor view
  - Type selector
  - Configuration form
  - Action selector
  - Preview

- [ ] **4.2.7** Implement drag-and-drop reordering

### 4.3 Actions Feature

- [ ] **4.3.1** Create action entity
  - Action class
  - ActionParameter class
  - HttpMethod enum

- [ ] **4.3.2** Create action repository
  - CRUD operations
  - Test action execution

- [ ] **4.3.3** Create actions view model
  - Load actions
  - Test actions

- [ ] **4.3.4** Create actions list view
  - List of actions
  - Quick test button
  - OpenAPI import button

- [ ] **4.3.5** Create action editor view
  - HTTP method selector
  - URL input with variable suggestions
  - Headers editor
  - Body editor (JSON)
  - Parameters definition

- [ ] **4.3.6** Create action test panel
  - Parameter input
  - Execute test
  - Show response

### 4.4 OpenAPI Integration Feature

- [ ] **4.4.1** Create OpenAPI parser service
  - Fetch spec from URL
  - Parse operations
  - Extract parameters

- [ ] **4.4.2** Create OpenAPI import view
  - URL input
  - Spec preview
  - Operation browser

- [ ] **4.4.3** Create operation selector
  - List available operations
  - Show operation details
  - Select and configure

- [ ] **4.4.4** Create parameter mapper
  - Map OpenAPI params to action params
  - Set default values
  - Configure variable bindings

### 4.5 Notifications Feature

- [ ] **4.5.1** Create notification topic entity
  - NotificationTopic class
  - NotificationConfig class

- [ ] **4.5.2** Create topic repository
  - CRUD operations
  - API key management

- [ ] **4.5.3** Create FCM service
  - Initialize FCM
  - Handle token refresh
  - Process incoming notifications
  - Show local notifications

- [ ] **4.5.4** Create topics view model
  - Load topics
  - Enable/disable topics

- [ ] **4.5.5** Create topics list view
  - List of topics
  - Webhook URL copy
  - API key reveal/copy
  - Enable/disable toggle

- [ ] **4.5.6** Create topic editor view
  - Name and description
  - Notification template configuration
  - Priority and sound settings

- [ ] **4.5.7** Create test notification feature
  - Send test notification from API
  - Verify delivery

### 4.6 Settings Feature

- [ ] **4.6.1** Create settings view
  - Account section
  - Notifications section
  - Appearance section
  - Data section
  - About section

- [ ] **4.6.2** Implement theme switching
  - Light/dark/system modes
  - Persist preference

- [ ] **4.6.3** Implement notification preferences
  - Enable/disable notifications
  - Quiet hours

- [ ] **4.6.4** Implement data export/import
  - Export configuration to JSON
  - Import configuration from JSON

---

## Phase 5: Integration

### 5.1 Event Flow Integration

- [ ] **5.1.1** Connect control interactions to events
  - Button press → event
  - Toggle change → event with state
  - Slider change → event with value

- [ ] **5.1.2** Implement event → action execution
  - Event received by API
  - Action lookup
  - Parameter substitution
  - HTTP execution
  - Result storage

- [ ] **5.1.3** Implement action result feedback
  - Show success/failure in app
  - Store result in event

### 5.2 Notification Flow Integration

- [ ] **5.2.1** Implement external webhook → notification
  - Receive webhook
  - Validate API key
  - Parse payload
  - Send FCM notification

- [ ] **5.2.2** Implement notification display
  - Foreground notification handling
  - Background notification handling
  - Notification tap handling

### 5.3 End-to-End Testing

- [ ] **5.3.1** Test control → action flow
  - Create action
  - Create control linked to action
  - Trigger control
  - Verify action executed

- [ ] **5.3.2** Test webhook → notification flow
  - Create topic
  - Send webhook request
  - Verify notification received

- [ ] **5.3.3** Test OpenAPI import flow
  - Provide OpenAPI spec URL
  - Import operation
  - Test generated action

---

## Phase 6: Polish

### 6.1 Error Handling

- [ ] **6.1.1** Implement comprehensive error handling
  - Network errors
  - Validation errors
  - Server errors
  - Action execution errors

- [ ] **6.1.2** Create user-friendly error messages

- [ ] **6.1.3** Implement offline mode
  - Cache data locally
  - Queue events when offline
  - Sync when online

### 6.2 Performance

- [ ] **6.2.1** Optimize API calls
  - Batch requests where possible
  - Implement caching

- [ ] **6.2.2** Optimize UI rendering
  - Use const constructors
  - Implement list virtualization

### 6.3 Security

- [ ] **6.3.1** Implement secure storage for credentials
  - Encrypt action credentials
  - Secure API key storage

- [ ] **6.3.2** Implement rate limiting on API
  - Per-user limits
  - Per-topic limits

- [ ] **6.3.3** Security audit
  - Review authentication flow
  - Review data validation
  - Review API security

### 6.4 Documentation

- [ ] **6.4.1** Write API documentation
  - Endpoint documentation
  - Authentication guide
  - Webhook integration guide

- [ ] **6.4.2** Write user documentation
  - Getting started guide
  - Feature documentation

- [ ] **6.4.3** Write developer documentation
  - Architecture overview
  - Contributing guide

### 6.5 Testing

- [ ] **6.5.1** Write unit tests
  - Repository tests
  - Service tests
  - ViewModel tests

- [ ] **6.5.2** Write widget tests
  - Control widget tests
  - Form tests
  - Navigation tests

- [ ] **6.5.3** Write integration tests
  - Full flow tests
  - API integration tests

### 6.6 Deployment

- [ ] **6.6.1** Set up production server
  - Configure Serverpod for production
  - Set up PostgreSQL
  - Set up Redis

- [ ] **6.6.2** Configure CI/CD
  - Automated testing
  - Automated deployment

- [ ] **6.6.3** Prepare app store assets
  - Screenshots
  - Description
  - Privacy policy

- [ ] **6.6.4** Submit to Google Play Store
  - Create developer account
  - Submit for review

---

## Quick Reference: Key Commands

### Serverpod Commands

```bash
# Generate code from models
serverpod generate

# Start development server
cd remotly_server && dart bin/main.dart

# Run database migrations
serverpod create-migration
serverpod apply-migrations
```

### Flutter Commands

```bash
# Get dependencies
flutter pub get

# Generate code (Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Build APK
flutter build apk
```

### Git Workflow

```bash
# Feature branch
git checkout -b feat/feature-name

# Commit
git commit -m "feat(scope): description"

# Push and PR
git push -u origin feat/feature-name
```

---

## Notes

- All model definitions use YAML for Serverpod code generation
- JSON fields are stored as strings and serialized/deserialized in code
- FCM requires real Android device for testing (not emulator)
- OpenAPI parsing should support both OpenAPI 3.0 and Swagger 2.0
