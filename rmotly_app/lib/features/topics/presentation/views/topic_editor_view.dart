import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../providers/topics_providers.dart';

/// View for creating and editing notification topics
class TopicEditorView extends ConsumerStatefulWidget {
  final NotificationTopic? topic;

  const TopicEditorView({super.key, this.topic});

  @override
  ConsumerState<TopicEditorView> createState() => _TopicEditorViewState();
}

class _TopicEditorViewState extends ConsumerState<TopicEditorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _titleTemplateController;
  late TextEditingController _bodyTemplateController;
  late String _priority;
  bool _isSaving = false;

  bool get isEditing => widget.topic != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topic?.name ?? '');
    _descriptionController = TextEditingController(text: widget.topic?.description ?? '');

    // Parse config JSON
    Map<String, dynamic> config = {};
    if (widget.topic?.config != null && widget.topic!.config.isNotEmpty) {
      try {
        config = jsonDecode(widget.topic!.config) as Map<String, dynamic>;
      } catch (_) {}
    }

    _titleTemplateController = TextEditingController(
      text: config['titleTemplate'] as String? ?? '{{title}}',
    );
    _bodyTemplateController = TextEditingController(
      text: config['bodyTemplate'] as String? ?? '{{body}}',
    );
    _priority = config['priority'] as String? ?? 'normal';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _titleTemplateController.dispose();
    _bodyTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Topic' : 'Create Topic'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTopic,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., GitHub Notifications',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What notifications will this topic receive?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Notification Template Section
            Text(
              'Notification Template',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure how incoming webhooks are displayed as notifications. '
              'Use {{variable}} syntax to reference payload fields.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Title template
            TextFormField(
              controller: _titleTemplateController,
              decoration: const InputDecoration(
                labelText: 'Title Template',
                hintText: '{{title}}',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Body template
            TextFormField(
              controller: _bodyTemplateController,
              decoration: const InputDecoration(
                labelText: 'Body Template',
                hintText: '{{body}}',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Priority Section
            Text(
              'Priority',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'low',
                  label: Text('Low'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: 'normal',
                  label: Text('Normal'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: 'high',
                  label: Text('High'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_priority},
              onSelectionChanged: (selected) {
                setState(() => _priority = selected.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getPriorityDescription(_priority),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Webhook Info (for editing)
            if (isEditing) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Webhook Integration',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To send notifications to this topic, make a POST request to the webhook URL with the API key in the Authorization header.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'curl -X POST <webhook_url> \\\n'
                        '  -H "Authorization: Bearer <api_key>" \\\n'
                        '  -H "Content-Type: application/json" \\\n'
                        '  -d \'{"title": "Hello", "body": "World"}\'',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPriorityDescription(String priority) {
    switch (priority) {
      case 'low':
        return 'Silent notification, no sound or vibration';
      case 'high':
        return 'Heads-up notification with sound and vibration';
      default:
        return 'Standard notification with default sound';
    }
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final config = jsonEncode({
        'titleTemplate': _titleTemplateController.text,
        'bodyTemplate': _bodyTemplateController.text,
        'priority': _priority,
      });

      final now = DateTime.now();
      final topic = NotificationTopic(
        id: widget.topic?.id,
        userId: widget.topic?.userId ?? 0, // Server will set the correct userId
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        apiKey: widget.topic?.apiKey ?? '', // Server generates API key
        enabled: widget.topic?.enabled ?? true,
        config: config,
        createdAt: widget.topic?.createdAt ?? now,
        updatedAt: now,
      );

      final viewModel = ref.read(topicsViewModelProvider.notifier);
      final result = isEditing
          ? await viewModel.updateTopic(topic)
          : await viewModel.createTopic(topic);

      if (result != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Topic updated' : 'Topic created'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
