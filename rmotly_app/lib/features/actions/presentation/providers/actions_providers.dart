import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_client_provider.dart';
import '../../data/repositories/action_repository_impl.dart';
import '../../domain/repositories/action_repository.dart';
import '../state/actions_state.dart';
import '../viewmodel/actions_viewmodel.dart';

/// Provider for the action repository implementation
final actionRepositoryProvider = Provider<ActionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ActionRepositoryImpl(client);
});

/// Provider for the actions view model
final actionsViewModelProvider =
    StateNotifierProvider<ActionsViewModel, ActionsState>((ref) {
  final repository = ref.watch(actionRepositoryProvider);
  return ActionsViewModel(repository);
});

/// Provider for the list of actions
final actionsListProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(actionsViewModelProvider).actions;
});

/// Provider to check if actions are loading
final isActionsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(actionsViewModelProvider).isLoading;
});

/// Provider for actions error
final actionsErrorProvider = Provider<String?>((ref) {
  return ref.watch(actionsViewModelProvider).error;
});

/// Provider for last test result
final lastTestResultProvider = Provider<ActionTestResult?>((ref) {
  return ref.watch(actionsViewModelProvider).lastTestResult;
});
