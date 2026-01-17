import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rmotly_client/rmotly_client.dart' as rmotly;

import '../providers/actions_providers.dart';
import '../state/actions_state.dart';
import '../widgets/action_card.dart';
import '../widgets/test_result_dialog.dart';
import 'action_editor_view.dart';

/// View for displaying and managing actions
class ActionsListView extends ConsumerStatefulWidget {
  const ActionsListView({super.key});

  @override
  ConsumerState<ActionsListView> createState() => _ActionsListViewState();
}

class _ActionsListViewState extends ConsumerState<ActionsListView> {
  @override
  void initState() {
    super.initState();
    // Listen for test results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTestResultListener();
    });
  }

  void _setupTestResultListener() {
    ref.listenManual(lastTestResultProvider, (previous, next) {
      if (next != null && mounted) {
        TestResultDialog.show(context, next);
        ref.read(actionsViewModelProvider.notifier).clearTestResult();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actionsViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.api),
            onPressed: () => context.push('/openapi-import'),
            tooltip: 'Import from OpenAPI',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref
                    .read(actionsViewModelProvider.notifier)
                    .refreshActions(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(state, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        tooltip: 'Create Action',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ActionsState state, ThemeData theme) {
    if (state.isLoading && state.actions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.actions.isEmpty) {
      return _buildErrorState(state.error!, theme);
    }

    if (state.actions.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(actionsViewModelProvider.notifier).refreshActions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.actions.length,
        itemBuilder: (context, index) {
          final action = state.actions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActionCard(
              action: action,
              isTesting: state.isActionTesting(action.id!),
              onTap: () => _navigateToEditor(context, action: action),
              onTest: () => _testAction(action.id!),
              onEdit: () => _navigateToEditor(context, action: action),
              onDelete: () => _confirmDelete(context, action),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(actionsViewModelProvider.notifier).loadActions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No actions yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first action to trigger HTTP requests\nwhen events occur.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Action'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/openapi-import'),
              icon: const Icon(Icons.api),
              label: const Text('Import from OpenAPI'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {rmotly.Action? action}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActionEditorView(action: action),
      ),
    );
  }

  void _testAction(int actionId) {
    // For now, test with empty parameters
    // In future, could show a dialog to input test parameters
    ref.read(actionsViewModelProvider.notifier).testAction(actionId, {});
  }

  Future<void> _confirmDelete(
      BuildContext context, rmotly.Action action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Action'),
        content: Text('Are you sure you want to delete "${action.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(actionsViewModelProvider.notifier).deleteAction(action.id!);
    }
  }
}
