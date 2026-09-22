import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/state_views.dart';

class StockRow {
  const StockRow({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.baseUnitSymbol,
    required this.quantity,
    required this.reorderLevel,
    required this.isLowStock,
  });

  final int productId;
  final String productName;
  final String productNameAr;
  final String baseUnitSymbol;
  final double quantity;
  final double reorderLevel;
  final bool isLowStock;

  factory StockRow.fromJson(Map<String, dynamic> json) => StockRow(
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        productNameAr: json['product_name_ar'] as String,
        baseUnitSymbol: json['base_unit_symbol'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        reorderLevel: (json['reorder_level'] as num).toDouble(),
        isLowStock: json['is_low_stock'] as bool,
      );
}

class _LowStockOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final stockLowStockOnlyProvider = NotifierProvider.autoDispose<_LowStockOnlyNotifier, bool>(_LowStockOnlyNotifier.new);

final stockListProvider = FutureProvider.autoDispose<List<StockRow>>((ref) {
  final lowStockOnly = ref.watch(stockLowStockOnlyProvider);
  return guardApiCall(() async {
    final dio = ref.watch(dioProvider);
    final response = await dio.get('/stock', queryParameters: {'per_page': 100, if (lowStockOnly) 'low_stock': true});
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data.map((e) => StockRow.fromJson(e as Map<String, dynamic>)).toList();
  });
});

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final stockAsync = ref.watch(stockListProvider);
    final lowStockOnly = ref.watch(stockLowStockOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStock),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(stockListProvider.future),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterChip(
                  label: Text(l10n.stockLowStockOnly),
                  avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                  selected: lowStockOnly,
                  onSelected: (value) => ref.read(stockLowStockOnlyProvider.notifier).set(value),
                ),
              ),
            ),
            Expanded(
              child: stockAsync.when(
                loading: () => const SkeletonList(),
                error: (error, _) => ListView(children: [
                  ErrorStateView(error: error, onRetry: () => ref.invalidate(stockListProvider)),
                ]),
                data: (rows) {
                  if (rows.isEmpty) return ListView(children: [EmptyStateView(title: l10n.stockEmpty)]);
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return Card(
                        child: ListTile(
                          title: Text(isArabic ? row.productNameAr : row.productName),
                          trailing: Text(
                            '${Formatters.number(row.quantity)} ${row.baseUnitSymbol}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: row.isLowStock ? AppColors.danger : null,
                            ),
                          ),
                          leading: row.isLowStock ? const Icon(Icons.warning_amber_rounded, color: AppColors.warning) : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
