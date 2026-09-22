import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_event_bus.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/sync/sync_manager.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthState {
  const AuthState({required this.status, this.user});

  final AuthStatus status;
  final UserModel? user;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}

/// Reads the cached profile synchronously so the router can decide the
/// initial screen instantly (no splash-screen network wait); a real 401
/// from any request is caught by [AuthEventBus] and forces logout.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.read(authEventBusProvider).onUnauthorized = logoutLocally;

    final cached = ref.read(preferencesServiceProvider).cachedUser;
    if (cached == null) return AuthState.unauthenticated;

    return AuthState(status: AuthStatus.authenticated, user: UserModel.fromJson(cached));
  }

  Future<void> login({required String login, required String password, bool remember = false}) async {
    final result = await ref.read(authRepositoryProvider).login(
          login: login,
          password: password,
          remember: remember,
          deviceName: 'flutter-mobile',
        );

    await ref.read(secureStorageServiceProvider).saveToken(result.token);
    await ref.read(preferencesServiceProvider).setCachedUser(result.user.toJson());
    await ref.read(preferencesServiceProvider).setRememberedLogin(remember ? login : null);

    state = AuthState(status: AuthStatus.authenticated, user: result.user);

    // Fire-and-forget: warms the offline catalog/customer cache right after
    // a fresh (necessarily online) login, instead of waiting for the first
    // reconnect cycle to populate it.
    unawaited(ref.read(syncManagerProvider.notifier).refreshReferenceCaches());
  }

  Future<void> refreshProfile() async {
    try {
      final user = await ref.read(authRepositoryProvider).me();
      await ref.read(preferencesServiceProvider).setCachedUser(user.toJson());
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException {
      // Keep the cached profile if the refresh itself fails (e.g. offline);
      // a real 401 is already handled via AuthEventBus.
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiException {
      // Still clear local session even if the server call fails/offline.
    }
    await logoutLocally();
  }

  Future<void> logoutLocally() async {
    await ref.read(secureStorageServiceProvider).deleteToken();
    await ref.read(preferencesServiceProvider).setCachedUser(null);
    state = AuthState.unauthenticated;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
