import 'package:test/test.dart';
import 'package:rmotly_server/src/services/payload_parser_service.dart';

void main() {
  group('PayloadParserService', () {
    late PayloadParserService service;

    setUp(() {
      service = PayloadParserService();
    });

    group('Firebase format', () {
      test('detects and parses Firebase format correctly', () {
        final payload = {
          'notification': {
            'title': 'Test Title',
            'body': 'Test Body',
            'image': 'https://example.com/image.png',
            'click_action': 'https://example.com'
          },
          'data': {'key': 'value'},
          'priority': 'high'
        };

        final result = service.parse(payload);

        expect(result.title, equals('Test Title'));
        expect(result.body, equals('Test Body'));
        expect(result.data, equals({'key': 'value'}));
        expect(result.priority, equals('high'));
        expect(result.imageUrl, equals('https://example.com/image.png'));
        expect(result.actionUrl, equals('https://example.com'));
        expect(result.sourceFormat, equals(PayloadFormat.firebase));
      });

      test('handles Firebase with Android-specific image', () {
        final payload = {
          'notification': {
            'title': 'Test',
            'body': 'Body',
          },
          'android': {
            'notification': {'image': 'https://example.com/android-image.png'}
          }
        };

        final result = service.parse(payload);

        expect(
            result.imageUrl, equals('https://example.com/android-image.png'));
        expect(result.sourceFormat, equals(PayloadFormat.firebase));
      });

      test('handles Firebase with missing optional fields', () {
        final payload = {
          'notification': {
            'title': 'Test',
          },
        };

        final result = service.parse(payload);

        expect(result.title, equals('Test'));
        expect(result.body, equals(''));
        expect(result.data, isNull);
        expect(result.priority, equals('normal'));
        expect(result.sourceFormat, equals(PayloadFormat.firebase));
      });

      test('uses default title when Firebase title is missing', () {
        final payload = {
          'notification': {
            'body': 'Body without title',
          },
        };

        final result = service.parse(payload);

        expect(result.title, equals('Notification'));
        expect(result.body, equals('Body without title'));
        expect(result.sourceFormat, equals(PayloadFormat.firebase));
      });
    });

    group('Pushover format', () {
      test('detects and parses Pushover format correctly', () {
        final payload = {
          'token': 'app-token',
          'user': 'user-key',
          'title': 'Pushover Title',
          'message': 'Pushover Message',
          'priority': 1,
          'url': 'https://example.com',
          'device': 'iphone',
          'sound': 'pushover'
        };

        final result = service.parse(payload);

        expect(result.title, equals('Pushover Title'));
        expect(result.body, equals('Pushover Message'));
        expect(result.priority, equals('high'));
        expect(result.actionUrl, equals('https://example.com'));
        expect(result.data, containsPair('device', 'iphone'));
        expect(result.data, containsPair('sound', 'pushover'));
        expect(result.sourceFormat, equals(PayloadFormat.pushover));
      });

      test('converts Pushover priority -2 to low', () {
        final payload = {'message': 'Test', 'priority': -2, 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('low'));
      });

      test('converts Pushover priority -1 to low', () {
        final payload = {'message': 'Test', 'priority': -1, 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('low'));
      });

      test('converts Pushover priority 0 to normal', () {
        final payload = {'message': 'Test', 'priority': 0, 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('normal'));
      });

      test('converts Pushover priority 1 to high', () {
        final payload = {'message': 'Test', 'priority': 1, 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('converts Pushover priority 2 to urgent', () {
        final payload = {'message': 'Test', 'priority': 2, 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('urgent'));
      });

      test('handles Pushover with missing optional fields', () {
        final payload = {'message': 'Message only', 'user': 'test'};

        final result = service.parse(payload);

        expect(result.title, equals('Notification'));
        expect(result.body, equals('Message only'));
        expect(result.priority, equals('normal'));
      });
    });

    group('Ntfy format', () {
      test('detects and parses ntfy format correctly', () {
        final payload = {
          'topic': 'my-topic',
          'title': 'Ntfy Title',
          'message': 'Ntfy Message',
          'priority': 4,
          'tags': ['tag1', 'tag2'],
          'click': 'https://example.com',
          'attach': 'https://example.com/image.jpg'
        };

        final result = service.parse(payload);

        expect(result.title, equals('Ntfy Title'));
        expect(result.body, equals('Ntfy Message'));
        expect(result.priority, equals('high'));
        expect(result.imageUrl, equals('https://example.com/image.jpg'));
        expect(result.actionUrl, equals('https://example.com'));
        expect(result.tags, equals(['tag1', 'tag2']));
        expect(result.data, containsPair('topic', 'my-topic'));
        expect(result.sourceFormat, equals(PayloadFormat.ntfy));
      });

      test('converts ntfy priority 1 to low', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': 1};

        final result = service.parse(payload);
        expect(result.priority, equals('low'));
      });

      test('converts ntfy priority 2 to low', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': 2};

        final result = service.parse(payload);
        expect(result.priority, equals('low'));
      });

      test('converts ntfy priority 3 to normal', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': 3};

        final result = service.parse(payload);
        expect(result.priority, equals('normal'));
      });

      test('converts ntfy priority 4 to high', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': 4};

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('converts ntfy priority 5 to urgent', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': 5};

        final result = service.parse(payload);
        expect(result.priority, equals('urgent'));
      });

      test('handles ntfy tags as comma-separated string', () {
        final payload = {
          'topic': 'test',
          'message': 'Test',
          'tags': 'tag1,tag2,tag3'
        };

        final result = service.parse(payload);
        expect(result.tags, equals(['tag1', 'tag2', 'tag3']));
      });

      test('handles ntfy with missing optional fields', () {
        final payload = {
          'topic': 'test',
        };

        final result = service.parse(payload);

        expect(result.title, equals('Notification'));
        expect(result.body, equals(''));
        expect(result.priority, equals('normal'));
        expect(result.sourceFormat, equals(PayloadFormat.ntfy));
      });
    });

    group('Gotify format', () {
      test('detects and parses Gotify format correctly', () {
        final payload = {
          'title': 'Gotify Title',
          'message': 'Gotify Message',
          'priority': 8,
          'extras': {
            'client::notification': {
              'click': {'url': 'https://example.com'},
              'bigImageUrl': 'https://example.com/image.png'
            },
            'custom': 'data'
          }
        };

        final result = service.parse(payload);

        expect(result.title, equals('Gotify Title'));
        expect(result.body, equals('Gotify Message'));
        expect(result.priority, equals('high'));
        expect(result.actionUrl, equals('https://example.com'));
        expect(result.imageUrl, equals('https://example.com/image.png'));
        expect(result.data!['custom'], equals('data'));
        expect(result.sourceFormat, equals(PayloadFormat.gotify));
      });

      test('converts Gotify priority 1-3 to low', () {
        for (var priority in [1, 2, 3]) {
          final payload = {
            'message': 'Test',
            'priority': priority,
            'extras': {}
          };

          final result = service.parse(payload);
          expect(result.priority, equals('low'),
              reason: 'Priority $priority should be low');
        }
      });

      test('converts Gotify priority 4-6 to normal', () {
        for (var priority in [4, 5, 6]) {
          final payload = {
            'message': 'Test',
            'priority': priority,
            'extras': {}
          };

          final result = service.parse(payload);
          expect(result.priority, equals('normal'),
              reason: 'Priority $priority should be normal');
        }
      });

      test('converts Gotify priority 7-8 to high', () {
        for (var priority in [7, 8]) {
          final payload = {
            'message': 'Test',
            'priority': priority,
            'extras': {}
          };

          final result = service.parse(payload);
          expect(result.priority, equals('high'),
              reason: 'Priority $priority should be high');
        }
      });

      test('converts Gotify priority 9-10 to urgent', () {
        for (var priority in [9, 10]) {
          final payload = {
            'message': 'Test',
            'priority': priority,
            'extras': {}
          };

          final result = service.parse(payload);
          expect(result.priority, equals('urgent'),
              reason: 'Priority $priority should be urgent');
        }
      });

      test('handles Gotify with appid but no extras', () {
        final payload = {'message': 'Test', 'appid': 5};

        final result = service.parse(payload);
        expect(result.sourceFormat, equals(PayloadFormat.gotify));
      });

      test('handles Gotify with missing optional fields', () {
        final payload = {'message': 'Message only', 'extras': {}};

        final result = service.parse(payload);

        expect(result.title, equals('Notification'));
        expect(result.body, equals('Message only'));
        expect(result.priority, equals('normal'));
      });
    });

    group('Home Assistant format', () {
      test('detects and parses Home Assistant format correctly', () {
        final payload = {
          'message': 'HA Message',
          'title': 'HA Title',
          'data': {
            'push': {'priority': 'time-sensitive'},
            'image': 'https://example.com/image.png',
            'url': 'https://example.com',
            'entity_id': 'switch.living_room'
          }
        };

        final result = service.parse(payload);

        expect(result.title, equals('HA Title'));
        expect(result.body, equals('HA Message'));
        expect(result.priority, equals('high'));
        expect(result.imageUrl, equals('https://example.com/image.png'));
        expect(result.actionUrl, equals('https://example.com'));
        expect(result.sourceFormat, equals(PayloadFormat.homeAssistant));
      });

      test('converts Home Assistant "critical" priority to high', () {
        final payload = {
          'message': 'Test',
          'data': {
            'push': {'priority': 'critical'},
            'entity_id': 'test'
          }
        };

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('converts Home Assistant "time-sensitive" priority to high', () {
        final payload = {
          'message': 'Test',
          'data': {
            'push': {'priority': 'time-sensitive'},
            'entity_id': 'test'
          }
        };

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('defaults to normal priority for Home Assistant', () {
        final payload = {
          'message': 'Test',
          'data': {'entity_id': 'test'}
        };

        final result = service.parse(payload);
        expect(result.priority, equals('normal'));
      });
    });

    group('Generic format', () {
      test('parses generic format with title and body', () {
        final payload = {
          'title': 'Generic Title',
          'body': 'Generic Body',
          'data': {'key': 'value'},
          'priority': 'high'
        };

        final result = service.parse(payload);

        expect(result.title, equals('Generic Title'));
        expect(result.body, equals('Generic Body'));
        expect(result.data, equals({'key': 'value'}));
        expect(result.priority, equals('high'));
        expect(result.sourceFormat, equals(PayloadFormat.generic));
      });

      test('tries alternative field names for title', () {
        final testCases = [
          {'subject': 'Subject Title'},
          {'header': 'Header Title'},
        ];

        for (var payload in testCases) {
          final result = service.parse(payload);
          expect(result.title, isNotEmpty);
        }
      });

      test('tries alternative field names for body', () {
        final testCases = [
          {'message': 'Message body'},
          {'text': 'Text body'},
          {'content': 'Content body'},
          {'description': 'Description body'},
        ];

        for (var payload in testCases) {
          final result = service.parse(payload);
          expect(result.body, isNotEmpty);
        }
      });

      test('tries alternative field names for data', () {
        final testCases = [
          {
            'payload': {'key': 'value'}
          },
          {
            'extras': {'key': 'value'}
          },
          {
            'extra': {'key': 'value'}
          },
        ];

        for (var payload in testCases) {
          final result = service.parse(payload);
          expect(result.data, isNotNull);
          expect(result.data!['key'], equals('value'));
        }
      });

      test('tries alternative field names for image', () {
        final testCases = [
          {'image': 'https://example.com/1.jpg'},
          {'imageUrl': 'https://example.com/2.jpg'},
          {'image_url': 'https://example.com/3.jpg'},
        ];

        for (var payload in testCases) {
          final result = service.parse(payload);
          expect(result.imageUrl, isNotNull);
        }
      });

      test('tries alternative field names for action URL', () {
        final testCases = [
          {'url': 'https://example.com/1'},
          {'actionUrl': 'https://example.com/2'},
          {'click_url': 'https://example.com/3'},
          {'link': 'https://example.com/4'},
        ];

        for (var payload in testCases) {
          final result = service.parse(payload);
          expect(result.actionUrl, isNotNull);
        }
      });

      test('converts generic priority strings correctly', () {
        final testCases = {
          'low': 'low',
          'min': 'low',
          '1': 'low',
          '2': 'low',
          'normal': 'normal',
          '3': 'normal',
          'high': 'high',
          '4': 'high',
          'important': 'high',
          'urgent': 'urgent',
          'critical': 'urgent',
          'max': 'urgent',
          '5': 'urgent',
        };

        for (var entry in testCases.entries) {
          final payload = {
            'priority': entry.key,
          };

          final result = service.parse(payload);
          expect(result.priority, equals(entry.value),
              reason: 'Priority "${entry.key}" should map to "${entry.value}"');
        }
      });

      test('handles empty generic payload', () {
        final payload = <String, dynamic>{};

        final result = service.parse(payload);

        expect(result.title, equals('Notification'));
        expect(result.body, equals(''));
        expect(result.priority, equals('normal'));
        expect(result.sourceFormat, equals(PayloadFormat.generic));
      });

      test('handles generic payload with only priority', () {
        final payload = {'priority': 'high'};

        final result = service.parse(payload);

        expect(result.priority, equals('high'));
        expect(result.sourceFormat, equals(PayloadFormat.generic));
      });

      test('converts tags list in generic format', () {
        final payload = {
          'tags': ['tag1', 'tag2']
        };

        final result = service.parse(payload);
        expect(result.tags, equals(['tag1', 'tag2']));
      });
    });

    group('parseWithFormat', () {
      test('forces parsing with specific format', () {
        // This payload looks like Firebase but we force Pushover
        final payload = {
          'notification': {'title': 'Test'},
          'message': 'Forced message'
        };

        final result = service.parseWithFormat(payload, PayloadFormat.pushover);

        expect(result.body, equals('Forced message'));
        expect(result.sourceFormat, equals(PayloadFormat.pushover));
      });

      test('supports all format types in parseWithFormat', () {
        final payload = {'title': 'Test', 'message': 'Body'};

        for (var format in PayloadFormat.values) {
          final result = service.parseWithFormat(payload, format);
          expect(result.sourceFormat, equals(format));
        }
      });
    });

    group('Edge cases', () {
      test('handles null priority gracefully', () {
        final payload = {'title': 'Test', 'priority': null};

        final result = service.parse(payload);
        expect(result.priority, equals('normal'));
      });

      test('handles non-map data field gracefully', () {
        final payload = {'title': 'Test', 'data': 'not a map'};

        final result = service.parse(payload);
        expect(result.data, isNull);
      });

      test('handles numeric priority as string in Pushover', () {
        final payload = {'message': 'Test', 'priority': '1', 'user': 'test'};

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('handles numeric priority as string in ntfy', () {
        final payload = {'topic': 'test', 'message': 'Test', 'priority': '4'};

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });

      test('handles numeric priority as string in Gotify', () {
        final payload = {'message': 'Test', 'priority': '8', 'extras': {}};

        final result = service.parse(payload);
        expect(result.priority, equals('high'));
      });
    });

    group('toJson', () {
      test('converts NotificationPayload to JSON correctly', () {
        final payload = NotificationPayload(
          title: 'Test',
          body: 'Body',
          data: {'key': 'value'},
          priority: 'high',
          imageUrl: 'https://example.com/image.png',
          actionUrl: 'https://example.com',
          tags: ['tag1', 'tag2'],
          sourceFormat: PayloadFormat.firebase,
        );

        final json = payload.toJson();

        expect(json['title'], equals('Test'));
        expect(json['body'], equals('Body'));
        expect(json['data'], equals({'key': 'value'}));
        expect(json['priority'], equals('high'));
        expect(json['imageUrl'], equals('https://example.com/image.png'));
        expect(json['actionUrl'], equals('https://example.com'));
        expect(json['tags'], equals(['tag1', 'tag2']));
        expect(json['sourceFormat'], equals('firebase'));
      });

      test('omits null fields in JSON', () {
        final payload = NotificationPayload(
          title: 'Test',
          body: 'Body',
          sourceFormat: PayloadFormat.generic,
        );

        final json = payload.toJson();

        expect(json.containsKey('data'), isFalse);
        expect(json.containsKey('imageUrl'), isFalse);
        expect(json.containsKey('actionUrl'), isFalse);
        expect(json.containsKey('tags'), isFalse);
      });
    });
  });
}
