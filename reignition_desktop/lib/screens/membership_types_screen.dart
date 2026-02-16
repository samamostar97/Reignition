import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../constants/status_colors.dart';
import '../providers/list_state.dart';
import '../providers/dashboard_provider.dart';
import '../providers/membership_type_provider.dart';
import '../widgets/shared/app_snackbars.dart';
import '../widgets/shared/delete_confirmation_dialog.dart';
import '../widgets/shared/hoverable_row.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/shimmer_rows.dart';
import '../widgets/shared/status_badge.dart';
import 'membership_type_form_dialog.dart';

class MembershipTypesScreen extends ConsumerStatefulWidget {
  const MembershipTypesScreen({super.key});

  @override
  ConsumerState<MembershipTypesScreen> createState() => _MembershipTypesScreenState();
}

class _MembershipTypesScreenState extends ConsumerState<MembershipTypesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(membershipTypeListProvider.notifier).load());
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
      ref.read(membershipTypeListProvider.notifier).setSearch(value);
    });
  }

  Future<void> _openForm([MembershipTypeResponse? item]) async {
    final result = await showDialog(
      context: context,
      builder: (_) => MembershipTypeFormDialog(item: item),
    );
    if (result != null && mounted) {
      if (item == null && result is MembershipTypeResponse) {
        ref.read(recentActivityProvider.notifier).addActivity(RecentActivity(
          type: ActivityType.membershipTypeCreated,
          description: 'Tip članarine "${result.name}" kreiran',
          entityId: result.id,
          timestamp: DateTime.now(),
        ));
      }
      final action = item == null ? 'kreiran' : 'ažuriran';
      AppSnackbars.success(context, 'Tip članarine uspješno $action.');
    }
  }

  Future<void> _handleDelete(MembershipTypeResponse item) async {
    final confirmed = await showDeleteConfirmation(context, item.name);
    if (!confirmed) return;
    try {
      await ref.read(membershipTypeListProvider.notifier).delete(item.id);
      if (mounted) AppSnackbars.success(context, 'Tip članarine "${item.name}" obrisan.');
    } on ApiException catch (e) {
      if (mounted) AppSnackbars.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipTypeListProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Tipovi članarina', style: theme.textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Novi tip'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Search
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Pretraži tipove...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(membershipTypeListProvider.notifier).setSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Content
          Expanded(child: _buildContent(state, theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ListState<MembershipTypeResponse, MembershipTypeQueryFilter> state, ThemeData theme) {
    if (state.error != null && state.items == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => ref.read(membershipTypeListProvider.notifier).load(),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }
    if (state.items == null) {
      return const ShimmerRows(columnFlex: [3, 2, 2, 2]);
    }
    if (state.items!.isEmpty) {
      final hasSearch = state.filter.search != null && state.filter.search!.isNotEmpty;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.tags, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasSearch ? 'Nema rezultata za "${state.filter.search}"' : 'Nema tipova članarina',
              style: theme.textTheme.bodyLarge,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: () => _openForm(), child: const Text('Kreiraj prvi tip')),
            ],
          ],
        ),
      );
    }

    final items = state.items!;
    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
          ),
          child: Row(
            children: [
              _headerCell('Naziv', flex: 3),
              _headerCell('Trajanje', flex: 2),
              _headerCell('Cijena', flex: 2),
              _headerCell('Status', flex: 2),
              const SizedBox(width: 48),
            ],
          ),
        ),
        // Rows
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
          onPageChanged: (page) => ref.read(membershipTypeListProvider.notifier).goToPage(page),
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

  Widget _buildRow(MembershipTypeResponse item, ThemeData theme) {
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
            child: Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text('${item.durationInDays} dana', style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text('${item.price.toStringAsFixed(2)} KM', style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(
              label: item.isActive ? 'Aktivno' : 'Neaktivno',
              color: item.isActive ? StatusColors.success : StatusColors.neutral,
            ),
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
