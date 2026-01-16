import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../viewmodel/dashboard_viewmodel.dart';

/// Option item for dropdown control
class DropdownOption {
  final String id;
  final String label;
  final String? icon;

  const DropdownOption({
    required this.id,
    required this.label,
    this.icon,
  });

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id'] as String? ?? json['value'] as String? ?? '',
      label: json['label'] as String? ?? json['name'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

/// Widget for dropdown control type
class DropdownControlWidget extends StatefulWidget {
  final Control control;
  final void Function(String optionId) onSelected;
  final bool isExecuting;

  const DropdownControlWidget({
    super.key,
    required this.control,
    required this.onSelected,
    this.isExecuting = false,
  });

  @override
  State<DropdownControlWidget> createState() => _DropdownControlWidgetState();
}

class _DropdownControlWidgetState extends State<DropdownControlWidget> {
  String? _selectedId;
  late List<DropdownOption> _options;

  @override
  void initState() {
    super.initState();
    _parseConfig();
  }

  @override
  void didUpdateWidget(DropdownControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control.config != widget.control.config) {
      _parseConfig();
    }
  }

  void _parseConfig() {
    final config = parseControlConfig(widget.control.config);
    final optionsList = config['options'] as List<dynamic>? ?? [];
    _options = optionsList.map((o) {
      if (o is Map<String, dynamic>) {
        return DropdownOption.fromJson(o);
      } else if (o is String) {
        return DropdownOption(id: o, label: o);
      }
      return DropdownOption(id: '', label: '');
    }).where((o) => o.id.isNotEmpty).toList();

    _selectedId = config['selected'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = parseControlConfig(widget.control.config);

    final placeholder = config['placeholder'] as String? ?? 'Select an option';

    if (_options.isEmpty) {
      return Text(
        'No options configured',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      child: DropdownButtonFormField<String>(
        value: _selectedId,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        hint: Text(placeholder),
        items: _options.map((option) {
          return DropdownMenuItem<String>(
            value: option.id,
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Icon(
                    _getIconFromName(option.icon!),
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: widget.isExecuting
            ? null
            : (value) {
                if (value != null) {
                  setState(() => _selectedId = value);
                  widget.onSelected(value);
                }
              },
      ),
    );
  }

  IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      default:
        return Icons.circle;
    }
  }
}
