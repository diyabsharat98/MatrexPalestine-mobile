import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decouples the Dio layer from the auth feature: the network interceptor
/// fires [onUnauthorized] on a 401 without needing to depend on
/// `authControllerProvider` (which itself depends on Dio), avoiding a
/// provider cycle. The app root wires the callback once at startup.
class AuthEventBus {
  void Function()? onUnauthorized;
}

final authEventBusProvider = Provider<AuthEventBus>((ref) => AuthEventBus());
