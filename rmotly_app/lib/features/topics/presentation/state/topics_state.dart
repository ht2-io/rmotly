import 'package:rmotly_client/rmotly_client.dart';

/// State for the topics feature
class TopicsState {
  final List<NotificationTopic> topics;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int? togglingTopicId;
  final int? regeneratingTopicId;

  const TopicsState({
    this.topics = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.togglingTopicId,
    this.regeneratingTopicId,
  });

  /// Initial state
  static const initial = TopicsState();

  /// Loading state
  static const loading = TopicsState(isLoading: true);

  TopicsState copyWith({
    List<NotificationTopic>? topics,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? togglingTopicId,
    int? regeneratingTopicId,
    bool clearError = false,
    bool clearTogglingTopic = false,
    bool clearRegeneratingTopic = false,
  }) {
    return TopicsState(
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      togglingTopicId:
          clearTogglingTopic ? null : (togglingTopicId ?? this.togglingTopicId),
      regeneratingTopicId: clearRegeneratingTopic
          ? null
          : (regeneratingTopicId ?? this.regeneratingTopicId),
    );
  }

  /// Check if a specific topic is being toggled
  bool isTopicToggling(int topicId) => togglingTopicId == topicId;

  /// Check if a specific topic's API key is being regenerated
  bool isTopicRegenerating(int topicId) => regeneratingTopicId == topicId;

  /// Get topic by ID
  NotificationTopic? getTopicById(int id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
