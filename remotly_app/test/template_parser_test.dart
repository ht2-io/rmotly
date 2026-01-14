import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/template_parser.dart';

void main() {
  group('TemplateParser', () {
    late TemplateParser parser;

    setUp(() {
      parser = TemplateParser();
    });

    group('Basic Variable Replacement', () {
      test('replaces single variable', () {
        // Arrange
        const template = 'Hello, {{name}}!';
        final variables = {'name': 'World'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello, World!');
      });

      test('replaces multiple variables', () {
        // Arrange
        const template = '{{greeting}}, {{name}}!';
        final variables = {
          'greeting': 'Hello',
          'name': 'World',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello, World!');
      });

      test('replaces same variable multiple times', () {
        // Arrange
        const template = '{{name}} loves {{name}}';
        final variables = {'name': 'Bob'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Bob loves Bob');
      });

      test('handles empty template', () {
        // Arrange
        const template = '';
        final variables = {'name': 'World'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, '');
      });

      test('handles template with no variables', () {
        // Arrange
        const template = 'No variables here';
        final variables = {'name': 'World'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'No variables here');
      });

      test('handles empty variables map', () {
        // Arrange
        const template = 'Hello, World!';
        final variables = <String, dynamic>{};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello, World!');
      });
    });

    group('Missing Variables', () {
      test('leaves missing variable placeholder unchanged', () {
        // Arrange
        const template = 'Value: {{missing}}';
        final variables = <String, dynamic>{};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Value: {{missing}}');
      });

      test('replaces existing and leaves missing variables', () {
        // Arrange
        const template = 'Hello {{name}}, your age is {{age}}';
        final variables = {'name': 'Alice'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello Alice, your age is {{age}}');
      });
    });

    group('Nested Object Access', () {
      test('accesses nested property with dot notation', () {
        // Arrange
        const template = 'User: {{user.name}}';
        final variables = {
          'user': {'name': 'Alice', 'age': 30},
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'User: Alice');
      });

      test('accesses deeply nested properties', () {
        // Arrange
        const template = 'City: {{address.city.name}}';
        final variables = {
          'address': {
            'city': {'name': 'New York', 'zip': '10001'},
          },
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'City: New York');
      });

      test('handles missing nested property', () {
        // Arrange
        const template = 'Email: {{user.email}}';
        final variables = {
          'user': {'name': 'Alice'},
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Email: {{user.email}}');
      });

      test('handles null intermediate value', () {
        // Arrange
        const template = 'City: {{address.city}}';
        final variables = {
          'address': null,
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'City: {{address.city}}');
      });
    });

    group('Array Access', () {
      test('accesses array element by index', () {
        // Arrange
        const template = 'First item: {{items.0}}';
        final variables = {
          'items': ['apple', 'banana', 'cherry'],
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'First item: apple');
      });

      test('accesses nested array element', () {
        // Arrange
        const template = 'Name: {{users.0.name}}';
        final variables = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
          ],
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Name: Alice');
      });

      test('handles out of bounds array access', () {
        // Arrange
        const template = 'Item: {{items.5}}';
        final variables = {
          'items': ['apple', 'banana'],
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Item: {{items.5}}');
      });

      test('handles array length property', () {
        // Arrange
        const template = 'Count: {{items.length}}';
        final variables = {
          'items': ['apple', 'banana', 'cherry'],
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Count: 3');
      });
    });

    group('Data Type Handling', () {
      test('converts number to string', () {
        // Arrange
        const template = 'Age: {{age}}';
        final variables = {'age': 30};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Age: 30');
      });

      test('converts boolean to string', () {
        // Arrange
        const template = 'Active: {{isActive}}';
        final variables = {'isActive': true};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Active: true');
      });

      test('converts double to string', () {
        // Arrange
        const template = 'Price: {{price}}';
        final variables = {'price': 19.99};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Price: 19.99');
      });

      test('handles null value', () {
        // Arrange
        const template = 'Value: {{value}}';
        final variables = {'value': null};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Value: null');
      });
    });

    group('Special Characters and Edge Cases', () {
      test('handles variables with underscores', () {
        // Arrange
        const template = 'Token: {{api_token}}';
        final variables = {'api_token': 'abc123'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Token: abc123');
      });

      test('handles variables with numbers', () {
        // Arrange
        const template = 'User: {{user123}}';
        final variables = {'user123': 'Alice'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'User: Alice');
      });

      test('ignores malformed placeholders with spaces', () {
        // Arrange
        const template = 'Value: {{ name }}';
        final variables = {'name': 'Alice'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Value: {{ name }}');
      });

      test('handles single curly brace', () {
        // Arrange
        const template = 'JSON: {name: {{name}}}';
        final variables = {'name': 'Alice'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'JSON: {name: Alice}');
      });

      test('handles consecutive placeholders', () {
        // Arrange
        const template = '{{first}}{{second}}';
        final variables = {
          'first': 'Hello',
          'second': 'World',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'HelloWorld');
      });

      test('handles placeholder at start', () {
        // Arrange
        const template = '{{greeting}} World';
        final variables = {'greeting': 'Hello'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello World');
      });

      test('handles placeholder at end', () {
        // Arrange
        const template = 'Hello {{name}}';
        final variables = {'name': 'World'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Hello World');
      });
    });

    group('Real-World Use Cases', () {
      test('parses URL template', () {
        // Arrange
        const template = 'https://api.example.com/users/{{userId}}/posts/{{postId}}';
        final variables = {
          'userId': '123',
          'postId': '456',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'https://api.example.com/users/123/posts/456');
      });

      test('parses JSON body template', () {
        // Arrange
        const template = '{"entity_id": "{{entityId}}", "state": "{{state}}"}';
        final variables = {
          'entityId': 'light.living_room',
          'state': 'on',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, '{"entity_id": "light.living_room", "state": "on"}');
      });

      test('parses notification title template', () {
        // Arrange
        const template = 'Order #{{orderId}} - {{status}}';
        final variables = {
          'orderId': '12345',
          'status': 'Delivered',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Order #12345 - Delivered');
      });

      test('parses notification body with nested data', () {
        // Arrange
        const template = 'New order from {{customer.name}}: {{items.length}} items';
        final variables = {
          'customer': {'name': 'John Doe', 'email': 'john@example.com'},
          'items': ['item1', 'item2', 'item3'],
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'New order from John Doe: 3 items');
      });

      test('parses authorization header', () {
        // Arrange
        const template = 'Bearer {{token}}';
        final variables = {'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      });
    });

    group('Performance and Limits', () {
      test('handles large number of variables', () {
        // Arrange
        const template = 'v1={{v1}}, v2={{v2}}, v3={{v3}}, v4={{v4}}, v5={{v5}}';
        final variables = {
          'v1': '1',
          'v2': '2',
          'v3': '3',
          'v4': '4',
          'v5': '5',
        };

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'v1=1, v2=2, v3=3, v4=4, v5=5');
      });

      test('handles long template string', () {
        // Arrange
        final template = 'Start {{value}} ' * 100 + 'End';
        final variables = {'value': 'X'};

        // Act
        final result = parser.parse(template, variables);

        // Assert
        expect(result, 'Start X ' * 100 + 'End');
      });
    });
  });
}
