import 'package:rmotly_client/rmotly_client.dart';

/// Repository for managing NotificationTopic entities.
///
/// Provides methods for CRUD operations on notification topics.
/// Once the Serverpod NotificationEndpoint is implemented, this repository
/// will communicate with the API to perform these operations.
class TopicRepository {
  final Client _client;

  TopicRepository(this._client);

  /// Lists all notification topics for the current user.
  ///
  /// Returns a list of [NotificationTopic] objects.
  /// Throws an exception if the operation fails.
  Future<List<NotificationTopic>> listTopics() async {
    // TODO: Implement once NotificationEndpoint is available
    // return await _client.notification.listTopics();
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }

  /// Gets a specific notification topic by ID.
  ///
  /// Parameters:
  /// - [topicId]: The ID of the topic to retrieve
  ///
  /// Returns the [NotificationTopic] object.
  /// Throws an exception if the topic is not found or operation fails.
  Future<NotificationTopic> getTopic(int topicId) async {
    // TODO: Implement once NotificationEndpoint is available
    // return await _client.notification.getTopic(topicId);
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }

  /// Creates a new notification topic.
  ///
  /// Parameters:
  /// - [topic]: The topic to create
  ///
  /// Returns the created [NotificationTopic] with its assigned ID and API key.
  /// Throws an exception if the operation fails.
  Future<NotificationTopic> createTopic(NotificationTopic topic) async {
    // TODO: Implement once NotificationEndpoint is available
    // return await _client.notification.createTopic(topic);
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }

  /// Updates an existing notification topic.
  ///
  /// Parameters:
  /// - [topic]: The topic with updated values
  ///
  /// Returns the updated [NotificationTopic].
  /// Throws an exception if the topic is not found or operation fails.
  Future<NotificationTopic> updateTopic(NotificationTopic topic) async {
    // TODO: Implement once NotificationEndpoint is available
    // return await _client.notification.updateTopic(topic);
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }

  /// Deletes a notification topic by ID.
  ///
  /// Parameters:
  /// - [topicId]: The ID of the topic to delete
  ///
  /// Throws an exception if the topic is not found or operation fails.
  Future<void> deleteTopic(int topicId) async {
    // TODO: Implement once NotificationEndpoint is available
    // await _client.notification.deleteTopic(topicId);
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }

  /// Regenerates the API key for a notification topic.
  ///
  /// Parameters:
  /// - [topicId]: The ID of the topic
  ///
  /// Returns the [NotificationTopic] with the new API key.
  /// Throws an exception if the topic is not found or operation fails.
  Future<NotificationTopic> regenerateApiKey(int topicId) async {
    // TODO: Implement once NotificationEndpoint is available
    // return await _client.notification.regenerateApiKey(topicId);
    throw UnimplementedError('NotificationEndpoint not yet implemented in Serverpod');
  }
}
