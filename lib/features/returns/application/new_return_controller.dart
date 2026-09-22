import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/sync_outbox_service.dart';
import '../../../core/sync/submit_result.dart';
import '../../../core/sync/sync_manager.dart';
import '../../customers/data/customer_model.dart';
import '../../sales/data/sale_model.dart';
import '../data/sales_return_model.dart';
import '../data/sales_returns_repository.dart';

class NewReturnState {
  const NewReturnState({this.customer, this.invoice, this.quantities = const {}});

  final CustomerModel? customer;
  final SaleModel? invoice;

  /// sales_invoice_item_id -> quantity to return (in the item's original unit)
  final Map<int, double> quantities;

  double lineTotal(SaleItemModel item) => (quantities[item.id] ?? 0) * item.unitPrice;

  double get total => invoice == null ? 0 : invoice!.items.fold(0.0, (sum, item) => sum + lineTotal(item));

  NewReturnState copyWith({CustomerModel? customer, SaleModel? invoice, Map<int, double>? quantities}) {
    return NewReturnState(
      customer: customer ?? this.customer,
      invoice: invoice ?? this.invoice,
      quantities: quantities ?? this.quantities,
    );
  }
}

class NewReturnController extends Notifier<NewReturnState> {
  @override
  NewReturnState build() => const NewReturnState();

  void setCustomer(CustomerModel customer) => state = NewReturnState(customer: customer);

  void setInvoice(SaleModel invoice) => state = state.copyWith(invoice: invoice, quantities: {});

  void setQuantity(int invoiceItemId, double quantity) {
    final updated = {...state.quantities, invoiceItemId: quantity};
    state = state.copyWith(quantities: updated);
  }

  /// Mirrors [NewSaleController.submit]'s online-first, queue-on-network-
  /// failure fallback (spec section 2) — see that method for the reasoning.
  Future<SubmitResult<SalesReturnModel>> submit() async {
    final invoice = state.invoice;
    if (invoice == null) {
      throw StateError('invoice_required');
    }

    final items = state.quantities.entries
        .where((e) => e.value > 0)
        .map((e) => (salesInvoiceItemId: e.key, quantity: e.value))
        .toList();

    final uuid = const Uuid().v4();

    if (ref.read(isOnlineProvider)) {
      try {
        final salesReturn = await ref.read(salesReturnsRepositoryProvider).create(
              uuid: uuid,
              salesInvoiceId: invoice.id,
              items: items,
            );
        return SubmitSynced(salesReturn);
      } on ApiException catch (e) {
        if (!e.isNetworkError) rethrow;
      }
    }

    await ref.read(syncOutboxServiceProvider).enqueue(
      uuid: uuid,
      type: 'return',
      payload: {
        'sales_invoice_id': invoice.id,
        'items': items.map((i) => {'sales_invoice_item_id': i.salesInvoiceItemId, 'quantity': i.quantity}).toList(),
      },
    );
    ref.invalidate(pendingSyncCountProvider);

    return SubmitQueued(uuid);
  }
}

final newReturnControllerProvider = NotifierProvider.autoDispose<NewReturnController, NewReturnState>(NewReturnController.new);
