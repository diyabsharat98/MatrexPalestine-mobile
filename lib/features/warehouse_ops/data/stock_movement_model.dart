class StockMovementModel {
  const StockMovementModel({
    required this.id,
    required this.type,
    required this.productName,
    required this.warehouseName,
    required this.quantityChange,
    required this.balanceAfter,
    required this.notes,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String productName;
  final String? warehouseName;
  final double quantityChange;
  final double balanceAfter;
  final String? notes;
  final String createdAt;

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    return StockMovementModel(
      id: json['id'] as int,
      type: json['type'] as String,
      productName: product['name'] as String,
      warehouseName: warehouse?['name'] as String?,
      quantityChange: (json['quantity_change'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
