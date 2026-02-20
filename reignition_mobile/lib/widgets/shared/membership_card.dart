import 'package:flutter/material.dart';
import 'package:reignition_core/reignition_core.dart';

import '../../constants/app_spacing.dart';

class MembershipCard extends StatelessWidget {
  final MembershipResponse membership;
  final bool isActive;

  const MembershipCard({super.key, required this.membership, this.isActive = false});

  String _statusLabel(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return 'Aktivna';
      case MembershipStatus.expired:
        return 'Istekla';
      case MembershipStatus.cancelled:
        return 'Otkazana';
    }
  }

  Color _statusColor(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return const Color(0xFF10B981);
      case MembershipStatus.expired:
        return const Color(0xFF6B7280);
      case MembershipStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = membership.endDate.difference(DateTime.now()).inDays;
    final statusColor = _statusColor(membership.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    membership.membershipTypeName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(membership.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  '${_formatDate(membership.startDate)} — ${_formatDate(membership.endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (isActive && membership.status == MembershipStatus.active && daysLeft >= 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                daysLeft == 0
                    ? 'Ističe danas'
                    : daysLeft == 1
                        ? 'Ističe sutra'
                        : 'Preostalo $daysLeft dana',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: daysLeft <= 7 ? const Color(0xFFF59E0B) : theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
