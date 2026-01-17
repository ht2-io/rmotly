import 'package:rmotly_client/rmotly_client.dart';

import '../../domain/repositories/action_repository.dart';

/// State for the actions feature
class ActionsState {
  final List<Action> actions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int? testingActionId;
  final ActionTestResult? lastTestResult;

  const ActionsState({
    this.actions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.testingActionId,
    this.lastTestResult,
  });

  /// Initial state
  static const initial = ActionsState();

  /// Loading state
  static const loading = ActionsState(isLoading: true);

  ActionsState copyWith({
    List<Action>? actions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? testingActionId,
    ActionTestResult? lastTestResult,
    bool clearError = false,
    bool clearTestingAction = false,
    bool clearLastTestResult = false,
  }) {
    return ActionsState(
      actions: actions ?? this.actions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      testingActionId:
          clearTestingAction ? null : (testingActionId ?? this.testingActionId),
      lastTestResult:
          clearLastTestResult ? null : (lastTestResult ?? this.lastTestResult),
    );
  }

  /// Check if a specific action is currently being tested
  bool isActionTesting(int actionId) => testingActionId == actionId;

  /// Get action by ID
  Action? getActionById(int id) {
    try {
      return actions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
