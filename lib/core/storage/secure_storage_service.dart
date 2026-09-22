import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps platform secure storage (Android Keystore / iOS Keychain) for the
/// auth token — never persisted in plain SharedPreferences.
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
