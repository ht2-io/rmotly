import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/openapi_models.dart';
import '../../domain/services/openapi_parser_service.dart';
import '../state/openapi_state.dart';
import '../viewmodel/openapi_viewmodel.dart';

/// Provider for OpenAPI parser service
final openApiParserServiceProvider = Provider<OpenApiParserService>((ref) {
  return OpenApiParserService();
});

/// Provider for OpenAPI view model
final openApiViewModelProvider =
    StateNotifierProvider<OpenApiViewModel, OpenApiState>((ref) {
  final parserService = ref.watch(openApiParserServiceProvider);
  return OpenApiViewModel(parserService);
});

/// Provider for the currently selected operation
final selectedOperationProvider = StateProvider<OpenApiOperation?>((ref) => null);

/// Provider for operations filtered by tag
final filteredOperationsProvider = Provider<List<OpenApiOperation>>((ref) {
  final state = ref.watch(openApiViewModelProvider);
  final selectedTag = ref.watch(selectedTagProvider);

  if (state.spec == null) return [];

  if (selectedTag == null || selectedTag.isEmpty) {
    return state.spec!.operations;
  }

  return state.spec!.operations
      .where((op) => op.tags.contains(selectedTag))
      .toList();
});

/// Provider for available tags from the spec
final availableTagsProvider = Provider<List<String>>((ref) {
  final state = ref.watch(openApiViewModelProvider);

  if (state.spec == null) return [];

  final tags = <String>{};
  for (final op in state.spec!.operations) {
    tags.addAll(op.tags);
  }

  return tags.toList()..sort();
});

/// Provider for the selected tag filter
final selectedTagProvider = StateProvider<String?>((ref) => null);
