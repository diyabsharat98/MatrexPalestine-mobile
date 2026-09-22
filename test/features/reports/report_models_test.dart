import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/data/report_models.dart';

void main() {
  group('ReportSummary', () {
    test('parses a sales report grouped by product', () {
      final json = {
        'from': '2026-09-01',
        'to': '2026-09-21',
        'group_by': 'product',
        'invoice_count': 5,
        'total': 1080.0,
        'rows': [
          {'product_id': 1, 'name': 'Cola', 'name_ar': 'كولا', 'quantity': 24.0, 'total': 720.0},
          {'product_id': 2, 'name': 'Juice', 'name_ar': 'عصير', 'quantity': 10.0, 'total': 360.0},
        ],
      };

      final report = ReportSummary.fromJson(json);

      expect(report.groupBy, 'product');
      expect(report.count, 5);
      expect(report.total, 1080.0);
      expect(report.rows, hasLength(2));
      expect(report.rows.first.name, 'Cola');
      expect(report.rows.first.nameAr, 'كولا');
      expect(report.rows.first.quantity, 24.0);
    });

    test('parses a collections report grouped by representative using payment_count', () {
      final json = {
        'from': '2026-09-21',
        'to': '2026-09-21',
        'group_by': 'representative',
        'payment_count': 3,
        'total': 800.0,
        'rows': [
          {'representative_id': 7, 'name': 'Ahmad', 'payment_count': 3, 'total': 800.0},
        ],
      };

      final report = ReportSummary.fromJson(json);

      expect(report.count, 3);
      expect(report.rows.single.id, 7);
      expect(report.rows.single.count, 3);
    });

    test('a date-grouped row falls back to its date as the label', () {
      final row = ReportRow.fromJson({'date': '2026-09-20', 'invoice_count': 2, 'total': 250.0});

      expect(row.date, '2026-09-20');
      expect(row.name, '2026-09-20');
    });
  });

  group('ProfitReport', () {
    test('parses revenue/cost/profit/margin at both summary and row level', () {
      final json = {
        'from': '2026-09-21',
        'to': '2026-09-21',
        'group_by': 'product',
        'revenue': 36.0,
        'cost': 24.0,
        'profit': 12.0,
        'margin': 33.33,
        'rows': [
          {'product_id': 1, 'name': 'Cola', 'revenue': 36.0, 'cost': 24.0, 'profit': 12.0, 'margin': 33.33},
        ],
      };

      final report = ProfitReport.fromJson(json);

      expect(report.profit, 12.0);
      expect(report.rows.single.margin, closeTo(33.33, 0.001));
    });
  });

  group('ReceivablesAging', () {
    test('parses buckets, total and the customer balance list', () {
      final json = {
        'buckets': {
          'current': 75000.0,
          'days_1_30': 45000.0,
          'days_31_60': 25000.0,
          'days_61_90': 18000.0,
          'days_over_90': 22000.0,
        },
        'total': 185000.0,
        'customers': [
          {'customer_id': 1, 'name': 'Restaurant A', 'name_ar': 'مطعم أ', 'balance': 5300.0},
        ],
      };

      final aging = ReceivablesAging.fromJson(json);

      expect(aging.buckets.current, 75000.0);
      expect(aging.buckets.daysOver90, 22000.0);
      expect(aging.total, 185000.0);
      expect(aging.customers.single.name, 'Restaurant A');
    });
  });

  group('StockMovementRow', () {
    test('parses a movement row with nested product/warehouse', () {
      final json = {
        'id': 1,
        'type': 'sale',
        'product': {'id': 1, 'name': 'Cola', 'name_ar': 'كولا'},
        'warehouse': {'id': 1, 'name': 'Main'},
        'quantity_change': -24.0,
        'balance_after': 176.0,
        'notes': null,
        'created_at': '2026-09-21T10:00:00Z',
      };

      final row = StockMovementRow.fromJson(json);

      expect(row.type, 'sale');
      expect(row.productName, 'Cola');
      expect(row.warehouseName, 'Main');
      expect(row.quantityChange, -24.0);
    });
  });
}
