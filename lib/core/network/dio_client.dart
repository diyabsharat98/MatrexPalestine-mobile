import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_event_bus.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(secureStorageServiceProvider).readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final isLoginRequest = error.requestOptions.path.contains('/login');
        if (error.response?.statusCode == 401 && !isLoginRequest) {
          ref.read(authEventBusProvider).onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Runs an API call and converts any [DioException] into a clean
/// [ApiException] — call sites never need to know about Dio directly.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
