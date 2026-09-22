import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'user_model.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<({String token, UserModel user})> login({
    required String login,
    required String password,
    bool remember = false,
    String? deviceName,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post('/login', data: {
        'login': login,
        'password': password,
        'remember': remember,
        'device_name': ?deviceName,
      });

      final data = response.data as Map<String, dynamic>;
      return (token: data['token'] as String, user: UserModel.fromJson(data['user'] as Map<String, dynamic>));
    });
  }

  Future<void> logout() {
    return guardApiCall(() async {
      await _dio.post('/logout');
    });
  }

  Future<UserModel> me() {
    return guardApiCall(() async {
      final response = await _dio.get('/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});
