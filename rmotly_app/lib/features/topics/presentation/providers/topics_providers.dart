import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_client_provider.dart';
import '../../data/repositories/topic_repository_impl.dart';
import '../../domain/repositories/topic_repository.dart';
import '../state/topics_state.dart';
import '../viewmodel/topics_viewmodel.dart';

/// Provider for the topic repository implementation
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TopicRepositoryImpl(client);
});

/// Provider for the topics view model
final topicsViewModelProvider =
    StateNotifierProvider<TopicsViewModel, TopicsState>((ref) {
  final repository = ref.watch(topicRepositoryProvider);
  return TopicsViewModel(repository);
});

/// Provider for the list of topics
final topicsListProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(topicsViewModelProvider).topics;
});

/// Provider to check if topics are loading
final isTopicsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(topicsViewModelProvider).isLoading;
});

/// Provider for topics error
final topicsErrorProvider = Provider<String?>((ref) {
  return ref.watch(topicsViewModelProvider).error;
});
