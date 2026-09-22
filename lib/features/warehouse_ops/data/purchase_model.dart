class PurchaseModel {
  const PurchaseModel({
    required this.id,
    required this.purchaseNumber,
    required this.purchaseDate,
    required this.supplierName,
    required this.total,
    required this.status,
  });

  final int id;
  final String purchaseNumber;
  final String purchaseDate;
  final String? supplierName;
  final double total;
  final String status;

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplier'] as Map<String, dynamic>?;
    return PurchaseModel(
      id: json['id'] as int,
      purchaseNumber: json['purchase_number'] as String,
      purchaseDate: json['purchase_date'] as String,
      supplierName: supplier?['name'] as String?,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
