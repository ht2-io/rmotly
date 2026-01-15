import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/api_key_service.dart';

/// Custom exception for authentication failures
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Endpoint for managing notification topics.
///
/// This endpoint provides CRUD operations for notification topics,
/// which are used to receive external webhook notifications.
///
/// All methods require authentication and will throw [AuthenticationException]
/// if the user is not authenticated.
class NotificationEndpoint extends Endpoint {
  final ApiKeyService _apiKeyService = ApiKeyService();

  /// Create a notification topic.
  ///
  /// Creates a new topic for receiving webhook notifications.
  /// Automatically generates a secure API key for the topic.
  ///
  /// [name] - Display name for the topic (required)
  /// [description] - Optional description of what notifications this topic receives
  /// [config] - Optional JSON configuration string (defaults to '{}')
  ///
  /// Returns the created [NotificationTopic] with generated API key.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if name is empty.
  Future<NotificationTopic> createTopic(
    Session session, {
    required String name,
    String? description,
    String? config,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated topic creation request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('Topic name cannot be empty');
    }

    // Generate API key
    final apiKey = _apiKeyService.generateApiKey();

    // Create topic
    final now = DateTime.now();
    final topic = NotificationTopic(
      userId: userId,
      name: name.trim(),
      description: description?.trim(),
      apiKey: apiKey,
      enabled: true,
      config: config ?? '{}',
      createdAt: now,
      updatedAt: now,
    );

    // Save to database
    final savedTopic = await NotificationTopic.db.insertRow(session, topic);

    session.log(
      'Created notification topic ${savedTopic.id} for user $userId',
      level: LogLevel.info,
    );

    return savedTopic;
  }

  /// List topics for current user.
  ///
  /// Returns all notification topics owned by the authenticated user,
  /// ordered by creation date (newest first).
  ///
  /// Returns an empty list if the user has no topics.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<List<NotificationTopic>> listTopics(Session session) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated topic list request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Listing topics for user $userId',
      level: LogLevel.debug,
    );

    // Query topics for user
    final topics = await NotificationTopic.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    return topics;
  }

  /// Get topic by ID.
  ///
  /// Returns the topic if it exists and belongs to the authenticated user.
  ///
  /// [topicId] - The ID of the topic to retrieve
  ///
  /// Returns the [NotificationTopic] if found, null otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<NotificationTopic?> getTopic(Session session, int topicId) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated topic get request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Getting topic $topicId for user $userId',
      level: LogLevel.debug,
    );

    // Find topic
    final topic = await NotificationTopic.db.findById(session, topicId);

    // Verify ownership
    if (topic != null && topic.userId != userId) {
      session.log(
        'User $userId attempted to access topic $topicId '
        'belonging to user ${topic.userId}',
        level: LogLevel.warning,
      );
      return null;
    }

    return topic;
  }

  /// Update topic.
  ///
  /// Updates an existing topic. Only the provided fields will be updated.
  ///
  /// [topicId] - The ID of the topic to update
  /// [name] - Optional new name for the topic
  /// [description] - Optional new description (pass empty string to clear)
  /// [config] - Optional new JSON configuration string
  /// [enabled] - Optional enabled status
  ///
  /// Returns the updated [NotificationTopic].
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the topic doesn't exist or belongs to another user.
  /// Throws [ArgumentError] if name is provided but empty.
  Future<NotificationTopic> updateTopic(
    Session session,
    int topicId, {
    String? name,
    String? description,
    String? config,
    bool? enabled,
  }) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated topic update request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Validate at least one parameter is provided
    if (name == null && description == null && config == null && enabled == null) {
      throw ArgumentError('At least one parameter must be provided to update');
    }

    // Validate name if provided
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Topic name cannot be empty');
    }

    // Find topic
    final topic = await NotificationTopic.db.findById(session, topicId);

    if (topic == null) {
      throw StateError('Topic not found: $topicId');
    }

    // Verify ownership
    if (topic.userId != userId) {
      session.log(
        'User $userId attempted to update topic $topicId '
        'belonging to user ${topic.userId}',
        level: LogLevel.warning,
      );
      throw StateError('Topic not found: $topicId');
    }

    // Update fields
    if (name != null) {
      topic.name = name.trim();
    }
    if (description != null) {
      topic.description = description.trim().isEmpty ? null : description.trim();
    }
    if (config != null) {
      topic.config = config;
    }
    if (enabled != null) {
      topic.enabled = enabled;
    }
    topic.updatedAt = DateTime.now();

    // Save to database
    await NotificationTopic.db.updateRow(session, topic);

    session.log(
      'Updated topic $topicId for user $userId',
      level: LogLevel.info,
    );

    return topic;
  }

  /// Delete topic.
  ///
  /// Deletes a notification topic permanently.
  ///
  /// [topicId] - The ID of the topic to delete
  ///
  /// Returns true if the topic was deleted, false if it didn't exist.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<bool> deleteTopic(Session session, int topicId) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated topic delete request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Find topic
    final topic = await NotificationTopic.db.findById(session, topicId);

    if (topic == null) {
      return false;
    }

    // Verify ownership
    if (topic.userId != userId) {
      session.log(
        'User $userId attempted to delete topic $topicId '
        'belonging to user ${topic.userId}',
        level: LogLevel.warning,
      );
      return false;
    }

    // Delete from database
    await NotificationTopic.db.deleteRow(session, topic);

    session.log(
      'Deleted topic $topicId for user $userId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Regenerate API key for topic.
  ///
  /// Generates a new API key for the topic, invalidating the old one.
  /// This is useful if the key has been compromised.
  ///
  /// [topicId] - The ID of the topic to regenerate the key for
  ///
  /// Returns the new API key.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the topic doesn't exist or belongs to another user.
  Future<String> regenerateApiKey(Session session, int topicId) async {
    // Authenticate user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated API key regeneration request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Find topic
    final topic = await NotificationTopic.db.findById(session, topicId);

    if (topic == null) {
      throw StateError('Topic not found: $topicId');
    }

    // Verify ownership
    if (topic.userId != userId) {
      session.log(
        'User $userId attempted to regenerate API key for topic $topicId '
        'belonging to user ${topic.userId}',
        level: LogLevel.warning,
      );
      throw StateError('Topic not found: $topicId');
    }

    // Generate new API key
    final newApiKey = _apiKeyService.generateApiKey();
    topic.apiKey = newApiKey;
    topic.updatedAt = DateTime.now();

    // Save to database
    await NotificationTopic.db.updateRow(session, topic);

    session.log(
      'Regenerated API key for topic $topicId for user $userId',
      level: LogLevel.info,
    );

    return newApiKey;
  }
}
