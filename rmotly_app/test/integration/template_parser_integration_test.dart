import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/core/template_parser.dart';

/// Integration tests verify that multiple components work together correctly.
/// These tests may involve more complex setups and interactions between services.
void main() {
  group('Template Parser Integration', () {
    late TemplateParser parser;

    setUp(() {
      parser = TemplateParser();
    });

    test('handles real-world webhook payload parsing', () {
      // Arrange - Simulating a webhook from an external service
      const template = '''
{
  "entity_id": "{{device.id}}",
  "state": "{{device.state}}",
  "attributes": {
    "temperature": {{sensor.temperature}},
    "humidity": {{sensor.humidity}},
    "location": "{{device.location.name}}"
  }
}''';

      final variables = {
        'device': {
          'id': 'sensor_01',
          'state': 'online',
          'location': {'name': 'Living Room'},
        },
        'sensor': {
          'temperature': 22.5,
          'humidity': 65,
        },
      };

      // Act
      final result = parser.parse(template, variables);

      // Assert
      expect(result, contains('"entity_id": "sensor_01"'));
      expect(result, contains('"state": "online"'));
      expect(result, contains('"temperature": 22.5'));
      expect(result, contains('"humidity": 65'));
      expect(result, contains('"location": "Living Room"'));
    });

    test('handles notification template with user data', () {
      // Arrange - Simulating notification template
      const titleTemplate = 'Hello {{user.name}}!';
      const bodyTemplate =
          'You have {{notifications.unread}} unread messages in {{folder.name}}';

      final variables = {
        'user': {'name': 'Alice', 'id': 123},
        'notifications': {'unread': 5, 'total': 42},
        'folder': {'name': 'Inbox', 'path': '/mail/inbox'},
      };

      // Act
      final title = parser.parse(titleTemplate, variables);
      final body = parser.parse(bodyTemplate, variables);

      // Assert
      expect(title, 'Hello Alice!');
      expect(body, 'You have 5 unread messages in Inbox');
    });

    test('handles API endpoint construction', () {
      // Arrange - Building REST API endpoint
      const template = 'https://api.example.com/v{{version}}/{{resource}}/{{id}}/{{action}}';

      final variables = {
        'version': 2,
        'resource': 'users',
        'id': 'user-123',
        'action': 'profile',
      };

      // Act
      final url = parser.parse(template, variables);

      // Assert
      expect(url, 'https://api.example.com/v2/users/user-123/profile');
    });

    test('handles complex webhook with arrays and nested data', () {
      // Arrange - Complex event payload
      const template = '''
Order #{{order.id}} from {{customer.name}}:
- Items: {{items.length}}
- First item: {{items.0.name}}
- Total: \${{order.total}}
- Status: {{order.status}}''';

      final variables = {
        'order': {
          'id': 'ORD-12345',
          'total': 99.99,
          'status': 'processing',
        },
        'customer': {
          'name': 'John Doe',
          'email': 'john@example.com',
        },
        'items': [
          {'name': 'Widget A', 'quantity': 2, 'price': 29.99},
          {'name': 'Widget B', 'quantity': 1, 'price': 39.99},
        ],
      };

      // Act
      final result = parser.parse(template, variables);

      // Assert
      expect(result, contains('Order #ORD-12345'));
      expect(result, contains('from John Doe'));
      expect(result, contains('Items: 2'));
      expect(result, contains('First item: Widget A'));
      expect(result, contains('Total: \$99.99'));
      expect(result, contains('Status: processing'));
    });

    test('handles authentication header construction', () {
      // Arrange - Building auth header
      const template = 'Bearer {{auth.token}}';
      final variables = {
        'auth': {
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature',
          'expires': 1234567890,
        },
      };

      // Act
      final header = parser.parse(template, variables);

      // Assert
      expect(header, startsWith('Bearer eyJ'));
      expect(header.split('.').length, 3); // JWT format
    });
  });
}
