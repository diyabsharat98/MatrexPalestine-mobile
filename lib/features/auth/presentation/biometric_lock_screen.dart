import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../application/auth_controller.dart';
import '../application/biometric_service.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    final ok = await ref.read(biometricServiceProvider).authenticate(
          reason: 'Unlock to continue',
        );

    if (!mounted) return;
    setState(() => _authenticating = false);

    if (ok) {
      ref.read(biometricLockControllerProvider.notifier).unlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userName = ref.watch(authControllerProvider).user?.name ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint, size: 96),
                const SizedBox(height: 16),
                Text(userName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _authenticating ? null : _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.loginBiometric),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  child: Text(l10n.commonLogout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
