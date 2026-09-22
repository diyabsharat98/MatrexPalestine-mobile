/// One row of a grouped Sales/Collections report — shape varies with
/// `group_by` (date/product/customer/representative) so most fields are
/// nullable; the caller knows which ones are populated from the `groupBy`
/// it requested.
class ReportRow {
  const ReportRow({
    this.date,
    this.id,
    required this.name,
    this.nameAr,
    this.count,
    this.quantity,
    required this.total,
  });

  final String? date;
  final int? id;
  final String name;
  final String? nameAr;
  final int? count;
  final double? quantity;
  final double total;

  factory ReportRow.fromJson(Map<String, dynamic> json) {
    final id = json['product_id'] ?? json['customer_id'] ?? json['representative_id'];
    return ReportRow(
      date: json['date'] as String?,
      id: id as int?,
      name: (json['name'] as String?) ?? (json['date'] as String?) ?? '',
      nameAr: json['name_ar'] as String?,
      count: (json['invoice_count'] ?? json['payment_count']) as int?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class ReportSummary {
  const ReportSummary({
    required this.from,
    required this.to,
    required this.groupBy,
    required this.total,
    this.count,
    required this.rows,
  });

  final String from;
  final String to;
  final String groupBy;
  final double total;
  final int? count;
  final List<ReportRow> rows;

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        from: json['from'] as String,
        to: json['to'] as String,
        groupBy: json['group_by'] as String,
        total: (json['total'] as num).toDouble(),
        count: (json['invoice_count'] ?? json['payment_count']) as int?,
        rows: (json['rows'] as List).map((r) => ReportRow.fromJson(r as Map<String, dynamic>)).toList(),
      );
}

class ProfitRow {
  const ProfitRow({
    required this.productId,
    required this.name,
    this.nameAr,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.margin,
  });

  final int productId;
  final String name;
  final String? nameAr;
  final double revenue;
  final double cost;
  final double profit;
  final double margin;

  factory ProfitRow.fromJson(Map<String, dynamic> json) => ProfitRow(
        productId: json['product_id'] as int,
        name: json['name'] as String? ?? '',
        nameAr: json['name_ar'] as String?,
        revenue: (json['revenue'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        profit: (json['profit'] as num).toDouble(),
        margin: (json['margin'] as num).toDouble(),
      );
}

class ProfitReport {
  const ProfitReport({
    required this.from,
    required this.to,
    required this.groupBy,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.margin,
    required this.rows,
  });

  final String from;
  final String to;
  final String groupBy;
  final double revenue;
  final double cost;
  final double profit;
  final double margin;
  final List<ProfitRow> rows;

  factory ProfitReport.fromJson(Map<String, dynamic> json) => ProfitReport(
        from: json['from'] as String,
        to: json['to'] as String,
        groupBy: json['group_by'] as String,
        revenue: (json['revenue'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        profit: (json['profit'] as num).toDouble(),
        margin: (json['margin'] as num).toDouble(),
        rows: (json['rows'] as List).map((r) => ProfitRow.fromJson(r as Map<String, dynamic>)).toList(),
      );
}

class ReceivablesBucket {
  const ReceivablesBucket({
    required this.current,
    required this.days1to30,
    required this.days31to60,
    required this.days61to90,
    required this.daysOver90,
  });

  final double current;
  final double days1to30;
  final double days31to60;
  final double days61to90;
  final double daysOver90;

  factory ReceivablesBucket.fromJson(Map<String, dynamic> json) => ReceivablesBucket(
        current: (json['current'] as num).toDouble(),
        days1to30: (json['days_1_30'] as num).toDouble(),
        days31to60: (json['days_31_60'] as num).toDouble(),
        days61to90: (json['days_61_90'] as num).toDouble(),
        daysOver90: (json['days_over_90'] as num).toDouble(),
      );
}

class ReceivableCustomerBalance {
  const ReceivableCustomerBalance({
    required this.customerId,
    required this.name,
    required this.nameAr,
    required this.balance,
  });

  final int customerId;
  final String name;
  final String nameAr;
  final double balance;

  factory ReceivableCustomerBalance.fromJson(Map<String, dynamic> json) => ReceivableCustomerBalance(
        customerId: json['customer_id'] as int,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
        balance: (json['balance'] as num).toDouble(),
      );
}

class ReceivablesAging {
  const ReceivablesAging({required this.buckets, required this.total, required this.customers});

  final ReceivablesBucket buckets;
  final double total;
  final List<ReceivableCustomerBalance> customers;

  factory ReceivablesAging.fromJson(Map<String, dynamic> json) => ReceivablesAging(
        buckets: ReceivablesBucket.fromJson(json['buckets'] as Map<String, dynamic>),
        total: (json['total'] as num).toDouble(),
        customers: (json['customers'] as List)
            .map((c) => ReceivableCustomerBalance.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class StockMovementRow {
  const StockMovementRow({
    required this.id,
    required this.type,
    required this.productName,
    required this.productNameAr,
    required this.warehouseName,
    required this.quantityChange,
    required this.balanceAfter,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String productName;
  final String productNameAr;
  final String? warehouseName;
  final double quantityChange;
  final double balanceAfter;
  final String createdAt;

  factory StockMovementRow.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    return StockMovementRow(
      id: json['id'] as int,
      type: json['type'] as String,
      productName: product['name'] as String,
      productNameAr: product['name_ar'] as String,
      warehouseName: warehouse?['name'] as String?,
      quantityChange: (json['quantity_change'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }
}
