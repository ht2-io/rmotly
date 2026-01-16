import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/control_repository_impl.dart';
import '../../domain/repositories/control_repository.dart';
import '../../../../core/providers/api_client_provider.dart';
import '../state/dashboard_state.dart';
import '../viewmodel/dashboard_viewmodel.dart';

/// Provider for the control repository implementation
final dashboardControlRepositoryProvider = Provider<ControlRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ControlRepositoryImpl(client);
});

/// Provider for the dashboard view model
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final repository = ref.watch(dashboardControlRepositoryProvider);
  return DashboardViewModel(repository);
});

/// Provider for the list of controls
final controlsProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(dashboardViewModelProvider).controls;
});

/// Provider to check if dashboard is loading
final isDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardViewModelProvider).isLoading;
});

/// Provider to check if dashboard is refreshing
final isDashboardRefreshingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardViewModelProvider).isRefreshing;
});

/// Provider for dashboard error
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardViewModelProvider).error;
});
