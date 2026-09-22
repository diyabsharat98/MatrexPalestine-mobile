import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/storage/sync_outbox_service.dart';
import '../../../core/sync/sync_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../customers/data/customer_model.dart';
import '../../customers/data/customers_repository.dart';
import '../data/payments_repository.dart';

class NewPaymentScreen extends ConsumerStatefulWidget {
  const NewPaymentScreen({super.key, this.initialCustomerId});

  final int? initialCustomerId;

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  CustomerModel? _customer;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  String _method = 'cash';
  bool _submitting = false;
  String? _error;
  double? _recordedAmount;
  double? _previousBalance;
  bool _queued = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerId != null) {
      ref.read(customersRepositoryProvider).find(widget.initialCustomerId!).then((c) {
        if (mounted) setState(() => _customer = c);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final customer = await context.push<CustomerModel>('/customer-picker');
    if (customer != null) setState(() => _customer = customer);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_customer == null) {
      setState(() => _error = l10n.paymentSelectCustomerFirst);
      return;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final previousBalance = _customer!.balance;
    final uuid = const Uuid().v4();
    var queued = false;

    try {
      if (ref.read(isOnlineProvider)) {
        try {
          await ref.read(paymentsRepositoryProvider).create(
                uuid: uuid,
                customerId: _customer!.id,
                amount: amount,
                method: _method,
                reference: _referenceController.text,
              );
        } on ApiException catch (e) {
          if (!e.isNetworkError) rethrow;
          queued = true;
        }
      } else {
        queued = true;
      }

      if (queued) {
        await ref.read(syncOutboxServiceProvider).enqueue(
          uuid: uuid,
          type: 'payment',
          payload: {
            'customer_id': _customer!.id,
            'amount': amount,
            'method': _method,
            if (_referenceController.text.isNotEmpty) 'reference': _referenceController.text,
          },
        );
        ref.invalidate(pendingSyncCountProvider);
      }

      setState(() {
        _recordedAmount = amount;
        _previousBalance = previousBalance;
        _queued = queued;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() => _error = e.message(isArabic));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_recordedAmount != null && _previousBalance != null) {
      return _ConfirmationView(
        previousBalance: _previousBalance!,
        paymentAmount: _recordedAmount!,
        queued: _queued,
        onDone: () => context.pop(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardCollectPayment)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_customer != null)
            Card(
              child: ListTile(
                title: Text(_customer!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${l10n.paymentCurrentBalance}: ${Formatters.money(_customer!.balance)}'),
                trailing: TextButton(onPressed: _pickCustomer, child: Text(l10n.commonSearch)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _pickCustomer,
              icon: const Icon(Icons.person_search),
              label: Text(l10n.saleSelectCustomer),
            ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(labelText: l10n.paymentAmount),
          ),
          const SizedBox(height: 20),
          Text(l10n.salePaymentMethod, style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<String>(
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            child: Column(
              children: [
                RadioListTile(title: Text(l10n.salePaymentCash), value: 'cash'),
                RadioListTile(title: Text(l10n.salePaymentBankTransfer), value: 'bank_transfer'),
                RadioListTile(title: Text(l10n.salePaymentCheque), value: 'cheque'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _referenceController,
            decoration: InputDecoration(labelText: l10n.paymentReference),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.paymentConfirm),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({
    required this.previousBalance,
    required this.paymentAmount,
    required this.onDone,
    this.queued = false,
  });

  final double previousBalance;
  final double paymentAmount;
  final bool queued;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final newBalance = previousBalance - paymentAmount;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 72),
                const SizedBox(height: 16),
                Text(l10n.paymentRecordedTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (queued) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(l10n.syncQueuedOffline, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 24),
                _row(context, l10n.paymentPreviousBalance, previousBalance),
                _row(context, l10n.paymentAmount, paymentAmount),
                const Divider(height: 32),
                _row(context, l10n.paymentNewBalance, newBalance, bold: true),
                const SizedBox(height: 32),
                FilledButton(onPressed: onDone, child: Text(l10n.commonClose)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              Formatters.money(value),
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 14),
            ),
          ],
        ),
      );
}
