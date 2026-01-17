import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../providers/topics_providers.dart';
import '../state/topics_state.dart';
import '../widgets/topic_card.dart';
import 'topic_editor_view.dart';

/// View for displaying and managing notification topics
class TopicsListView extends ConsumerWidget {
  const TopicsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(topicsViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(topicsViewModelProvider.notifier).refreshTopics(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context, ref, state, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        tooltip: 'Create Topic',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    TopicsState state,
    ThemeData theme,
  ) {
    if (state.isLoading && state.topics.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.topics.isEmpty) {
      return _buildErrorState(context, ref, state.error!, theme);
    }

    if (state.topics.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    final viewModel = ref.read(topicsViewModelProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshTopics(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.topics.length,
        itemBuilder: (context, index) {
          final topic = state.topics[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TopicCard(
              topic: topic,
              webhookUrl: viewModel.getWebhookUrl(topic.id!),
              isToggling: state.isTopicToggling(topic.id!),
              isRegenerating: state.isTopicRegenerating(topic.id!),
              onTap: () => _navigateToEditor(context, topic: topic),
              onToggle: (enabled) => viewModel.toggleTopic(topic.id!, enabled),
              onEdit: () => _navigateToEditor(context, topic: topic),
              onDelete: () => _confirmDelete(context, ref, topic),
              onRegenerateApiKey: () => viewModel.regenerateApiKey(topic.id!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    ThemeData theme,
  ) {
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
              'Failed to load topics',
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
              onPressed: () => ref.read(topicsViewModelProvider.notifier).loadTopics(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No topics yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a notification topic to receive\nwebhook notifications from external services.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Topic'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {NotificationTopic? topic}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicEditorView(topic: topic),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    NotificationTopic topic,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text(
          'Are you sure you want to delete "${topic.name}"? '
          'All webhook URLs using this topic will stop working.',
        ),
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

    if (confirmed == true) {
      ref.read(topicsViewModelProvider.notifier).deleteTopic(topic.id!);
    }
  }
}
