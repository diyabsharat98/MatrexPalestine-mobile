import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/pdf/pdf_builder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';
import 'widgets/report_filter_bar.dart';

/// Spec section 22 "Profit": Sales / Cost / Gross Profit / Gross Margin,
/// derived from `sales_invoice_items.cost_price_snapshot` (the cost
/// recorded at the moment of sale, not today's product cost) so historical
/// margins stay accurate even after supplier prices change.
class ProfitReportScreen extends ConsumerStatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  ConsumerState<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends ConsumerState<ProfitReportScreen> {
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  String _groupBy = 'none';
  late Future<ProfitReport> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ProfitReport> _load() {
    return ref.read(reportsRepositoryProvider).profit(from: _isoDate(_from), to: _isoDate(_to), groupBy: _groupBy);
  }

  String _isoDate(DateTime date) => date.toIso8601String().split('T').first;

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
        _future = _load();
      });
    }
  }

  void _setGroupBy(String value) {
    setState(() {
      _groupBy = value;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsProfit)),
      body: FutureBuilder<ProfitReport>(
        future: _future,
        builder: (context, snapshot) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ReportDateRangeBar(from: _from, to: _to, onTap: _pickRange),
                    const SizedBox(height: 12),
                    ReportGroupByChips(
                      value: _groupBy,
                      onChanged: _setGroupBy,
                      options: {'none': l10n.reportGroupByNone, 'product': l10n.reportGroupByProduct},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (snapshot.connectionState) {
                  ConnectionState.done when snapshot.hasError => ListView(children: [
                      ErrorStateView(
                        error: snapshot.error is ApiException
                            ? snapshot.error! as ApiException
                            : ApiException(messageEn: l10n.commonSomethingWentWrong, messageAr: l10n.commonSomethingWentWrong),
                        onRetry: () => setState(() => _future = _load()),
                      ),
                    ]),
                  ConnectionState.done when snapshot.hasData => _ProfitReportBody(report: snapshot.data!, isArabic: isArabic),
                  _ => const SkeletonList(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfitReportBody extends StatelessWidget {
  const _ProfitReportBody({required this.report, required this.isArabic});

  final ProfitReport report;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summary(context, l10n.profitRevenue, Formatters.money(report.revenue)),
                  _summary(context, l10n.profitCost, Formatters.money(report.cost)),
                  const Divider(),
                  _summary(context, l10n.profitGrossProfit, Formatters.money(report.profit), bold: true),
                  _summary(context, l10n.profitMargin, '${Formatters.number(report.margin)}%', bold: true),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: report.rows.isEmpty
              ? ListView(children: [EmptyStateView(title: l10n.reportNoData)])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: report.rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = report.rows[index];
                    final label = (isArabic ? row.nameAr : row.name) ?? row.name;
                    return Card(
                      child: ListTile(
                        title: Text(label),
                        subtitle: Text('${l10n.profitRevenue}: ${Formatters.money(row.revenue)}  •  ${l10n.profitCost}: ${Formatters.money(row.cost)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.money(row.profit),
                              style: TextStyle(fontWeight: FontWeight.bold, color: row.profit >= 0 ? AppColors.success : AppColors.danger),
                            ),
                            Text('${Formatters.number(row.margin)}%', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
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
                      final doc = await _buildPdf(l10n);
                      await Printing.sharePdf(bytes: await doc.save(), filename: 'profit_report.pdf');
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.commonShare),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final doc = await _buildPdf(l10n);
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
  }

  Widget _summary(BuildContext context, String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14)),
          ],
        ),
      );

  Future<pw.Document> _buildPdf(AppLocalizations l10n) {
    return PdfBuilder.genericReport(
      title: l10n.reportsProfit,
      subtitle: '${report.from} – ${report.to}',
      headers: [l10n.reportGroupBy, l10n.profitRevenue, l10n.profitCost, l10n.profitGrossProfit, l10n.profitMargin],
      rows: report.rows
          .map((r) => [
                (isArabic ? r.nameAr : r.name) ?? r.name,
                Formatters.money(r.revenue),
                Formatters.money(r.cost),
                Formatters.money(r.profit),
                '${Formatters.number(r.margin)}%',
              ])
          .toList(),
      summary: [
        MapEntry(l10n.profitRevenue, Formatters.money(report.revenue)),
        MapEntry(l10n.profitCost, Formatters.money(report.cost)),
        MapEntry(l10n.profitGrossProfit, Formatters.money(report.profit)),
        MapEntry(l10n.profitMargin, '${Formatters.number(report.margin)}%'),
      ],
    );
  }
}
