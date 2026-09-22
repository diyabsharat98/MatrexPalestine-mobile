import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../vehicles/data/vehicle_model.dart';
import '../../warehouse_ops/data/warehouse_ops_repository.dart';
import '../data/product_catalog_repository.dart';
import '../data/products_repository.dart';

class NewProductScreen extends ConsumerStatefulWidget {
  const NewProductScreen({super.key});

  @override
  ConsumerState<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends ConsumerState<NewProductScreen> {
  final _name = TextEditingController();
  final _nameAr = TextEditingController();
  final _barcode = TextEditingController();
  final _costPrice = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _reorderLevel = TextEditingController();
  final _bulkConversionFactor = TextEditingController();
  final _bulkSellingPrice = TextEditingController();
  final _openingQuantity = TextEditingController();

  late Future<void> _refDataFuture;
  List<CatalogRef> _categories = [];
  List<CatalogRef> _brands = [];
  List<CatalogRef> _units = [];
  List<WarehouseModel> _warehouses = [];

  int? _categoryId;
  int? _brandId;
  int? _baseUnitId;
  int? _bulkUnitId;
  int? _warehouseId;
  bool _addBulkUnit = false;
  bool _addOpeningStock = false;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refDataFuture = _loadReferenceData();
  }

  @override
  void dispose() {
    _name.dispose();
    _nameAr.dispose();
    _barcode.dispose();
    _costPrice.dispose();
    _sellingPrice.dispose();
    _reorderLevel.dispose();
    _bulkConversionFactor.dispose();
    _bulkSellingPrice.dispose();
    _openingQuantity.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final catalog = ref.read(productCatalogRepositoryProvider);
    final warehouseOps = ref.read(warehouseOpsRepositoryProvider);

    final (categories, brands, units, warehouses) = (
      await catalog.categories(),
      await catalog.brands(),
      await catalog.units(),
      await warehouseOps.listWarehouses(),
    );

    setState(() {
      _categories = categories;
      _brands = brands;
      _units = units;
      _warehouses = warehouses;
      _baseUnitId = _units.isNotEmpty ? _units.first.id : null;
      _warehouseId = _warehouses.isNotEmpty ? _warehouses.first.id : null;
    });
  }

  Future<void> _addCatalogRef({
    required String title,
    required Future<CatalogRef> Function(String name, String nameAr) create,
    required void Function(CatalogRef) onCreated,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final nameArController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameArController, decoration: InputDecoration(labelText: l10n.customerFieldNameAr)),
            const SizedBox(height: 8),
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.customerFieldName)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );

    if (created != true || nameController.text.trim().isEmpty || nameArController.text.trim().isEmpty) return;

    try {
      final ref = await create(nameController.text.trim(), nameArController.text.trim());
      onCreated(ref);
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() => _error = e.message(isArabic));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_name.text.trim().isEmpty || _nameAr.text.trim().isEmpty || _baseUnitId == null || _sellingPrice.text.trim().isEmpty) {
      setState(() => _error = l10n.productValidationRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final product = await ref.read(productsRepositoryProvider).create(
            name: _name.text.trim(),
            nameAr: _nameAr.text.trim(),
            barcode: _barcode.text.trim(),
            categoryId: _categoryId,
            brandId: _brandId,
            baseUnitId: _baseUnitId!,
            costPrice: double.tryParse(_costPrice.text.trim()),
            sellingPrice: double.parse(_sellingPrice.text.trim()),
            reorderLevel: double.tryParse(_reorderLevel.text.trim()),
            bulkUnitId: _addBulkUnit ? _bulkUnitId : null,
            bulkConversionFactor: _addBulkUnit ? double.tryParse(_bulkConversionFactor.text.trim()) : null,
            bulkSellingPrice: _addBulkUnit ? double.tryParse(_bulkSellingPrice.text.trim()) : null,
            warehouseId: _addOpeningStock ? _warehouseId : null,
            openingQuantity: _addOpeningStock ? double.tryParse(_openingQuantity.text.trim()) : null,
          );
      if (mounted) context.pop(product);
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
      appBar: AppBar(title: Text(l10n.productNewProduct)),
      body: FutureBuilder<void>(
        future: _refDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.commonSomethingWentWrong));
          }

          return ListView(
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
              TextField(controller: _nameAr, decoration: InputDecoration(labelText: l10n.customerFieldNameAr)),
              const SizedBox(height: 12),
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.customerFieldName)),
              const SizedBox(height: 12),
              TextField(controller: _barcode, decoration: InputDecoration(labelText: l10n.productBarcode)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RefDropdown(
                      label: l10n.productCategory,
                      items: _categories,
                      isArabic: isArabic,
                      value: _categoryId,
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _addCatalogRef(
                      title: l10n.productAddCategory,
                      create: ref.read(productCatalogRepositoryProvider).createCategory,
                      onCreated: (c) => setState(() {
                        _categories = [..._categories, c];
                        _categoryId = c.id;
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _RefDropdown(
                      label: l10n.productBrand,
                      items: _brands,
                      isArabic: isArabic,
                      value: _brandId,
                      onChanged: (v) => setState(() => _brandId = v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _addCatalogRef(
                      title: l10n.productAddBrand,
                      create: ref.read(productCatalogRepositoryProvider).createBrand,
                      onCreated: (b) => setState(() {
                        _brands = [..._brands, b];
                        _brandId = b.id;
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _RefDropdown(
                      label: l10n.productBaseUnit,
                      items: _units,
                      isArabic: isArabic,
                      value: _baseUnitId,
                      onChanged: (v) => setState(() => _baseUnitId = v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _addUnit((u) => setState(() {
                      _units = [..._units, u];
                      _baseUnitId = u.id;
                    })),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.purchaseUnitCost),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _sellingPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.productSellingPrice),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reorderLevel,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.productReorderLevel),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.productAddBulkUnit),
                value: _addBulkUnit,
                onChanged: (v) => setState(() => _addBulkUnit = v),
              ),
              if (_addBulkUnit) ...[
                Row(
                  children: [
                    Expanded(
                      child: _RefDropdown(
                        label: l10n.productBulkUnit,
                        items: _units.where((u) => u.id != _baseUnitId).toList(),
                        isArabic: isArabic,
                        value: _bulkUnitId,
                        onChanged: (v) => setState(() => _bulkUnitId = v),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addUnit((u) => setState(() {
                        _units = [..._units, u];
                        _bulkUnitId = u.id;
                      })),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bulkConversionFactor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.productBulkConversion),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _bulkSellingPrice,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.productSellingPrice),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.productAddOpeningStock),
                value: _addOpeningStock,
                onChanged: (v) => setState(() => _addOpeningStock = v),
              ),
              if (_addOpeningStock) ...[
                _RefDropdown(
                  label: l10n.navStock,
                  items: _warehouses.map((w) => CatalogRef(id: w.id, name: w.name, nameAr: w.nameAr)).toList(),
                  isArabic: isArabic,
                  value: _warehouseId,
                  onChanged: (v) => setState(() => _warehouseId = v),
                ),
                TextField(
                  controller: _openingQuantity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.productOpeningQuantity),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.productSave),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addUnit(void Function(CatalogRef) onCreated) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final nameArController = TextEditingController();
    final symbolController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.productAddUnit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameArController, decoration: InputDecoration(labelText: l10n.customerFieldNameAr)),
            const SizedBox(height: 8),
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.customerFieldName)),
            const SizedBox(height: 8),
            TextField(controller: symbolController, decoration: InputDecoration(labelText: l10n.productUnitSymbol)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );

    if (created != true ||
        nameController.text.trim().isEmpty ||
        nameArController.text.trim().isEmpty ||
        symbolController.text.trim().isEmpty) {
      return;
    }

    try {
      final unit = await ref
          .read(productCatalogRepositoryProvider)
          .createUnit(nameController.text.trim(), nameArController.text.trim(), symbolController.text.trim());
      onCreated(unit);
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() => _error = e.message(isArabic));
    }
  }
}

class _RefDropdown extends StatelessWidget {
  const _RefDropdown({required this.label, required this.items, required this.isArabic, required this.value, required this.onChanged});

  final String label;
  final List<CatalogRef> items;
  final bool isArabic;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: items.any((i) => i.id == value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((i) => DropdownMenuItem(value: i.id, child: Text(isArabic ? i.nameAr : i.name, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
