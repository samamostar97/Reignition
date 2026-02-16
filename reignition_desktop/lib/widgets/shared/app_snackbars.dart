import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';

abstract class AppSnackbars {
  static void success(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.error);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.warning);
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.info);
  }

  static void _show(BuildContext context, {
    required String message,
    required _SnackbarType type,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: type.backgroundColor,
      duration: type.duration,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: type == _SnackbarType.error
          ? SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {})
          : null,
      content: Row(
        children: [
          _AnimatedSnackbarIcon(type: type),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
    ));
  }
}

enum _SnackbarType {
  success(Color(0xFF22C55E), Duration(seconds: 3), Icons.check_circle_rounded),
  error(Color(0xFFEF4444), Duration(seconds: 5), Icons.error_rounded),
  warning(Color(0xFFF59E0B), Duration(seconds: 4), Icons.warning_rounded),
  info(Color(0xFF3B82F6), Duration(seconds: 3), Icons.info_rounded);

  final Color backgroundColor;
  final Duration duration;
  final IconData icon;
  const _SnackbarType(this.backgroundColor, this.duration, this.icon);
}

class _AnimatedSnackbarIcon extends StatefulWidget {
  final _SnackbarType type;
  const _AnimatedSnackbarIcon({required this.type});

  @override
  State<_AnimatedSnackbarIcon> createState() => _AnimatedSnackbarIconState();
}

class _AnimatedSnackbarIconState extends State<_AnimatedSnackbarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(widget.type.icon, color: Colors.white, size: 20),
    );
  }
}
