import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated_response.dart';
import '../../vehicles/data/vehicle_model.dart';
import 'purchase_model.dart';
import 'stock_movement_model.dart';

class WarehouseOpsRepository {
  WarehouseOpsRepository(this._dio);

  final Dio _dio;

  Future<List<WarehouseModel>> listWarehouses() {
    return guardApiCall(() async {
      final response = await _dio.get('/warehouses');
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((w) => WarehouseModel.fromJson(w as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<SupplierModel>> listSuppliers() {
    return guardApiCall(() async {
      final response = await _dio.get('/suppliers');
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((s) => SupplierModel.fromJson(s as Map<String, dynamic>))
          .toList();
    });
  }

  Future<PaginatedResponse<PurchaseModel>> listPurchases({int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/purchases', queryParameters: {'page': page, 'per_page': 25});
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, PurchaseModel.fromJson);
    });
  }

  Future<PurchaseModel> createPurchase({
    required int supplierId,
    required int warehouseId,
    required List<({int productId, int productUnitId, double quantity, double unitCost})> items,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/purchases', data: {
        'supplier_id': supplierId,
        'warehouse_id': warehouseId,
        'items': items
            .map((i) => {
                  'product_id': i.productId,
                  'product_unit_id': i.productUnitId,
                  'quantity': i.quantity,
                  'unit_cost': i.unitCost,
                })
            .toList(),
      });
      return PurchaseModel.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    });
  }

  Future<void> createTransfer({
    required int fromWarehouseId,
    required int toWarehouseId,
    required List<({int productId, double quantityBase})> items,
  }) {
    return guardApiCall(() async {
      await _dio.post('/stock-transfers', data: {
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'items': items.map((i) => {'product_id': i.productId, 'quantity_base': i.quantityBase}).toList(),
      });
    });
  }

  Future<void> createAdjustment({
    required int warehouseId,
    required int productId,
    required double quantityChange,
    required String reason,
  }) {
    return guardApiCall(() async {
      await _dio.post('/stock-adjustments', data: {
        'warehouse_id': warehouseId,
        'product_id': productId,
        'quantity_change': quantityChange,
        'reason': reason,
      });
    });
  }

  Future<PaginatedResponse<StockMovementModel>> listMovements({int? productId, int page = 1}) {
    return guardApiCall(() async {
      final response = await _dio.get('/stock-movements', queryParameters: {
        'product_id': ?productId,
        'page': page,
        'per_page': 25,
      });
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, StockMovementModel.fromJson);
    });
  }
}

final warehouseOpsRepositoryProvider = Provider<WarehouseOpsRepository>((ref) {
  return WarehouseOpsRepository(ref.watch(dioProvider));
});
