import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'dashboard_model.dart';

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardModel> fetch() {
    return guardApiCall(() async {
      final response = await _dio.get('/dashboard');
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    });
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

final dashboardProvider = FutureProvider.autoDispose<DashboardModel>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetch();
});
