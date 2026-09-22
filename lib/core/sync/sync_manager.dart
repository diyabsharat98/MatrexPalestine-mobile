import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customers/data/customers_repository.dart';
import '../../features/products/data/products_repository.dart';
import '../network/connectivity_provider.dart';
import '../network/dio_client.dart';
import '../storage/sync_outbox_service.dart';

class SyncResultSummary {
  const SyncResultSummary({required this.synced, required this.failed});

  final int synced;
  final int failed;
}

/// Drains the offline outbox against `POST /api/sync` (spec sections 2/33):
/// each queued transaction is processed independently and idempotently, so
/// a partial failure never blocks the rest of the batch and a retry of the
/// same batch is always safe.
class SyncManager extends Notifier<bool> {
  @override
  bool build() {
    // `state` here just means "a sync is currently running" — the actual
    // pending-count the UI cares about lives in [pendingSyncCountProvider].
    ref.listen(isOnlineProvider, (previous, isOnline) {
      if (previous == false && isOnline) {
        syncNow();
        refreshReferenceCaches();
      }
    });
    return false;
  }

  /// Best-effort catalog/customer cache warm-up for offline use — failures
  /// here (e.g. a permission issue) must never surface to the user, since
  /// this is opportunistic and the app already works from a stale cache.
  Future<void> refreshReferenceCaches() async {
    try {
      await ref.read(productsRepositoryProvider).refreshOfflineCache();
    } catch (_) {
      // Ignored — next successful sync/login retries this.
    }
    try {
      await ref.read(customersRepositoryProvider).refreshOfflineCache();
    } catch (_) {
      // Ignored — next successful sync/login retries this.
    }
  }

  Future<SyncResultSummary> syncNow() async {
    if (state) return const SyncResultSummary(synced: 0, failed: 0);

    final outbox = ref.read(syncOutboxServiceProvider);
    final pending = await outbox.pending();
    if (pending.isEmpty) return const SyncResultSummary(synced: 0, failed: 0);

    state = true;
    var synced = 0;
    var failed = 0;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/sync', data: {
        'transactions': pending
            .map((item) => {'type': item.type, 'uuid': item.uuid, 'payload': item.payload})
            .toList(),
      });

      final results = (response.data as Map<String, dynamic>)['results'] as List;
      for (final result in results) {
        final map = result as Map<String, dynamic>;
        final uuid = map['uuid'] as String;
        if (map['status'] == 'synced') {
          await outbox.markSynced(uuid);
          synced++;
        } else {
          await outbox.markFailed(
            uuid,
            messageEn: map['message'] as String? ?? 'Sync failed.',
            messageAr: map['message_ar'] as String?,
          );
          failed++;
        }
      }
    } on DioException {
      // Connection dropped mid-sync — leave everything pending, the next
      // connectivity-restore or manual retry will pick it up again.
    } finally {
      state = false;
      ref.invalidate(pendingSyncCountProvider);
    }

    return SyncResultSummary(synced: synced, failed: failed);
  }
}

final syncManagerProvider = NotifierProvider<SyncManager, bool>(SyncManager.new);

final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(syncOutboxServiceProvider).pendingCount();
});
