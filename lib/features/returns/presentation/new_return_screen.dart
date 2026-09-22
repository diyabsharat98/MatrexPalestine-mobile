import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/submit_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../customers/data/customer_model.dart';
import '../../sales/data/sale_model.dart';
import '../../sales/data/sales_repository.dart';
import '../application/new_return_controller.dart';
import '../data/sales_return_model.dart';

final _customerInvoicesProvider = FutureProvider.autoDispose.family<List<SaleModel>, int>((ref, customerId) async {
  final result = await ref.watch(salesRepositoryProvider).list(customerId: customerId);
  return result.items.where((i) => i.status == 'confirmed').toList();
});

class NewReturnScreen extends ConsumerStatefulWidget {
  const NewReturnScreen({super.key});

  @override
  ConsumerState<NewReturnScreen> createState() => _NewReturnScreenState();
}

class _NewReturnScreenState extends ConsumerState<NewReturnScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _pickCustomer() async {
    final customer = await context.push<CustomerModel>('/customer-picker');
    if (customer != null) {
      ref.read(newReturnControllerProvider.notifier).setCustomer(customer);
    }
  }

  Future<void> _pickInvoice(int invoiceId) async {
    final full = await ref.read(salesRepositoryProvider).find(invoiceId);
    ref.read(newReturnControllerProvider.notifier).setInvoice(full);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await ref.read(newReturnControllerProvider.notifier).submit();
      if (mounted) {
        final total = ref.read(newReturnControllerProvider).total;
        final queued = result is SubmitQueued<SalesReturnModel>;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.returnCompletedTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.money(total)),
                if (queued) ...[
                  const SizedBox(height: 8),
                  Text(l10n.syncQueuedOffline, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop();
                },
                child: Text(l10n.commonClose),
              ),
            ],
          ),
        );
      }
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(newReturnControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.returnNewReturn)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.customer == null)
            OutlinedButton.icon(onPressed: _pickCustomer, icon: const Icon(Icons.person_search), label: Text(l10n.saleSelectCustomer))
          else ...[
            Card(
              child: ListTile(
                title: Text(isArabic ? state.customer!.nameAr : state.customer!.name),
                trailing: TextButton(onPressed: _pickCustomer, child: Text(l10n.commonSearch)),
              ),
            ),
            const SizedBox(height: 16),
            if (state.invoice == null) ...[
              Text(l10n.returnSelectInvoice, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Consumer(builder: (context, ref, _) {
                final invoicesAsync = ref.watch(_customerInvoicesProvider(state.customer!.id));
                return invoicesAsync.when(
                  loading: () => const SkeletonList(itemCount: 3),
                  error: (error, _) => ErrorStateView(error: error),
                  data: (invoices) {
                    if (invoices.isEmpty) return EmptyStateView(title: l10n.salesEmpty);
                    return Column(
                      children: invoices
                          .map((inv) => Card(
                                child: ListTile(
                                  title: Text(inv.invoiceNumber),
                                  subtitle: Text('${Formatters.dateFromIso(inv.invoiceDate)} • ${Formatters.money(inv.total)}'),
                                  onTap: () => _pickInvoice(inv.id),
                                ),
                              ))
                          .toList(),
                    );
                  },
                );
              }),
            ] else ...[
              Text(l10n.returnSelectProducts, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ),
                const SizedBox(height: 12),
              ],
              ...state.invoice!.items.map((item) {
                final qty = state.quantities[item.id] ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${l10n.returnMaxReturnable}: ${Formatters.number(item.quantity)} ${item.unitSymbol}', style: Theme.of(context).textTheme.bodySmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: qty > 0
                                      ? () => ref.read(newReturnControllerProvider.notifier).setQuantity(item.id, qty - 1)
                                      : null,
                                ),
                                Text(Formatters.number(qty), style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: qty < item.quantity
                                      ? () => ref.read(newReturnControllerProvider.notifier).setQuantity(item.id, qty + 1)
                                      : null,
                                ),
                              ],
                            ),
                            Text(Formatters.money(qty * item.unitPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.saleTotal, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(Formatters.money(state.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: (_submitting || state.total <= 0) ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.returnConfirm),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
