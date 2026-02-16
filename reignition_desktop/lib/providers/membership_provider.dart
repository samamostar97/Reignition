import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import 'list_state.dart';

final membershipServiceProvider = Provider<MembershipService>((ref) => MembershipService());

final membershipListProvider = StateNotifierProvider<MembershipListNotifier,
    ListState<MembershipResponse, MembershipQueryFilter>>((ref) {
  return MembershipListNotifier(ref.read(membershipServiceProvider));
});

class MembershipListNotifier
    extends StateNotifier<ListState<MembershipResponse, MembershipQueryFilter>> {
  final MembershipService _service;

  MembershipListNotifier(this._service)
      : super(ListState(filter: MembershipQueryFilter()));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> create(CreateMembershipRequest request) async {
    await _service.createFromRequest(request);
    await load();
  }

  Future<void> update(int id, UpdateMembershipRequest request) async {
    await _service.updateFromRequest(id, request);
    await load();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    await load();
  }

  void setSearch(String search) {
    state = state.copyWithFilter(MembershipQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: search.isEmpty ? null : search,
      orderBy: state.filter.orderBy,
      userId: state.filter.userId,
      membershipTypeId: state.filter.membershipTypeId,
      status: state.filter.status,
    ));
    load();
  }

  void setStatusFilter(MembershipStatus? status) {
    state = state.copyWithFilter(MembershipQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      userId: state.filter.userId,
      membershipTypeId: state.filter.membershipTypeId,
      status: status,
    ));
    load();
  }

  void goToPage(int page) {
    state = state.copyWithFilter(MembershipQueryFilter(
      pageNumber: page,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      userId: state.filter.userId,
      membershipTypeId: state.filter.membershipTypeId,
      status: state.filter.status,
    ));
    load();
  }
}
