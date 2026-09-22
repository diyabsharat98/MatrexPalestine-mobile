import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import 'report_models.dart';

/// Spec section 22 "Reports on Mobile" — thin client over the read-only
/// aggregate report endpoints (Sales/Collections/Profit are computed
/// server-side from posted transactions, never faked/derived on-device).
class ReportsRepository {
  ReportsRepository(this._dio);

  final Dio _dio;

  Future<ReportSummary> sales({required String from, required String to, String groupBy = 'none'}) {
    return guardApiCall(() async {
      final response = await _dio.get('/reports/sales', queryParameters: {'from': from, 'to': to, 'group_by': groupBy});
      return ReportSummary.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<ReportSummary> collections({required String from, required String to, String groupBy = 'none'}) {
    return guardApiCall(() async {
      final response = await _dio.get('/reports/collections', queryParameters: {'from': from, 'to': to, 'group_by': groupBy});
      return ReportSummary.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<ProfitReport> profit({required String from, required String to, String groupBy = 'none'}) {
    return guardApiCall(() async {
      final response = await _dio.get('/reports/profit', queryParameters: {'from': from, 'to': to, 'group_by': groupBy});
      return ProfitReport.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<ReceivablesAging> receivables() {
    return guardApiCall(() async {
      final response = await _dio.get('/receivables');
      return ReceivablesAging.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<PaginatedResponse<StockMovementRow>> stockMovements({
    int? productId,
    String? type,
    String? from,
    String? to,
    int page = 1,
  }) {
    return guardApiCall(() async {
      final response = await _dio.get('/stock-movements', queryParameters: {
        'product_id': ?productId,
        'type': ?(type?.isNotEmpty == true ? type : null),
        'from': ?from,
        'to': ?to,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, StockMovementRow.fromJson);
    });
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.watch(dioProvider));
});
