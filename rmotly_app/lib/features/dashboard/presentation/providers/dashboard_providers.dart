import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/control_repository_impl.dart';
import '../../domain/repositories/control_repository.dart';
import '../../../../core/providers/api_client_provider.dart';
import '../../../../core/providers/local_storage_provider.dart';
import '../state/dashboard_state.dart';
import '../viewmodel/dashboard_viewmodel.dart';

/// Provider for the control repository implementation
final dashboardControlRepositoryProvider = Provider<ControlRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return ControlRepositoryImpl(client, storage);
});

/// Provider for the dashboard view model
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final repository = ref.watch(dashboardControlRepositoryProvider);
  return DashboardViewModel(repository);
});

/// Selective provider for the list of controls
/// Using select() to minimize rebuilds when only controls change
final controlsProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(
    dashboardViewModelProvider.select((state) => state.controls),
  );
});

/// Selective provider to check if dashboard is loading
/// Only rebuilds when isLoading changes
final isDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(
    dashboardViewModelProvider.select((state) => state.isLoading),
  );
});

/// Selective provider to check if dashboard is refreshing
/// Only rebuilds when isRefreshing changes
final isDashboardRefreshingProvider = Provider<bool>((ref) {
  return ref.watch(
    dashboardViewModelProvider.select((state) => state.isRefreshing),
  );
});

/// Selective provider for dashboard error
/// Only rebuilds when error changes
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(
    dashboardViewModelProvider.select((state) => state.error),
  );
});

/// Selective provider for executing control ID
/// Only rebuilds when executingControlId changes
final executingControlIdProvider = Provider<int?>((ref) {
  return ref.watch(
    dashboardViewModelProvider.select((state) => state.executingControlId),
  );
});
