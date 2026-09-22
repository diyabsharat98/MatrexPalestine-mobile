import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import 'vehicle_load_model.dart';
import 'vehicle_model.dart';
import 'vehicle_settlement_model.dart';

class VehiclesRepository {
  VehiclesRepository(this._dio);

  final Dio _dio;

  Future<List<VehicleModel>> listVehicles() {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicles');
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<SalesRepModel>> listSalesReps() {
    return guardApiCall(() async {
      final response = await _dio.get('/sales-reps');
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((v) => SalesRepModel.fromJson(v as Map<String, dynamic>))
          .toList();
    });
  }

  Future<PaginatedResponse<VehicleLoadModel>> listLoads({String? status, int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicle-loads', queryParameters: {
        'status': ?status,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, VehicleLoadModel.fromJson);
    });
  }

  Future<VehicleLoadModel?> currentLoad() {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicle-loads/current');
      final data = (response.data as Map<String, dynamic>)['data'];
      return data == null ? null : VehicleLoadModel.fromJson(data as Map<String, dynamic>);
    });
  }

  Future<List<VehicleStockRow>> currentLoadStock() {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicle-loads/current');
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      if (data == null) return [];
      return (data['stock'] as List).map((s) => VehicleStockRow.fromJson(s as Map<String, dynamic>)).toList();
    });
  }

  Future<VehicleLoadModel> createLoad({
    required int vehicleId,
    required int salesRepId,
    required int warehouseId,
    required List<({int productId, double quantityBase})> items,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/vehicle-loads', data: {
        'vehicle_id': vehicleId,
        'sales_rep_id': salesRepId,
        'warehouse_id': warehouseId,
        'items': items.map((i) => {'product_id': i.productId, 'quantity_base': i.quantityBase}).toList(),
      });
      return VehicleLoadModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<List<VehicleStockRow>> previewSettlement(int vehicleLoadId) {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicle-loads/$vehicleLoadId/preview-settlement');
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((s) => VehicleStockRow.fromJson(s as Map<String, dynamic>))
          .toList();
    });
  }

  Future<VehicleSettlementModel> submitSettlement({
    required int vehicleLoadId,
    required List<({int productId, double actualRemainingQty, String? reason})> items,
    String? notes,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/vehicle-loads/$vehicleLoadId/settlement', data: {
        'notes': notes,
        'items': items.map((i) => {
              'product_id': i.productId,
              'actual_remaining_qty': i.actualRemainingQty,
              if (i.reason != null) 'reason': i.reason,
            }).toList(),
      });
      return VehicleSettlementModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<PaginatedResponse<VehicleSettlementModel>> listSettlements({String? status, int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/vehicle-settlements', queryParameters: {
        'status': ?status,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, VehicleSettlementModel.fromJson);
    });
  }

  Future<VehicleSettlementModel> approveSettlement(int settlementId) {
    return guardApiCall(() async {
      final response = await _dio.post('/vehicle-settlements/$settlementId/approve');
      return VehicleSettlementModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }
}

final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  return VehiclesRepository(ref.watch(dioProvider));
});
