import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_provider.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/membership_types_screen.dart';
import '../../screens/memberships_screen.dart';
import '../../screens/users_screen.dart';
import 'sidebar.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  Widget _buildScreen(String currentRoute) {
    switch (currentRoute) {
      case '/membership-types':
        return const MembershipTypesScreen();
      case '/memberships':
        return const MembershipsScreen();
      case '/users':
        return const UsersScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentRoute = ref.watch(currentRouteProvider);

    void navigate(String route) => ref.read(currentRouteProvider.notifier).state = route;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () => navigate('/dashboard'),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () => navigate('/membership-types'),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () => navigate('/memberships'),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () => navigate('/users'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              Sidebar(
                currentRoute: currentRoute,
                onNavigate: navigate,
              ),
              VerticalDivider(width: 1, color: theme.colorScheme.outline),
              Expanded(child: _buildScreen(currentRoute)),
            ],
          ),
        ),
      ),
    );
  }
}
