import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import 'membership_provider.dart';
import 'membership_type_provider.dart';

// ── Dashboard Stats ─────────────────────────────────────────────

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService());

class DashboardStatsState {
  final DashboardStatsResponse? data;
  final bool isLoading;
  final String? error;

  const DashboardStatsState({this.data, this.isLoading = false, this.error});

  DashboardStatsState copyWithLoading() =>
      DashboardStatsState(data: data, isLoading: true);

  DashboardStatsState copyWithData(DashboardStatsResponse data) =>
      DashboardStatsState(data: data);

  DashboardStatsState copyWithError(String error) =>
      DashboardStatsState(data: data, error: error);
}

final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStatsState>((ref) {
  return DashboardStatsNotifier(ref.read(dashboardServiceProvider));
});

class DashboardStatsNotifier extends StateNotifier<DashboardStatsState> {
  final DashboardService _service;

  DashboardStatsNotifier(this._service) : super(const DashboardStatsState());

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getStats();
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }
}

// ── Recent Activities ───────────────────────────────────────────

enum ActivityType { membershipCreated, membershipTypeCreated }

class RecentActivity {
  final ActivityType type;
  final String description;
  final int entityId;
  final DateTime timestamp;

  const RecentActivity({
    required this.type,
    required this.description,
    required this.entityId,
    required this.timestamp,
  });
}

final recentActivityProvider =
    StateNotifierProvider<RecentActivityNotifier, List<RecentActivity>>((ref) {
  return RecentActivityNotifier(
    ref.read(membershipServiceProvider),
    ref.read(membershipTypeServiceProvider),
  );
});

class RecentActivityNotifier extends StateNotifier<List<RecentActivity>> {
  final MembershipService _membershipService;
  final MembershipTypeService _membershipTypeService;

  RecentActivityNotifier(this._membershipService, this._membershipTypeService)
      : super([]);

  void addActivity(RecentActivity activity) {
    state = [activity, ...state].take(10).toList();
  }

  Future<void> undoActivity(RecentActivity activity) async {
    switch (activity.type) {
      case ActivityType.membershipCreated:
        await _membershipService.delete(activity.entityId);
      case ActivityType.membershipTypeCreated:
        await _membershipTypeService.delete(activity.entityId);
    }
    state = state.where((a) => a != activity).toList();
  }
}
