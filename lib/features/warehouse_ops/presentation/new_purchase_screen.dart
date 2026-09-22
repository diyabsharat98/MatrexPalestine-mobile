import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../products/data/product_model.dart';
import '../../vehicles/data/vehicle_model.dart';
import '../application/new_purchase_controller.dart';
import '../data/warehouse_ops_repository.dart';

final _suppliersProvider = FutureProvider.autoDispose((ref) => ref.watch(warehouseOpsRepositoryProvider).listSuppliers());

class NewPurchaseScreen extends ConsumerStatefulWidget {
  const NewPurchaseScreen({super.key});

  @override
  ConsumerState<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends ConsumerState<NewPurchaseScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _addProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) {
      ref.read(newPurchaseControllerProvider.notifier).addProduct(product);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final warehouseId = ref.read(authControllerProvider).user?.warehouse?.id;
    if (warehouseId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(newPurchaseControllerProvider.notifier).submit(warehouseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.purchaseConfirm)));
        context.pop();
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
    final state = ref.watch(newPurchaseControllerProvider);
    final suppliersAsync = ref.watch(_suppliersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseNewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
            const SizedBox(height: 16),
          ],
          suppliersAsync.when(
            loading: () => const SkeletonBlock(height: 56),
            error: (error, _) => ErrorStateView(error: error),
            data: (suppliers) => DropdownButtonFormField<SupplierModel>(
              initialValue: state.supplier,
              decoration: InputDecoration(labelText: l10n.purchaseSelectSupplier),
              items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(isArabic ? s.nameAr : s.name))).toList(),
              onChanged: (s) {
                if (s != null) ref.read(newPurchaseControllerProvider.notifier).setSupplier(s);
              },
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: _addProduct, icon: const Icon(Icons.add), label: Text(l10n.vehicleLoadAddProduct)),
          const SizedBox(height: 12),
          ...state.lines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(isArabic ? line.product.nameAr : line.product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => ref.read(newPurchaseControllerProvider.notifier).removeLine(index),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: Formatters.number(line.quantity),
                            decoration: InputDecoration(labelText: '${l10n.saleQuantity} (${line.unit.unitSymbol})', isDense: true),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (v) => ref.read(newPurchaseControllerProvider.notifier).updateLine(index, quantity: double.tryParse(v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: Formatters.number(line.unitCost),
                            decoration: InputDecoration(labelText: l10n.purchaseUnitCost, isDense: true),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (v) => ref.read(newPurchaseControllerProvider.notifier).updateLine(index, unitCost: double.tryParse(v)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(Formatters.money(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_submitting || state.supplier == null || state.lines.isEmpty) ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.purchaseConfirm),
          ),
        ],
      ),
    );
  }
}
