import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/pdf/pdf_builder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';

/// Spec section 23 "Receivables Aging" — current/1-30/31-60/61-90/90+ day
/// buckets plus the per-customer balance list (tap a customer to open their
/// statement), backed by [ReceivableController], which already existed
/// since Phase 1 but had no mobile screen until now.
class ReceivablesReportScreen extends ConsumerStatefulWidget {
  const ReceivablesReportScreen({super.key});

  @override
  ConsumerState<ReceivablesReportScreen> createState() => _ReceivablesReportScreenState();
}

class _ReceivablesReportScreenState extends ConsumerState<ReceivablesReportScreen> {
  late Future<ReceivablesAging> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(reportsRepositoryProvider).receivables();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsReceivables)),
      body: FutureBuilder<ReceivablesAging>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return ErrorStateView(
              error: snapshot.error is ApiException
                  ? snapshot.error! as ApiException
                  : ApiException(messageEn: l10n.commonSomethingWentWrong, messageAr: l10n.commonSomethingWentWrong),
              onRetry: () => setState(() => _future = ref.read(reportsRepositoryProvider).receivables()),
            );
          }

          final aging = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _bucketRow(context, l10n.receivablesCurrent, aging.buckets.current),
                            _bucketRow(context, l10n.receivablesDays1to30, aging.buckets.days1to30),
                            _bucketRow(context, l10n.receivablesDays31to60, aging.buckets.days31to60),
                            _bucketRow(context, l10n.receivablesDays61to90, aging.buckets.days61to90),
                            _bucketRow(context, l10n.receivablesOver90, aging.buckets.daysOver90),
                            const Divider(height: 24),
                            _bucketRow(context, l10n.receivablesTotal, aging.total, bold: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.receivablesCustomers, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (aging.customers.isEmpty)
                      EmptyStateView(title: l10n.receivablesEmpty)
                    else
                      ...aging.customers.map(
                        (customer) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(isArabic ? customer.nameAr : customer.name),
                            trailing: Text(Formatters.money(customer.balance), style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () => context.push('/customers/${customer.customerId}/statement'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final doc = await _buildPdf(l10n, aging, isArabic);
                            await Printing.sharePdf(bytes: await doc.save(), filename: 'receivables_aging.pdf');
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.commonShare),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final doc = await _buildPdf(l10n, aging, isArabic);
                            await Printing.layoutPdf(onLayout: (_) => doc.save());
                          },
                          icon: const Icon(Icons.print_outlined),
                          label: Text(l10n.commonPrint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bucketRow(BuildContext context, String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(Formatters.money(value), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14)),
          ],
        ),
      );

  Future<pw.Document> _buildPdf(AppLocalizations l10n, ReceivablesAging aging, bool isArabic) {
    return PdfBuilder.genericReport(
      title: l10n.reportsReceivables,
      subtitle: DateTime.now().toIso8601String().split('T').first,
      headers: [l10n.receivablesCustomers, l10n.reportTotal],
      rows: aging.customers.map((c) => [isArabic ? c.nameAr : c.name, Formatters.money(c.balance)]).toList(),
      summary: [
        MapEntry(l10n.receivablesCurrent, Formatters.money(aging.buckets.current)),
        MapEntry(l10n.receivablesDays1to30, Formatters.money(aging.buckets.days1to30)),
        MapEntry(l10n.receivablesDays31to60, Formatters.money(aging.buckets.days31to60)),
        MapEntry(l10n.receivablesDays61to90, Formatters.money(aging.buckets.days61to90)),
        MapEntry(l10n.receivablesOver90, Formatters.money(aging.buckets.daysOver90)),
        MapEntry(l10n.receivablesTotal, Formatters.money(aging.total)),
      ],
    );
  }
}
