import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../providers/membership_provider.dart';
import '../widgets/shared/membership_card.dart';

class MembershipsScreen extends ConsumerWidget {
  const MembershipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberships = ref.watch(myMembershipsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Moje članarine')),
      body: memberships.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.alertCircle, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  error is ApiException ? error.message : 'Greška pri učitavanju.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.invalidate(myMembershipsProvider),
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.creditCard, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: AppSpacing.md),
                  Text('Nemate aktivnih članarina.', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          final active = items.where((m) => m.status == MembershipStatus.active).toList();
          final history = items.where((m) => m.status != MembershipStatus.active).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myMembershipsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (active.isNotEmpty) ...[
                  Text('Aktivna članarina', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...active.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MembershipCard(membership: m, isActive: true),
                      )),
                ],
                if (history.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('Historija', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...history.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MembershipCard(membership: m),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
