import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_app/core/data/cached_repository.dart';
import 'package:rmotly_app/core/data/pagination.dart';
import 'package:rmotly_app/core/services/cache_service.dart';
import 'package:rmotly_app/core/utils/request_deduplicator.dart';
import 'package:rmotly_app/shared/widgets/optimized_list_view.dart';

// ============================================================================
// EXAMPLE 1: Repository with Caching
// ============================================================================

/// Example control model
class Control {
  final String id;
  final String name;

  Control({required this.id, required this.name});

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Example repository with caching
class ControlRepository extends CachedRepository<List<Control>> {
  final Ref ref;

  ControlRepository(CacheService cacheService, this.ref) : super(cacheService);

  @override
  Future<List<Control>?> fetchFromApi() async {
    // This would call the actual API
    // For demo purposes, returning mock data
    await Future.delayed(const Duration(seconds: 1));
    return [
      Control(id: '1', name: 'Light Switch'),
      Control(id: '2', name: 'Thermostat'),
    ];
  }

  /// Get controls with caching and deduplication
  Future<List<Control>?> getControls({bool forceRefresh = false}) async {
    // Use deduplication to prevent duplicate requests
    return await ref.deduplicate(
      key: 'controls_list',
      fetcher: () async {
        // Check cache first (unless force refresh)
        return await fetchWithCache(
          key: 'controls_list',
          forceRefresh: forceRefresh,
          ttl: const Duration(minutes: 5),
        );
      },
    );
  }
}

// ============================================================================
// EXAMPLE 2: ViewModel with Pagination
// ============================================================================

/// ViewModel managing paginated control list
class ControlsViewModel extends StateNotifier<PaginationState<Control>> {
  final ControlRepository repository;

  ControlsViewModel(this.repository) : super(const PaginationState());

  /// Load first page
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.toLoading();

    try {
      final controls = await repository.getControls();
      if (controls != null) {
        state = state.toSuccess(
          newItems: controls,
          page: 0,
          total: controls.length,
          totalPages: 1,
        );
      }
    } catch (e) {
      state = state.toError(e.toString());
    }
  }

  /// Load more items (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      // In real implementation, pass page number to API
      final newControls = await repository.getControls();
      if (newControls != null) {
        state = state.toSuccess(
          newItems: newControls,
          page: state.currentPage + 1,
          total: state.totalItems + newControls.length,
          totalPages: 2,
          append: true,
        );
      }
    } catch (e) {
      state = state.toError(e.toString());
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    state = const PaginationState();
    await load();
  }
}

// ============================================================================
// EXAMPLE 3: UI with Optimized List View
// ============================================================================

/// Example screen using optimized components
class ControlsScreen extends ConsumerWidget {
  const ControlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In real implementation, create proper providers
    // This is just showing the pattern
    final controls = <Control>[
      Control(id: '1', name: 'Light Switch'),
      Control(id: '2', name: 'Thermostat'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
      ),
      body: OptimizedListView<Control>(
        items: controls,
        itemBuilder: (context, control, index) {
          return ControlCard(control: control);
        },
        separatorBuilder: (context, index) => const Divider(),
        onRefresh: () async {
          // Refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        isLoading: false,
        emptyWidget: const Center(
          child: Text('No controls available'),
        ),
      ),
    );
  }
}

/// Example control card widget
class ControlCard extends StatelessWidget {
  const ControlCard({
    super.key,
    required this.control,
  });

  final Control control;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lightbulb),
      title: Text(control.name),
      trailing: Switch(
        value: false,
        onChanged: (value) {
          // Handle toggle
        },
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Usage in main.dart
// ============================================================================

/// Example of initializing cache service in main.dart
Future<void> initializeServices(WidgetRef ref) async {
  // Initialize cache service
  final cacheService = ref.read(cacheServiceProvider);
  await cacheService.initialize();

  // Schedule periodic cleanup (every hour)
  Future.doWhile(() async {
    await Future.delayed(const Duration(hours: 1));
    await cacheService.cleanup();
    return true;
  });
}
