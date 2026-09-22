import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../application/products_list_controller.dart';
import '../data/product_model.dart';
import 'widgets/product_found_sheet.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key, this.forSelection = false});

  final bool forSelection;

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsListControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(productsListControllerProvider.notifier).search(value);
    });
  }

  Future<void> _onProductTap(ProductModel product) async {
    final selected = await showProductFoundSheet(context, product, forSelection: widget.forSelection);
    if (selected == null || !mounted) return;
    context.pop(selected);
  }

  Future<void> _onScanTap() async {
    final scanned = await context.push<ProductModel>('/products/scan');
    if (scanned == null || !mounted) return;

    final selected = await showProductFoundSheet(context, scanned, forSelection: widget.forSelection);
    if (selected == null || !mounted) return;
    context.pop(selected);
  }

  Future<void> _onAddProductTap() async {
    final created = await context.push('/products/new');
    if (created != null) ref.invalidate(productsListControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(productsListControllerProvider);
    final canCreate = !widget.forSelection && ref.watch(authControllerProvider).user?.can('products.create') == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.saleAddProducts),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(onPressed: _onAddProductTap, child: const Icon(Icons.add))
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: l10n.productSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _onScanTap,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const SkeletonList(),
              error: (error, _) => ErrorStateView(
                error: error,
                onRetry: () => ref.invalidate(productsListControllerProvider),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return EmptyStateView(title: l10n.productsEmpty, icon: Icons.inventory_2_outlined);
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.items.length + (data.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= data.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final product = data.items[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(isArabic ? product.nameAr : product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${product.sku}${product.barcode != null ? ' • ${product.barcode}' : ''}'),
                        trailing: Text(
                          Formatters.money(product.defaultSaleUnit.sellingPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _onProductTap(product),
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
