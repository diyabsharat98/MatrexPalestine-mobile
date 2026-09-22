import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payment_model.dart';
import '../data/payments_repository.dart';

class PaymentsListState {
  const PaymentsListState({this.items = const [], this.page = 1, this.hasMore = true, this.loadingMore = false});

  final List<PaymentModel> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  PaymentsListState copyWith({List<PaymentModel>? items, int? page, bool? hasMore, bool? loadingMore}) {
    return PaymentsListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class PaymentsListController extends AsyncNotifier<PaymentsListState> {
  @override
  Future<PaymentsListState> build() async {
    final result = await ref.watch(paymentsRepositoryProvider).list(page: 1);
    return PaymentsListState(items: result.items, page: result.currentPage, hasMore: result.hasMore);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    final result = await ref.read(paymentsRepositoryProvider).list(page: current.page + 1);

    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.items],
      page: result.currentPage,
      hasMore: result.hasMore,
      loadingMore: false,
    ));
  }
}

final paymentsListControllerProvider =
    AsyncNotifierProvider.autoDispose<PaymentsListController, PaymentsListState>(PaymentsListController.new);
