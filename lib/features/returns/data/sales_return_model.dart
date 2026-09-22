class SalesReturnItemModel {
  const SalesReturnItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitSymbol,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int id;
  final int productId;
  final String productName;
  final String? unitSymbol;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  factory SalesReturnItemModel.fromJson(Map<String, dynamic> json) => SalesReturnItemModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        unitSymbol: json['unit_symbol'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unit_price'] as num).toDouble(),
        lineTotal: (json['line_total'] as num).toDouble(),
      );
}

class SalesReturnModel {
  const SalesReturnModel({
    required this.id,
    required this.returnNumber,
    required this.returnDate,
    required this.customerName,
    required this.salesInvoiceNumber,
    required this.total,
    required this.status,
    required this.items,
  });

  final int id;
  final String returnNumber;
  final String returnDate;
  final String? customerName;
  final String? salesInvoiceNumber;
  final double total;
  final String status;
  final List<SalesReturnItemModel> items;

  factory SalesReturnModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return SalesReturnModel(
      id: json['id'] as int,
      returnNumber: json['return_number'] as String,
      returnDate: json['return_date'] as String,
      customerName: customer?['name'] as String?,
      salesInvoiceNumber: json['sales_invoice_number'] as String?,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      items: (json['items'] as List? ?? []).map((i) => SalesReturnItemModel.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}
