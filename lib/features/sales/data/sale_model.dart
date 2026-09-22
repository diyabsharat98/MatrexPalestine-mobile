class SaleItemModel {
  const SaleItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitSymbol,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.lineTotal,
  });

  final int id;
  final int productId;
  final String productName;
  final String unitSymbol;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double lineTotal;

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        unitSymbol: json['unit_symbol'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unit_price'] as num).toDouble(),
        discountAmount: (json['discount_amount'] as num).toDouble(),
        lineTotal: (json['line_total'] as num).toDouble(),
      );
}

class SaleModel {
  const SaleModel({
    required this.id,
    required this.uuid,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerId,
    required this.customerName,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    required this.status,
    required this.items,
  });

  final int id;
  final String uuid;
  final String invoiceNumber;
  final String invoiceDate;
  final int? customerId;
  final String? customerName;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final String paymentMethod;
  final String status;
  final List<SaleItemModel> items;

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return SaleModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: json['invoice_date'] as String,
      customerId: customer?['id'] as int?,
      customerName: customer?['name'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      items: (json['items'] as List? ?? []).map((i) => SaleItemModel.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }

  /// Round-trips through the same shape [fromJson] expects — used to
  /// persist this invoice in the offline "previous invoices" cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'invoice_number': invoiceNumber,
        'invoice_date': invoiceDate,
        'customer': customerId != null ? {'id': customerId, 'name': customerName} : null,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'total': total,
        'paid_amount': paidAmount,
        'remaining_amount': remainingAmount,
        'payment_method': paymentMethod,
        'status': status,
        'items': items
            .map((i) => {
                  'id': i.id,
                  'product_id': i.productId,
                  'product_name': i.productName,
                  'unit_symbol': i.unitSymbol,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                  'discount_amount': i.discountAmount,
                  'line_total': i.lineTotal,
                })
            .toList(),
      };
}
