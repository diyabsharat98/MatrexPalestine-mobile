# Beverage Distribution — Mobile App (Phase 2)

Flutter client for the Beverage Distribution backend. This covers **Phase 2**
only: login, dashboard, products (with barcode scan), customers, sales
(the full new-sale flow + invoice view/share/print), and payments. Offline
sync, warehouse/vehicle workflows, visits, settlement, and reports are later
phases — the app is online-only for now (it shows live connectivity status,
but does not yet queue transactions offline).

## Requirements

- Flutter 3.47+ (stable channel)
- Android SDK (platform-tools, platform 34+, build-tools) + JDK 17
- The Phase 1 Laravel backend running and reachable from the device

## Setup

```bash
flutter pub get
flutter run
```

### Pointing the app at the backend

`lib/core/network/api_config.dart` defaults to `http://10.0.2.2:8000/api`,
which is the Android emulator's alias for the host machine's `localhost` —
this works out of the box against `php artisan serve` on the same machine
with an emulator. For a different setup, override at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api
```

- **Physical device over USB**: run `adb reverse tcp:8000 tcp:8000`, then use
  `http://127.0.0.1:8000/api`.
- **Physical device over Wi-Fi**: use the host machine's LAN IP.

Demo logins are the same ones seeded by the backend (see
`backend/README.md`) — e.g. username `ahmad`, password `Passw0rd@123`, for
the Sales Representative experience.

## Tests

```bash
flutter analyze
flutter test
```

## Architecture

- **State management**: Riverpod (`Notifier`/`AsyncNotifier`), one
  controller per screen/feature under `application/`.
- **Networking**: a single `Dio` instance (`core/network/dio_client.dart`)
  attaches the bearer token to every request and converts any `DioException`
  into a clean `ApiException` (bilingual `message`/`message_ar` +
  `error_code`, mirroring the backend's `BusinessException` shape) via
  `guardApiCall()`. A 401 anywhere fires `AuthEventBus.onUnauthorized`,
  which the auth controller wires to a local logout — no provider cycle
  between the network and auth layers.
- **Routing**: `go_router` with a `StatefulShellRoute.indexedStack` bottom
  nav shell whose branches (and labels/icons) differ for a Sales
  Representative vs. everyone else (spec section 5); a `redirect` handles
  the login gate and an optional biometric app-lock gate.
- **Biometric login**: local_auth is used as an app-lock (unlock gate on
  cold start when the device supports it), not as a backend auth method —
  the API has no biometric-specific endpoint, so this never replaces the
  password login, only re-gates an already-valid session.
- **Localization**: Arabic (default, RTL) and English via Flutter's
  standard `gen-l10n` (ARB files in `lib/core/localization/`) — every
  user-facing string goes through `AppLocalizations`, never hardcoded.
- **PDF**: invoices and customer statements are rendered client-side
  (`core/pdf/pdf_builder.dart`) from already-fetched API data, then shared
  or printed via the `printing` package.
- Money is always formatted through `Formatters.money()`; nothing is
  computed client-side that the backend doesn't already return — cart
  totals during invoice entry are the one deliberate exception (immediate
  UI feedback), and the server independently recomputes and is the final
  authority when the sale is actually submitted.
