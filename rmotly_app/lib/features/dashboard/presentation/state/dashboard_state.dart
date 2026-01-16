import 'package:rmotly_client/rmotly_client.dart';

/// State for the dashboard view
class DashboardState {
  final List<Control> controls;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int? executingControlId;

  const DashboardState({
    this.controls = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.executingControlId,
  });

  /// Initial state
  static const initial = DashboardState();

  /// Loading state
  static const loading = DashboardState(isLoading: true);

  DashboardState copyWith({
    List<Control>? controls,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? executingControlId,
    bool clearError = false,
    bool clearExecutingControl = false,
  }) {
    return DashboardState(
      controls: controls ?? this.controls,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      executingControlId: clearExecutingControl
          ? null
          : (executingControlId ?? this.executingControlId),
    );
  }

  /// Check if a specific control is currently executing
  bool isControlExecuting(int controlId) => executingControlId == controlId;

  /// Get control by ID
  Control? getControlById(int id) {
    try {
      return controls.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
