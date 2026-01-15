# Core Module

This directory contains app-wide constants, enums, utilities, and shared functionality used throughout the Rmotly Flutter app.

## Contents

### Constants

- **`app_constants.dart`** - Application-wide constants including:
  - App information (name, version)
  - Timeouts and retry configuration
  - UI constants (padding, border radius, elevation)
  - Control grid configuration
  - Input limits (max lengths, max counts)
  - Local storage keys
  - Animation durations
  - Default values

- **`api_constants.dart`** - API-specific constants including:
  - Base URLs for different environments
  - API endpoint paths
  - Webhook routes
  - Query parameter names
  - HTTP header names
  - Content types
  - API key configuration
  - Pagination defaults
  - Built-in variable names for template substitution

### Enums

- **`control_type.dart`** - Dashboard control types:
  - `button` - Single tap trigger
  - `toggle` - On/off switch
  - `slider` - Range value selector
  - `input` - Text input with submit
  - `dropdown` - Selection from options
  
  Each type includes:
  - Human-readable labels
  - Descriptions
  - Payload structure documentation

- **`http_method.dart`** - HTTP methods for action execution:
  - `get`, `post`, `put`, `patch`, `delete`
  
  Features:
  - Uppercase string values (`GET`, `POST`, etc.)
  - Case-insensitive `fromString()` parsing

- **`event_type.dart`** - Event types for control interactions:
  - `buttonPress`, `toggleChange`, `sliderChange`, `inputSubmit`, `dropdownSelect`
  
  Features:
  - Human-readable labels
  - API-compatible string values (snake_case)
  - Bidirectional conversion with `fromString()`

- **`notification_priority.dart`** - Push notification priority levels:
  - `low`, `normal`, `high`, `urgent`
  
  Features:
  - Android importance level mapping
  - API-compatible string values
  - Case-insensitive parsing

### Exports

- **`core.dart`** - Convenience export file for importing all core constants and enums

## Usage Examples

### Importing Constants

```dart
import 'package:rmotly_app/core/app_constants.dart';
import 'package:rmotly_app/core/api_constants.dart';

// Use constants
final timeout = AppConstants.defaultTimeout;
final endpoint = ApiConstants.controlsEndpoint;
```

### Using Enums

```dart
import 'package:rmotly_app/core/control_type.dart';
import 'package:rmotly_app/core/http_method.dart';

// Create a control
final control = Control(
  name: 'Light Switch',
  type: ControlType.button,
);

// Display control info
print(control.type.label); // "Button"
print(control.type.description); // "Trigger an action with a single tap"
print(control.type.payloadDescription); // "{ "pressed": true }"

// Parse from string
final method = HttpMethod.fromString('POST'); // HttpMethod.post
final methodValue = method?.value; // "POST"

// Convert event type
final eventType = EventType.buttonPress;
print(eventType.value); // "button_press"
final parsed = EventType.fromString('button_press'); // EventType.buttonPress
```

### Importing Everything

```dart
// Import all core constants and enums
import 'package:rmotly_app/core/core.dart';

// Now you can use any constant or enum
final gridCount = AppConstants.defaultGridCrossAxisCount;
final controlType = ControlType.slider;
final priority = NotificationPriority.high;
```

## Testing

All enums have comprehensive unit tests in the `test/` directory:

- `test/control_type_test.dart`
- `test/http_method_test.dart`
- `test/event_type_test.dart`
- `test/notification_priority_test.dart`

Run tests with:
```bash
flutter test
```

## Design Decisions

1. **Constants as Static Class Members**: Constants are organized in non-instantiable classes (private constructor) rather than top-level constants for better organization and namespace management.

2. **lowerCamelCase for Constants**: Following Effective Dart guidelines, constants use `lowerCamelCase` instead of `SCREAMING_CAPS`.

3. **Enum Extensions**: Each enum provides helper methods (`label`, `value`, `fromString`) for common operations, reducing boilerplate throughout the codebase.

4. **Bidirectional Conversion**: Enums that need to be serialized (EventType, HttpMethod, NotificationPriority) provide `fromString()` methods for parsing API responses.

5. **Documentation**: All enums and their values are thoroughly documented with examples of their usage and payload structures.

## Future Additions

As the app grows, this module may include:

- Custom exceptions (`errors/`)
- Extension methods (`extensions/`)
- Utility classes (`utils/`)
- Theme definitions (`theme/`)
