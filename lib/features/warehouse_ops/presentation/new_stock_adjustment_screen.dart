import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../products/data/product_model.dart';
import '../data/warehouse_ops_repository.dart';

class NewStockAdjustmentScreen extends ConsumerStatefulWidget {
  const NewStockAdjustmentScreen({super.key});

  @override
  ConsumerState<NewStockAdjustmentScreen> createState() => _NewStockAdjustmentScreenState();
}

class _NewStockAdjustmentScreenState extends ConsumerState<NewStockAdjustmentScreen> {
  ProductModel? _product;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) setState(() => _product = product);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final warehouseId = ref.read(authControllerProvider).user?.warehouse?.id;
    final quantity = double.tryParse(_quantityController.text);
    if (warehouseId == null || _product == null || quantity == null || quantity == 0 || _reasonController.text.isEmpty) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(warehouseOpsRepositoryProvider).createAdjustment(
            warehouseId: warehouseId,
            productId: _product!.id,
            quantityChange: quantity * _product!.defaultSaleUnit.conversionFactor,
            reason: _reasonController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adjustmentConfirm)));
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adjustmentNewTitle)),
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
          if (_product == null)
            OutlinedButton.icon(onPressed: _pickProduct, icon: const Icon(Icons.search), label: Text(l10n.productSearchHint))
          else
            Card(
              child: ListTile(
                title: Text(isArabic ? _product!.nameAr : _product!.name),
                trailing: TextButton(onPressed: _pickProduct, child: Text(l10n.commonSearch)),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              labelText: _product == null ? l10n.adjustmentQuantityChange : '${l10n.adjustmentQuantityChange} (${_product!.defaultSaleUnit.unitSymbol})',
              helperText: 'e.g. -2, +5',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(labelText: l10n.adjustmentReason),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.adjustmentConfirm),
          ),
        ],
      ),
    );
  }
}
