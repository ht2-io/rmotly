import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../../../core/control_type.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/dashboard_providers.dart';
import '../state/dashboard_state.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/widgets.dart';

/// Main dashboard view showing control grid
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final viewModel = ref.read(dashboardViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _buildBody(context, ref, state, viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddControlDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Control'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    DashboardViewModel viewModel,
  ) {
    // Show error snackbar if there's an error
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () => viewModel.clearError(),
            ),
          ),
        );
        viewModel.clearError();
      });
    }

    // Loading state
    if (state.isLoading && state.controls.isEmpty) {
      return const LoadingWidget(message: 'Loading controls...');
    }

    // Empty state
    if (state.controls.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.dashboard_outlined,
        title: 'No Controls Yet',
        message: 'Add your first control to start automating your workflows.',
        actionLabel: 'Add Control',
        onAction: () => _showAddControlDialog(context, ref),
      );
    }

    // Control grid with pull-to-refresh
    return RefreshIndicator(
      onRefresh: viewModel.refreshControls,
      child: _ControlGrid(
        controls: state.controls,
        executingControlId: state.executingControlId,
        onReorder: viewModel.reorderControls,
        onButtonPressed: viewModel.onButtonPressed,
        onToggleChanged: viewModel.onToggleChanged,
        onSliderChanged: viewModel.onSliderChanged,
        onInputSubmitted: viewModel.onInputSubmitted,
        onDropdownSelected: viewModel.onDropdownSelected,
        onEdit: (control) => _showEditControlDialog(context, ref, control),
        onDelete: (control) => _confirmDeleteControl(context, ref, control),
      ),
    );
  }

  void _showAddControlDialog(BuildContext context, WidgetRef ref) {
    context.push('/control/new');
  }

  void _showEditControlDialog(
      BuildContext context, WidgetRef ref, Control control) {
    context.push('/control/${control.id}');
  }

  Future<void> _confirmDeleteControl(
    BuildContext context,
    WidgetRef ref,
    Control control,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Control',
      message:
          'Are you sure you want to delete "${control.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete,
    );

    if (confirmed) {
      ref.read(dashboardViewModelProvider.notifier).deleteControl(control.id!);
    }
  }
}

/// Reorderable grid of control cards
class _ControlGrid extends StatelessWidget {
  final List<Control> controls;
  final int? executingControlId;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(Control control) onButtonPressed;
  final void Function(Control control, bool value) onToggleChanged;
  final void Function(Control control, double value) onSliderChanged;
  final void Function(Control control, String text) onInputSubmitted;
  final void Function(Control control, String optionId) onDropdownSelected;
  final void Function(Control control) onEdit;
  final void Function(Control control) onDelete;

  const _ControlGrid({
    required this.controls,
    this.executingControlId,
    required this.onReorder,
    required this.onButtonPressed,
    required this.onToggleChanged,
    required this.onSliderChanged,
    required this.onInputSubmitted,
    required this.onDropdownSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid columns based on screen width
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          buildDefaultDragHandles: false,
          itemCount: controls.length,
          onReorder: onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final scale = Tween<double>(begin: 1.0, end: 1.05)
                    .animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ))
                    .value;
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final control = controls[index];
            final isExecuting = executingControlId == control.id;

            return ReorderableDragStartListener(
              key: ValueKey(control.id ?? index),
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildControlCard(context, control, isExecuting),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlCard(
      BuildContext context, Control control, bool isExecuting) {
    final controlType = getControlTypeFromString(control.controlType);

    Widget controlWidget;
    switch (controlType) {
      case ControlType.button:
        controlWidget = ButtonControlWidget(
          control: control,
          onPressed: () => onButtonPressed(control),
          isExecuting: isExecuting,
        );
        break;
      case ControlType.toggle:
        controlWidget = ToggleControlWidget(
          control: control,
          onChanged: (value) => onToggleChanged(control, value),
          isExecuting: isExecuting,
        );
        break;
      case ControlType.slider:
        controlWidget = SliderControlWidget(
          control: control,
          onChanged: (value) => onSliderChanged(control, value),
          isExecuting: isExecuting,
        );
        break;
      case ControlType.input:
        controlWidget = InputControlWidget(
          control: control,
          onSubmitted: (text) => onInputSubmitted(control, text),
          isExecuting: isExecuting,
        );
        break;
      case ControlType.dropdown:
        controlWidget = DropdownControlWidget(
          control: control,
          onSelected: (optionId) => onDropdownSelected(control, optionId),
          isExecuting: isExecuting,
        );
        break;
      default:
        controlWidget = const Text('Unknown control type');
    }

    return SizedBox(
      height: _getControlHeight(controlType),
      child: ControlCard(
        control: control,
        isExecuting: isExecuting,
        onEdit: () => onEdit(control),
        onDelete: () => onDelete(control),
        child: controlWidget,
      ),
    );
  }

  double _getControlHeight(ControlType? type) {
    switch (type) {
      case ControlType.button:
        return 140;
      case ControlType.toggle:
        return 150;
      case ControlType.slider:
        return 180;
      case ControlType.input:
        return 200;
      case ControlType.dropdown:
        return 160;
      default:
        return 150;
    }
  }
}
