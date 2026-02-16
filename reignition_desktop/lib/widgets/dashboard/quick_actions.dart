import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../../constants/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../screens/membership_form_dialog.dart';
import '../../screens/membership_type_form_dialog.dart';
import '../shared/app_snackbars.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  Future<void> _openNewMembership(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<MembershipResponse>(
      context: context,
      builder: (_) => const MembershipFormDialog(),
    );
    if (result != null && context.mounted) {
      ref.read(recentActivityProvider.notifier).addActivity(RecentActivity(
        type: ActivityType.membershipCreated,
        description: 'Članarina kreirana za ${result.userFullName}',
        entityId: result.id,
        timestamp: DateTime.now(),
      ));
      ref.read(dashboardStatsProvider.notifier).load();
      AppSnackbars.success(context, 'Članarina uspješno kreirana.');
    }
  }

  Future<void> _openNewMembershipType(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<MembershipTypeResponse>(
      context: context,
      builder: (_) => const MembershipTypeFormDialog(),
    );
    if (result != null && context.mounted) {
      ref.read(recentActivityProvider.notifier).addActivity(RecentActivity(
        type: ActivityType.membershipTypeCreated,
        description: 'Tip članarine "${result.name}" kreiran',
        entityId: result.id,
        timestamp: DateTime.now(),
      ));
      ref.read(dashboardStatsProvider.notifier).load();
      AppSnackbars.success(context, 'Tip članarine uspješno kreiran.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Brze akcije', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            icon: LucideIcons.creditCard,
            label: 'Nova članarina',
            onTap: () => _openNewMembership(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: LucideIcons.tags,
            label: 'Novi tip članarine',
            onTap: () => _openNewMembershipType(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: LucideIcons.users,
            label: 'Pregledaj korisnike',
            onTap: () => ref.read(currentRouteProvider.notifier).state = '/users',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm + 4),
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
