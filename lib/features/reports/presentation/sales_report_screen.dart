import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/pdf/pdf_builder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';
import 'widgets/report_filter_bar.dart';

/// Spec section 22 "Sales" reports: Today's Sales / by Date / by Product /
/// by Customer / by Representative are all the same aggregate query, just
/// grouped differently — one screen with a group-by selector instead of
/// five near-identical ones.
class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  String _groupBy = 'none';
  late Future<ReportSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ReportSummary> _load() {
    return ref.read(reportsRepositoryProvider).sales(from: _isoDate(_from), to: _isoDate(_to), groupBy: _groupBy);
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
      appBar: AppBar(title: Text(l10n.reportsSales)),
      body: FutureBuilder<ReportSummary>(
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
                      options: {
                        'none': l10n.reportGroupByNone,
                        'date': l10n.reportGroupByDate,
                        'product': l10n.reportGroupByProduct,
                        'customer': l10n.reportGroupByCustomer,
                        'representative': l10n.reportGroupByRepresentative,
                      },
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
                  ConnectionState.done when snapshot.hasData => _SalesReportBody(report: snapshot.data!, isArabic: isArabic),
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

class _SalesReportBody extends StatelessWidget {
  const _SalesReportBody({required this.report, required this.isArabic});

  final ReportSummary report;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.reportInvoiceCount, style: Theme.of(context).textTheme.bodySmall),
                      Text('${report.count ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.reportTotal, style: Theme.of(context).textTheme.bodySmall),
                      Text(Formatters.money(report.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
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
                    final label = row.date != null ? Formatters.dateFromIso(row.date!) : ((isArabic ? row.nameAr : row.name) ?? row.name);
                    return Card(
                      child: ListTile(
                        title: Text(label),
                        subtitle: row.count != null
                            ? Text('${row.count} ${l10n.reportInvoiceCount}')
                            : row.quantity != null
                                ? Text(Formatters.number(row.quantity!))
                                : null,
                        trailing: Text(Formatters.money(row.total), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      await Printing.sharePdf(bytes: await doc.save(), filename: 'sales_report.pdf');
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

  Future<pw.Document> _buildPdf(AppLocalizations l10n) {
    return PdfBuilder.genericReport(
      title: l10n.reportsSales,
      subtitle: '${report.from} – ${report.to}',
      headers: [l10n.reportGroupBy, l10n.reportInvoiceCount, l10n.reportTotal],
      rows: report.rows
          .map((r) => [
                r.date != null ? Formatters.dateFromIso(r.date!) : ((isArabic ? r.nameAr : r.name) ?? r.name),
                r.count?.toString() ?? '-',
                Formatters.money(r.total),
              ])
          .toList(),
      summary: [
        MapEntry(l10n.reportInvoiceCount, '${report.count ?? 0}'),
        MapEntry(l10n.reportTotal, Formatters.money(report.total)),
      ],
    );
  }
}
