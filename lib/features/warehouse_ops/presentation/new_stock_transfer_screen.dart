import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../products/data/product_model.dart';
import '../../vehicles/data/vehicle_model.dart';
import '../data/warehouse_ops_repository.dart';

final _warehousesProvider = FutureProvider.autoDispose((ref) => ref.watch(warehouseOpsRepositoryProvider).listWarehouses());

class NewStockTransferScreen extends ConsumerStatefulWidget {
  const NewStockTransferScreen({super.key});

  @override
  ConsumerState<NewStockTransferScreen> createState() => _NewStockTransferScreenState();
}

class _NewStockTransferScreenState extends ConsumerState<NewStockTransferScreen> {
  WarehouseModel? _from;
  WarehouseModel? _to;
  final List<({ProductModel product, double quantity})> _lines = [];
  bool _submitting = false;
  String? _error;

  Future<void> _addProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) {
      setState(() => _lines.add((product: product, quantity: product.defaultSaleUnit.conversionFactor)));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_from == null || _to == null || _lines.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(warehouseOpsRepositoryProvider).createTransfer(
            fromWarehouseId: _from!.id,
            toWarehouseId: _to!.id,
            items: _lines.map((l) => (productId: l.product.id, quantityBase: l.quantity)).toList(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.transferConfirm)));
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
    final warehousesAsync = ref.watch(_warehousesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transferNewTitle)),
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
          warehousesAsync.when(
            loading: () => const SkeletonBlock(height: 56),
            error: (error, _) => ErrorStateView(error: error),
            data: (warehouses) => Column(
              children: [
                DropdownButtonFormField<WarehouseModel>(
                  initialValue: _from,
                  decoration: InputDecoration(labelText: l10n.transferFromWarehouse),
                  items: warehouses.map((w) => DropdownMenuItem(value: w, child: Text(isArabic ? w.nameAr : w.name))).toList(),
                  onChanged: (w) => setState(() => _from = w),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<WarehouseModel>(
                  initialValue: _to,
                  decoration: InputDecoration(labelText: l10n.transferToWarehouse),
                  items: warehouses.map((w) => DropdownMenuItem(value: w, child: Text(isArabic ? w.nameAr : w.name))).toList(),
                  onChanged: (w) => setState(() => _to = w),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: _addProduct, icon: const Icon(Icons.add), label: Text(l10n.vehicleLoadAddProduct)),
          const SizedBox(height: 12),
          ..._lines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(isArabic ? line.product.nameAr : line.product.name),
                subtitle: Text('${Formatters.number(line.quantity)} ${line.product.baseUnitSymbol}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: () => setState(() => _lines.removeAt(index)),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_submitting || _from == null || _to == null || _lines.isEmpty) ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.transferConfirm),
          ),
        ],
      ),
    );
  }
}
