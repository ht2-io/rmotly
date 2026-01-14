import 'package:test/test.dart';

// Import the generated test helper file
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Test the Event model database operations
  withServerpod('Given Event model', (sessionBuilder, endpoints) {
    test('when creating an Event then it should be saved to database', () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_123',
        eventType: 'button_press',
        payload: '{"value": true}',
        timestamp: DateTime.now(),
      );

      // Act
      final savedEvent = await Event.db.insertRow(session, event);

      // Assert
      expect(savedEvent.id, isNotNull);
      expect(savedEvent.userId, equals(1));
      expect(savedEvent.sourceType, equals('control'));
      expect(savedEvent.sourceId, equals('ctrl_123'));
      expect(savedEvent.eventType, equals('button_press'));
      expect(savedEvent.payload, equals('{"value": true}'));
    });

    test('when finding Event by ID then it should return the correct event',
        () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event = Event(
        userId: 1,
        sourceType: 'webhook',
        sourceId: 'webhook_456',
        eventType: 'notification',
        payload: '{"message": "Hello"}',
        actionResult: '{"status": 200}',
        timestamp: DateTime.now(),
      );
      final savedEvent = await Event.db.insertRow(session, event);

      // Act
      final foundEvent = await Event.db.findById(session, savedEvent.id!);

      // Assert
      expect(foundEvent, isNotNull);
      expect(foundEvent!.id, equals(savedEvent.id));
      expect(foundEvent.sourceType, equals('webhook'));
      expect(foundEvent.actionResult, equals('{"status": 200}'));
    });

    test('when updating Event actionResult then it should be persisted',
        () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_789',
        eventType: 'slider_change',
        payload: '{"value": 50}',
        timestamp: DateTime.now(),
      );
      final savedEvent = await Event.db.insertRow(session, event);

      // Act
      savedEvent.actionResult = '{"status": 200, "response": "OK"}';
      await Event.db.updateRow(session, savedEvent);

      // Assert
      final updatedEvent = await Event.db.findById(session, savedEvent.id!);
      expect(updatedEvent!.actionResult,
          equals('{"status": 200, "response": "OK"}'));
    });

    test('when finding Events by userId then it should return user events',
        () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event1 = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_1',
        eventType: 'button_press',
        timestamp: DateTime.now(),
      );
      final event2 = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_2',
        eventType: 'toggle_switch',
        timestamp: DateTime.now(),
      );
      final event3 = Event(
        userId: 2,
        sourceType: 'control',
        sourceId: 'ctrl_3',
        eventType: 'button_press',
        timestamp: DateTime.now(),
      );

      await Event.db.insertRow(session, event1);
      await Event.db.insertRow(session, event2);
      await Event.db.insertRow(session, event3);

      // Act
      final userEvents = await Event.db.find(
        session,
        where: (t) => t.userId.equals(1),
      );

      // Assert
      expect(userEvents.length, equals(2));
      expect(userEvents.every((e) => e.userId == 1), isTrue);
    });

    test('when deleting Event then it should be removed from database',
        () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_delete',
        eventType: 'button_press',
        timestamp: DateTime.now(),
      );
      final savedEvent = await Event.db.insertRow(session, event);

      // Act
      await Event.db.deleteRow(session, savedEvent);

      // Assert
      final deletedEvent = await Event.db.findById(session, savedEvent.id!);
      expect(deletedEvent, isNull);
    });

    test('when creating Event with null optional fields then it should succeed',
        () async {
      // Arrange
      final session = await sessionBuilder.build();
      final event = Event(
        userId: 1,
        sourceType: 'control',
        sourceId: 'ctrl_minimal',
        eventType: 'button_press',
        timestamp: DateTime.now(),
        // payload and actionResult are null
      );

      // Act
      final savedEvent = await Event.db.insertRow(session, event);

      // Assert
      expect(savedEvent.id, isNotNull);
      expect(savedEvent.payload, isNull);
      expect(savedEvent.actionResult, isNull);
    });
  });
}
