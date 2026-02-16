import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/app_spacing.dart';
import '../constants/status_colors.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard/quick_actions.dart';
import '../widgets/dashboard/recent_activities.dart';
import '../widgets/dashboard/stat_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardStatsProvider.notifier).load());
  }

  String _formatRevenue(double value) {
    return '${value.toStringAsFixed(2)} KM';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statsState = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          if (statsState.isLoading && statsState.data == null)
            const Center(child: CircularProgressIndicator())
          else if (statsState.error != null && statsState.data == null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(statsState.error!, style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => ref.read(dashboardStatsProvider.notifier).load(),
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            )
          else ...[
            if (statsState.isLoading) const LinearProgressIndicator(),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.users,
                    label: 'Ukupno članova',
                    value: '${statsState.data?.totalMembers ?? 0}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.creditCard,
                    label: 'Aktivne članarine',
                    value: '${statsState.data?.activeMemberships ?? 0}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.alertTriangle,
                    label: 'Ističu uskoro',
                    value: '${statsState.data?.expiringSoon ?? 0}',
                    valueColor: StatusColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.banknote,
                    label: 'Prihod (mjesec)',
                    value: _formatRevenue(statsState.data?.monthlyRevenue ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 280, child: QuickActions()),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: RecentActivities()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
