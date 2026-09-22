class VehicleLoadItemModel {
  const VehicleLoadItemModel({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.baseUnitSymbol,
    required this.quantityBase,
  });

  final int productId;
  final String productName;
  final String productNameAr;
  final String baseUnitSymbol;
  final double quantityBase;

  factory VehicleLoadItemModel.fromJson(Map<String, dynamic> json) => VehicleLoadItemModel(
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        productNameAr: json['product_name_ar'] as String,
        baseUnitSymbol: json['base_unit_symbol'] as String,
        quantityBase: (json['quantity_base'] as num).toDouble(),
      );
}

class VehicleLoadModel {
  const VehicleLoadModel({
    required this.id,
    required this.loadNumber,
    required this.loadDate,
    required this.status,
    required this.vehicleName,
    required this.salesRepId,
    required this.salesRepName,
    required this.warehouseId,
    required this.items,
  });

  final int id;
  final String loadNumber;
  final String loadDate;
  final String status;
  final String? vehicleName;
  final int? salesRepId;
  final String? salesRepName;
  final int warehouseId;
  final List<VehicleLoadItemModel> items;

  bool get isOpen => status == 'loaded';

  factory VehicleLoadModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final salesRep = json['sales_rep'] as Map<String, dynamic>?;
    return VehicleLoadModel(
      id: json['id'] as int,
      loadNumber: json['load_number'] as String,
      loadDate: json['load_date'] as String,
      status: json['status'] as String,
      vehicleName: vehicle?['name'] as String?,
      salesRepId: salesRep?['id'] as int?,
      salesRepName: salesRep?['name'] as String?,
      warehouseId: json['warehouse_id'] as int,
      items: (json['items'] as List? ?? []).map((i) => VehicleLoadItemModel.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class VehicleStockRow {
  const VehicleStockRow({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.baseUnitSymbol,
    required this.loadedQty,
    required this.soldQty,
    required this.returnedQty,
    required this.expectedRemainingQty,
  });

  final int productId;
  final String productName;
  final String productNameAr;
  final String baseUnitSymbol;
  final double loadedQty;
  final double soldQty;
  final double returnedQty;
  final double expectedRemainingQty;

  factory VehicleStockRow.fromJson(Map<String, dynamic> json) => VehicleStockRow(
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        productNameAr: json['product_name_ar'] as String,
        baseUnitSymbol: json['base_unit_symbol'] as String,
        loadedQty: (json['loaded_qty'] as num).toDouble(),
        soldQty: (json['sold_qty'] as num).toDouble(),
        returnedQty: (json['returned_qty'] as num).toDouble(),
        expectedRemainingQty: (json['expected_remaining_qty'] as num).toDouble(),
      );
}
