import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/customer_detail_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final customerAsync = ref.watch(customerDetailProvider(customerId));

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: customerAsync.maybeWhen(
            data: (c) => Text(isArabic ? c.nameAr : c.name),
            orElse: () => const Text(''),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.customerTabOverview),
              Tab(text: l10n.customerTabSales),
              Tab(text: l10n.customerTabPayments),
              Tab(text: l10n.returnNewReturn),
              Tab(text: l10n.customerTabStatement),
            ],
          ),
        ),
        body: customerAsync.when(
          loading: () => const SkeletonList(),
          error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customerDetailProvider(customerId))),
          data: (customer) => TabBarView(
            children: [
              _OverviewTab(customerId: customerId),
              _SalesTab(customerId: customerId),
              _PaymentsTab(customerId: customerId),
              _ReturnsTab(customerId: customerId),
              _StatementTab(customerId: customerId),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final customer = ref.watch(customerDetailProvider(customerId)).requireValue;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (customer.phone != null)
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(customer.phone!),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => launchUrl(Uri.parse('tel:${customer.phone}')),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        if (customer.address != null)
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(customer.address!),
            contentPadding: EdgeInsets.zero,
          ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            KpiCard(label: l10n.customerBalance, value: Formatters.money(customer.balance)),
            KpiCard(label: l10n.customerCreditLimit, value: Formatters.money(customer.creditLimit)),
            KpiCard(label: l10n.customerAvailableCredit, value: Formatters.money(customer.availableCredit)),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => context.push('/sales/new', extra: customer.id),
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(l10n.customerNewSale),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/payments/new', extra: customer.id),
          icon: const Icon(Icons.payments_outlined),
          label: Text(l10n.customerPayment),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/customers/${customer.id}/statement'),
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text(l10n.customerStatement),
        ),
      ],
    );
  }
}

class _SalesTab extends ConsumerWidget {
  const _SalesTab({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salesAsync = ref.watch(customerSalesProvider(customerId));

    return salesAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customerSalesProvider(customerId))),
      data: (sales) {
        if (sales.isEmpty) return EmptyStateView(title: l10n.salesEmpty);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              child: ListTile(
                title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(Formatters.dateFromIso(sale.invoiceDate)),
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
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final paymentsAsync = ref.watch(customerPaymentsProvider(customerId));

    return paymentsAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customerPaymentsProvider(customerId))),
      data: (payments) {
        if (payments.isEmpty) return EmptyStateView(title: l10n.paymentsEmpty);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final payment = payments[index];
            return Card(
              child: ListTile(
                title: Text(payment.paymentNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(Formatters.dateFromIso(payment.paymentDate)),
                trailing: Text(Formatters.money(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReturnsTab extends ConsumerWidget {
  const _ReturnsTab({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final returnsAsync = ref.watch(customerReturnsProvider(customerId));

    return returnsAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customerReturnsProvider(customerId))),
      data: (returns) {
        if (returns.isEmpty) return EmptyStateView(title: l10n.returnsEmpty);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: returns.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final r = returns[index];
            return Card(
              child: ListTile(
                title: Text(r.returnNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(Formatters.dateFromIso(r.returnDate)),
                trailing: Text(Formatters.money(r.total), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatementTab extends ConsumerWidget {
  const _StatementTab({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statementAsync = ref.watch(customerStatementProvider(customerId));

    return statementAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customerStatementProvider(customerId))),
      data: (statement) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.customerOpeningBalance),
              Text(Formatters.money(statement.openingBalance), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          ...statement.transactions.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.description ?? t.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(Formatters.dateFromIso(t.date), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    '${t.amount >= 0 ? '+' : ''}${Formatters.money(t.amount)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: t.amount >= 0 ? Colors.red : Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.customerClosingBalance, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                Formatters.money(statement.closingBalance),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/customers/$customerId/statement'),
            icon: const Icon(Icons.filter_alt_outlined),
            label: Text(l10n.commonFilter),
          ),
        ],
      ),
    );
  }
}
