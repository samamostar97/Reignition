import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../../constants/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../shared/app_snackbars.dart';

class RecentActivities extends ConsumerWidget {
  const RecentActivities({super.key});

  IconData _activityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.membershipCreated:
        return LucideIcons.creditCard;
      case ActivityType.membershipTypeCreated:
        return LucideIcons.tags;
    }
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Upravo';
    if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Prije ${diff.inHours}h';
    return 'Prije ${diff.inDays}d';
  }

  Future<void> _handleUndo(BuildContext context, WidgetRef ref, RecentActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda poništavanja'),
        content: Text('Da li ste sigurni da želite poništiti: "${activity.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Poništi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(recentActivityProvider.notifier).undoActivity(activity);
      if (context.mounted) {
        ref.read(dashboardStatsProvider.notifier).load();
        AppSnackbars.success(context, 'Akcija uspješno poništena.');
      }
    } on ApiException catch (e) {
      if (context.mounted) AppSnackbars.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activities = ref.watch(recentActivityProvider);

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
          Text('Nedavne aktivnosti', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (activities.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 36, color: theme.colorScheme.outline),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Nema nedavnih aktivnosti',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          _activityIcon(activity.type),
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.description,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                _relativeTime(activity.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: () => _handleUndo(context, ref, activity),
                          icon: const Icon(LucideIcons.undo2, size: 14),
                          label: const Text('Poništi'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            textStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
