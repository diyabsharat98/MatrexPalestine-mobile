import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/application/auth_controller.dart';
import '../application/sales_list_controller.dart';

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(salesListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(salesListControllerProvider);
    final canCreate = ref.watch(authControllerProvider).user?.can('sales.create') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSales),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/sales/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.saleNewSale),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(salesListControllerProvider.notifier).refresh(),
        child: state.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [
            ErrorStateView(error: error, onRetry: () => ref.invalidate(salesListControllerProvider)),
          ]),
          data: (data) {
            if (data.items.isEmpty) {
              return ListView(children: [EmptyStateView(title: l10n.salesEmpty, icon: Icons.receipt_long_outlined)]);
            }
            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: data.items.length + (data.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= data.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final sale = data.items[index];
                return Card(
                  child: ListTile(
                    title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${sale.customerName ?? ''} • ${Formatters.dateFromIso(sale.invoiceDate)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.money(sale.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                        StatusChip(
                          label: sale.status == 'confirmed' ? l10n.saleStatusConfirmed : l10n.saleStatusCancelled,
                          positive: sale.status == 'confirmed',
                        ),
                      ],
                    ),
                    onTap: () => context.push('/sales/${sale.id}'),
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
