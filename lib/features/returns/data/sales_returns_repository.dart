import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import 'sales_return_model.dart';

class SalesReturnsRepository {
  SalesReturnsRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<SalesReturnModel>> list({int? customerId, int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/sales-returns', queryParameters: {
        'customer_id': ?customerId,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, SalesReturnModel.fromJson);
    });
  }

  Future<SalesReturnModel> create({
    required String uuid,
    required int salesInvoiceId,
    required List<({int salesInvoiceItemId, double quantity})> items,
    String? notes,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/sales-returns', data: {
        'uuid': uuid,
        'sales_invoice_id': salesInvoiceId,
        'items': items.map((i) => {'sales_invoice_item_id': i.salesInvoiceItemId, 'quantity': i.quantity}).toList(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return SalesReturnModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }
}

final salesReturnsRepositoryProvider = Provider<SalesReturnsRepository>((ref) {
  return SalesReturnsRepository(ref.watch(dioProvider));
});
