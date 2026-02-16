import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import 'list_state.dart';

final membershipTypeServiceProvider = Provider<MembershipTypeService>((ref) => MembershipTypeService());

final membershipTypeListProvider = StateNotifierProvider<MembershipTypeListNotifier,
    ListState<MembershipTypeResponse, MembershipTypeQueryFilter>>((ref) {
  return MembershipTypeListNotifier(ref.read(membershipTypeServiceProvider));
});

final membershipTypeLookupProvider = FutureProvider.autoDispose<List<LookupResponse>>((ref) {
  return ref.watch(membershipTypeServiceProvider).getLookup();
});

class MembershipTypeListNotifier
    extends StateNotifier<ListState<MembershipTypeResponse, MembershipTypeQueryFilter>> {
  final MembershipTypeService _service;

  MembershipTypeListNotifier(this._service)
      : super(ListState(filter: MembershipTypeQueryFilter()));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> create(CreateMembershipTypeRequest request) async {
    await _service.createFromRequest(request);
    await load();
  }

  Future<void> update(int id, UpdateMembershipTypeRequest request) async {
    await _service.updateFromRequest(id, request);
    await load();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    await load();
  }

  void setSearch(String search) {
    state = state.copyWithFilter(MembershipTypeQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: search.isEmpty ? null : search,
      orderBy: state.filter.orderBy,
      isActive: state.filter.isActive,
    ));
    load();
  }

  void goToPage(int page) {
    state = state.copyWithFilter(MembershipTypeQueryFilter(
      pageNumber: page,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      isActive: state.filter.isActive,
    ));
    load();
  }
}
