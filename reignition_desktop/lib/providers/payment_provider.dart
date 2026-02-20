import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import 'list_state.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

final paymentListProvider = StateNotifierProvider<PaymentListNotifier,
    ListState<PaymentResponse, PaymentQueryFilter>>((ref) {
  return PaymentListNotifier(ref.read(paymentServiceProvider));
});

final membershipLookupForPaymentProvider =
    FutureProvider.autoDispose<List<LookupResponse>>((ref) {
  return ref.watch(paymentServiceProvider).getLookup();
});

class PaymentListNotifier
    extends StateNotifier<ListState<PaymentResponse, PaymentQueryFilter>> {
  final PaymentService _service;

  PaymentListNotifier(this._service)
      : super(ListState(filter: PaymentQueryFilter()));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> create(CreatePaymentRequest request) async {
    await _service.createFromRequest(request);
    await load();
  }

  Future<void> update(int id, UpdatePaymentRequest request) async {
    await _service.updateFromRequest(id, request);
    await load();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    await load();
  }

  void setSearch(String search) {
    state = state.copyWithFilter(PaymentQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: search.isEmpty ? null : search,
      orderBy: state.filter.orderBy,
      paymentMethod: state.filter.paymentMethod,
      status: state.filter.status,
      dateFrom: state.filter.dateFrom,
      dateTo: state.filter.dateTo,
    ));
    load();
  }

  void setStatusFilter(PaymentStatus? status) {
    state = state.copyWithFilter(PaymentQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      paymentMethod: state.filter.paymentMethod,
      status: status,
      dateFrom: state.filter.dateFrom,
      dateTo: state.filter.dateTo,
    ));
    load();
  }

  void goToPage(int page) {
    state = state.copyWithFilter(PaymentQueryFilter(
      pageNumber: page,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      paymentMethod: state.filter.paymentMethod,
      status: state.filter.status,
      dateFrom: state.filter.dateFrom,
      dateTo: state.filter.dateTo,
    ));
    load();
  }
}
