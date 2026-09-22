import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/state_views.dart';
import '../data/vehicle_load_model.dart';
import '../data/vehicles_repository.dart';

typedef _CurrentTrip = ({VehicleLoadModel load, List<VehicleStockRow> stock});

final _currentLoadProvider = FutureProvider.autoDispose<_CurrentTrip?>((ref) async {
  final repo = ref.watch(vehiclesRepositoryProvider);
  final load = await repo.currentLoad();
  if (load == null) return null;
  final stock = await repo.currentLoadStock();
  return (load: load, stock: stock);
});

class MyVehicleStockScreen extends ConsumerWidget {
  const MyVehicleStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final loadAsync = ref.watch(_currentLoadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myVehicleStockTitle),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_currentLoadProvider.future),
        child: loadAsync.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [ErrorStateView(error: error, onRetry: () => ref.invalidate(_currentLoadProvider))]),
          data: (trip) {
            if (trip == null) {
              return ListView(children: [EmptyStateView(title: l10n.myVehicleStockNoTrip, icon: Icons.local_shipping_outlined)]);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(trip.load.vehicleName ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(trip.load.loadNumber, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                ...trip.stock.map((row) => _StockCard(row: row, isArabic: isArabic, l10n: l10n)),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push('/vehicle-loads/${trip.load.id}/settlement'),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l10n.myVehicleStockSettle),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.row, required this.isArabic, required this.l10n});

  final VehicleStockRow row;
  final bool isArabic;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final unit = row.baseUnitSymbol;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? row.productNameAr : row.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(context, l10n.myVehicleStockLoaded, row.loadedQty, unit),
                _stat(context, l10n.myVehicleStockSold, row.soldQty, unit),
                _stat(context, l10n.myVehicleStockReturned, row.returnedQty, unit),
                _stat(context, l10n.myVehicleStockRemaining, row.expectedRemainingQty, unit, bold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, double value, String unit, {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          Formatters.number(value),
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14),
        ),
      ],
    );
  }
}
