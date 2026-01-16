import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../../../core/control_type.dart';
import '../../../../shared/services/auth_service.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/widgets.dart';

/// View for creating or editing a control
class ControlEditorView extends ConsumerStatefulWidget {
  final int? controlId;

  const ControlEditorView({super.key, this.controlId});

  bool get isEditing => controlId != null;

  @override
  ConsumerState<ControlEditorView> createState() => _ControlEditorViewState();
}

class _ControlEditorViewState extends ConsumerState<ControlEditorView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  ControlType _selectedType = ControlType.button;
  bool _isLoading = false;
  Control? _existingControl;

  // Button config
  final _buttonLabelController = TextEditingController(text: 'Press');
  String _buttonIcon = 'touch_app';

  // Toggle config
  final _onLabelController = TextEditingController(text: 'ON');
  final _offLabelController = TextEditingController(text: 'OFF');
  bool _toggleState = false;

  // Slider config
  final _sliderMinController = TextEditingController(text: '0');
  final _sliderMaxController = TextEditingController(text: '100');
  final _sliderUnitController = TextEditingController();
  int _sliderDivisions = 10;

  // Input config
  final _inputPlaceholderController = TextEditingController(text: 'Enter text...');
  final _inputButtonLabelController = TextEditingController(text: 'Send');
  String _inputType = 'text';

  // Dropdown config
  final _dropdownOptionsController = TextEditingController();
  final _dropdownPlaceholderController = TextEditingController(text: 'Select an option');

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingControl();
    }
  }

  Future<void> _loadExistingControl() async {
    setState(() => _isLoading = true);

    try {
      final state = ref.read(dashboardViewModelProvider);
      final control = state.getControlById(widget.controlId!);

      if (control != null) {
        _existingControl = control;
        _nameController.text = control.name;
        _selectedType = ControlType.values.firstWhere(
          (t) => t.name == control.controlType,
          orElse: () => ControlType.button,
        );
        _parseExistingConfig(control.config);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _parseExistingConfig(String configJson) {
    try {
      final config = jsonDecode(configJson) as Map<String, dynamic>;

      switch (_selectedType) {
        case ControlType.button:
          _buttonLabelController.text = config['label'] as String? ?? 'Press';
          _buttonIcon = config['icon'] as String? ?? 'touch_app';
          break;
        case ControlType.toggle:
          _onLabelController.text = config['onLabel'] as String? ?? 'ON';
          _offLabelController.text = config['offLabel'] as String? ?? 'OFF';
          _toggleState = config['state'] as bool? ?? false;
          break;
        case ControlType.slider:
          _sliderMinController.text = (config['min'] as num?)?.toString() ?? '0';
          _sliderMaxController.text = (config['max'] as num?)?.toString() ?? '100';
          _sliderUnitController.text = config['unit'] as String? ?? '';
          _sliderDivisions = config['divisions'] as int? ?? 10;
          break;
        case ControlType.input:
          _inputPlaceholderController.text = config['placeholder'] as String? ?? 'Enter text...';
          _inputButtonLabelController.text = config['buttonLabel'] as String? ?? 'Send';
          _inputType = config['inputType'] as String? ?? 'text';
          break;
        case ControlType.dropdown:
          final options = config['options'] as List<dynamic>?;
          if (options != null) {
            _dropdownOptionsController.text = options.map((o) {
              if (o is Map) {
                return '${o['id']}:${o['label']}';
              }
              return o.toString();
            }).join('\n');
          }
          _dropdownPlaceholderController.text = config['placeholder'] as String? ?? 'Select an option';
          break;
      }
    } catch (_) {
      // Ignore parse errors
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buttonLabelController.dispose();
    _onLabelController.dispose();
    _offLabelController.dispose();
    _sliderMinController.dispose();
    _sliderMaxController.dispose();
    _sliderUnitController.dispose();
    _inputPlaceholderController.dispose();
    _inputButtonLabelController.dispose();
    _dropdownOptionsController.dispose();
    _dropdownPlaceholderController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildConfig() {
    switch (_selectedType) {
      case ControlType.button:
        return {
          'label': _buttonLabelController.text,
          'icon': _buttonIcon,
        };
      case ControlType.toggle:
        return {
          'onLabel': _onLabelController.text,
          'offLabel': _offLabelController.text,
          'state': _toggleState,
        };
      case ControlType.slider:
        return {
          'min': double.tryParse(_sliderMinController.text) ?? 0,
          'max': double.tryParse(_sliderMaxController.text) ?? 100,
          'unit': _sliderUnitController.text,
          'divisions': _sliderDivisions,
          'showValue': true,
        };
      case ControlType.input:
        return {
          'placeholder': _inputPlaceholderController.text,
          'buttonLabel': _inputButtonLabelController.text,
          'inputType': _inputType,
        };
      case ControlType.dropdown:
        final lines = _dropdownOptionsController.text.split('\n');
        final options = lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
              final parts = line.split(':');
              if (parts.length >= 2) {
                return {'id': parts[0].trim(), 'label': parts.sublist(1).join(':').trim()};
              }
              return {'id': line.trim(), 'label': line.trim()};
            })
            .toList();
        return {
          'options': options,
          'placeholder': _dropdownPlaceholderController.text,
        };
    }
  }

  Future<void> _saveControl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider) ?? 1;
      final config = jsonEncode(_buildConfig());
      final now = DateTime.now();

      final control = Control(
        id: _existingControl?.id,
        userId: userId,
        name: _nameController.text.trim(),
        controlType: _selectedType.name,
        config: config,
        position: _existingControl?.position ?? 0,
        createdAt: _existingControl?.createdAt ?? now,
        updatedAt: now,
      );

      final repository = ref.read(dashboardControlRepositoryProvider);

      if (widget.isEditing) {
        await repository.updateControl(control);
      } else {
        await repository.createControl(control);
      }

      // Refresh controls
      ref.read(dashboardViewModelProvider.notifier).loadControls();

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save control: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Control' : 'New Control'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveControl,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading && _existingControl == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Control name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Control Name',
                      hintText: 'e.g., Living Room Light',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Control type selector
                  Text(
                    'Control Type',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ControlType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(type.label),
                        avatar: Icon(
                          _getIconForType(type),
                          size: 18,
                          color: isSelected ? colorScheme.onPrimary : null,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedType.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Type-specific configuration
                  _buildTypeConfig(),
                  const SizedBox(height: 24),

                  // Preview
                  Text(
                    'Preview',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildPreview(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeConfig() {
    switch (_selectedType) {
      case ControlType.button:
        return _buildButtonConfig();
      case ControlType.toggle:
        return _buildToggleConfig();
      case ControlType.slider:
        return _buildSliderConfig();
      case ControlType.input:
        return _buildInputConfig();
      case ControlType.dropdown:
        return _buildDropdownConfig();
    }
  }

  Widget _buildButtonConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _buttonLabelController,
          decoration: const InputDecoration(
            labelText: 'Button Label',
            hintText: 'e.g., Turn On',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _buttonIcon,
          decoration: const InputDecoration(
            labelText: 'Icon',
          ),
          items: const [
            DropdownMenuItem(value: 'touch_app', child: Text('Touch')),
            DropdownMenuItem(value: 'power', child: Text('Power')),
            DropdownMenuItem(value: 'play', child: Text('Play')),
            DropdownMenuItem(value: 'stop', child: Text('Stop')),
            DropdownMenuItem(value: 'refresh', child: Text('Refresh')),
            DropdownMenuItem(value: 'send', child: Text('Send')),
            DropdownMenuItem(value: 'light', child: Text('Light')),
            DropdownMenuItem(value: 'lock', child: Text('Lock')),
            DropdownMenuItem(value: 'unlock', child: Text('Unlock')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _buttonIcon = value);
          },
        ),
      ],
    );
  }

  Widget _buildToggleConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _onLabelController,
                decoration: const InputDecoration(
                  labelText: 'ON Label',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _offLabelController,
                decoration: const InputDecoration(
                  labelText: 'OFF Label',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Initial State'),
          value: _toggleState,
          onChanged: (value) => setState(() => _toggleState = value),
        ),
      ],
    );
  }

  Widget _buildSliderConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sliderMinController,
                decoration: const InputDecoration(
                  labelText: 'Min Value',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _sliderMaxController,
                decoration: const InputDecoration(
                  labelText: 'Max Value',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sliderUnitController,
          decoration: const InputDecoration(
            labelText: 'Unit (optional)',
            hintText: 'e.g., %, °F, etc.',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Divisions: '),
            Expanded(
              child: Slider(
                value: _sliderDivisions.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: _sliderDivisions.toString(),
                onChanged: (value) => setState(() => _sliderDivisions = value.round()),
              ),
            ),
            Text(_sliderDivisions.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildInputConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _inputPlaceholderController,
          decoration: const InputDecoration(
            labelText: 'Placeholder Text',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _inputButtonLabelController,
          decoration: const InputDecoration(
            labelText: 'Button Label',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _inputType,
          decoration: const InputDecoration(
            labelText: 'Input Type',
          ),
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Text')),
            DropdownMenuItem(value: 'number', child: Text('Number')),
            DropdownMenuItem(value: 'email', child: Text('Email')),
            DropdownMenuItem(value: 'phone', child: Text('Phone')),
            DropdownMenuItem(value: 'url', child: Text('URL')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _inputType = value);
          },
        ),
      ],
    );
  }

  Widget _buildDropdownConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _dropdownPlaceholderController,
          decoration: const InputDecoration(
            labelText: 'Placeholder Text',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dropdownOptionsController,
          decoration: const InputDecoration(
            labelText: 'Options (one per line)',
            hintText: 'id:Label\nor just: Option 1',
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final config = jsonEncode(_buildConfig());
    final control = Control(
      id: 0,
      userId: 1,
      name: _nameController.text.isEmpty ? 'Preview' : _nameController.text,
      controlType: _selectedType.name,
      config: config,
      position: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Container(
      height: _getPreviewHeight(),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ControlCard(
        control: control,
        child: _buildPreviewWidget(control),
      ),
    );
  }

  Widget _buildPreviewWidget(Control control) {
    switch (_selectedType) {
      case ControlType.button:
        return ButtonControlWidget(
          control: control,
          onPressed: () {},
        );
      case ControlType.toggle:
        return ToggleControlWidget(
          control: control,
          onChanged: (_) {},
        );
      case ControlType.slider:
        return SliderControlWidget(
          control: control,
          onChanged: (_) {},
        );
      case ControlType.input:
        return InputControlWidget(
          control: control,
          onSubmitted: (_) {},
        );
      case ControlType.dropdown:
        return DropdownControlWidget(
          control: control,
          onSelected: (_) {},
        );
    }
  }

  double _getPreviewHeight() {
    switch (_selectedType) {
      case ControlType.button:
        return 160;
      case ControlType.toggle:
        return 170;
      case ControlType.slider:
        return 200;
      case ControlType.input:
        return 220;
      case ControlType.dropdown:
        return 180;
    }
  }

  IconData _getIconForType(ControlType type) {
    switch (type) {
      case ControlType.button:
        return Icons.touch_app;
      case ControlType.toggle:
        return Icons.toggle_on;
      case ControlType.slider:
        return Icons.linear_scale;
      case ControlType.input:
        return Icons.text_fields;
      case ControlType.dropdown:
        return Icons.arrow_drop_down_circle;
    }
  }
}
