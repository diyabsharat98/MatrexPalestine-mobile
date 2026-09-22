import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../application/payments_list_controller.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(paymentsListControllerProvider.notifier).loadMore();
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
    final state = ref.watch(paymentsListControllerProvider);
    final canCreate = ref.watch(authControllerProvider).user?.can('payments.create') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCollections),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/payments/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.dashboardCollectPayment),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentsListControllerProvider.notifier).refresh(),
        child: state.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ListView(children: [
            ErrorStateView(error: error, onRetry: () => ref.invalidate(paymentsListControllerProvider)),
          ]),
          data: (data) {
            if (data.items.isEmpty) {
              return ListView(children: [EmptyStateView(title: l10n.paymentsEmpty, icon: Icons.payments_outlined)]);
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
                final payment = data.items[index];
                return Card(
                  child: ListTile(
                    title: Text(payment.paymentNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${payment.customerName ?? ''} • ${Formatters.dateFromIso(payment.paymentDate)}'),
                    trailing: Text(Formatters.money(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
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
