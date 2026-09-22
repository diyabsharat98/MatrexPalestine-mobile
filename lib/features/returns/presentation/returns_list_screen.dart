import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../data/sales_returns_repository.dart';

final _returnsListProvider = FutureProvider.autoDispose((ref) async {
  final result = await ref.watch(salesReturnsRepositoryProvider).list();
  return result.items;
});

class ReturnsListScreen extends ConsumerWidget {
  const ReturnsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final returnsAsync = ref.watch(_returnsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.returnNewReturn)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/returns/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.returnNewReturn),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_returnsListProvider.future),
        child: returnsAsync.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [ErrorStateView(error: error, onRetry: () => ref.invalidate(_returnsListProvider))]),
          data: (returns) {
            if (returns.isEmpty) {
              return ListView(children: [EmptyStateView(title: l10n.returnsEmpty, icon: Icons.assignment_return_outlined)]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: returns.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = returns[index];
                return Card(
                  child: ListTile(
                    title: Text(r.returnNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${r.customerName ?? ''} • ${Formatters.dateFromIso(r.returnDate)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.money(r.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                        StatusChip(
                          label: r.status == 'confirmed' ? l10n.saleStatusConfirmed : l10n.saleStatusCancelled,
                          positive: r.status == 'confirmed',
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
