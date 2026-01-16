import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../generated/protocol.dart';

/// Endpoint for managing notification topics and sending notifications.
///
/// Notification topics are used to receive external webhooks and route
/// notifications to users. Each topic has a unique API key for authentication.
class NotificationEndpoint extends Endpoint {
  final _uuid = const Uuid();

  /// Create a new notification topic.
  ///
  /// Generates a unique API key for webhook authentication.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [name]: Display name for the topic
  /// - [description]: Optional description
  /// - [config]: Optional configuration as JSON string
  ///
  /// Returns: The created [NotificationTopic] with generated API key.
  Future<NotificationTopic> createTopic(
    Session session, {
    required String name,
    String? description,
    String? config,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('name cannot be empty');
    }

    // Generate API key
    final apiKey = _generateApiKey();

    // Create the topic
    final topic = NotificationTopic(
      userId: userId,
      name: name.trim(),
      description: description?.trim(),
      apiKey: apiKey,
      enabled: true,
      config: config ?? '{}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final savedTopic = await NotificationTopic.db.insertRow(session, topic);

    session.log(
      'Topic created: ${savedTopic.id} - ${savedTopic.name}',
      level: LogLevel.info,
    );

    return savedTopic;
  }

  /// List all notification topics for the authenticated user.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [includeDisabled]: Include disabled topics (default: false)
  ///
  /// Returns: List of [NotificationTopic] objects.
  Future<List<NotificationTopic>> listTopics(
    Session session, {
    bool includeDisabled = false,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    final topics = await NotificationTopic.db.find(
      session,
      where: (t) {
        var condition = t.userId.equals(userId);
        if (!includeDisabled) {
          condition = condition & t.enabled.equals(true);
        }
        return condition;
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    return topics;
  }

  /// Get a specific notification topic by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to retrieve
  ///
  /// Returns: The [NotificationTopic] if found and owned by user.
  Future<NotificationTopic> getTopic(
    Session session, {
    required int topicId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    final topic = await NotificationTopic.db.findById(session, topicId);
    if (topic == null) {
      throw ArgumentError('Topic not found: $topicId');
    }

    // Verify ownership
    if (topic.userId != userId) {
      throw ArgumentError('Topic not found: $topicId');
    }

    return topic;
  }

  /// Update an existing notification topic.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to update
  /// - [name]: New name (optional)
  /// - [description]: New description (optional)
  /// - [enabled]: New enabled state (optional)
  /// - [config]: New configuration (optional)
  ///
  /// Returns: The updated [NotificationTopic].
  Future<NotificationTopic> updateTopic(
    Session session, {
    required int topicId,
    String? name,
    String? description,
    bool? enabled,
    String? config,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Fetch the topic
    final topic = await NotificationTopic.db.findById(session, topicId);
    if (topic == null) {
      throw ArgumentError('Topic not found: $topicId');
    }

    // Verify ownership
    if (topic.userId != userId) {
      throw ArgumentError('Topic not found: $topicId');
    }

    // Update fields
    if (name != null && name.trim().isNotEmpty) {
      topic.name = name.trim();
    }
    if (description != null) {
      topic.description = description.trim().isEmpty ? null : description.trim();
    }
    if (enabled != null) {
      topic.enabled = enabled;
    }
    if (config != null) {
      topic.config = config;
    }
    topic.updatedAt = DateTime.now();

    final updatedTopic = await NotificationTopic.db.updateRow(session, topic);

    session.log(
      'Topic updated: ${updatedTopic.id}',
      level: LogLevel.info,
    );

    return updatedTopic;
  }

  /// Delete a notification topic.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to delete
  ///
  /// Returns: True if the topic was deleted.
  Future<bool> deleteTopic(
    Session session, {
    required int topicId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Fetch the topic
    final topic = await NotificationTopic.db.findById(session, topicId);
    if (topic == null) {
      return false;
    }

    // Verify ownership
    if (topic.userId != userId) {
      return false;
    }

    // Delete the topic
    await NotificationTopic.db.deleteRow(session, topic);

    session.log(
      'Topic deleted: $topicId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Regenerate the API key for a topic.
  ///
  /// The old API key will immediately stop working.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic
  ///
  /// Returns: The [NotificationTopic] with new API key.
  Future<NotificationTopic> regenerateApiKey(
    Session session, {
    required int topicId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Fetch the topic
    final topic = await NotificationTopic.db.findById(session, topicId);
    if (topic == null) {
      throw ArgumentError('Topic not found: $topicId');
    }

    // Verify ownership
    if (topic.userId != userId) {
      throw ArgumentError('Topic not found: $topicId');
    }

    // Generate new API key
    topic.apiKey = _generateApiKey();
    topic.updatedAt = DateTime.now();

    final updatedTopic = await NotificationTopic.db.updateRow(session, topic);

    session.log(
      'API key regenerated for topic: $topicId',
      level: LogLevel.info,
    );

    return updatedTopic;
  }

  /// Send a notification to a specific user.
  ///
  /// This is for internal use (e.g., system notifications).
  /// External notifications should come through the webhook endpoint.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [title]: Notification title
  /// - [body]: Notification body
  /// - [payload]: Optional additional data as JSON string
  /// - [priority]: Notification priority (low, normal, high, urgent)
  ///
  /// Returns: True if the notification was queued for delivery.
  Future<bool> sendNotification(
    Session session, {
    required String title,
    required String body,
    String? payload,
    String priority = 'normal',
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Validate priority
    const validPriorities = ['low', 'normal', 'high', 'urgent'];
    if (!validPriorities.contains(priority)) {
      throw ArgumentError(
        'priority must be one of: ${validPriorities.join(', ')}',
      );
    }

    // Queue the notification
    final queueEntry = NotificationQueue(
      userId: userId,
      subscriptionId: null, // Will be populated for each subscription during delivery
      title: title,
      body: body,
      payload: payload,
      priority: priority,
      status: 'pending',
      deliveryTier: null,
      attemptCount: 0,
      maxAttempts: 3,
      lastError: null,
      createdAt: DateTime.now(),
      scheduledAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      deliveredAt: null,
    );

    await NotificationQueue.db.insertRow(session, queueEntry);

    session.log(
      'Notification queued for user $userId: $title',
      level: LogLevel.info,
    );

    return true;
  }

  /// Generate a secure API key.
  String _generateApiKey() {
    final uuid = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = '$uuid:$timestamp';
    final hash = sha256.convert(utf8.encode(combined)).toString();
    return 'rmotly_${hash.substring(0, 32)}';
  }
}

/// Exception thrown when authentication fails
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
