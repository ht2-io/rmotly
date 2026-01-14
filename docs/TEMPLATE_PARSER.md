# TemplateParser Utility

## Overview

The `TemplateParser` utility class provides template string parsing with variable substitution using the `{{variable}}` syntax. It supports simple variables, nested object access, and array operations.

## Installation

The TemplateParser is part of the core utilities:

```dart
import 'package:remotly_app/core/utils.dart';
```

## Basic Usage

```dart
final parser = TemplateParser();
final result = parser.parse(
  'Hello, {{name}}!',
  {'name': 'World'},
);
// Output: "Hello, World!"
```

## Features

### 1. Simple Variable Substitution

Replace placeholders with values from a map:

```dart
parser.parse(
  '{{greeting}}, {{name}}!',
  {'greeting': 'Hello', 'name': 'Alice'},
);
// Output: "Hello, Alice!"
```

### 2. Nested Object Access

Access nested properties using dot notation:

```dart
parser.parse(
  'User: {{user.name}}, Email: {{user.email}}',
  {
    'user': {
      'name': 'Bob Smith',
      'email': 'bob@example.com',
    },
  },
);
// Output: "User: Bob Smith, Email: bob@example.com"
```

### 3. Array Access by Index

Access array elements using numeric indices:

```dart
parser.parse(
  'First: {{items.0}}, Second: {{items.1}}',
  {
    'items': ['apple', 'banana', 'cherry'],
  },
);
// Output: "First: apple, Second: banana"
```

### 4. Array Length Property

Get the length of arrays:

```dart
parser.parse(
  'You have {{items.length}} items',
  {
    'items': ['item1', 'item2', 'item3'],
  },
);
// Output: "You have 3 items"
```

### 5. Complex Nested Access

Combine nested objects and arrays:

```dart
parser.parse(
  'First user: {{users.0.name}}',
  {
    'users': [
      {'name': 'Alice', 'age': 30},
      {'name': 'Bob', 'age': 25},
    ],
  },
);
// Output: "First user: Alice"
```

## Common Use Cases

### HTTP Action URL Templates

```dart
parser.parse(
  'https://api.example.com/users/{{userId}}/posts/{{postId}}',
  {'userId': '123', 'postId': '456'},
);
// Output: "https://api.example.com/users/123/posts/456"
```

### JSON Body Templates

```dart
parser.parse(
  '{"entity_id": "{{entityId}}", "state": "{{state}}"}',
  {'entityId': 'light.living_room', 'state': 'on'},
);
// Output: '{"entity_id": "light.living_room", "state": "on"}'
```

### Authorization Headers

```dart
parser.parse(
  'Bearer {{token}}',
  {'token': 'your_auth_token_here'},
);
// Output: "Bearer your_auth_token_here"
```

### Notification Templates

```dart
parser.parse(
  'Order #{{orderId}} - {{status}}',
  {'orderId': '12345', 'status': 'Delivered'},
);
// Output: "Order #12345 - Delivered"
```

### Notification Body with Nested Data

```dart
parser.parse(
  'New order from {{customer.name}}: {{items.length}} items',
  {
    'customer': {'name': 'John Doe'},
    'items': ['item1', 'item2', 'item3'],
  },
);
// Output: "New order from John Doe: 3 items"
```

## Edge Cases

### Missing Variables

Placeholders for missing variables are left unchanged:

```dart
parser.parse(
  'Hello {{name}}, your code is {{code}}',
  {'name': 'Alice'},
);
// Output: "Hello Alice, your code is {{code}}"
```

### Null Values

Explicitly null values are converted to the string "null":

```dart
parser.parse(
  'Value: {{value}}',
  {'value': null},
);
// Output: "Value: null"
```

### Malformed Placeholders

Placeholders with spaces are ignored:

```dart
parser.parse(
  'Value: {{ name }}',
  {'name': 'Alice'},
);
// Output: "Value: {{ name }}"
```

### Data Type Conversion

All values are automatically converted to strings:

```dart
parser.parse(
  'Age: {{age}}, Active: {{isActive}}, Price: {{price}}',
  {'age': 30, 'isActive': true, 'price': 19.99},
);
// Output: "Age: 30, Active: true, Price: 19.99"
```

## Variable Name Rules

Variable names can contain:
- Letters (a-z, A-Z)
- Numbers (0-9)
- Underscores (_)
- Dots (.) for nested access

Examples of valid variable names:
- `{{name}}`
- `{{user_id}}`
- `{{user123}}`
- `{{api_token}}`
- `{{user.name}}`
- `{{items.0}}`
- `{{users.0.orders.0.id}}`

## API Reference

### TemplateParser Class

#### `parse(String template, Map<String, dynamic> variables) → String`

Parses a template string by replacing placeholders with values from the variables map.

**Parameters:**
- `template` - The template string containing `{{variable}}` placeholders
- `variables` - A map of variable names to their values

**Returns:**
The parsed string with all found variables replaced. Placeholders for missing variables are left unchanged.

**Example:**
```dart
final parser = TemplateParser();
final result = parser.parse(
  'Hello, {{name}}!',
  {'name': 'World'},
);
```

## Performance Considerations

- The parser uses a compiled regular expression for efficient placeholder matching
- Template parsing is done in a single pass
- Suitable for real-time use in HTTP requests and notifications
- No reflection is used, making it safe and predictable

## Testing

The TemplateParser includes comprehensive unit tests covering:
- Basic variable replacement
- Missing variables handling
- Nested object access
- Array access and operations
- Data type handling
- Special characters and edge cases
- Real-world use cases
- Performance with large templates

Run tests with:
```bash
cd remotly_app
flutter test test/template_parser_test.dart
```

## Related Documentation

- [TASKS.md](../../TASKS.md#313-create-utility-classes) - Task 3.1.3
- [TESTING.md](../../docs/TESTING.md) - Testing guide
- [API.md](../../docs/API.md) - API documentation showing template usage
