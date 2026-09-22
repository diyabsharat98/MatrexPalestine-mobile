import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sale_model.dart';
import '../data/sales_repository.dart';

class SalesListState {
  const SalesListState({this.items = const [], this.page = 1, this.hasMore = true, this.loadingMore = false});

  final List<SaleModel> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  SalesListState copyWith({List<SaleModel>? items, int? page, bool? hasMore, bool? loadingMore}) {
    return SalesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class SalesListController extends AsyncNotifier<SalesListState> {
  @override
  Future<SalesListState> build() async {
    final result = await ref.watch(salesRepositoryProvider).list(page: 1);
    return SalesListState(items: result.items, page: result.currentPage, hasMore: result.hasMore);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    final result = await ref.read(salesRepositoryProvider).list(page: current.page + 1);

    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.items],
      page: result.currentPage,
      hasMore: result.hasMore,
      loadingMore: false,
    ));
  }
}

final salesListControllerProvider =
    AsyncNotifierProvider.autoDispose<SalesListController, SalesListState>(SalesListController.new);
