import '../../products/data/product_model.dart';

class VehicleLoadLine {
  const VehicleLoadLine({required this.product, required this.unit, required this.quantity});

  final ProductModel product;
  final ProductUnitModel unit;

  /// Quantity expressed in [unit] (e.g. cartons) — the natural way a
  /// warehouse worker thinks about loading a truck.
  final double quantity;

  double get quantityBase => quantity * unit.conversionFactor;

  VehicleLoadLine copyWith({double? quantity}) => VehicleLoadLine(product: product, unit: unit, quantity: quantity ?? this.quantity);
}
