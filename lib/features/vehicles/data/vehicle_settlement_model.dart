class VehicleSettlementItemModel {
  const VehicleSettlementItemModel({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.baseUnitSymbol,
    required this.loadedQty,
    required this.soldQty,
    required this.returnedQty,
    required this.expectedRemainingQty,
    required this.actualRemainingQty,
    required this.differenceQty,
    required this.reason,
  });

  final int productId;
  final String productName;
  final String productNameAr;
  final String baseUnitSymbol;
  final double loadedQty;
  final double soldQty;
  final double returnedQty;
  final double expectedRemainingQty;
  final double actualRemainingQty;
  final double differenceQty;
  final String? reason;

  factory VehicleSettlementItemModel.fromJson(Map<String, dynamic> json) => VehicleSettlementItemModel(
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        productNameAr: json['product_name_ar'] as String,
        baseUnitSymbol: json['base_unit_symbol'] as String,
        loadedQty: (json['loaded_qty'] as num).toDouble(),
        soldQty: (json['sold_qty'] as num).toDouble(),
        returnedQty: (json['returned_qty'] as num).toDouble(),
        expectedRemainingQty: (json['expected_remaining_qty'] as num).toDouble(),
        actualRemainingQty: (json['actual_remaining_qty'] as num).toDouble(),
        differenceQty: (json['difference_qty'] as num).toDouble(),
        reason: json['reason'] as String?,
      );
}

class VehicleSettlementModel {
  const VehicleSettlementModel({
    required this.id,
    required this.settlementNumber,
    required this.settlementDate,
    required this.status,
    required this.notes,
    required this.items,
  });

  final int id;
  final String settlementNumber;
  final String settlementDate;
  final String status;
  final String? notes;
  final List<VehicleSettlementItemModel> items;

  factory VehicleSettlementModel.fromJson(Map<String, dynamic> json) => VehicleSettlementModel(
        id: json['id'] as int,
        settlementNumber: json['settlement_number'] as String,
        settlementDate: json['settlement_date'] as String,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        items: (json['items'] as List? ?? []).map((i) => VehicleSettlementItemModel.fromJson(i as Map<String, dynamic>)).toList(),
      );
}
