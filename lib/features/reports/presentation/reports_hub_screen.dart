import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';

class _ReportCategory {
  const _ReportCategory({required this.icon, required this.title, required this.subtitle, required this.route});

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

/// Spec section 22 "Reports on Mobile" hub — one entry point fanning out to
/// the Sales/Collections/Receivables/Inventory/Profit report screens.
/// Reachable only for users with the `reports.view` permission (gated at
/// the More-screen navigation entry; the backend enforces it again on every
/// underlying endpoint regardless of what the client shows).
class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final categories = [
      _ReportCategory(icon: Icons.point_of_sale, title: l10n.reportsSales, subtitle: l10n.reportsSalesSubtitle, route: '/reports/sales'),
      _ReportCategory(icon: Icons.payments, title: l10n.reportsCollections, subtitle: l10n.reportsCollectionsSubtitle, route: '/reports/collections'),
      _ReportCategory(icon: Icons.account_balance_wallet, title: l10n.reportsReceivables, subtitle: l10n.reportsReceivablesSubtitle, route: '/reports/receivables'),
      _ReportCategory(icon: Icons.inventory_2, title: l10n.reportsInventory, subtitle: l10n.reportsInventorySubtitle, route: '/reports/stock-movements'),
      _ReportCategory(icon: Icons.trending_up, title: l10n.reportsProfit, subtitle: l10n.reportsProfitSubtitle, route: '/reports/profit'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(category.icon)),
              title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(category.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(category.route),
            ),
          );
        },
      ),
    );
  }
}
