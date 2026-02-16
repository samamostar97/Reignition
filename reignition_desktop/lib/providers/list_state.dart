import 'package:reignition_core/reignition_core.dart';

class ListState<T, TFilter extends BaseQueryFilter> {
  final List<T>? items;
  final int totalCount;
  final bool isLoading;
  final String? error;
  final TFilter filter;

  const ListState({
    this.items,
    this.totalCount = 0,
    this.isLoading = false,
    this.error,
    required this.filter,
  });

  int get totalPages => (totalCount / filter.pageSize).ceil();

  ListState<T, TFilter> copyWithLoading() => ListState(
        items: items,
        totalCount: totalCount,
        isLoading: true,
        error: null,
        filter: filter,
      );

  ListState<T, TFilter> copyWithData(PagedResult<T> result) => ListState(
        items: result.items,
        totalCount: result.totalCount,
        isLoading: false,
        error: null,
        filter: filter,
      );

  ListState<T, TFilter> copyWithError(String error) => ListState(
        items: items,
        totalCount: totalCount,
        isLoading: false,
        error: error,
        filter: filter,
      );

  ListState<T, TFilter> copyWithFilter(TFilter filter) => ListState(
        items: items,
        totalCount: totalCount,
        isLoading: isLoading,
        error: error,
        filter: filter,
      );
}
