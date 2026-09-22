import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import 'payment_model.dart';

class PaymentsRepository {
  PaymentsRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<PaymentModel>> list({int? customerId, int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/payments', queryParameters: {
        'customer_id': ?customerId,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, PaymentModel.fromJson);
    });
  }

  Future<PaymentModel> create({
    required String uuid,
    required int customerId,
    required double amount,
    required String method,
    String? reference,
    String? notes,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/payments', data: {
        'uuid': uuid,
        'customer_id': customerId,
        'amount': amount,
        'method': method,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return PaymentModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(dioProvider));
});
