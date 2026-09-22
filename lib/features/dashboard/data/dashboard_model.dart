class WarehouseKpis {
  const WarehouseKpis({
    required this.totalProducts,
    required this.lowStockCount,
    required this.todayReceipts,
    required this.todayIssues,
  });

  final int totalProducts;
  final int lowStockCount;
  final int todayReceipts;
  final int todayIssues;

  factory WarehouseKpis.fromJson(Map<String, dynamic> json) => WarehouseKpis(
        totalProducts: json['total_products'] as int,
        lowStockCount: json['low_stock_count'] as int,
        todayReceipts: json['today_receipts'] as int,
        todayIssues: json['today_issues'] as int,
      );
}

class DashboardModel {
  const DashboardModel({
    required this.date,
    required this.userName,
    required this.todaySales,
    required this.todayInvoicesCount,
    required this.collections,
    required this.receivables,
    this.warehouse,
  });

  final String date;
  final String userName;
  final double todaySales;
  final int todayInvoicesCount;
  final double collections;
  final double receivables;
  final WarehouseKpis? warehouse;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        date: json['date'] as String,
        userName: json['user_name'] as String,
        todaySales: (json['today_sales'] as num).toDouble(),
        todayInvoicesCount: json['today_invoices_count'] as int,
        collections: (json['collections'] as num).toDouble(),
        receivables: (json['receivables'] as num).toDouble(),
        warehouse: json['warehouse'] != null ? WarehouseKpis.fromJson(json['warehouse'] as Map<String, dynamic>) : null,
      );
}
