import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/products/data/product_model.dart';
import 'package:mobile/features/sales/application/new_sale_controller.dart';

ProductModel _product({required int id, required double price, double conversionFactor = 24}) {
  return ProductModel(
    id: id,
    sku: 'SKU-$id',
    barcode: null,
    name: 'Product $id',
    nameAr: 'منتج $id',
    categoryName: null,
    brandName: null,
    baseUnitSymbol: 'PC',
    costPrice: price / 2,
    sellingPrice: price,
    reorderLevel: 10,
    isActive: true,
    availableStock: null,
    units: [
      ProductUnitModel(
        id: id * 10,
        unitId: 2,
        unitName: 'Carton',
        unitNameAr: 'كرتون',
        unitSymbol: 'CTN',
        conversionFactor: conversionFactor,
        sellingPrice: price,
        isBaseUnit: false,
        isDefaultSaleUnit: true,
      ),
    ],
  );
}

void main() {
  group('NewSaleController cart math', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('adding a product creates a cart line with quantity 1', () {
      final notifier = container.read(newSaleControllerProvider.notifier);
      notifier.addProduct(_product(id: 1, price: 36));

      final state = container.read(newSaleControllerProvider);
      expect(state.lines, hasLength(1));
      expect(state.lines.first.quantity, 1);
      expect(state.subtotal, 36);
      expect(state.total, 36);
      expect(state.remaining, 36);
    });

    test('adding the same product twice increments quantity instead of duplicating', () {
      final notifier = container.read(newSaleControllerProvider.notifier);
      final product = _product(id: 1, price: 36);
      notifier.addProduct(product);
      notifier.addProduct(product);

      final state = container.read(newSaleControllerProvider);
      expect(state.lines, hasLength(1));
      expect(state.lines.first.quantity, 2);
      expect(state.subtotal, 72);
    });

    test('updateQuantity to zero removes the line', () {
      final notifier = container.read(newSaleControllerProvider.notifier);
      notifier.addProduct(_product(id: 1, price: 36));
      notifier.updateQuantity(0, 0);

      expect(container.read(newSaleControllerProvider).lines, isEmpty);
    });

    test('discount reduces the total but not the subtotal, and paid amount reduces remaining', () {
      final notifier = container.read(newSaleControllerProvider.notifier);
      notifier.addProduct(_product(id: 1, price: 100, conversionFactor: 1));
      notifier.setDiscount(10);
      notifier.setPaidAmount(50);

      final state = container.read(newSaleControllerProvider);
      expect(state.subtotal, 100);
      expect(state.total, 90);
      expect(state.remaining, 40);
    });

    test('two different products sum into the subtotal correctly', () {
      final notifier = container.read(newSaleControllerProvider.notifier);
      notifier.addProduct(_product(id: 1, price: 36));
      notifier.addProduct(_product(id: 2, price: 20));

      final state = container.read(newSaleControllerProvider);
      expect(state.subtotal, 56);
    });
  });
}
