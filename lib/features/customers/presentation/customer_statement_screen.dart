import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/pdf/pdf_builder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/customer_model.dart';
import '../data/customer_statement_model.dart';
import '../data/customers_repository.dart';

class CustomerStatementScreen extends ConsumerStatefulWidget {
  const CustomerStatementScreen({super.key, required this.customerId});

  final int customerId;

  @override
  ConsumerState<CustomerStatementScreen> createState() => _CustomerStatementScreenState();
}

class _CustomerStatementScreenState extends ConsumerState<CustomerStatementScreen> {
  DateTime? _from;
  DateTime? _to;
  CustomerModel? _customer;
  late Future<CustomerStatement> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<CustomerStatement> _load() async {
    final repo = ref.read(customersRepositoryProvider);
    _customer ??= await repo.find(widget.customerId);
    return repo.statement(widget.customerId, from: _from, to: _to);
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _from != null && _to != null ? DateTimeRange(start: _from!, end: _to!) : null,
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
        _future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerStatement),
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: _pickRange),
        ],
      ),
      body: FutureBuilder<CustomerStatement>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return ErrorStateView(
              error: snapshot.error is ApiException ? snapshot.error! : ApiException(
                messageEn: l10n.commonSomethingWentWrong,
                messageAr: l10n.commonSomethingWentWrong,
              ),
              onRetry: () => setState(() => _future = _load()),
            );
          }

          final statement = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_customer != null)
                      Text(_customer!.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
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
                            final doc = await PdfBuilder.statement(_customer!, statement);
                            await Printing.sharePdf(bytes: await doc.save(), filename: 'statement_${_customer!.code}.pdf');
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.commonShare),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final doc = await PdfBuilder.statement(_customer!, statement);
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
}
