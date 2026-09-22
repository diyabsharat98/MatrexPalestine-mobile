/// Backend base URL.
///
/// `10.0.2.2` is the Android emulator's alias for the host machine's
/// `localhost`, so this default works out of the box against
/// `php artisan serve` on the same development machine. For a physical
/// device over USB, run `adb reverse tcp:8000 tcp:8000` and switch this to
/// `http://127.0.0.1:8000/api`; for a device on the same Wi-Fi, use the
/// host machine's LAN IP instead (e.g. `http://192.168.1.20:8000/api`).
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
