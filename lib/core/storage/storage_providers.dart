import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_service.dart';
import 'secure_storage_service.dart';

/// Overridden in `main.dart` with the resolved instance before `runApp`,
/// since `SharedPreferences.getInstance()` is async and providers must be
/// synchronous to read at app startup (router redirect, locale, etc.).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(sharedPreferencesProvider));
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
