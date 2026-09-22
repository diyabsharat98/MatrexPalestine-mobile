import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import '../../../core/storage/reference_cache_service.dart';
import 'sale_model.dart';

class NewSaleItem {
  const NewSaleItem({
    required this.productId,
    required this.productUnitId,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0,
  });

  final int productId;
  final int productUnitId;
  final double quantity;
  final double unitPrice;
  final double discountAmount;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_unit_id': productUnitId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'discount_amount': discountAmount,
      };
}

class SalesRepository {
  SalesRepository(this._dio, this._cache);

  final Dio _dio;
  final ReferenceCacheService _cache;

  /// [cached_sales.customer_id] has no real "all invoices" concept, so `0`
  /// is used as the bucket key for an unfiltered (own) invoice list.
  static const _allBucket = 0;

  Future<PaginatedResponse<SaleModel>> list({int? customerId, int page = 1}) async {
    try {
      final result = await guardApiCall(() async {
        final response = await _dio.get('/sales', queryParameters: {
          'customer_id': ?customerId,
          'page': page,
          'per_page': 25,
        });
        return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, SaleModel.fromJson);
      });

      if (page == 1) {
        await _cache.replaceCustomerSales(
          customerId ?? _allBucket,
          result.items.map((s) => (id: s.id, json: s.toJson())).toList(),
        );
      }

      return result;
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final cached = await _cache.customerSales(customerId ?? _allBucket);
      final items = cached.map(SaleModel.fromJson).toList();
      return PaginatedResponse(items: items, currentPage: 1, lastPage: 1, total: items.length);
    }
  }

  Future<SaleModel> find(int id) async {
    try {
      return await guardApiCall(() async {
        final response = await _dio.get('/sales/$id');
        return SaleModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      for (final bucketId in [_allBucket, ...await _knownCustomerIds()]) {
        final cached = await _cache.customerSales(bucketId);
        final match = cached.map(SaleModel.fromJson).where((s) => s.id == id);
        if (match.isNotEmpty) return match.first;
      }
      rethrow;
    }
  }

  Future<SaleModel> create({
    required String uuid,
    required int customerId,
    required int warehouseId,
    required String paymentMethod,
    required List<NewSaleItem> items,
    double discountAmount = 0,
    double paidAmount = 0,
    String? notes,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/sales', data: {
        'uuid': uuid,
        'customer_id': customerId,
        'warehouse_id': warehouseId,
        'payment_method': paymentMethod,
        'items': items.map((i) => i.toJson()).toList(),
        'discount_amount': discountAmount,
        'paid_amount': paidAmount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return SaleModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<List<int>> _knownCustomerIds() async {
    final cached = await _cache.all('cached_customers');
    return cached.map((c) => c['id'] as int).toList();
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(dioProvider), ref.watch(referenceCacheServiceProvider));
});
