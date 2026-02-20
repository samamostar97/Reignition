import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/app_spacing.dart';
import '../providers/auth_provider.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                user != null
                    ? '${user.firstName[0]}${user.lastName[0]}'
                    : '?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              user?.fullName ?? '',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _InfoRow(icon: LucideIcons.mail, label: 'Email', value: user?.email ?? '—'),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(icon: LucideIcons.phone, label: 'Telefon', value: user?.phoneNumber ?? '—'),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(icon: LucideIcons.atSign, label: 'Korisničko ime', value: user?.username ?? '—'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: Icon(LucideIcons.keyRound, color: theme.colorScheme.primary),
              title: const Text('Promijeni lozinku'),
              trailing: const Icon(LucideIcons.chevronRight, size: 18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: () => _handleLogout(context, ref),
            icon: Icon(LucideIcons.logOut, size: 18, color: theme.colorScheme.error),
            label: Text('Odjavi se', style: TextStyle(color: theme.colorScheme.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: AppSpacing.sm + 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
