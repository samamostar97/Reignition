import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../constants/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final String route;

  const SidebarItem({required this.label, required this.icon, required this.route});
}

const _sidebarItems = [
  SidebarItem(label: 'Dashboard', icon: LucideIcons.layoutDashboard, route: '/dashboard'),
  SidebarItem(label: 'Tipovi članarina', icon: LucideIcons.tags, route: '/membership-types'),
  SidebarItem(label: 'Članarine', icon: LucideIcons.creditCard, route: '/memberships'),
  SidebarItem(label: 'Uplate', icon: LucideIcons.wallet, route: '/payments'),
  SidebarItem(label: 'Korisnici', icon: LucideIcons.users, route: '/users'),
];

class Sidebar extends ConsumerWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const Sidebar({super.key, required this.currentRoute, required this.onNavigate});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Da li ste sigurni da se želite odjaviti?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Otkaži')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Odjavi se')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authStateProvider.notifier).logout();
    ref.read(currentRouteProvider.notifier).state = '/dashboard';
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Container(
      width: 240,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
            child: Row(
              children: [
                Icon(LucideIcons.flame, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text('Reignition', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isActive = currentRoute == item.route;
                return _SidebarTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => onNavigate(item.route),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(LucideIcons.user, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    authState.user?.fullName ?? 'Admin',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.logOut, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  onPressed: () => _handleLogout(context, ref),
                  tooltip: 'Odjavi se',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarTile({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final bgColor = isActive ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4, vertical: AppSpacing.sm + 2),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.sm + 4),
                Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
