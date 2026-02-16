import 'package:flutter/material.dart';

class HoverableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;

  const HoverableRow({
    super.key,
    required this.child,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.decoration,
  });

  @override
  State<HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<HoverableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: (widget.decoration ?? const BoxDecoration()).copyWith(
            color: _isHovered ? theme.colorScheme.primary.withAlpha(10) : Colors.transparent,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
