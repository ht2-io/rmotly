import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/openapi_providers.dart';
import '../widgets/operation_selector.dart';
import '../widgets/parameter_mapper.dart';

/// View for importing actions from an OpenAPI specification
class OpenApiImportView extends ConsumerStatefulWidget {
  const OpenApiImportView({super.key});

  @override
  ConsumerState<OpenApiImportView> createState() => _OpenApiImportViewState();
}

class _OpenApiImportViewState extends ConsumerState<OpenApiImportView> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(openApiViewModelProvider);
    final viewModel = ref.read(openApiViewModelProvider.notifier);

    // Show error snackbar
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: colorScheme.error,
          ),
        );
        viewModel.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from OpenAPI'),
        actions: [
          if (state.hasSpec)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload spec',
              onPressed: () => viewModel.loadSpec(_urlController.text),
            ),
        ],
      ),
      body: Column(
        children: [
          // URL Input Section
          _buildUrlInput(context, state, viewModel),

          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.hasSpec
                    ? state.hasSelectedOperation
                        ? _buildParameterMapper(context)
                        : _buildOperationBrowser(context)
                    : _buildPlaceholder(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput(
    BuildContext context,
    state,
    viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenAPI Specification URL',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'https://api.example.com/openapi.json',
                      prefixIcon: const Icon(Icons.link),
                      suffixIcon: _urlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _urlController.clear();
                                viewModel.clearSpec();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a URL';
                      }
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            viewModel.loadSpec(_urlController.text);
                          }
                        },
                  icon: const Icon(Icons.download),
                  label: const Text('Fetch'),
                ),
              ],
            ),
            if (state.hasSpec) ...[
              const SizedBox(height: 12),
              _buildSpecInfo(context, state.spec!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecInfo(BuildContext context, spec) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'v${spec.version} - ${spec.operations.length} operations',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Import from OpenAPI',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter an OpenAPI specification URL above to browse and import API operations as actions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildExampleUrls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleUrls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = ref.read(openApiViewModelProvider.notifier);

    final examples = [
      ('Petstore', 'https://petstore3.swagger.io/api/v3/openapi.json'),
      ('JSONPlaceholder', 'https://jsonplaceholder.typicode.com/openapi.json'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try an example:',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...examples.map((example) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton.icon(
              onPressed: () {
                _urlController.text = example.$2;
                viewModel.loadSpec(example.$2);
              },
              icon: const Icon(Icons.science, size: 18),
              label: Text(example.$1),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOperationBrowser(BuildContext context) {
    return const OperationSelector();
  }

  Widget _buildParameterMapper(BuildContext context) {
    return ParameterMapper(
      onCancel: () {
        ref.read(openApiViewModelProvider.notifier).deselectOperation();
      },
      onConfirm: (config) {
        // Navigate back with the action configuration
        // The calling screen can use this to create the action
        context.pop(config);
      },
    );
  }
}
