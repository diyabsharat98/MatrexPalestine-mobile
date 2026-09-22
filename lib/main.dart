import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_providers.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BeverageDistributionApp(),
    ),
  );
}

class BeverageDistributionApp extends ConsumerWidget {
  const BeverageDistributionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch the auth controller once at app start so its build() (which
    // wires the 401 -> logout callback) runs before any network call.
    ref.watch(authControllerProvider);

    // Arms the connectivity-restored -> auto-sync listener immediately,
    // rather than only whenever some screen happens to watch it first.
    ref.watch(syncManagerProvider);

    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
