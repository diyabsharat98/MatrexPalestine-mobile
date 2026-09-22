import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/application/auth_controller.dart';
import '../data/vehicles_repository.dart';

final _loadsListProvider = FutureProvider.autoDispose((ref) async {
  final result = await ref.watch(vehiclesRepositoryProvider).listLoads();
  return result.items;
});

class VehicleLoadsListScreen extends ConsumerWidget {
  const VehicleLoadsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final loadsAsync = ref.watch(_loadsListProvider);
    final canCreate = ref.watch(authControllerProvider).user?.can('vehicle_loads.create') ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.warehouseDocumentsTitle)),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/vehicle-loads/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.vehicleLoadNewTitle),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_loadsListProvider.future),
        child: loadsAsync.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [ErrorStateView(error: error, onRetry: () => ref.invalidate(_loadsListProvider))]),
          data: (loads) {
            if (loads.isEmpty) {
              return ListView(children: [EmptyStateView(title: l10n.vehicleLoadsEmpty, icon: Icons.local_shipping_outlined)]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: loads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final load = loads[index];
                return Card(
                  child: ListTile(
                    title: Text(load.loadNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${load.salesRepName ?? ''} • ${load.vehicleName ?? ''} • ${Formatters.dateFromIso(load.loadDate)}'),
                    trailing: StatusChip(
                      label: load.isOpen ? l10n.vehicleLoadStatusLoaded : l10n.vehicleLoadStatusSettled,
                      positive: !load.isOpen,
                    ),
                    onTap: load.isOpen ? () => context.push('/vehicle-loads/${load.id}/settlement') : null,
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
