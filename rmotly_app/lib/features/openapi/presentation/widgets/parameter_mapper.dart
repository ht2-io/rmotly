import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/openapi_models.dart';
import '../providers/openapi_providers.dart';
import '../viewmodel/openapi_viewmodel.dart';

/// Widget for mapping OpenAPI parameters to action parameters
class ParameterMapper extends ConsumerStatefulWidget {
  final VoidCallback onCancel;
  final void Function(ActionConfig config) onConfirm;

  const ParameterMapper({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  ConsumerState<ParameterMapper> createState() => _ParameterMapperState();
}

class _ParameterMapperState extends ConsumerState<ParameterMapper> {
  final _actionNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with generated action name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(openApiViewModelProvider);
      _actionNameController.text = state.generatedActionName ?? '';
    });
  }

  @override
  void dispose() {
    _actionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(openApiViewModelProvider);
    final operation = state.selectedOperation;

    if (operation == null) {
      return const Center(child: Text('No operation selected'));
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure Action',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${operation.method} ${operation.path}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Action Name
                _buildSection(
                  context,
                  title: 'Action Name',
                  child: TextFormField(
                    controller: _actionNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter action name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an action name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref
                          .read(openApiViewModelProvider.notifier)
                          .setActionName(value);
                    },
                  ),
                ),

                // Generated URL Preview
                _buildSection(
                  context,
                  title: 'URL Template',
                  child: _buildUrlPreview(context, operation, state),
                ),

                // Path Parameters
                if (operation.pathParameters.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Path Parameters',
                    description:
                        'These values will be substituted into the URL path',
                    child: _buildParametersList(
                      context,
                      operation.pathParameters,
                      state.parameterValues,
                    ),
                  ),

                // Query Parameters
                if (operation.queryParameters.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Query Parameters',
                    description: 'These will be added as query string parameters',
                    child: _buildParametersList(
                      context,
                      operation.queryParameters,
                      state.parameterValues,
                    ),
                  ),

                // Header Parameters
                if (operation.headerParameters.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Header Parameters',
                    description: 'These will be sent as HTTP headers',
                    child: _buildParametersList(
                      context,
                      operation.headerParameters,
                      state.parameterValues,
                    ),
                  ),

                // Request Body
                if (operation.requestBody != null)
                  _buildSection(
                    context,
                    title: 'Request Body',
                    description:
                        'This operation expects a request body. You can configure it when using the action.',
                    child: _buildRequestBodyInfo(context, operation.requestBody!),
                  ),

                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final config = ref
                          .read(openApiViewModelProvider.notifier)
                          .generateActionConfig();
                      if (config != null) {
                        widget.onConfirm(config);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Action'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? description,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildUrlPreview(
    BuildContext context,
    OpenApiOperation operation,
    state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spec = state.spec;

    final baseUrl = spec?.effectiveBaseUrl ?? '';
    var urlTemplate = '$baseUrl${operation.path}';

    // Replace path params with template syntax
    for (final param in operation.pathParameters) {
      urlTemplate = urlTemplate.replaceAll(
        '{${param.name}}',
        '{{${param.name}}}',
      );
    }

    // Add query params
    if (operation.queryParameters.isNotEmpty) {
      final queryParts =
          operation.queryParameters.map((p) => '${p.name}={{${p.name}}}');
      urlTemplate = '$urlTemplate?${queryParts.join('&')}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          urlTemplate,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildParametersList(
    BuildContext context,
    List<OpenApiParameter> parameters,
    Map<String, String> values,
  ) {
    return Column(
      children: parameters.map((param) {
        return _ParameterField(
          parameter: param,
          value: values[param.name],
          onChanged: (value) {
            ref
                .read(openApiViewModelProvider.notifier)
                .setParameterValue(param.name, value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildRequestBodyInfo(
    BuildContext context,
    OpenApiRequestBody body,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final contentTypes = body.content.keys.toList();
    final schema = body.jsonContent?.schema;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                contentTypes.join(', '),
                style: theme.textTheme.labelMedium,
              ),
              if (body.required)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
          if (body.description != null) ...[
            const SizedBox(height: 8),
            Text(
              body.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (schema != null && schema.properties != null) ...[
            const SizedBox(height: 12),
            Text(
              'Properties:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...schema.properties!.entries.take(5).map((entry) {
              final isRequired =
                  schema.requiredProperties?.contains(entry.key) ?? false;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${entry.key}${isRequired ? "*" : ""}: ${entry.value.typeDisplayString}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
            if (schema.properties!.length > 5)
              Text(
                '... and ${schema.properties!.length - 5} more',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Field for editing a single parameter
class _ParameterField extends StatelessWidget {
  final OpenApiParameter parameter;
  final String? value;
  final ValueChanged<String> onChanged;

  const _ParameterField({
    required this.parameter,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                parameter.name,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              if (parameter.required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  parameter.typeString,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (parameter.description != null) ...[
            const SizedBox(height: 4),
            Text(
              parameter.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value ?? parameter.defaultValue?.toString(),
            decoration: InputDecoration(
              hintText: parameter.example?.toString() ??
                  'Use {{variableName}} for dynamic values',
              helperText: 'Default value for this parameter',
              isDense: true,
            ),
            onChanged: onChanged,
            validator: parameter.required
                ? (val) {
                    if (val == null || val.isEmpty) {
                      return 'This parameter is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
