import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../constants/app_spacing.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final from = (currentPage - 1) * pageSize + 1;
    final to = min(currentPage * pageSize, totalCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            'Prikazano $from–$to od $totalCount',
            style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            tooltip: 'Prethodna',
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              '$currentPage / $totalPages',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, size: 18),
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            tooltip: 'Sljedeća',
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
