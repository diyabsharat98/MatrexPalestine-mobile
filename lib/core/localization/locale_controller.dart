import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';

/// App language. Defaults to Arabic (RTL) per the product spec; the user
/// can switch to English from the More tab.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(preferencesServiceProvider).locale;
    return Locale(saved ?? 'ar');
  }

  Future<void> setLocale(String languageCode) async {
    await ref.read(preferencesServiceProvider).setLocale(languageCode);
    state = Locale(languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
