import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given PushSubscriptionEndpoint', (sessionBuilder, endpoints) {
    group('registerEndpoint', () {
      test('when called without authentication then throws', () async {
        // Act & Assert: Expect exception when not authenticated
        expect(
          () => endpoints.pushSubscription.registerEndpoint(
            sessionBuilder,
            endpoint: 'https://ntfy.sh/test123',
            subscriptionType: 'unifiedpush',
            deviceId: 'device-1',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('when called with valid data then creates subscription', () async {
        // Arrange: Create authenticated session
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Register a push endpoint
        final subscription = await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/test123',
          p256dh: 'test-p256dh-key',
          authSecret: 'test-auth-secret',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
          userAgent: 'TestAgent/1.0',
        );

        // Assert
        expect(subscription.endpoint, 'https://ntfy.sh/test123');
        expect(subscription.userId, 1);
        expect(subscription.subscriptionType, 'unifiedpush');
        expect(subscription.deviceId, 'device-1');
        expect(subscription.active, true);
        expect(subscription.failureCount, 0);
      });

      test('when called with invalid subscription type then throws', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act & Assert
        expect(
          () => endpoints.pushSubscription.registerEndpoint(
            authenticatedSession,
            endpoint: 'https://ntfy.sh/test123',
            subscriptionType: 'invalid-type',
            deviceId: 'device-1',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('when called with same device ID then updates subscription',
          () async {
        // Arrange: Create authenticated session
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create initial subscription
        final firstSub = await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/old-endpoint',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );

        // Act: Register again with same device ID but different endpoint
        final updatedSub = await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/new-endpoint',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );

        // Assert: Should update existing subscription
        expect(updatedSub.id, firstSub.id); // Same ID
        expect(updatedSub.endpoint,
            'https://ntfy.sh/new-endpoint'); // Updated endpoint
        expect(updatedSub.failureCount, 0); // Failures reset
      });
    });

    group('listSubscriptions', () {
      test('when user has no subscriptions then returns empty list', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act
        final subscriptions =
            await endpoints.pushSubscription.listSubscriptions(
          authenticatedSession,
        );

        // Assert
        expect(subscriptions, isEmpty);
      });

      test('when user has subscriptions then returns them', () async {
        // Arrange: Create authenticated session
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create two subscriptions
        await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/device1',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );
        await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/device2',
          subscriptionType: 'webpush',
          deviceId: 'device-2',
        );

        // Act
        final subscriptions =
            await endpoints.pushSubscription.listSubscriptions(
          authenticatedSession,
        );

        // Assert
        expect(subscriptions, hasLength(2));
        expect(subscriptions[0].deviceId, 'device-1');
        expect(subscriptions[1].deviceId, 'device-2');
      });
    });

    group('unregisterEndpoint', () {
      test('when subscription exists then removes it', () async {
        // Arrange: Create authenticated session and subscription
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/test123',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );

        // Act: Unregister
        final removed = await endpoints.pushSubscription.unregisterEndpoint(
          authenticatedSession,
          'device-1',
        );

        // Assert
        expect(removed, true);

        // Verify it's gone
        final subscriptions =
            await endpoints.pushSubscription.listSubscriptions(
          authenticatedSession,
        );
        expect(subscriptions, isEmpty);
      });

      test('when subscription does not exist then returns false', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Try to unregister non-existent subscription
        final removed = await endpoints.pushSubscription.unregisterEndpoint(
          authenticatedSession,
          'non-existent-device',
        );

        // Assert
        expect(removed, false);
      });
    });

    group('updateSubscription', () {
      test('when disabling subscription then sets active to false', () async {
        // Arrange: Create authenticated session and subscription
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final subscription = await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession,
          endpoint: 'https://ntfy.sh/test123',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );

        // Act: Disable subscription
        final updated = await endpoints.pushSubscription.updateSubscription(
          authenticatedSession,
          subscription.id!,
          active: false,
        );

        // Assert
        expect(updated.active, false);
        expect(updated.id, subscription.id);
      });

      test('when updating another user subscription then throws', () async {
        // Arrange: Create two users
        final authenticatedSession1 = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );
        final authenticatedSession2 = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(2, {}),
        );

        // User 1 creates subscription
        final subscription = await endpoints.pushSubscription.registerEndpoint(
          authenticatedSession1,
          endpoint: 'https://ntfy.sh/user1-device',
          subscriptionType: 'unifiedpush',
          deviceId: 'device-1',
        );

        // Act & Assert: User 2 tries to update User 1's subscription
        expect(
          () => endpoints.pushSubscription.updateSubscription(
            authenticatedSession2,
            subscription.id!,
            active: false,
          ),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
