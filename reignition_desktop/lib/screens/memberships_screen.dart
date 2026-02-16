import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../constants/status_colors.dart';
import '../providers/list_state.dart';
import '../providers/dashboard_provider.dart';
import '../providers/membership_provider.dart';
import '../widgets/shared/app_snackbars.dart';
import '../widgets/shared/delete_confirmation_dialog.dart';
import '../widgets/shared/hoverable_row.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/shimmer_rows.dart';
import '../widgets/shared/status_badge.dart';
import 'membership_form_dialog.dart';

class MembershipsScreen extends ConsumerStatefulWidget {
  const MembershipsScreen({super.key});

  @override
  ConsumerState<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends ConsumerState<MembershipsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(membershipListProvider.notifier).load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(membershipListProvider.notifier).setSearch(value);
    });
  }

  Future<void> _openForm([MembershipResponse? item]) async {
    final result = await showDialog(
      context: context,
      builder: (_) => MembershipFormDialog(item: item),
    );
    if (result != null && mounted) {
      if (item == null && result is MembershipResponse) {
        ref.read(recentActivityProvider.notifier).addActivity(RecentActivity(
          type: ActivityType.membershipCreated,
          description: 'Članarina kreirana za ${result.userFullName}',
          entityId: result.id,
          timestamp: DateTime.now(),
        ));
      }
      final action = item == null ? 'kreirana' : 'ažurirana';
      AppSnackbars.success(context, 'Članarina uspješno $action.');
    }
  }

  Future<void> _handleDelete(MembershipResponse item) async {
    final confirmed = await showDeleteConfirmation(context, item.userFullName);
    if (!confirmed) return;
    try {
      await ref.read(membershipListProvider.notifier).delete(item.id);
      if (mounted) AppSnackbars.success(context, 'Članarina za "${item.userFullName}" obrisana.');
    } on ApiException catch (e) {
      if (mounted) AppSnackbars.error(context, e.message);
    }
  }

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
        return StatusColors.success;
      case MembershipStatus.expired:
        return StatusColors.neutral;
      case MembershipStatus.cancelled:
        return StatusColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipListProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Članarine', style: theme.textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Nova članarina'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Search + Status filter
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Pretraži po korisniku...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(membershipListProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _StatusFilterChips(
                current: state.filter.status,
                onChanged: (s) => ref.read(membershipListProvider.notifier).setStatusFilter(s),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildContent(state, theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ListState<MembershipResponse, MembershipQueryFilter> state, ThemeData theme) {
    if (state.error != null && state.items == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => ref.read(membershipListProvider.notifier).load(),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }
    if (state.items == null) {
      return const ShimmerRows(columnFlex: [3, 2, 2, 2, 2]);
    }
    if (state.items!.isEmpty) {
      final hasSearch = state.filter.search != null && state.filter.search!.isNotEmpty;
      final hasFilter = state.filter.status != null;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.creditCard, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasSearch
                  ? 'Nema rezultata za "${state.filter.search}"'
                  : hasFilter
                      ? 'Nema članarina sa ovim statusom'
                      : 'Nema članarina',
              style: theme.textTheme.bodyLarge,
            ),
            if (!hasSearch && !hasFilter) ...[
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: () => _openForm(), child: const Text('Dodaj članarinu')),
            ],
          ],
        ),
      );
    }

    final items = state.items!;
    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
          ),
          child: Row(
            children: [
              _headerCell('Korisnik', flex: 3),
              _headerCell('Tip', flex: 2),
              _headerCell('Početak', flex: 2),
              _headerCell('Kraj', flex: 2),
              _headerCell('Status', flex: 2),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _buildRow(items[index], theme),
          ),
        ),
        PaginationControls(
          currentPage: state.filter.pageNumber,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          pageSize: state.filter.pageSize,
          onPageChanged: (page) => ref.read(membershipListProvider.notifier).goToPage(page),
        ),
      ],
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
    );
  }

  Widget _buildRow(MembershipResponse item, ThemeData theme) {
    return HoverableRow(
      onTap: () => _openForm(item),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.userFullName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 2, child: Text(item.membershipTypeName, style: theme.textTheme.bodyMedium)),
          Expanded(flex: 2, child: Text(_formatDate(item.startDate), style: theme.textTheme.bodyMedium)),
          Expanded(flex: 2, child: Text(_formatDate(item.endDate), style: theme.textTheme.bodyMedium)),
          Expanded(
            flex: 2,
            child: StatusBadge(label: _statusLabel(item.status), color: _statusColor(item.status)),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: Icon(LucideIcons.trash2, size: 16, color: theme.colorScheme.error),
              onPressed: () => _handleDelete(item),
              tooltip: 'Obriši',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  final MembershipStatus? current;
  final void Function(MembershipStatus?) onChanged;

  const _StatusFilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _chip(context, theme, 'Sve', null),
        const SizedBox(width: AppSpacing.xs),
        _chip(context, theme, 'Aktivne', MembershipStatus.active),
        const SizedBox(width: AppSpacing.xs),
        _chip(context, theme, 'Istekle', MembershipStatus.expired),
        const SizedBox(width: AppSpacing.xs),
        _chip(context, theme, 'Otkazane', MembershipStatus.cancelled),
      ],
    );
  }

  Widget _chip(BuildContext context, ThemeData theme, String label, MembershipStatus? status) {
    final isSelected = current == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(status),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
