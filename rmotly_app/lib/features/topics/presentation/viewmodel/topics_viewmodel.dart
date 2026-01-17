import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../domain/repositories/topic_repository.dart';
import '../state/topics_state.dart';

/// View model for the topics feature
class TopicsViewModel extends StateNotifier<TopicsState> {
  final TopicRepository? _repository;

  TopicsViewModel(TopicRepository repository)
      : _repository = repository,
        super(TopicsState.initial) {
    loadTopics();
  }

  /// Create a view model with an initial error state (e.g., server not configured)
  TopicsViewModel.withError(String error)
      : _repository = null,
        super(TopicsState(error: error));

  /// Load topics from the repository
  Future<void> loadTopics() async {
    if (_repository == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final topics = await _repository.getTopics();
      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to load topics: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load topics: $e',
      );
    }
  }

  /// Refresh topics (pull-to-refresh)
  Future<void> refreshTopics() async {
    if (_repository == null || state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final topics = await _repository.getTopics();
      state = state.copyWith(
        topics: topics,
        isRefreshing: false,
      );
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to refresh topics: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh topics',
      );
    }
  }

  /// Create a new topic
  Future<NotificationTopic?> createTopic(NotificationTopic topic) async {
    if (_repository == null) return null;

    try {
      final created = await _repository.createTopic(topic);

      // Add to local state
      state = state.copyWith(
        topics: [...state.topics, created],
      );

      return created;
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to create topic: $e');
      state = state.copyWith(error: 'Failed to create topic');
      return null;
    }
  }

  /// Update an existing topic
  Future<NotificationTopic?> updateTopic(NotificationTopic topic) async {
    if (_repository == null) return null;

    try {
      final updated = await _repository.updateTopic(topic);

      // Update in local state
      final topics = state.topics.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      state = state.copyWith(topics: topics);

      return updated;
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to update topic: $e');
      state = state.copyWith(error: 'Failed to update topic');
      return null;
    }
  }

  /// Delete a topic
  Future<void> deleteTopic(int topicId) async {
    if (_repository == null) return;

    try {
      final success = await _repository.deleteTopic(topicId);

      if (success) {
        // Remove from local state
        final topics = state.topics.where((t) => t.id != topicId).toList();
        state = state.copyWith(topics: topics);
      }
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to delete topic: $e');
      state = state.copyWith(error: 'Failed to delete topic');
    }
  }

  /// Toggle a topic's enabled state
  Future<void> toggleTopic(int topicId, bool enabled) async {
    if (_repository == null) return;

    state = state.copyWith(togglingTopicId: topicId);

    try {
      final updated = await _repository.toggleTopic(topicId, enabled);

      // Update in local state
      final topics = state.topics.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      state = state.copyWith(
        topics: topics,
        clearTogglingTopic: true,
      );
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to toggle topic: $e');
      state = state.copyWith(
        clearTogglingTopic: true,
        error: 'Failed to toggle topic',
      );
    }
  }

  /// Regenerate API key for a topic
  Future<NotificationTopic?> regenerateApiKey(int topicId) async {
    if (_repository == null) return null;

    state = state.copyWith(regeneratingTopicId: topicId);

    try {
      final updated = await _repository.regenerateApiKey(topicId);

      // Update in local state
      final topics = state.topics.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      state = state.copyWith(
        topics: topics,
        clearRegeneratingTopic: true,
      );

      return updated;
    } catch (e) {
      debugPrint('TopicsViewModel: Failed to regenerate API key: $e');
      state = state.copyWith(
        clearRegeneratingTopic: true,
        error: 'Failed to regenerate API key',
      );
      return null;
    }
  }

  /// Get webhook URL for a topic
  String getWebhookUrl(int topicId) {
    return _repository?.getWebhookUrl(topicId) ?? '';
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
