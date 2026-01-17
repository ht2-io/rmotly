import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart' as rmotly;

import '../providers/actions_providers.dart';
import '../viewmodel/actions_viewmodel.dart';

/// View for creating and editing actions
class ActionEditorView extends ConsumerStatefulWidget {
  final rmotly.Action? action;

  const ActionEditorView({super.key, this.action});

  @override
  ConsumerState<ActionEditorView> createState() => _ActionEditorViewState();
}

class _ActionEditorViewState extends ConsumerState<ActionEditorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _descriptionController;
  late TextEditingController _bodyController;
  late TextEditingController _headersController;
  late HttpMethod _selectedMethod;
  bool _isSaving = false;

  bool get isEditing => widget.action != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.action?.name ?? '');
    _urlController =
        TextEditingController(text: widget.action?.urlTemplate ?? '');
    _descriptionController =
        TextEditingController(text: widget.action?.description ?? '');
    _bodyController =
        TextEditingController(text: widget.action?.bodyTemplate ?? '');
    _headersController =
        TextEditingController(text: widget.action?.headersTemplate ?? '');
    _selectedMethod = HttpMethod.fromString(widget.action?.httpMethod ?? 'GET');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
    _headersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Action' : 'Create Action'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAction,
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
                hintText: 'e.g., Deploy to Production',
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

            // HTTP Method and URL
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Method dropdown
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<HttpMethod>(
                    value: _selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                    ),
                    items: HttpMethod.values.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(
                          method.value,
                          style: TextStyle(
                            color: _getMethodColor(method),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMethod = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // URL field
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Template',
                      hintText: 'https://api.example.com/{{path}}',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a URL';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use {{variable}} syntax for dynamic values',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What does this action do?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Headers section
            Text(
              'Headers (JSON)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _headersController,
              decoration: const InputDecoration(
                hintText: '{"Authorization": "Bearer {{token}}"}',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              style: const TextStyle(fontFamily: 'monospace'),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  try {
                    jsonDecode(value);
                  } catch (_) {
                    return 'Invalid JSON format';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'JSON object with header key-value pairs. Use {{variable}} for dynamic values.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Request body (for POST, PUT, PATCH)
            if (_selectedMethod != HttpMethod.get &&
                _selectedMethod != HttpMethod.delete) ...[
              Text(
                'Request Body',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: '{"key": "{{value}}"}',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                'JSON body template. Use {{variable}} for dynamic values.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final action = rmotly.Action(
        id: widget.action?.id,
        userId:
            widget.action?.userId ?? 0, // Server will set the correct userId
        name: _nameController.text,
        httpMethod: _selectedMethod.value,
        urlTemplate: _urlController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        bodyTemplate:
            _bodyController.text.isEmpty ? null : _bodyController.text,
        headersTemplate:
            _headersController.text.isEmpty ? null : _headersController.text,
        createdAt: widget.action?.createdAt ?? now,
        updatedAt: now,
      );

      final viewModel = ref.read(actionsViewModelProvider.notifier);
      final result = isEditing
          ? await viewModel.updateAction(action)
          : await viewModel.createAction(action);

      if (result != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Action updated' : 'Action created'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Color _getMethodColor(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return Colors.green;
      case HttpMethod.post:
        return Colors.blue;
      case HttpMethod.put:
        return Colors.orange;
      case HttpMethod.patch:
        return Colors.purple;
      case HttpMethod.delete:
        return Colors.red;
    }
  }
}
