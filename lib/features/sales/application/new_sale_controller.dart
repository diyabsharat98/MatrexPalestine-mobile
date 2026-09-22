import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/sync_outbox_service.dart';
import '../../../core/sync/submit_result.dart';
import '../../../core/sync/sync_manager.dart';
import '../../auth/application/auth_controller.dart';
import '../../customers/data/customer_model.dart';
import '../../products/data/product_model.dart';
import '../data/sale_model.dart';
import '../data/sales_repository.dart';

class CartLine {
  const CartLine({required this.product, required this.unit, required this.quantity, this.discountAmount = 0});

  final ProductModel product;
  final ProductUnitModel unit;
  final double quantity;
  final double discountAmount;

  double get lineTotal => (quantity * unit.sellingPrice) - discountAmount;

  CartLine copyWith({double? quantity, double? discountAmount}) => CartLine(
        product: product,
        unit: unit,
        quantity: quantity ?? this.quantity,
        discountAmount: discountAmount ?? this.discountAmount,
      );
}

class NewSaleState {
  const NewSaleState({
    this.customer,
    this.lines = const [],
    this.paymentMethod = 'cash',
    this.paidAmount = 0,
    this.discountAmount = 0,
    this.notes = '',
  });

  final CustomerModel? customer;
  final List<CartLine> lines;
  final String paymentMethod;
  final double paidAmount;
  final double discountAmount;
  final String notes;

  double get subtotal => lines.fold(0, (sum, l) => sum + (l.quantity * l.unit.sellingPrice));

  double get total => subtotal - discountAmount;

  double get remaining => total - paidAmount;

  NewSaleState copyWith({
    CustomerModel? customer,
    List<CartLine>? lines,
    String? paymentMethod,
    double? paidAmount,
    double? discountAmount,
    String? notes,
  }) {
    return NewSaleState(
      customer: customer ?? this.customer,
      lines: lines ?? this.lines,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
    );
  }
}

class NewSaleController extends Notifier<NewSaleState> {
  @override
  NewSaleState build() => const NewSaleState();

  void setCustomer(CustomerModel customer) => state = state.copyWith(customer: customer);

  void addProduct(ProductModel product) {
    final unit = product.defaultSaleUnit;
    final existingIndex = state.lines.indexWhere((l) => l.product.id == product.id && l.unit.id == unit.id);

    if (existingIndex >= 0) {
      final updated = [...state.lines];
      updated[existingIndex] = updated[existingIndex].copyWith(quantity: updated[existingIndex].quantity + 1);
      state = state.copyWith(lines: updated);
    } else {
      state = state.copyWith(lines: [...state.lines, CartLine(product: product, unit: unit, quantity: 1)]);
    }
  }

  void updateQuantity(int index, double quantity) {
    if (quantity <= 0) {
      removeLine(index);
      return;
    }
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(quantity: quantity);
    state = state.copyWith(lines: updated);
  }

  void removeLine(int index) {
    final updated = [...state.lines]..removeAt(index);
    state = state.copyWith(lines: updated);
  }

  void setPaymentMethod(String method) => state = state.copyWith(paymentMethod: method);

  void setPaidAmount(double amount) => state = state.copyWith(paidAmount: amount);

  void setDiscount(double amount) => state = state.copyWith(discountAmount: amount);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  /// Tries the API when online; if that fails purely for network reasons
  /// (or there's no connection at all), the sale is queued in the local
  /// outbox instead of being lost — spec section 2's core offline
  /// requirement. A genuine business/validation error (insufficient stock,
  /// credit limit, bad input) is never silently queued: it surfaces
  /// immediately so the rep can fix it on the spot, exactly as if online.
  Future<SubmitResult<SaleModel>> submit(int actorWarehouseId) async {
    final customer = state.customer;
    if (customer == null) {
      throw StateError('customer_required');
    }

    final uuid = const Uuid().v4();
    final items = state.lines
        .map((l) => NewSaleItem(
              productId: l.product.id,
              productUnitId: l.unit.id,
              quantity: l.quantity,
              unitPrice: l.unit.sellingPrice,
              discountAmount: l.discountAmount,
            ))
        .toList();

    if (ref.read(isOnlineProvider)) {
      try {
        final sale = await ref.read(salesRepositoryProvider).create(
              uuid: uuid,
              customerId: customer.id,
              warehouseId: actorWarehouseId,
              paymentMethod: state.paymentMethod,
              items: items,
              discountAmount: state.discountAmount,
              paidAmount: state.paidAmount,
              notes: state.notes,
            );
        return SubmitSynced(sale);
      } on ApiException catch (e) {
        if (!e.isNetworkError) rethrow;
      }
    }

    await ref.read(syncOutboxServiceProvider).enqueue(
      uuid: uuid,
      type: 'sale',
      payload: {
        'customer_id': customer.id,
        'warehouse_id': actorWarehouseId,
        'payment_method': state.paymentMethod,
        'items': items.map((i) => i.toJson()).toList(),
        'discount_amount': state.discountAmount,
        'paid_amount': state.paidAmount,
        if (state.notes.isNotEmpty) 'notes': state.notes,
      },
    );
    ref.invalidate(pendingSyncCountProvider);

    return SubmitQueued(uuid);
  }
}

final newSaleControllerProvider = NotifierProvider.autoDispose<NewSaleController, NewSaleState>(NewSaleController.new);

final currentUserWarehouseIdProvider = Provider.autoDispose<int?>((ref) {
  return ref.watch(authControllerProvider).user?.warehouse?.id;
});
