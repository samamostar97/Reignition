import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import 'list_state.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userListProvider = StateNotifierProvider<UserListNotifier,
    ListState<UserResponse, UserQueryFilter>>((ref) {
  return UserListNotifier(ref.read(userServiceProvider));
});

final userLookupProvider = FutureProvider.autoDispose<List<LookupResponse>>((ref) {
  return ref.watch(userServiceProvider).getLookup();
});

class UserListNotifier
    extends StateNotifier<ListState<UserResponse, UserQueryFilter>> {
  final UserService _service;

  UserListNotifier(this._service)
      : super(ListState(filter: UserQueryFilter()));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> update(int id, UpdateUserRequest request) async {
    await _service.updateUser(id, request);
    await load();
  }

  void setSearch(String search) {
    state = state.copyWithFilter(UserQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: search.isEmpty ? null : search,
      orderBy: state.filter.orderBy,
      role: state.filter.role,
      isActive: state.filter.isActive,
    ));
    load();
  }

  void setActiveFilter(bool? isActive) {
    state = state.copyWithFilter(UserQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      role: state.filter.role,
      isActive: isActive,
    ));
    load();
  }

  void goToPage(int page) {
    state = state.copyWithFilter(UserQueryFilter(
      pageNumber: page,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      role: state.filter.role,
      isActive: state.filter.isActive,
    ));
    load();
  }
}
