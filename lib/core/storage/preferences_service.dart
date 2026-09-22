import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive local preferences: language, remembered login, and small
/// convenience caches (recent/favorite customers). Never used for tokens.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'locale';
  static const _rememberedLoginKey = 'remembered_login';
  static const _recentCustomerIdsKey = 'recent_customer_ids';
  static const _favoriteCustomerIdsKey = 'favorite_customer_ids';
  static const _cachedUserKey = 'cached_user';

  String? get locale => _prefs.getString(_localeKey);

  Future<void> setLocale(String languageCode) => _prefs.setString(_localeKey, languageCode);

  String? get rememberedLogin => _prefs.getString(_rememberedLoginKey);

  Future<void> setRememberedLogin(String? login) {
    if (login == null) return _prefs.remove(_rememberedLoginKey);
    return _prefs.setString(_rememberedLoginKey, login);
  }

  List<int> get recentCustomerIds =>
      (_prefs.getStringList(_recentCustomerIdsKey) ?? []).map(int.parse).toList();

  Future<void> pushRecentCustomer(int customerId) async {
    final ids = recentCustomerIds..remove(customerId);
    ids.insert(0, customerId);
    await _prefs.setStringList(
      _recentCustomerIdsKey,
      ids.take(10).map((id) => id.toString()).toList(),
    );
  }

  Set<int> get favoriteCustomerIds =>
      (_prefs.getStringList(_favoriteCustomerIdsKey) ?? []).map(int.parse).toSet();

  Future<void> toggleFavoriteCustomer(int customerId) async {
    final ids = favoriteCustomerIds;
    if (!ids.add(customerId)) ids.remove(customerId);
    await _prefs.setStringList(_favoriteCustomerIdsKey, ids.map((id) => id.toString()).toList());
  }

  /// Caches the logged-in user's profile (roles/permissions/warehouse) so
  /// the app can restore a session instantly on launch without waiting on
  /// the network — not sensitive, so plain prefs (not secure storage) are
  /// fine; the token itself never lives here.
  Map<String, dynamic>? get cachedUser {
    final raw = _prefs.getString(_cachedUserKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setCachedUser(Map<String, dynamic>? user) {
    if (user == null) return _prefs.remove(_cachedUserKey);
    return _prefs.setString(_cachedUserKey, jsonEncode(user));
  }
}
