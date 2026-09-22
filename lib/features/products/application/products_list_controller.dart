import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_model.dart';
import '../data/products_repository.dart';

class ProductsListState {
  const ProductsListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.search = '',
  });

  final List<ProductModel> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String search;

  ProductsListState copyWith({
    List<ProductModel>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? search,
  }) {
    return ProductsListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      search: search ?? this.search,
    );
  }
}

class ProductsListController extends AsyncNotifier<ProductsListState> {
  @override
  Future<ProductsListState> build() async {
    final result = await ref.watch(productsRepositoryProvider).list(page: 1);
    return ProductsListState(items: result.items, page: result.currentPage, hasMore: result.hasMore);
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(productsRepositoryProvider).list(search: query, page: 1);
      return ProductsListState(items: result.items, page: result.currentPage, hasMore: result.hasMore, search: query);
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    final nextPage = current.page + 1;
    final result = await ref.read(productsRepositoryProvider).list(search: current.search, page: nextPage);

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...result.items],
        page: result.currentPage,
        hasMore: result.hasMore,
        loadingMore: false,
      ),
    );
  }
}

final productsListControllerProvider =
    AsyncNotifierProvider.autoDispose<ProductsListController, ProductsListState>(ProductsListController.new);
