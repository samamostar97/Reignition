import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';

class ShimmerRows extends StatefulWidget {
  final int rowCount;
  final List<int> columnFlex;

  const ShimmerRows({
    super.key,
    this.rowCount = 5,
    required this.columnFlex,
  });

  @override
  State<ShimmerRows> createState() => _ShimmerRowsState();
}

class _ShimmerRowsState extends State<ShimmerRows> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.04, end: 0.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final color = theme.colorScheme.onSurface.withValues(alpha: _animation.value);
        return Column(
          children: [
            // Shimmer header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
              ),
              child: Row(
                children: widget.columnFlex.map((flex) {
                  return Expanded(
                    flex: flex,
                    child: Container(
                      height: 12,
                      margin: const EdgeInsets.only(right: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Shimmer rows
            ...List.generate(widget.rowCount, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: widget.columnFlex.map((flex) {
                    return Expanded(
                      flex: flex,
                      child: Container(
                        height: 14,
                        margin: const EdgeInsets.only(right: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
