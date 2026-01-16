import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_app/core/providers/api_client_provider.dart';
import 'package:rmotly_app/core/repositories/repositories.dart';

/// Provider for the ControlRepository.
///
/// Provides access to control-related operations.
/// Depends on the API client provider.
final controlRepositoryProvider = Provider<ControlRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ControlRepository(client);
});

/// Provider for the ActionRepository.
///
/// Provides access to action-related operations.
/// Depends on the API client provider.
final actionRepositoryProvider = Provider<ActionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ActionRepository(client);
});

/// Provider for the TopicRepository.
///
/// Provides access to notification topic-related operations.
/// Depends on the API client provider.
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TopicRepository(client);
});

/// Provider for the EventRepository.
///
/// Provides access to event-related operations.
/// Depends on the API client provider.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return EventRepository(client);
});
