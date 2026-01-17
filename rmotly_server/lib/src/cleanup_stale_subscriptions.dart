import 'package:serverpod/serverpod.dart';
import 'package:rmotly_server/src/generated/protocol.dart';
import 'package:rmotly_server/src/services/subscription_manager_service.dart';

/// Future call for cleaning up stale push subscriptions.
///
/// This task runs periodically to remove subscriptions that haven't been
/// used in the defined stale threshold (default: 30 days).
///
/// Stale subscriptions can occur when:
/// - User uninstalls the app without proper cleanup
/// - Device is permanently offline
/// - UnifiedPush distributor is uninstalled
/// - User switches devices without re-registering
///
/// The cleanup helps maintain database hygiene and reduces unnecessary
/// push delivery attempts.
class CleanupStaleSubscriptions extends FutureCall<Greeting> {
  final SubscriptionManagerService _subscriptionManager =
      SubscriptionManagerService();

  @override
  Future<void> invoke(Session session, Greeting? object) async {
    session.log(
      'Starting cleanup of stale push subscriptions',
      level: LogLevel.info,
    );

    try {
      final removedCount =
          await _subscriptionManager.cleanupStaleSubscriptions(session);

      if (removedCount > 0) {
        session.log(
          'Cleaned up $removedCount stale push subscription(s)',
          level: LogLevel.info,
        );
      } else {
        session.log(
          'No stale subscriptions found',
          level: LogLevel.debug,
        );
      }
    } catch (e, stackTrace) {
      session.log(
        'Failed to clean up stale subscriptions: $e',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}
