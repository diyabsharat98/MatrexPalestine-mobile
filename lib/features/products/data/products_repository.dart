import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import '../../../core/storage/reference_cache_service.dart';
import 'product_model.dart';

class ProductsRepository {
  ProductsRepository(this._dio, this._cache);

  final Dio _dio;
  final ReferenceCacheService _cache;

  static const _table = 'cached_products';
  static const _perPage = 25;

  Future<PaginatedResponse<ProductModel>> list({String? search, int page = 1}) async {
    try {
      return await guardApiCall(() async {
        final response = await _dio.get('/products', queryParameters: {
          'search': ?(search?.isNotEmpty == true ? search : null),
          'page': page,
          'per_page': _perPage,
        });
        return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, ProductModel.fromJson);
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      return _listFromCache(search: search, page: page);
    }
  }

  Future<ProductModel> findByBarcode(String barcode) async {
    try {
      return await guardApiCall(() async {
        final response = await _dio.get('/products/barcode/$barcode');
        return ProductModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final cached = await _cache.all(_table);
      final match = cached.map(ProductModel.fromJson).where((p) => p.barcode == barcode).toList();
      if (match.isEmpty) {
        throw const ApiException(
          messageEn: 'Product not found in the offline catalog.',
          messageAr: 'المنتج غير موجود في الكتالوج غير المتصل.',
          errorCode: 'product_not_found',
        );
      }
      return match.first;
    }
  }

  Future<ProductModel> create({
    required String name,
    required String nameAr,
    required int baseUnitId,
    required double sellingPrice,
    String? barcode,
    int? categoryId,
    int? brandId,
    double? costPrice,
    double? reorderLevel,
    int? bulkUnitId,
    double? bulkConversionFactor,
    double? bulkSellingPrice,
    int? warehouseId,
    double? openingQuantity,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/products', data: {
        'name': name,
        'name_ar': nameAr,
        'base_unit_id': baseUnitId,
        'selling_price': sellingPrice,
        'barcode': ?(barcode?.isNotEmpty == true ? barcode : null),
        'category_id': ?categoryId,
        'brand_id': ?brandId,
        'cost_price': ?costPrice,
        'reorder_level': ?reorderLevel,
        'bulk_unit_id': ?bulkUnitId,
        'bulk_conversion_factor': ?bulkConversionFactor,
        'bulk_selling_price': ?bulkSellingPrice,
        'warehouse_id': ?warehouseId,
        'opening_quantity': ?openingQuantity,
      });
      return ProductModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  /// Downloads the full active catalog (a beverage distributor's product
  /// list is small enough to hold entirely on-device) so Products screens
  /// and the New Sale flow keep working with no connection.
  Future<void> refreshOfflineCache() async {
    final all = <ProductModel>[];
    var page = 1;
    while (true) {
      final result = await guardApiCall(() async {
        final response = await _dio.get('/products', queryParameters: {'page': page, 'per_page': 100});
        return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, ProductModel.fromJson);
      });
      all.addAll(result.items);
      if (!result.hasMore || page > 50) break;
      page++;
    }
    await _cache.replaceAll(_table, all.map((p) => (id: p.id, json: p.toJson())).toList());
  }

  Future<PaginatedResponse<ProductModel>> _listFromCache({String? search, int page = 1}) async {
    final cached = (await _cache.all(_table)).map(ProductModel.fromJson).toList();

    final filtered = search == null || search.isEmpty
        ? cached
        : cached.where((p) {
            final q = search.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.nameAr.contains(search) ||
                p.sku.toLowerCase().contains(q) ||
                (p.barcode?.contains(search) ?? false);
          }).toList();

    final start = (page - 1) * _perPage;
    final end = (start + _perPage).clamp(0, filtered.length);
    final items = start >= filtered.length ? <ProductModel>[] : filtered.sublist(start, end);
    final lastPage = (filtered.length / _perPage).ceil().clamp(1, 1 << 30);

    return PaginatedResponse(items: items, currentPage: page, lastPage: lastPage, total: filtered.length);
  }
}

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(dioProvider), ref.watch(referenceCacheServiceProvider));
});
