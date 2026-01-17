import 'package:rmotly_client/rmotly_client.dart';

/// Repository interface for managing NotificationTopic entities.
abstract class TopicRepository {
  /// Lists all notification topics for the current user.
  Future<List<NotificationTopic>> getTopics();

  /// Gets a specific notification topic by ID.
  Future<NotificationTopic?> getTopic(int topicId);

  /// Creates a new notification topic.
  Future<NotificationTopic> createTopic(NotificationTopic topic);

  /// Updates an existing notification topic.
  Future<NotificationTopic> updateTopic(NotificationTopic topic);

  /// Deletes a notification topic by ID.
  Future<bool> deleteTopic(int topicId);

  /// Toggles the enabled state of a topic.
  Future<NotificationTopic> toggleTopic(int topicId, bool enabled);

  /// Regenerates the API key for a notification topic.
  Future<NotificationTopic> regenerateApiKey(int topicId);

  /// Gets the webhook URL for a topic.
  String getWebhookUrl(int topicId);
}
