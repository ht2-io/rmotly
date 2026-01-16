import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../viewmodel/dashboard_viewmodel.dart';

/// Widget for input control type
class InputControlWidget extends StatefulWidget {
  final Control control;
  final void Function(String text) onSubmitted;
  final bool isExecuting;

  const InputControlWidget({
    super.key,
    required this.control,
    required this.onSubmitted,
    this.isExecuting = false,
  });

  @override
  State<InputControlWidget> createState() => _InputControlWidgetState();
}

class _InputControlWidgetState extends State<InputControlWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final config = parseControlConfig(widget.control.config);
    final initialValue = config['value'] as String? ?? '';
    _controller = TextEditingController(text: initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isExecuting) {
      widget.onSubmitted(text);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = parseControlConfig(widget.control.config);

    final placeholder = config['placeholder'] as String? ?? 'Enter text...';
    final buttonLabel = config['buttonLabel'] as String? ?? 'Send';
    final maxLength = config['maxLength'] as int?;
    final inputType = config['inputType'] as String? ?? 'text';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.isExecuting,
          maxLength: maxLength,
          keyboardType: _getKeyboardType(inputType),
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
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
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: widget.isExecuting ? null : _submit,
          icon: const Icon(Icons.send, size: 18),
          label: Text(buttonLabel),
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 40),
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType(String type) {
    switch (type.toLowerCase()) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}
