import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/pdf/pdf_builder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../data/sale_model.dart';
import '../data/sales_repository.dart';

final _saleDetailProvider = FutureProvider.autoDispose.family<SaleModel, int>((ref, id) {
  return ref.watch(salesRepositoryProvider).find(id);
});

class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({super.key, required this.invoiceId, this.justCreated = false});

  final int invoiceId;
  final bool justCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final saleAsync = ref.watch(_saleDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleInvoiceNumber)),
      body: saleAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(_saleDetailProvider(invoiceId))),
        data: (sale) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (justCreated)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.saleCompletedTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sale.invoiceNumber, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      StatusChip(
                        label: sale.status == 'confirmed' ? l10n.saleStatusConfirmed : l10n.saleStatusCancelled,
                        positive: sale.status == 'confirmed',
                      ),
                    ],
                  ),
                  Text('${sale.customerName ?? ''} • ${Formatters.dateFromIso(sale.invoiceDate)}'),
                  const SizedBox(height: 20),
                  ...sale.items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.productName),
                        subtitle: Text('${Formatters.number(item.quantity)} ${item.unitSymbol} × ${Formatters.money(item.unitPrice)}'),
                        trailing: Text(Formatters.money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _summaryLine(context, l10n.saleSubtotal, sale.subtotal),
                  _summaryLine(context, l10n.saleDiscount, sale.discountAmount),
                  const Divider(),
                  _summaryLine(context, l10n.saleTotal, sale.total, bold: true),
                  _summaryLine(context, l10n.salePaid, sale.paidAmount),
                  _summaryLine(context, l10n.saleRemaining, sale.remainingAmount, bold: true, highlight: sale.remainingAmount > 0),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final doc = await PdfBuilder.invoice(sale);
                              await Printing.sharePdf(bytes: await doc.save(), filename: '${sale.invoiceNumber}.pdf');
                            },
                            icon: const Icon(Icons.share_outlined),
                            label: Text(l10n.commonShare),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final doc = await PdfBuilder.invoice(sale);
                              await Printing.layoutPdf(onLayout: (_) => doc.save());
                            },
                            icon: const Icon(Icons.print_outlined),
                            label: Text(l10n.commonPrint),
                          ),
                        ),
                      ],
                    ),
                    if (justCreated) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => context.pushReplacement('/sales/new', extra: sale.customerId),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.saleNewSale),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(BuildContext context, String label, num value, {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            Formatters.money(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: highlight ? AppColors.warning : null,
            ),
          ),
        ],
      ),
    );
  }
}
