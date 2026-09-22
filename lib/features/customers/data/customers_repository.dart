import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import '../../../core/storage/reference_cache_service.dart';
import 'customer_model.dart';
import 'customer_statement_model.dart';

class CustomersRepository {
  CustomersRepository(this._dio, this._cache);

  final Dio _dio;
  final ReferenceCacheService _cache;

  static const _table = 'cached_customers';
  static const _perPage = 25;

  Future<PaginatedResponse<CustomerModel>> list({String? search, int page = 1}) async {
    try {
      return await guardApiCall(() async {
        final response = await _dio.get('/customers', queryParameters: {
          'search': ?(search?.isNotEmpty == true ? search : null),
          'page': page,
          'per_page': _perPage,
        });
        return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, CustomerModel.fromJson);
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      return _listFromCache(search: search, page: page);
    }
  }

  Future<CustomerModel> find(int id) async {
    try {
      return await guardApiCall(() async {
        final response = await _dio.get('/customers/$id');
        return CustomerModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final cached = await _cache.all(_table);
      final match = cached.map(CustomerModel.fromJson).where((c) => c.id == id);
      if (match.isEmpty) rethrow;
      return match.first;
    }
  }

  Future<CustomerModel> create({
    required String name,
    required String nameAr,
    String? phone,
    String? secondaryPhone,
    String? area,
    String? city,
    String? address,
    double? creditLimit,
    int? paymentTermsDays,
    String? notes,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/customers', data: {
        'name': name,
        'name_ar': nameAr,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (secondaryPhone != null && secondaryPhone.isNotEmpty) 'secondary_phone': secondaryPhone,
        if (area != null && area.isNotEmpty) 'area': area,
        if (city != null && city.isNotEmpty) 'city': city,
        if (address != null && address.isNotEmpty) 'address': address,
        'credit_limit': ?creditLimit,
        'payment_terms_days': ?paymentTermsDays,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return CustomerModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<CustomerStatement> statement(int id, {DateTime? from, DateTime? to}) {
    return guardApiCall(() async {
      final response = await _dio.get('/customer-statements/$id', queryParameters: {
        'from': ?from?.toIso8601String().split('T').first,
        'to': ?to?.toIso8601String().split('T').first,
      });
      return CustomerStatement.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Downloads the rep's full assigned/visible customer list so Customers,
  /// customer balances, and the New Sale/Payment/Return flows keep working
  /// with no connection (spec section 2).
  Future<void> refreshOfflineCache() async {
    final all = <CustomerModel>[];
    var page = 1;
    while (true) {
      final result = await guardApiCall(() async {
        final response = await _dio.get('/customers', queryParameters: {'page': page, 'per_page': 100});
        return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, CustomerModel.fromJson);
      });
      all.addAll(result.items);
      if (!result.hasMore || page > 50) break;
      page++;
    }
    await _cache.replaceAll(_table, all.map((c) => (id: c.id, json: c.toJson())).toList());
  }

  Future<PaginatedResponse<CustomerModel>> _listFromCache({String? search, int page = 1}) async {
    final cached = (await _cache.all(_table)).map(CustomerModel.fromJson).toList();

    final filtered = search == null || search.isEmpty
        ? cached
        : cached.where((c) {
            final q = search.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.nameAr.contains(search) ||
                c.code.toLowerCase().contains(q) ||
                (c.phone?.contains(search) ?? false) ||
                (c.area?.toLowerCase().contains(q) ?? false);
          }).toList();

    final start = (page - 1) * _perPage;
    final end = (start + _perPage).clamp(0, filtered.length);
    final items = start >= filtered.length ? <CustomerModel>[] : filtered.sublist(start, end);
    final lastPage = (filtered.length / _perPage).ceil().clamp(1, 1 << 30);

    return PaginatedResponse(items: items, currentPage: page, lastPage: lastPage, total: filtered.length);
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(dioProvider), ref.watch(referenceCacheServiceProvider));
});
