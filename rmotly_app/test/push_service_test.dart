import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/shared/services/push_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushService', () {
    late PushService pushService;

    setUp(() {
      pushService = PushService();
    });

    tearDown(() {
      pushService.dispose();
    });

    test('initial state is not initialized', () {
      expect(pushService.state.isInitialized, false);
      expect(pushService.state.unifiedPushEndpoint, null);
      expect(pushService.state.isWebSocketConnected, false);
      expect(pushService.state.isSseConnected, false);
      expect(pushService.state.pendingNotifications, isEmpty);
      expect(pushService.state.error, null);
    });

    group('PushNotification', () {
      test('fromJson creates notification with all fields', () {
        final json = {
          'id': 'test-123',
          'title': 'Test Title',
          'body': 'Test Body',
          'data': {'key': 'value'},
          'imageUrl': 'https://example.com/image.png',
          'actionUrl': 'https://example.com/action',
        };

        final notification = PushNotification.fromJson(
          json,
          DeliveryMethod.webpush,
        );

        expect(notification.id, 'test-123');
        expect(notification.title, 'Test Title');
        expect(notification.body, 'Test Body');
        expect(notification.data, {'key': 'value'});
        expect(notification.imageUrl, 'https://example.com/image.png');
        expect(notification.actionUrl, 'https://example.com/action');
        expect(notification.deliveryMethod, DeliveryMethod.webpush);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'title': 'Test Title',
          'body': 'Test Body',
        };

        final notification = PushNotification.fromJson(
          json,
          DeliveryMethod.sse,
        );

        expect(notification.title, 'Test Title');
        expect(notification.body, 'Test Body');
        expect(notification.data, null);
        expect(notification.imageUrl, null);
        expect(notification.actionUrl, null);
        expect(notification.deliveryMethod, DeliveryMethod.sse);
      });

      test('fromJson uses message field as fallback for body', () {
        final json = {
          'message': 'Test Message',
        };

        final notification = PushNotification.fromJson(
          json,
          DeliveryMethod.websocket,
        );

        expect(notification.body, 'Test Message');
      });
    });

    group('PushServiceState', () {
      test('copyWith updates specified fields', () {
        const initialState = PushServiceState(
          isInitialized: false,
          unifiedPushEndpoint: null,
        );

        final updatedState = initialState.copyWith(
          isInitialized: true,
          unifiedPushEndpoint: 'https://push.example.com/endpoint',
        );

        expect(updatedState.isInitialized, true);
        expect(updatedState.unifiedPushEndpoint,
            'https://push.example.com/endpoint');
        expect(updatedState.isWebSocketConnected, false); // unchanged
      });

      test('copyWith preserves unspecified fields', () {
        const initialState = PushServiceState(
          isInitialized: true,
          isWebSocketConnected: true,
          unifiedPushEndpoint: 'https://push.example.com/endpoint',
        );

        final updatedState = initialState.copyWith(
          isSseConnected: true,
        );

        expect(updatedState.isInitialized, true);
        expect(updatedState.isWebSocketConnected, true);
        expect(updatedState.unifiedPushEndpoint,
            'https://push.example.com/endpoint');
        expect(updatedState.isSseConnected, true);
      });

      test('copyWith can clear nullable fields', () {
        const initialState = PushServiceState(
          unifiedPushEndpoint: 'https://push.example.com/endpoint',
          error: 'Some error',
        );

        final updatedState = initialState.copyWith(
          clearUnifiedPushEndpoint: true,
          clearError: true,
        );

        expect(updatedState.unifiedPushEndpoint, null);
        expect(updatedState.error, null);
      });
    });

    group('DeliveryMethod', () {
      test('has correct enum values', () {
        expect(DeliveryMethod.values.length, 3);
        expect(DeliveryMethod.values, contains(DeliveryMethod.websocket));
        expect(DeliveryMethod.values, contains(DeliveryMethod.webpush));
        expect(DeliveryMethod.values, contains(DeliveryMethod.sse));
      });
    });

    group('UnifiedPush handlers', () {
      test('onUnifiedPushEndpoint updates state', () async {
        final endpoint = 'https://push.example.com/test-endpoint';

        await pushService.onUnifiedPushEndpoint(endpoint);

        expect(pushService.state.unifiedPushEndpoint, endpoint);
      });

      test('onUnifiedPushMessage parses and emits notification', () async {
        final message = jsonEncode({
          'id': 'msg-1',
          'title': 'Test Push',
          'body': 'Test Body',
        });

        final notifications = <PushNotification>[];
        final subscription = pushService.notifications.listen(
          (notification) => notifications.add(notification),
        );

        // Note: This will fail to show the local notification due to plugin
        // not being initialized, but should still emit to the stream
        await pushService.onUnifiedPushMessage(message);

        // Wait a bit for the stream to process
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifications.length, 1);
        expect(notifications[0].title, 'Test Push');
        expect(notifications[0].body, 'Test Body');
        expect(notifications[0].deliveryMethod, DeliveryMethod.webpush);

        await subscription.cancel();
      });

      test('onUnifiedPushUnregistered clears endpoint', () async {
        // First set an endpoint and wait for it to complete
        await pushService
            .onUnifiedPushEndpoint('https://push.example.com/endpoint');

        // Verify it was set
        expect(pushService.state.unifiedPushEndpoint,
            'https://push.example.com/endpoint');

        // Now unregister and verify it was cleared
        await pushService.onUnifiedPushUnregistered();

        expect(pushService.state.unifiedPushEndpoint, null);
      });
    });

    group('WebSocket handlers', () {
      test('onWebSocketNotification emits notification', () async {
        final data = {
          'id': 'ws-1',
          'title': 'WebSocket Test',
          'body': 'WebSocket Body',
        };

        final notifications = <PushNotification>[];
        final subscription = pushService.notifications.listen(
          (notification) => notifications.add(notification),
        );

        pushService.onWebSocketNotification(data);

        // Wait for stream to process
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifications.length, 1);
        expect(notifications[0].title, 'WebSocket Test');
        expect(notifications[0].deliveryMethod, DeliveryMethod.websocket);

        await subscription.cancel();
      });
    });

    group('SSE handlers', () {
      test('onSseNotification emits notification', () async {
        final data = {
          'id': 'sse-1',
          'title': 'SSE Test',
          'body': 'SSE Body',
        };

        final notifications = <PushNotification>[];
        final subscription = pushService.notifications.listen(
          (notification) => notifications.add(notification),
        );

        pushService.onSseNotification(data);

        // Wait for stream to process
        await Future.delayed(const Duration(milliseconds: 10));

        expect(notifications.length, 1);
        expect(notifications[0].title, 'SSE Test');
        expect(notifications[0].deliveryMethod, DeliveryMethod.sse);

        await subscription.cancel();
      });
    });

    group('Connection state', () {
      test('connectWebSocket updates state', () async {
        await pushService.connectWebSocket();

        expect(pushService.state.isWebSocketConnected, true);
      });

      test('disconnectWebSocket updates state', () async {
        await pushService.connectWebSocket();
        await pushService.disconnectWebSocket();

        expect(pushService.state.isWebSocketConnected, false);
      });
    });
  });
}
