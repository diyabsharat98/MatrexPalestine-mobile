import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/vehicle_settlement_model.dart';
import '../data/vehicles_repository.dart';

final _pendingSettlementsProvider = FutureProvider.autoDispose((ref) async {
  final result = await ref.watch(vehiclesRepositoryProvider).listSettlements(status: 'pending_approval');
  return result.items;
});

class PendingSettlementsScreen extends ConsumerWidget {
  const PendingSettlementsScreen({super.key});

  Future<void> _approve(BuildContext context, WidgetRef ref, VehicleSettlementModel settlement) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(vehiclesRepositoryProvider).approveSettlement(settlement.id);
      ref.invalidate(_pendingSettlementsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settlementApproved)));
      }
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message(isArabic))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final settlementsAsync = ref.watch(_pendingSettlementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlementStatusPending)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_pendingSettlementsProvider.future),
        child: settlementsAsync.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [ErrorStateView(error: error, onRetry: () => ref.invalidate(_pendingSettlementsProvider))]),
          data: (settlements) {
            if (settlements.isEmpty) {
              return ListView(children: [EmptyStateView(title: l10n.settlementsEmpty, icon: Icons.fact_check_outlined)]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: settlements.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final settlement = settlements[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settlement.settlementNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(Formatters.dateFromIso(settlement.settlementDate), style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        ...settlement.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(isArabic ? item.productNameAr : item.productName)),
                                  Text(
                                    '${item.differenceQty >= 0 ? '+' : ''}${Formatters.number(item.differenceQty)} ${item.baseUnitSymbol}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.differenceQty < 0 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (settlement.items.any((i) => i.reason != null)) ...[
                          const SizedBox(height: 4),
                          ...settlement.items.where((i) => i.reason != null).map(
                                (i) => Text('• ${i.reason}', style: Theme.of(context).textTheme.bodySmall),
                              ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => _approve(context, ref, settlement),
                          child: Text(l10n.settlementApprove),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
