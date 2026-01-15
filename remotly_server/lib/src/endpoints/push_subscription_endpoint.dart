import 'package:serverpod/serverpod.dart';

import '../services/subscription_manager_service.dart';
import 'notification_stream_endpoint.dart' show AuthenticationException;

/// Endpoint for managing UnifiedPush/WebPush subscriptions.
///
/// This endpoint allows clients to register push endpoints (from UnifiedPush
/// distributors like ntfy, FCM, NextPush, etc.) and manage their subscriptions.
///
/// See docs/PUSH_NOTIFICATION_DESIGN.md for the complete architecture.
///
/// Usage:
/// ```dart
/// // Register a new push endpoint
/// final subscription = await client.pushSubscription.registerEndpoint(
///   endpoint: 'https://ntfy.sh/ABC123',
///   p256dh: 'base64-encoded-public-key',
///   authSecret: 'base64-encoded-auth-secret',
///   deliveryMethod: 'webpush',
/// );
///
/// // List all subscriptions
/// final subscriptions = await client.pushSubscription.listSubscriptions();
///
/// // Disable a subscription
/// await client.pushSubscription.updateSubscription(
///   subscriptionId: 1,
///   enabled: false,
/// );
/// ```
class PushSubscriptionEndpoint extends Endpoint {
  final SubscriptionManagerService _subscriptionManager =
      SubscriptionManagerService();

  /// Register a push endpoint (from UnifiedPush).
  ///
  /// When a Flutter client registers with a UnifiedPush distributor,
  /// it receives an endpoint URL. This method stores that endpoint
  /// so the server can send push notifications to it.
  ///
  /// [endpoint] - The push endpoint URL from the UnifiedPush distributor
  /// [p256dh] - Optional P-256 public key for WebPush encryption (base64url)
  /// [authSecret] - Optional authentication secret for WebPush (base64url)
  /// [deliveryMethod] - The delivery method: 'webpush', 'sse', or 'websocket'
  ///
  /// Returns the registered subscription information.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if deliveryMethod is invalid.
  Future<PushSubscriptionInfo> registerEndpoint(
    Session session, {
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated push subscription registration rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    // Validate endpoint
    if (endpoint.trim().isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    // Validate endpoint format
    try {
      final uri = Uri.parse(endpoint);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw ArgumentError('Endpoint must be a valid HTTP(S) URL');
      }
    } catch (e) {
      throw ArgumentError('Invalid endpoint URL: $e');
    }

    // Register the subscription
    session.log(
      'Registering push endpoint for user $userId: $deliveryMethod',
      level: LogLevel.info,
    );

    return await _subscriptionManager.registerSubscription(
      session,
      userId: userId,
      endpoint: endpoint,
      p256dh: p256dh,
      authSecret: authSecret,
      deliveryMethod: deliveryMethod,
    );
  }

  /// Unregister a push endpoint.
  ///
  /// Removes the specified endpoint from the user's subscriptions.
  /// This should be called when:
  /// - User explicitly disables push notifications
  /// - UnifiedPush distributor is uninstalled
  /// - Endpoint becomes invalid
  ///
  /// [endpoint] - The endpoint URL to unregister
  ///
  /// Returns true if the endpoint was found and removed, false otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<bool> unregisterEndpoint(Session session, String endpoint) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated push subscription unregistration rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    if (endpoint.trim().isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    session.log(
      'Unregistering push endpoint for user $userId',
      level: LogLevel.info,
    );

    return await _subscriptionManager.unregisterSubscription(
      session,
      userId: userId,
      endpoint: endpoint,
    );
  }

  /// List subscriptions for the current user.
  ///
  /// Returns all push subscriptions (both active and disabled)
  /// for the authenticated user.
  ///
  /// Returns an empty list if the user has no subscriptions.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<List<PushSubscriptionInfo>> listSubscriptions(Session session) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated subscription list request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    session.log(
      'Listing subscriptions for user $userId',
      level: LogLevel.debug,
    );

    return await _subscriptionManager.getAllSubscriptions(session, userId);
  }

  /// Update a subscription (enable/disable).
  ///
  /// Allows toggling subscriptions on/off without removing them.
  /// Useful for temporary notification silencing.
  ///
  /// [subscriptionId] - The ID of the subscription to update
  /// [enabled] - Whether the subscription should be enabled
  ///
  /// Returns the updated subscription information.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the subscription doesn't exist or belongs to another user.
  Future<PushSubscriptionInfo> updateSubscription(
    Session session,
    int subscriptionId, {
    bool? enabled,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated subscription update rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    if (enabled == null) {
      throw ArgumentError('At least one parameter must be provided to update');
    }

    session.log(
      'Updating subscription $subscriptionId for user $userId',
      level: LogLevel.info,
    );

    // TODO: This requires the PushSubscription model to be generated.
    // For now, we'll verify the subscription exists and belongs to the user,
    // then perform the update.
    //
    // The implementation will be similar to:
    // 1. Fetch subscription by ID
    // 2. Verify it belongs to the authenticated user
    // 3. Update the enabled field
    // 4. Save and return
    //
    // Once the PushSubscription model is generated, uncomment:
    //
    // final subscription = await PushSubscription.db.findById(
    //   session,
    //   subscriptionId,
    // );
    //
    // if (subscription == null) {
    //   throw StateError('Subscription not found: $subscriptionId');
    // }
    //
    // if (subscription.userId != userId) {
    //   session.log(
    //     'User $userId attempted to update subscription $subscriptionId '
    //     'belonging to user ${subscription.userId}',
    //     level: LogLevel.warning,
    //   );
    //   throw StateError('Subscription not found: $subscriptionId');
    // }
    //
    // if (enabled != null) {
    //   subscription.enabled = enabled;
    // }
    // subscription.updatedAt = DateTime.now();
    //
    // await PushSubscription.db.updateRow(session, subscription);
    //
    // return PushSubscriptionInfo(
    //   id: subscription.id!,
    //   userId: subscription.userId,
    //   endpoint: subscription.endpoint,
    //   p256dh: subscription.p256dh,
    //   authSecret: subscription.authSecret,
    //   deliveryMethod: subscription.deliveryMethod,
    //   enabled: subscription.enabled,
    //   lastUsed: subscription.lastUsed,
    //   failureCount: subscription.failureCount,
    //   createdAt: subscription.createdAt,
    //   updatedAt: subscription.updatedAt,
    // );

    // Placeholder implementation until model is generated
    throw StateError(
      'updateSubscription requires PushSubscription model to be generated. '
      'Create lib/src/models/push_subscription.yaml and run serverpod generate.',
    );
  }
}
