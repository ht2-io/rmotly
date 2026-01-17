import 'package:rmotly_client/rmotly_client.dart';
import '../services/error_handler_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

/// Repository for managing NotificationTopic entities.
///
/// Provides methods for CRUD operations on notification topics.
/// Includes offline caching and error handling.
class TopicRepository {
  final Client _client;
  final ErrorHandlerService _errorHandler;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivityService;

  TopicRepository(
    this._client,
    this._errorHandler,
    this._localStorage,
    this._connectivityService,
  );

  /// Lists all notification topics for the current user.
  ///
  /// Returns a list of [NotificationTopic] objects.
  /// If offline, returns cached topics.
  /// Throws an exception if the operation fails and no cache is available.
  Future<List<NotificationTopic>> listTopics() async {
    try {
      // TODO: Implement once NotificationEndpoint is available
      // final topics = await _client.notification.listTopics();
      //
      // // Cache the topics
      // await _localStorage.cacheTopics(topics);
      //
      // return topics;
      throw UnimplementedError(
          'NotificationEndpoint not yet implemented in Serverpod');
    } catch (error) {
      // If offline or error, try to return cached data
      if (!_connectivityService.isOnline || _errorHandler.isRetryable(error)) {
        try {
          final cachedTopics = await _localStorage.getCachedTopics();
          if (cachedTopics.isNotEmpty) {
            return cachedTopics;
          }
        } catch (_) {
          // Cache read failed, fall through to error handling
        }
      }

      // Map error to AppException
      throw _errorHandler.mapToAppException(error);
    }
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
    throw UnimplementedError(
        'NotificationEndpoint not yet implemented in Serverpod');
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
    throw UnimplementedError(
        'NotificationEndpoint not yet implemented in Serverpod');
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
    throw UnimplementedError(
        'NotificationEndpoint not yet implemented in Serverpod');
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
    throw UnimplementedError(
        'NotificationEndpoint not yet implemented in Serverpod');
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
    throw UnimplementedError(
        'NotificationEndpoint not yet implemented in Serverpod');
  }
}
