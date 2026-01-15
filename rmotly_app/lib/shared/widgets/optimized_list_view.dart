import 'package:flutter/material.dart';

/// Optimized list view with automatic virtualization and item memoization.
///
/// This widget provides efficient rendering for large lists by:
/// 1. Using ListView.builder for virtualization
/// 2. Wrapping items in RepaintBoundary
/// 3. Supporting pull-to-refresh
/// 4. Handling loading and error states
///
/// Use this instead of ListView when displaying dynamic lists.
class OptimizedListView<T> extends StatelessWidget {
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.onRefresh,
    this.isLoading = false,
    this.error,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final String? error;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading && items.isEmpty) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    // Show error state
    if (error != null && items.isEmpty) {
      return errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    // Show empty state
    if (items.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('No items'),
          );
    }

    // Build list view
    final listView = separatorBuilder != null
        ? ListView.separated(
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
            reverse: reverse,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: itemBuilder(context, items[index], index),
              );
            },
            separatorBuilder: separatorBuilder!,
          )
        : ListView.builder(
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
            reverse: reverse,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: itemBuilder(context, items[index], index),
              );
            },
          );

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}

/// Optimized grid view with automatic virtualization.
///
/// Similar to OptimizedListView but for grid layouts.
class OptimizedGridView<T> extends StatelessWidget {
  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.onRefresh,
    this.isLoading = false,
    this.error,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final String? error;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading && items.isEmpty) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    // Show error state
    if (error != null && items.isEmpty) {
      return errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    // Show empty state
    if (items.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('No items'),
          );
    }

    // Build grid view
    final gridView = GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, items[index], index),
        );
      },
    );

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: gridView,
      );
    }

    return gridView;
  }
}
