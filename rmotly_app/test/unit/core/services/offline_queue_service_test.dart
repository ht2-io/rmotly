import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rmotly_app/core/services/offline_queue_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineQueueService queueService;

  setUp(() async {
    // Initialize Hive with a temporary directory for testing
    await Hive.initFlutter();
    queueService = OfflineQueueService();
    await queueService.init();
    await queueService.clearQueue(); // Start with clean queue
  });

  tearDown(() async {
    await queueService.close();
    await Hive.deleteFromDisk();
  });

  group('OfflineQueueService', () {
    test('queues event successfully', () async {
      final eventId = await queueService.queueEvent(
        controlId: 1,
        eventType: 'button_press',
        payload: '{"value": true}',
      );

      expect(eventId, isNotEmpty);
      
      final count = await queueService.getQueuedCount();
      expect(count, 1);
    });

    test('retrieves queued events', () async {
      await queueService.queueEvent(
        controlId: 1,
        eventType: 'button_press',
        payload: '{"value": true}',
      );

      await queueService.queueEvent(
        controlId: 2,
        eventType: 'slider_change',
        payload: '{"value": 50}',
      );

      final events = await queueService.getQueuedEvents();
      expect(events.length, 2);
      expect(events[0].controlId, 1);
      expect(events[1].controlId, 2);
    });

    test('removes event from queue', () async {
      final eventId = await queueService.queueEvent(
        controlId: 1,
        eventType: 'button_press',
      );

      await queueService.removeEvent(eventId);

      final count = await queueService.getQueuedCount();
      expect(count, 0);
    });

    test('marks event as failed and increments attempt count', () async {
      final eventId = await queueService.queueEvent(
        controlId: 1,
        eventType: 'button_press',
      );

      await queueService.markEventFailed(eventId, 'Network error');

      final events = await queueService.getQueuedEvents();
      expect(events.length, 1);
      expect(events[0].attemptCount, 1);
      expect(events[0].lastError, 'Network error');
    });

    test('removes event after max attempts', () async {
      final eventId = await queueService.queueEvent(
        controlId: 1,
        eventType: 'button_press',
      );

      // Mark as failed 3 times (max attempts)
      await queueService.markEventFailed(eventId, 'Error 1');
      await queueService.markEventFailed(eventId, 'Error 2');
      await queueService.markEventFailed(eventId, 'Error 3');

      final count = await queueService.getQueuedCount();
      expect(count, 0);
    });

    test('clears all queued events', () async {
      await queueService.queueEvent(controlId: 1, eventType: 'test1');
      await queueService.queueEvent(controlId: 2, eventType: 'test2');
      await queueService.queueEvent(controlId: 3, eventType: 'test3');

      await queueService.clearQueue();

      final count = await queueService.getQueuedCount();
      expect(count, 0);
    });

    test('returns events sorted by queued time', () async {
      final id1 = await queueService.queueEvent(
        controlId: 1,
        eventType: 'first',
      );

      // Small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));

      final id2 = await queueService.queueEvent(
        controlId: 2,
        eventType: 'second',
      );

      final events = await queueService.getQueuedEvents();
      expect(events.length, 2);
      expect(events[0].id, id1);
      expect(events[1].id, id2);
    });
  });
}
