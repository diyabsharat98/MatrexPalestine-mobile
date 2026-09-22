import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../network/connectivity_provider.dart';
import '../sync/sync_manager.dart';
import '../theme/app_theme.dart';

/// Status pill: 🟢 Online / 🟠 Offline, plus a pending-sync count when there
/// is one — spec sections 2 and 33 ("⟳ 3 transactions waiting for sync").
/// Tapping it while there's a queue opens the sync status screen.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final l10n = AppLocalizations.of(context)!;
    final hasPending = pendingCount > 0;
    final color = !isOnline ? AppColors.warning : (hasPending ? AppColors.info : AppColors.success);

    return InkWell(
      onTap: hasPending ? () => context.push('/sync-status') : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasPending ? Icons.sync : Icons.circle, size: hasPending ? 12 : 8, color: color),
            const SizedBox(width: 6),
            Text(
              hasPending ? l10n.syncPending(pendingCount) : (isOnline ? l10n.commonOnline : l10n.commonOffline),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
