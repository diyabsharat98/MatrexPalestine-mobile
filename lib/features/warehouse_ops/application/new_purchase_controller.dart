import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/product_model.dart';
import '../../vehicles/data/vehicle_model.dart';
import '../data/warehouse_ops_repository.dart';

class PurchaseLine {
  const PurchaseLine({required this.product, required this.unit, required this.quantity, required this.unitCost});

  final ProductModel product;
  final ProductUnitModel unit;
  final double quantity;
  final double unitCost;

  double get lineTotal => quantity * unitCost;

  PurchaseLine copyWith({double? quantity, double? unitCost}) => PurchaseLine(
        product: product,
        unit: unit,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
      );
}

class NewPurchaseState {
  const NewPurchaseState({this.supplier, this.lines = const []});

  final SupplierModel? supplier;
  final List<PurchaseLine> lines;

  double get total => lines.fold(0.0, (sum, l) => sum + l.lineTotal);

  NewPurchaseState copyWith({SupplierModel? supplier, List<PurchaseLine>? lines}) {
    return NewPurchaseState(supplier: supplier ?? this.supplier, lines: lines ?? this.lines);
  }
}

class NewPurchaseController extends Notifier<NewPurchaseState> {
  @override
  NewPurchaseState build() => const NewPurchaseState();

  void setSupplier(SupplierModel supplier) => state = state.copyWith(supplier: supplier);

  void addProduct(ProductModel product) {
    final unit = product.defaultSaleUnit;
    if (state.lines.any((l) => l.product.id == product.id)) return;
    state = state.copyWith(lines: [
      ...state.lines,
      PurchaseLine(product: product, unit: unit, quantity: 1, unitCost: unit.sellingPrice * 0.7),
    ]);
  }

  void updateLine(int index, {double? quantity, double? unitCost}) {
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(quantity: quantity, unitCost: unitCost);
    state = state.copyWith(lines: updated);
  }

  void removeLine(int index) {
    final updated = [...state.lines]..removeAt(index);
    state = state.copyWith(lines: updated);
  }

  Future<void> submit(int warehouseId) async {
    final supplier = state.supplier;
    if (supplier == null || state.lines.isEmpty) {
      throw StateError('incomplete_purchase');
    }

    await ref.read(warehouseOpsRepositoryProvider).createPurchase(
          supplierId: supplier.id,
          warehouseId: warehouseId,
          items: state.lines
              .map((l) => (productId: l.product.id, productUnitId: l.unit.id, quantity: l.quantity, unitCost: l.unitCost))
              .toList(),
        );
  }
}

final newPurchaseControllerProvider = NotifierProvider.autoDispose<NewPurchaseController, NewPurchaseState>(NewPurchaseController.new);
