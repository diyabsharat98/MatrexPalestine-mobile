import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/submit_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../customers/data/customer_model.dart';
import '../../customers/data/customers_repository.dart';
import '../../products/data/product_model.dart';
import '../application/new_sale_controller.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key, this.initialCustomerId});

  final int? initialCustomerId;

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  int _step = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerId != null) {
      _step = 1;
      Future.microtask(() async {
        final customer = await ref.read(customersRepositoryProvider).find(widget.initialCustomerId!);
        ref.read(newSaleControllerProvider.notifier).setCustomer(customer);
      });
    }
  }

  Future<void> _pickCustomer() async {
    final customer = await context.push<CustomerModel>('/customer-picker');
    if (customer != null) {
      ref.read(newSaleControllerProvider.notifier).setCustomer(customer);
    }
  }

  Future<void> _pickProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) {
      ref.read(newSaleControllerProvider.notifier).addProduct(product);
    }
  }

  Future<void> _scanProduct() async {
    final product = await context.push<ProductModel>('/products/scan');
    if (product != null) {
      ref.read(newSaleControllerProvider.notifier).addProduct(product);
    }
  }

  bool _canGoNext(NewSaleState state) {
    if (_step == 0) return state.customer != null;
    if (_step == 1) return state.lines.isNotEmpty;
    return true;
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final warehouseId = ref.read(currentUserWarehouseIdProvider);
    if (warehouseId == null) return;

    setState(() => _submitting = true);
    try {
      final result = await ref.read(newSaleControllerProvider.notifier).submit(warehouseId);
      if (!mounted) return;

      switch (result) {
        case SubmitSynced(:final data):
          context.pushReplacement('/sales/${data.id}', extra: true);
        case SubmitQueued():
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.saleCompletedTitle),
              content: Text(l10n.syncQueuedOffline),
              actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonClose))],
            ),
          );
          if (mounted) context.go('/');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.loginFailedTitle),
          content: Text(e.message(isArabic)),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonClose))],
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(newSaleControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleNewSale)),
      body: IndexedStack(
        index: _step,
        children: [
          _CustomerStep(onPick: _pickCustomer),
          _ProductsStep(onAdd: _pickProduct, onScan: _scanProduct),
          _ReviewStep(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step -= 1),
                    child: Text(l10n.saleBackStep),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: !_canGoNext(state)
                      ? null
                      : _submitting
                          ? null
                          : _step < 2
                              ? () => setState(() => _step += 1)
                              : _confirm,
                  child: _submitting
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_step < 2 ? l10n.saleNextStep : l10n.saleConfirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerStep extends ConsumerWidget {
  const _CustomerStep({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final customer = ref.watch(newSaleControllerProvider).customer;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (customer != null)
            Card(
              child: ListTile(
                title: Text(isArabic ? customer.nameAr : customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${l10n.customerBalance}: ${Formatters.money(customer.balance)}'),
                trailing: TextButton(onPressed: onPick, child: Text(l10n.commonSearch)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.person_search),
              label: Text(l10n.saleSelectCustomer),
            ),
        ],
      ),
    );
  }
}

class _ProductsStep extends ConsumerWidget {
  const _ProductsStep({required this.onAdd, required this.onScan});

  final VoidCallback onAdd;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(newSaleControllerProvider);
    final notifier = ref.read(newSaleControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.search), label: Text(l10n.productSearchHint)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(onPressed: onScan, icon: const Icon(Icons.qr_code_scanner), label: Text(l10n.productScanBarcode)),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.lines.isEmpty
              ? Center(child: Text(l10n.saleCartEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.lines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final line = state.lines[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isArabic ? line.product.nameAr : line.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                  onPressed: () => notifier.removeLine(index),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => notifier.updateQuantity(index, line.quantity - 1),
                                    ),
                                    Text(Formatters.number(line.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => notifier.updateQuantity(index, line.quantity + 1),
                                    ),
                                    Text(line.unit.unitSymbol),
                                  ],
                                ),
                                Text(Formatters.money(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (state.lines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.saleSubtotal, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(Formatters.money(state.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<_ReviewStep> {
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  static const _methods = ['cash', 'bank_transfer', 'cheque', 'credit', 'partial'];

  String _methodLabel(AppLocalizations l10n, String method) => switch (method) {
        'cash' => l10n.salePaymentCash,
        'bank_transfer' => l10n.salePaymentBankTransfer,
        'cheque' => l10n.salePaymentCheque,
        'credit' => l10n.salePaymentCredit,
        'partial' => l10n.salePaymentPartial,
        _ => method,
      };

  @override
  void dispose() {
    _discountController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(newSaleControllerProvider);
    final notifier = ref.read(newSaleControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.saleReview, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _discountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.saleDiscount),
          onChanged: (v) => notifier.setDiscount(double.tryParse(v) ?? 0),
        ),
        const SizedBox(height: 16),
        Text(l10n.salePaymentMethod, style: Theme.of(context).textTheme.titleSmall),
        Wrap(
          spacing: 8,
          children: _methods
              .map((m) => ChoiceChip(
                    label: Text(_methodLabel(l10n, m)),
                    selected: state.paymentMethod == m,
                    onSelected: (_) => notifier.setPaymentMethod(m),
                  ))
              .toList(),
        ),
        if (state.paymentMethod == 'partial' || state.paymentMethod == 'cash' || state.paymentMethod == 'bank_transfer' || state.paymentMethod == 'cheque') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _paidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.salePaid),
            onChanged: (v) => notifier.setPaidAmount(double.tryParse(v) ?? 0),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(labelText: l10n.commonNotes),
          onChanged: notifier.setNotes,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _line(l10n.saleSubtotal, state.subtotal),
        _line(l10n.saleDiscount, state.discountAmount),
        const Divider(),
        _line(l10n.saleTotal, state.total, bold: true),
        _line(l10n.salePaid, state.paidAmount),
        _line(l10n.saleRemaining, state.remaining, bold: true),
      ],
    );
  }

  Widget _line(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            Text(Formatters.money(value), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14)),
          ],
        ),
      );
}
