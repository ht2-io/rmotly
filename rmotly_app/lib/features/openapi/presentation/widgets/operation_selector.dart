import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/openapi_models.dart';
import '../providers/openapi_providers.dart';

/// Widget for selecting an operation from the OpenAPI spec
class OperationSelector extends ConsumerWidget {
  const OperationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOperations = ref.watch(filteredOperationsProvider);
    final availableTags = ref.watch(availableTagsProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return Column(
      children: [
        // Tag filter
        if (availableTags.isNotEmpty)
          _buildTagFilter(context, ref, availableTags, selectedTag),

        // Operations list
        Expanded(
          child: filteredOperations.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOperations.length,
                  itemBuilder: (context, index) {
                    final operation = filteredOperations[index];
                    return _OperationCard(
                      operation: operation,
                      onTap: () {
                        ref
                            .read(openApiViewModelProvider.notifier)
                            .selectOperation(operation);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTagFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> tags,
    String? selectedTag,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // All tag
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedTag == null,
              onSelected: (_) {
                ref.read(selectedTagProvider.notifier).state = null;
              },
            ),
          ),
          // Tag chips
          ...tags.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: selectedTag == tag,
                onSelected: (_) {
                  ref.read(selectedTagProvider.notifier).state =
                      selectedTag == tag ? null : tag;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No operations found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try clearing the tag filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying an operation
class _OperationCard extends StatelessWidget {
  final OpenApiOperation operation;
  final VoidCallback onTap;

  const _OperationCard({
    required this.operation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Method and Path
              Row(
                children: [
                  _MethodBadge(method: operation.method),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      operation.path,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (operation.deprecated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Deprecated',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),

              // Summary/Description
              if (operation.summary != null || operation.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  operation.summary ?? operation.description ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Tags and Parameters info
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Tags
                  ...operation.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }),

                  // Parameters count
                  if (operation.parameters.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${operation.parameters.length} params',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Request body indicator
                  if (operation.requestBody != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.code,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Body',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing the HTTP method with appropriate color
class _MethodBadge extends StatelessWidget {
  final String method;

  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getMethodColor(method),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      case 'HEAD':
        return Colors.teal;
      case 'OPTIONS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
