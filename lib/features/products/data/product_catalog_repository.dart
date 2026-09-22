import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

/// Minimal id/name/name_ar reference used for categories, brands, and units
/// — the supporting reference data an "Add Product" form needs, each with
/// list + quick-create so a rep/warehouse user never gets stuck waiting on
/// someone else to set up a category before they can add a real product.
class CatalogRef {
  const CatalogRef({required this.id, required this.name, required this.nameAr, this.symbol});

  final int id;
  final String name;
  final String nameAr;
  final String? symbol;

  factory CatalogRef.fromJson(Map<String, dynamic> json) => CatalogRef(
        id: json['id'] as int,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
        symbol: json['symbol'] as String?,
      );
}

class ProductCatalogRepository {
  ProductCatalogRepository(this._dio);

  final Dio _dio;

  Future<List<CatalogRef>> categories() => _list('/categories');

  Future<List<CatalogRef>> brands() => _list('/brands');

  Future<List<CatalogRef>> units() => _list('/units');

  Future<CatalogRef> createCategory(String name, String nameAr) => _create('/categories', name, nameAr);

  Future<CatalogRef> createBrand(String name, String nameAr) => _create('/brands', name, nameAr);

  Future<CatalogRef> createUnit(String name, String nameAr, String symbol) {
    return guardApiCall(() async {
      final response = await _dio.post('/units', data: {'name': name, 'name_ar': nameAr, 'symbol': symbol});
      return CatalogRef.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<List<CatalogRef>> _list(String path) {
    return guardApiCall(() async {
      final response = await _dio.get(path);
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data.map((e) => CatalogRef.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<CatalogRef> _create(String path, String name, String nameAr) {
    return guardApiCall(() async {
      final response = await _dio.post(path, data: {'name': name, 'name_ar': nameAr});
      return CatalogRef.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }
}

final productCatalogRepositoryProvider = Provider<ProductCatalogRepository>((ref) {
  return ProductCatalogRepository(ref.watch(dioProvider));
});
