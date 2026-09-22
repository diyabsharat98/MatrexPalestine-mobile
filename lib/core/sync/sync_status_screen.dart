import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_localizations.dart';
import '../storage/sync_outbox_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/state_views.dart';
import 'sync_manager.dart';

final _outboxProvider = FutureProvider.autoDispose((ref) {
  ref.watch(pendingSyncCountProvider);
  return ref.watch(syncOutboxServiceProvider).pending();
});

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
        'sale' => l10n.syncTypeSale,
        'payment' => l10n.syncTypePayment,
        'return' => l10n.syncTypeReturn,
        _ => type,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isSyncing = ref.watch(syncManagerProvider);
    final outboxAsync = ref.watch(_outboxProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncStatusTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSyncing
            ? null
            : () async {
                final summary = await ref.read(syncManagerProvider.notifier).syncNow();
                ref.invalidate(_outboxProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.syncCompleted}: ${summary.synced}/${summary.synced + summary.failed}')),
                  );
                }
              },
        icon: isSyncing
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.sync),
        label: Text(l10n.syncNow),
      ),
      body: outboxAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(_outboxProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateView(title: l10n.syncNoPending, icon: Icons.cloud_done_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final isFailed = item.status == 'failed';
              return Card(
                child: ListTile(
                  leading: Icon(
                    isFailed ? Icons.error_outline : Icons.hourglass_top,
                    color: isFailed ? AppColors.danger : AppColors.warning,
                  ),
                  title: Text(_typeLabel(l10n, item.type)),
                  subtitle: Text(
                    isFailed
                        ? (item.errorMessage(isArabic) ?? l10n.syncFailedBadge)
                        : '${l10n.syncPendingBadge} • ${Formatters.date(item.createdAt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
