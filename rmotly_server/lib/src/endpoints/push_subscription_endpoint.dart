import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
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
  /// [subscriptionType] - The subscription type: 'unifiedpush' or 'webpush'
  /// [deviceId] - Unique identifier for the device
  /// [userAgent] - Optional user agent string
  ///
  /// Returns the registered subscription.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if subscriptionType is invalid.
  Future<PushSubscription> registerEndpoint(
    Session session, {
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String subscriptionType,
    required String deviceId,
    String? userAgent,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated push subscription registration rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

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

    if (deviceId.trim().isEmpty) {
      throw ArgumentError('Device ID cannot be empty');
    }

    // Register the subscription
    session.log(
      'Registering push endpoint for user $userId device $deviceId: $subscriptionType',
      level: LogLevel.info,
    );

    return await _subscriptionManager.registerSubscription(
      session,
      userId: userId,
      endpoint: endpoint,
      p256dh: p256dh,
      authSecret: authSecret,
      subscriptionType: subscriptionType,
      deviceId: deviceId,
      userAgent: userAgent,
    );
  }

  /// Unregister a push endpoint.
  ///
  /// Removes the specified device's endpoint from the user's subscriptions.
  /// This should be called when:
  /// - User explicitly disables push notifications
  /// - UnifiedPush distributor is uninstalled
  /// - Endpoint becomes invalid
  ///
  /// [deviceId] - The device ID to unregister
  ///
  /// Returns true if the endpoint was found and removed, false otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<bool> unregisterEndpoint(Session session, String deviceId) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated push subscription unregistration rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    if (deviceId.trim().isEmpty) {
      throw ArgumentError('Device ID cannot be empty');
    }

    session.log(
      'Unregistering push endpoint for user $userId device $deviceId',
      level: LogLevel.info,
    );

    return await _subscriptionManager.unregisterSubscription(
      session,
      userId: userId,
      deviceId: deviceId,
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
  Future<List<PushSubscription>> listSubscriptions(Session session) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated subscription list request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

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
  /// [active] - Whether the subscription should be active
  ///
  /// Returns the updated subscription.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the subscription doesn't exist or belongs to another user.
  Future<PushSubscription> updateSubscription(
    Session session,
    int subscriptionId, {
    bool? active,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated subscription update rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    if (active == null) {
      throw ArgumentError('At least one parameter must be provided to update');
    }

    session.log(
      'Updating subscription $subscriptionId for user $userId',
      level: LogLevel.info,
    );

    // Fetch subscription by ID
    final subscription = await PushSubscription.db.findById(
      session,
      subscriptionId,
    );

    if (subscription == null) {
      throw StateError('Subscription not found: $subscriptionId');
    }

    // Verify it belongs to the authenticated user
    if (subscription.userId != userId) {
      session.log(
        'User $userId attempted to update subscription $subscriptionId '
        'belonging to user ${subscription.userId}',
        level: LogLevel.warning,
      );
      throw StateError('Subscription not found: $subscriptionId');
    }

    // Update the active field
    subscription.active = active;
    subscription.updatedAt = DateTime.now();

    // Save and return
    return await PushSubscription.db.updateRow(session, subscription);
  }
}
