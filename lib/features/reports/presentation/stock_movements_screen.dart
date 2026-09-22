import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../products/data/product_model.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';

/// Spec section 22 "Inventory" — Stock Movement / Product Stock Card:
/// the same filtered-by-product movement ledger, either browsed freely
/// (Stock Movement) or narrowed to one product (Product Stock Card, via the
/// product-picker filter chip) — [StockMovementController] already
/// supported both on the backend, so this is the first UI for it.
class StockMovementsScreen extends ConsumerStatefulWidget {
  const StockMovementsScreen({super.key});

  @override
  ConsumerState<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends ConsumerState<StockMovementsScreen> {
  ProductModel? _product;
  String? _type;
  late Future<List<StockMovementRow>> _future;

  static const _types = ['purchase', 'sale', 'return', 'adjustment', 'transfer', 'vehicle_load', 'vehicle_return'];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<StockMovementRow>> _load() async {
    final result = await ref.read(reportsRepositoryProvider).stockMovements(productId: _product?.id, type: _type);
    return result.items;
  }

  Future<void> _pickProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) {
      setState(() {
        _product = product;
        _future = _load();
      });
    }
  }

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
        'purchase' => l10n.movementTypePurchase,
        'sale' => l10n.movementTypeSale,
        'return' => l10n.movementTypeReturn,
        'adjustment' => l10n.movementTypeAdjustment,
        'transfer' => l10n.movementTypeTransfer,
        'vehicle_load' => l10n.movementTypeVehicleLoad,
        'vehicle_return' => l10n.movementTypeVehicleReturn,
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.movementsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickProduct,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: Text(
                          _product == null ? l10n.productSearchHint : (isArabic ? _product!.nameAr : _product!.name),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (_product != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _product = null;
                          _future = _load();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(l10n.movementTypeAll),
                          selected: _type == null,
                          onSelected: (_) => setState(() {
                            _type = null;
                            _future = _load();
                          }),
                        ),
                      ),
                      for (final type in _types)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(_typeLabel(l10n, type)),
                            selected: _type == type,
                            onSelected: (_) => setState(() {
                              _type = type;
                              _future = _load();
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StockMovementRow>>(
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
                    onRetry: () => setState(() => _future = _load()),
                  );
                }

                final rows = snapshot.data!;
                if (rows.isEmpty) {
                  return ListView(children: [EmptyStateView(title: l10n.movementsEmpty)]);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final isIncrease = row.quantityChange >= 0;
                    return Card(
                      child: ListTile(
                        title: Text(isArabic ? row.productNameAr : row.productName),
                        subtitle: Text(
                          '${_typeLabel(l10n, row.type)} • ${Formatters.dateFromIso(row.createdAt)}'
                          '${row.warehouseName != null ? ' • ${row.warehouseName}' : ''}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncrease ? '+' : ''}${Formatters.number(row.quantityChange)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isIncrease ? AppColors.success : AppColors.danger),
                            ),
                            Text(Formatters.number(row.balanceAfter), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
