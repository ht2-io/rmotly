import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../domain/repositories/action_repository.dart';
import '../state/actions_state.dart';

/// View model for the actions feature
class ActionsViewModel extends StateNotifier<ActionsState> {
  final ActionRepository _repository;

  ActionsViewModel(this._repository) : super(ActionsState.initial) {
    loadActions();
  }

  /// Load actions from the repository
  Future<void> loadActions() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final actions = await _repository.getActions();
      state = state.copyWith(
        actions: actions,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to load actions: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load actions: $e',
      );
    }
  }

  /// Refresh actions (pull-to-refresh)
  Future<void> refreshActions() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final actions = await _repository.getActions();
      state = state.copyWith(
        actions: actions,
        isRefreshing: false,
      );
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to refresh actions: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh actions',
      );
    }
  }

  /// Create a new action
  Future<Action?> createAction(Action action) async {
    try {
      final created = await _repository.createAction(action);

      // Add to local state
      state = state.copyWith(
        actions: [...state.actions, created],
      );

      return created;
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to create action: $e');
      state = state.copyWith(error: 'Failed to create action');
      return null;
    }
  }

  /// Update an existing action
  Future<Action?> updateAction(Action action) async {
    try {
      final updated = await _repository.updateAction(action);

      // Update in local state
      final actions = state.actions.map((a) {
        return a.id == updated.id ? updated : a;
      }).toList();

      state = state.copyWith(actions: actions);

      return updated;
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to update action: $e');
      state = state.copyWith(error: 'Failed to update action');
      return null;
    }
  }

  /// Delete an action
  Future<void> deleteAction(int actionId) async {
    try {
      final success = await _repository.deleteAction(actionId);

      if (success) {
        // Remove from local state
        final actions = state.actions.where((a) => a.id != actionId).toList();
        state = state.copyWith(actions: actions);
      }
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to delete action: $e');
      state = state.copyWith(error: 'Failed to delete action');
    }
  }

  /// Test an action
  Future<void> testAction(int actionId, Map<String, dynamic> parameters) async {
    state = state.copyWith(
      testingActionId: actionId,
      clearLastTestResult: true,
    );

    try {
      final result = await _repository.testAction(actionId, parameters);

      state = state.copyWith(
        clearTestingAction: true,
        lastTestResult: result,
      );
    } catch (e) {
      debugPrint('ActionsViewModel: Failed to test action: $e');
      state = state.copyWith(
        clearTestingAction: true,
        lastTestResult: ActionTestResult(
          success: false,
          executionTimeMs: 0,
          error: 'Failed to test action: $e',
        ),
      );
    }
  }

  /// Clear the last test result
  void clearTestResult() {
    state = state.copyWith(clearLastTestResult: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// HTTP methods available for actions
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  final String value;
  const HttpMethod(this.value);

  static HttpMethod fromString(String value) {
    return HttpMethod.values.firstWhere(
      (m) => m.value.toUpperCase() == value.toUpperCase(),
      orElse: () => HttpMethod.get,
    );
  }
}
