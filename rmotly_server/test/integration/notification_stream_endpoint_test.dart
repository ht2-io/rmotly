import 'dart:async';

import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given NotificationStreamEndpoint', (sessionBuilder, endpoints) {
    group('streamNotifications method', () {
      test('when user is not authenticated then throws AuthenticationException', () async {
        // Act & Assert: Expect exception when streaming without authentication
        expect(
          () async {
            await for (final _ in endpoints.notificationStream.streamNotifications(sessionBuilder)) {
              // Should not reach here
            }
          },
          throwsA(isA<Exception>()),
        );
      });

      test('when user is authenticated then stream is created', () async {
        // Arrange: Create authenticated sessionBuilder with userId 1
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Start streaming (we'll just verify it starts without error)
        final stream = endpoints.notificationStream.streamNotifications(authenticatedSession);

        // Assert: Stream should be created
        expect(stream, isA<Stream>());

        // Clean up: cancel the stream after a short delay
        final subscription = stream.listen((_) {});
        await Future.delayed(Duration(milliseconds: 100));
        await subscription.cancel();
      });

      test('when notification is sent then stream receives it', () async {
        // Arrange: Create authenticated sessionBuilder with userId 1
        final userId = 1;
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(userId, {}),
        );

        // Create a completer to track when we receive the notification
        final completer = Completer<bool>();

        // Act: Start streaming
        final stream = endpoints.notificationStream.streamNotifications(authenticatedSession);
        final subscription = stream.listen((notification) {
          // Assert: Verify we received a notification
          expect(notification.title, equals('Test Notification'));
          expect(notification.body, equals('This is a test notification from Rmotly.'));
          completer.complete(true);
        });

        // Send a test notification
        await endpoints.notificationStream.sendTestNotification(
          authenticatedSession,
          title: 'Test Notification',
          body: 'This is a test notification from Rmotly.',
        );

        // Wait for notification or timeout
        final received = await completer.future.timeout(
          Duration(seconds: 2),
          onTimeout: () => false,
        );

        // Clean up
        await subscription.cancel();

        // Assert: We should have received the notification
        expect(received, isTrue);
      });
    });

    group('getConnectionCount method', () {
      test('when user is not authenticated then throws AuthenticationException', () async {
        // Act & Assert
        expect(
          () => endpoints.notificationStream.getConnectionCount(sessionBuilder),
          throwsA(isA<Exception>()),
        );
      });

      test('when user has no connections then returns 0', () async {
        // Arrange: Create authenticated sessionBuilder
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act
        final count = await endpoints.notificationStream.getConnectionCount(authenticatedSession);

        // Assert
        expect(count, equals(0));
      });

      test('when user has active stream then returns 1', () async {
        // Arrange: Create authenticated sessionBuilder and start a stream
        final userId = 1;
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(userId, {}),
        );
        final stream = endpoints.notificationStream.streamNotifications(authenticatedSession);
        final subscription = stream.listen((_) {});

        // Wait a bit for the stream to be registered
        await Future.delayed(Duration(milliseconds: 100));

        // Act
        final count = await endpoints.notificationStream.getConnectionCount(authenticatedSession);

        // Clean up
        await subscription.cancel();

        // Assert
        expect(count, equals(1));
      });
    });

    group('sendTestNotification method', () {
      test('when user is not authenticated then throws AuthenticationException', () async {
        // Act & Assert
        expect(
          () => endpoints.notificationStream.sendTestNotification(
            sessionBuilder,
            title: 'Test',
            body: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('when user has no connections then returns 0', () async {
        // Arrange: Create authenticated sessionBuilder without active stream
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act
        final delivered = await endpoints.notificationStream.sendTestNotification(
          authenticatedSession,
          title: 'Test Notification',
          body: 'This is a test notification from Rmotly.',
        );

        // Assert
        expect(delivered, equals(0));
      });

      test('when user has active stream then notification is delivered', () async {
        // Arrange: Create authenticated sessionBuilder and start a stream
        final userId = 1;
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(userId, {}),
        );
        final stream = endpoints.notificationStream.streamNotifications(authenticatedSession);
        
        final receivedNotifications = <dynamic>[];
        final subscription = stream.listen((notification) {
          receivedNotifications.add(notification);
        });

        // Wait for stream to be registered
        await Future.delayed(Duration(milliseconds: 100));

        // Act: Send test notification
        final delivered = await endpoints.notificationStream.sendTestNotification(
          authenticatedSession,
          title: 'Custom Test',
          body: 'Custom body',
        );

        // Wait for notification to be received
        await Future.delayed(Duration(milliseconds: 100));

        // Clean up
        await subscription.cancel();

        // Assert
        expect(delivered, equals(1));
        expect(receivedNotifications.length, equals(1));
        expect(receivedNotifications[0].title, equals('Custom Test'));
        expect(receivedNotifications[0].body, equals('Custom body'));
      });
    });

    group('multiple connections', () {
      test('when user has multiple streams then all receive notifications', () async {
        // Arrange: Create authenticated sessionBuilder and start multiple streams
        final userId = 1;
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(userId, {}),
        );
        
        final stream1 = endpoints.notificationStream.streamNotifications(authenticatedSession);
        final stream2 = endpoints.notificationStream.streamNotifications(authenticatedSession);
        
        final received1 = <dynamic>[];
        final received2 = <dynamic>[];
        
        final subscription1 = stream1.listen((notification) {
          received1.add(notification);
        });
        final subscription2 = stream2.listen((notification) {
          received2.add(notification);
        });

        // Wait for streams to be registered
        await Future.delayed(Duration(milliseconds: 100));

        // Act: Send test notification
        final delivered = await endpoints.notificationStream.sendTestNotification(
          authenticatedSession,
          title: 'Test Notification',
          body: 'This is a test notification from Rmotly.',
        );

        // Wait for notifications to be received
        await Future.delayed(Duration(milliseconds: 100));

        // Clean up
        await subscription1.cancel();
        await subscription2.cancel();

        // Assert: Both streams should have received the notification
        expect(delivered, equals(2));
        expect(received1.length, equals(1));
        expect(received2.length, equals(1));
      });
    });
  });
}
