import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/customer_model.dart';
import '../data/customers_repository.dart';

class CustomersListState {
  const CustomersListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.search = '',
  });

  final List<CustomerModel> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String search;

  CustomersListState copyWith({List<CustomerModel>? items, int? page, bool? hasMore, bool? loadingMore, String? search}) {
    return CustomersListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      search: search ?? this.search,
    );
  }
}

class CustomersListController extends AsyncNotifier<CustomersListState> {
  @override
  Future<CustomersListState> build() async {
    final result = await ref.watch(customersRepositoryProvider).list(page: 1);
    return CustomersListState(items: result.items, page: result.currentPage, hasMore: result.hasMore);
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(customersRepositoryProvider).list(search: query, page: 1);
      return CustomersListState(items: result.items, page: result.currentPage, hasMore: result.hasMore, search: query);
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    final result = await ref.read(customersRepositoryProvider).list(search: current.search, page: current.page + 1);

    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.items],
      page: result.currentPage,
      hasMore: result.hasMore,
      loadingMore: false,
    ));
  }
}

final customersListControllerProvider =
    AsyncNotifierProvider.autoDispose<CustomersListController, CustomersListState>(CustomersListController.new);
