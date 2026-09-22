import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../data/dashboard_model.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.dashboardGoodMorning;
    if (hour < 18) return l10n.dashboardGoodAfternoon;
    return l10n.dashboardGoodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).user;
    final dashboardAsync = ref.watch(dashboardProvider);
    ref.watch(isOnlineProvider); // keep the connectivity banner live

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: dashboardAsync.when(
          loading: () => const SkeletonList(itemCount: 5, itemHeight: 88),
          error: (error, _) => ListView(
            children: [ErrorStateView(error: error, onRetry: () => ref.refresh(dashboardProvider))],
          ),
          data: (dashboard) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_greeting(l10n), style: Theme.of(context).textTheme.titleMedium),
              Text(
                user?.name ?? dashboard.userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(Formatters.dateFromIso(dashboard.date), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  KpiCard(
                    label: l10n.dashboardTodaySales,
                    value: Formatters.money(dashboard.todaySales),
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                  KpiCard(
                    label: l10n.dashboardCollections,
                    value: Formatters.money(dashboard.collections),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.info,
                  ),
                  KpiCard(
                    label: l10n.dashboardReceivables,
                    value: Formatters.money(dashboard.receivables),
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                  ),
                  KpiCard(
                    label: l10n.dashboardTodayInvoices,
                    value: Formatters.number(dashboard.todayInvoicesCount),
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              ),
              if (dashboard.warehouse case final WarehouseKpis w) ...[
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    KpiCard(label: l10n.dashboardTotalProducts, value: Formatters.number(w.totalProducts)),
                    KpiCard(
                      label: l10n.dashboardLowStock,
                      value: Formatters.number(w.lowStockCount),
                      color: w.lowStockCount > 0 ? AppColors.danger : null,
                    ),
                    KpiCard(label: l10n.dashboardTodayReceipts, value: Formatters.number(w.todayReceipts)),
                    KpiCard(label: l10n.dashboardTodayIssues, value: Formatters.number(w.todayIssues)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(l10n.dashboardQuickActions, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (user?.can('sales.create') ?? false)
                    _QuickAction(
                      icon: Icons.add_shopping_cart,
                      label: l10n.dashboardNewSale,
                      onTap: () => context.push('/sales/new'),
                    ),
                  if (user?.can('payments.create') ?? false)
                    _QuickAction(
                      icon: Icons.payments_outlined,
                      label: l10n.dashboardCollectPayment,
                      onTap: () => context.push('/payments/new'),
                    ),
                  if (user?.can('stock.view') ?? false)
                    _QuickAction(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.dashboardMyStock,
                      onTap: () => context.go('/stock'),
                    )
                  else if (user?.can('vehicle_loads.view') ?? false)
                    _QuickAction(
                      icon: Icons.local_shipping_outlined,
                      label: l10n.dashboardMyStock,
                      onTap: () => context.push('/my-vehicle-stock'),
                    ),
                  _QuickAction(
                    icon: Icons.people_outline,
                    label: l10n.dashboardCustomers,
                    onTap: () => context.go('/customers'),
                  ),
                  if (user?.can('products.create') ?? false)
                    _QuickAction(
                      icon: Icons.inventory_outlined,
                      label: l10n.dashboardProducts,
                      onTap: () => context.push('/products'),
                    ),
                  if (user?.can('returns.create') ?? false)
                    _QuickAction(
                      icon: Icons.assignment_return_outlined,
                      label: l10n.returnNewReturn,
                      onTap: () => context.push('/returns/new'),
                    ),
                  if (user?.can('purchases.create') ?? false)
                    _QuickAction(
                      icon: Icons.local_shipping,
                      label: l10n.purchaseNewTitle,
                      onTap: () => context.push('/purchases/new'),
                    ),
                  if (user?.can('stock.manage') ?? false) ...[
                    _QuickAction(
                      icon: Icons.swap_horiz,
                      label: l10n.transferNewTitle,
                      onTap: () => context.push('/stock-transfers/new'),
                    ),
                    _QuickAction(
                      icon: Icons.tune,
                      label: l10n.adjustmentNewTitle,
                      onTap: () => context.push('/stock-adjustments/new'),
                    ),
                  ],
                  if (user?.can('settlements.approve') ?? false)
                    _QuickAction(
                      icon: Icons.fact_check_outlined,
                      label: l10n.settlementStatusPending,
                      onTap: () => context.push('/settlements/pending'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
