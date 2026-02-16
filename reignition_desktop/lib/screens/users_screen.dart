import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../constants/status_colors.dart';
import '../providers/list_state.dart';
import '../providers/user_provider.dart';
import '../widgets/shared/app_snackbars.dart';
import '../widgets/shared/hoverable_row.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/shimmer_rows.dart';
import '../widgets/shared/status_badge.dart';
import 'user_form_dialog.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userListProvider.notifier).load());
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
      ref.read(userListProvider.notifier).setSearch(value);
    });
  }

  Future<void> _openForm(UserResponse item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(item: item),
    );
    if (result == true && mounted) {
      AppSnackbars.success(context, 'Korisnik uspješno ažuriran.');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Korisnici', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Pretraži korisnike...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(userListProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _ActiveFilterChips(
                current: state.filter.isActive,
                onChanged: (a) => ref.read(userListProvider.notifier).setActiveFilter(a),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildContent(state, theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ListState<UserResponse, UserQueryFilter> state, ThemeData theme) {
    if (state.error != null && state.items == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => ref.read(userListProvider.notifier).load(),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }
    if (state.items == null) {
      return const ShimmerRows(columnFlex: [3, 2, 3, 2, 2]);
    }
    if (state.items!.isEmpty) {
      final hasSearch = state.filter.search != null && state.filter.search!.isNotEmpty;
      final hasFilter = state.filter.role != null || state.filter.isActive != null;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.users, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasSearch
                  ? 'Nema rezultata za "${state.filter.search}"'
                  : hasFilter
                      ? 'Nema korisnika sa ovim filterima'
                      : 'Nema korisnika',
              style: theme.textTheme.bodyLarge,
            ),
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
              _headerCell('Ime i prezime', flex: 3),
              _headerCell('Korisničko ime', flex: 2),
              _headerCell('Email', flex: 3),
              _headerCell('Status', flex: 2),
              _headerCell('Registrovan', flex: 2),
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
          onPageChanged: (page) => ref.read(userListProvider.notifier).goToPage(page),
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

  Widget _buildRow(UserResponse item, ThemeData theme) {
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
            child: Text(item.fullName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 2, child: Text(item.username, style: theme.textTheme.bodyMedium)),
          Expanded(flex: 3, child: Text(item.email, style: theme.textTheme.bodyMedium)),
          Expanded(
            flex: 2,
            child: StatusBadge(
              label: item.isActive ? 'Aktivan' : 'Neaktivan',
              color: item.isActive ? StatusColors.success : StatusColors.neutral,
            ),
          ),
          Expanded(flex: 2, child: Text(_formatDate(item.createdAt), style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  final bool? current;
  final void Function(bool?) onChanged;

  const _ActiveFilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _chip(context, theme, 'Svi', null),
        const SizedBox(width: AppSpacing.xs),
        _chip(context, theme, 'Aktivni', true),
        const SizedBox(width: AppSpacing.xs),
        _chip(context, theme, 'Neaktivni', false),
      ],
    );
  }

  Widget _chip(BuildContext context, ThemeData theme, String label, bool? isActive) {
    final isSelected = current == isActive;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(isActive),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
