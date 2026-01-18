import 'package:serverpod/serverpod.dart';
import 'package:rmotly_server/src/generated/protocol.dart';

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
  Future<PushSubscription> registerSubscription(
    Session session, {
    required int userId,
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String subscriptionType,
    required String deviceId,
    String? userAgent,
  }) async {
    // Validate subscription type
    const validTypes = ['unifiedpush', 'webpush'];
    if (!validTypes.contains(subscriptionType)) {
      throw ArgumentError(
        'Invalid subscription type: $subscriptionType. '
        'Must be one of: ${validTypes.join(', ')}',
      );
    }

    // Check if subscription already exists for this device
    final existing = await PushSubscription.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.deviceId.equals(deviceId),
    );

    if (existing != null) {
      // Update existing subscription
      existing.endpoint = endpoint;
      existing.p256dh = p256dh;
      existing.auth = authSecret;
      existing.subscriptionType = subscriptionType;
      existing.userAgent = userAgent;
      existing.active = true;
      existing.failureCount = 0; // Reset failures on re-registration
      existing.updatedAt = DateTime.now();

      final updated = await PushSubscription.db.updateRow(session, existing);

      session.log(
        'Updated push subscription for user $userId device $deviceId',
        level: LogLevel.info,
      );

      return updated;
    }

    // Create new subscription
    final now = DateTime.now();
    final subscription = PushSubscription(
      userId: userId,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: authSecret,
      subscriptionType: subscriptionType,
      deviceId: deviceId,
      userAgent: userAgent,
      active: true,
      lastUsedAt: null,
      failureCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await PushSubscription.db.insertRow(session, subscription);

    session.log(
      'Registered push subscription for user $userId device $deviceId: $endpoint',
      level: LogLevel.info,
    );

    return saved;
  }

  /// Handle endpoint rotation (UnifiedPush distributor change)
  ///
  /// When a user switches UnifiedPush distributors, the endpoint URL changes.
  /// This method handles the transition.
  Future<PushSubscription?> rotateEndpoint(
    Session session, {
    required int userId,
    required String deviceId,
    required String newEndpoint,
    String? p256dh,
    String? authSecret,
  }) async {
    // Find the subscription for this device
    final existing = await PushSubscription.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.deviceId.equals(deviceId),
    );

    if (existing == null) {
      session.log(
        'Endpoint rotation failed: subscription for device $deviceId not found',
        level: LogLevel.warning,
      );
      return null;
    }

    // Update to new endpoint
    existing.endpoint = newEndpoint;
    if (p256dh != null) existing.p256dh = p256dh;
    if (authSecret != null) existing.auth = authSecret;
    existing.updatedAt = DateTime.now();
    existing.failureCount = 0; // Reset failures

    final updated = await PushSubscription.db.updateRow(session, existing);

    session.log(
      'Rotated endpoint for user $userId device $deviceId: $newEndpoint',
      level: LogLevel.info,
    );

    return updated;
  }

  /// Unregister a subscription
  Future<bool> unregisterSubscription(
    Session session, {
    required int userId,
    required String deviceId,
  }) async {
    final subscription = await PushSubscription.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.deviceId.equals(deviceId),
    );

    if (subscription == null) {
      return false;
    }

    await PushSubscription.db.deleteRow(session, subscription);

    session.log(
      'Unregistered subscription for user $userId device $deviceId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Get all active subscriptions for a user
  Future<List<PushSubscription>> getActiveSubscriptions(
    Session session,
    int userId,
  ) async {
    return await PushSubscription.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.active.equals(true),
    );
  }

  /// Get all subscriptions for a user (including disabled)
  Future<List<PushSubscription>> getAllSubscriptions(
    Session session,
    int userId,
  ) async {
    return await PushSubscription.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }

  /// Mark a subscription as used
  Future<void> markUsed(Session session, int subscriptionId) async {
    final subscription =
        await PushSubscription.db.findById(session, subscriptionId);
    if (subscription != null) {
      subscription.lastUsedAt = DateTime.now();
      await PushSubscription.db.updateRow(session, subscription);
    }
  }

  /// Record a delivery failure
  ///
  /// Increments the failure count. If it exceeds maxFailures,
  /// the subscription is disabled.
  Future<void> recordFailure(Session session, int subscriptionId) async {
    final subscription =
        await PushSubscription.db.findById(session, subscriptionId);
    if (subscription != null) {
      subscription.failureCount++;
      if (subscription.failureCount >= maxFailures) {
        subscription.active = false;
        session.log(
          'Subscription $subscriptionId disabled after $maxFailures failures',
          level: LogLevel.warning,
        );
      }
      subscription.updatedAt = DateTime.now();
      await PushSubscription.db.updateRow(session, subscription);
    }
  }

  /// Reset failure count after successful delivery
  Future<void> resetFailures(Session session, int subscriptionId) async {
    final subscription =
        await PushSubscription.db.findById(session, subscriptionId);
    if (subscription != null && subscription.failureCount > 0) {
      subscription.failureCount = 0;
      subscription.updatedAt = DateTime.now();
      await PushSubscription.db.updateRow(session, subscription);
    }
  }

  /// Clean up stale subscriptions
  ///
  /// Removes subscriptions that haven't been used in [staleThreshold].
  /// Returns the number of subscriptions removed.
  Future<int> cleanupStaleSubscriptions(Session session) async {
    final cutoff = DateTime.now().subtract(staleThreshold);

    // Find stale subscriptions where lastUsedAt is not null and before cutoff
    final stale = await PushSubscription.db.find(
      session,
      where: (t) => t.lastUsedAt.notEquals(null) & (t.lastUsedAt < cutoff),
    );

    // Delete them
    for (final subscription in stale) {
      await PushSubscription.db.deleteRow(session, subscription);
    }

    if (stale.isNotEmpty) {
      session.log(
        'Cleaned up ${stale.length} stale subscriptions',
        level: LogLevel.info,
      );
    }

    return stale.length;
  }
}
