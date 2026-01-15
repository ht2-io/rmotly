import 'package:serverpod/serverpod.dart';

/// Push subscription data
class PushSubscriptionInfo {
  final int id;
  final int userId;
  final String endpoint;
  final String? p256dh;
  final String? authSecret;
  final String deliveryMethod;
  final bool enabled;
  final DateTime? lastUsed;
  final int failureCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PushSubscriptionInfo({
    required this.id,
    required this.userId,
    required this.endpoint,
    this.p256dh,
    this.authSecret,
    required this.deliveryMethod,
    required this.enabled,
    this.lastUsed,
    required this.failureCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get supportsEncryption => p256dh != null && authSecret != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'endpoint': endpoint,
        'deliveryMethod': deliveryMethod,
        'enabled': enabled,
        'lastUsed': lastUsed?.toIso8601String(),
        'failureCount': failureCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Service for managing push subscriptions.
///
/// Handles:
/// - Subscription registration and updates
/// - Endpoint rotation (when distributor changes)
/// - Stale subscription cleanup
/// - Failure tracking
class SubscriptionManagerService {
  /// Maximum failure count before disabling subscription
  static const maxFailures = 5;

  /// Duration after which unused subscriptions are considered stale
  static const staleThreshold = Duration(days: 30);

  /// Register or update a push subscription
  ///
  /// If the endpoint already exists for the user, updates the subscription.
  /// Otherwise, creates a new subscription.
  Future<PushSubscriptionInfo> registerSubscription(
    Session session, {
    required int userId,
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
  }) async {
    // Validate delivery method
    const validMethods = ['webpush', 'sse', 'websocket'];
    if (!validMethods.contains(deliveryMethod)) {
      throw ArgumentError(
        'Invalid delivery method: $deliveryMethod. '
        'Must be one of: ${validMethods.join(', ')}',
      );
    }

    // Check if subscription already exists
    final existing = await _findByEndpoint(session, userId, endpoint);
    if (existing != null) {
      // Update existing subscription
      return await _updateSubscription(
        session,
        existing.id,
        p256dh: p256dh,
        authSecret: authSecret,
        enabled: true,
        failureCount: 0, // Reset failures on re-registration
      );
    }

    // Create new subscription
    final now = DateTime.now();

    // TODO: Replace with actual model once generated
    // final subscription = PushSubscription(
    //   userId: userId,
    //   endpoint: endpoint,
    //   p256dh: p256dh,
    //   authSecret: authSecret,
    //   deliveryMethod: deliveryMethod,
    //   enabled: true,
    //   lastUsed: null,
    //   failureCount: 0,
    //   createdAt: now,
    //   updatedAt: now,
    // );
    // final saved = await PushSubscription.db.insertRow(session, subscription);

    session.log(
      'Registered push subscription for user $userId: $endpoint',
      level: LogLevel.info,
    );

    // Return placeholder until model is generated
    return PushSubscriptionInfo(
      id: 0,
      userId: userId,
      endpoint: endpoint,
      p256dh: p256dh,
      authSecret: authSecret,
      deliveryMethod: deliveryMethod,
      enabled: true,
      lastUsed: null,
      failureCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Handle endpoint rotation (UnifiedPush distributor change)
  ///
  /// When a user switches UnifiedPush distributors, the endpoint URL changes.
  /// This method handles the transition.
  Future<PushSubscriptionInfo?> rotateEndpoint(
    Session session, {
    required int userId,
    required String oldEndpoint,
    required String newEndpoint,
    String? p256dh,
    String? authSecret,
  }) async {
    // Find the old subscription
    final old = await _findByEndpoint(session, userId, oldEndpoint);
    if (old == null) {
      session.log(
        'Endpoint rotation failed: old endpoint not found',
        level: LogLevel.warning,
      );
      return null;
    }

    // Update to new endpoint
    // TODO: Replace with actual model update
    // old.endpoint = newEndpoint;
    // if (p256dh != null) old.p256dh = p256dh;
    // if (authSecret != null) old.authSecret = authSecret;
    // old.updatedAt = DateTime.now();
    // old.failureCount = 0; // Reset failures
    // await PushSubscription.db.updateRow(session, old);

    session.log(
      'Rotated endpoint for user $userId: $oldEndpoint -> $newEndpoint',
      level: LogLevel.info,
    );

    return PushSubscriptionInfo(
      id: old.id,
      userId: userId,
      endpoint: newEndpoint,
      p256dh: p256dh ?? old.p256dh,
      authSecret: authSecret ?? old.authSecret,
      deliveryMethod: old.deliveryMethod,
      enabled: old.enabled,
      lastUsed: old.lastUsed,
      failureCount: 0,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Unregister a subscription
  Future<bool> unregisterSubscription(
    Session session, {
    required int userId,
    required String endpoint,
  }) async {
    final subscription = await _findByEndpoint(session, userId, endpoint);
    if (subscription == null) {
      return false;
    }

    // TODO: Replace with actual model delete
    // await PushSubscription.db.deleteRow(session, subscription);

    session.log(
      'Unregistered subscription for user $userId: $endpoint',
      level: LogLevel.info,
    );

    return true;
  }

  /// Get all active subscriptions for a user
  Future<List<PushSubscriptionInfo>> getActiveSubscriptions(
    Session session,
    int userId,
  ) async {
    // TODO: Replace with actual model query
    // return await PushSubscription.db.find(
    //   session,
    //   where: (t) => t.userId.equals(userId) & t.enabled.equals(true),
    // );

    return [];
  }

  /// Get all subscriptions for a user (including disabled)
  Future<List<PushSubscriptionInfo>> getAllSubscriptions(
    Session session,
    int userId,
  ) async {
    // TODO: Replace with actual model query
    // return await PushSubscription.db.find(
    //   session,
    //   where: (t) => t.userId.equals(userId),
    // );

    return [];
  }

  /// Mark a subscription as used
  Future<void> markUsed(Session session, int subscriptionId) async {
    // TODO: Replace with actual model update
    // final subscription = await PushSubscription.db.findById(session, subscriptionId);
    // if (subscription != null) {
    //   subscription.lastUsed = DateTime.now();
    //   await PushSubscription.db.updateRow(session, subscription);
    // }
  }

  /// Record a delivery failure
  ///
  /// Increments the failure count. If it exceeds maxFailures,
  /// the subscription is disabled.
  Future<void> recordFailure(Session session, int subscriptionId) async {
    // TODO: Replace with actual model update
    // final subscription = await PushSubscription.db.findById(session, subscriptionId);
    // if (subscription != null) {
    //   subscription.failureCount++;
    //   if (subscription.failureCount >= maxFailures) {
    //     subscription.enabled = false;
    //     session.log(
    //       'Subscription $subscriptionId disabled after $maxFailures failures',
    //       level: LogLevel.warning,
    //     );
    //   }
    //   subscription.updatedAt = DateTime.now();
    //   await PushSubscription.db.updateRow(session, subscription);
    // }
  }

  /// Reset failure count after successful delivery
  Future<void> resetFailures(Session session, int subscriptionId) async {
    // TODO: Replace with actual model update
    // final subscription = await PushSubscription.db.findById(session, subscriptionId);
    // if (subscription != null && subscription.failureCount > 0) {
    //   subscription.failureCount = 0;
    //   subscription.updatedAt = DateTime.now();
    //   await PushSubscription.db.updateRow(session, subscription);
    // }
  }

  /// Clean up stale subscriptions
  ///
  /// Removes subscriptions that haven't been used in [staleThreshold].
  /// Returns the number of subscriptions removed.
  Future<int> cleanupStaleSubscriptions(Session session) async {
    final cutoff = DateTime.now().subtract(staleThreshold);

    // TODO: Replace with actual model query and delete
    // final stale = await PushSubscription.db.find(
    //   session,
    //   where: (t) =>
    //       t.lastUsed.notEquals(null) & t.lastUsed.lessThan(cutoff),
    // );
    //
    // for (final subscription in stale) {
    //   await PushSubscription.db.deleteRow(session, subscription);
    // }
    //
    // if (stale.isNotEmpty) {
    //   session.log(
    //     'Cleaned up ${stale.length} stale subscriptions',
    //     level: LogLevel.info,
    //   );
    // }
    //
    // return stale.length;

    return 0;
  }

  /// Find subscription by endpoint
  Future<PushSubscriptionInfo?> _findByEndpoint(
    Session session,
    int userId,
    String endpoint,
  ) async {
    // TODO: Replace with actual model query
    // return await PushSubscription.db.findFirstRow(
    //   session,
    //   where: (t) => t.userId.equals(userId) & t.endpoint.equals(endpoint),
    // );

    return null;
  }

  /// Update a subscription
  Future<PushSubscriptionInfo> _updateSubscription(
    Session session,
    int id, {
    String? p256dh,
    String? authSecret,
    bool? enabled,
    int? failureCount,
  }) async {
    // TODO: Replace with actual model update
    // final subscription = await PushSubscription.db.findById(session, id);
    // if (subscription == null) {
    //   throw StateError('Subscription not found: $id');
    // }
    //
    // if (p256dh != null) subscription.p256dh = p256dh;
    // if (authSecret != null) subscription.authSecret = authSecret;
    // if (enabled != null) subscription.enabled = enabled;
    // if (failureCount != null) subscription.failureCount = failureCount;
    // subscription.updatedAt = DateTime.now();
    //
    // await PushSubscription.db.updateRow(session, subscription);
    // return subscription;

    throw StateError('Not implemented');
  }
}
