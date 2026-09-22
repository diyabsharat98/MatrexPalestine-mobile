class ProductUnitModel {
  const ProductUnitModel({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.unitNameAr,
    required this.unitSymbol,
    required this.conversionFactor,
    required this.sellingPrice,
    required this.isBaseUnit,
    required this.isDefaultSaleUnit,
  });

  final int id;
  final int unitId;
  final String unitName;
  final String unitNameAr;
  final String unitSymbol;
  final double conversionFactor;
  final double sellingPrice;
  final bool isBaseUnit;
  final bool isDefaultSaleUnit;

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) => ProductUnitModel(
        id: json['id'] as int,
        unitId: json['unit_id'] as int,
        unitName: json['unit_name'] as String? ?? '',
        unitNameAr: json['unit_name_ar'] as String? ?? '',
        unitSymbol: json['unit_symbol'] as String? ?? '',
        conversionFactor: (json['conversion_factor'] as num).toDouble(),
        sellingPrice: (json['selling_price'] as num).toDouble(),
        isBaseUnit: json['is_base_unit'] as bool? ?? false,
        isDefaultSaleUnit: json['is_default_sale_unit'] as bool? ?? false,
      );
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.nameAr,
    required this.categoryName,
    required this.brandName,
    required this.baseUnitSymbol,
    required this.costPrice,
    required this.sellingPrice,
    required this.reorderLevel,
    required this.isActive,
    required this.units,
    required this.availableStock,
  });

  final int id;
  final String sku;
  final String? barcode;
  final String name;
  final String nameAr;
  final String? categoryName;
  final String? brandName;
  final String baseUnitSymbol;
  final double costPrice;
  final double sellingPrice;
  final double reorderLevel;
  final bool isActive;
  final List<ProductUnitModel> units;
  final double? availableStock;

  ProductUnitModel get defaultSaleUnit =>
      units.firstWhere((u) => u.isDefaultSaleUnit, orElse: () => units.first);

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        sku: json['sku'] as String,
        barcode: json['barcode'] as String?,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
        categoryName: (json['category'] as Map<String, dynamic>?)?['name'] as String?,
        brandName: (json['brand'] as Map<String, dynamic>?)?['name'] as String?,
        baseUnitSymbol: (json['base_unit'] as Map<String, dynamic>?)?['symbol'] as String? ?? '',
        costPrice: (json['cost_price'] as num).toDouble(),
        sellingPrice: (json['selling_price'] as num).toDouble(),
        reorderLevel: (json['reorder_level'] as num).toDouble(),
        isActive: json['is_active'] as bool? ?? true,
        units: (json['units'] as List? ?? []).map((u) => ProductUnitModel.fromJson(u as Map<String, dynamic>)).toList(),
        availableStock: json['available_stock'] != null ? (json['available_stock'] as num).toDouble() : null,
      );

  /// Round-trips through the same shape [fromJson] expects — used to
  /// persist this product in the offline cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'barcode': barcode,
        'name': name,
        'name_ar': nameAr,
        'category': categoryName != null ? {'name': categoryName} : null,
        'brand': brandName != null ? {'name': brandName} : null,
        'base_unit': {'symbol': baseUnitSymbol},
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'reorder_level': reorderLevel,
        'is_active': isActive,
        'units': units
            .map((u) => {
                  'id': u.id,
                  'unit_id': u.unitId,
                  'unit_name': u.unitName,
                  'unit_name_ar': u.unitNameAr,
                  'unit_symbol': u.unitSymbol,
                  'conversion_factor': u.conversionFactor,
                  'selling_price': u.sellingPrice,
                  'is_base_unit': u.isBaseUnit,
                  'is_default_sale_unit': u.isDefaultSaleUnit,
                })
            .toList(),
        'available_stock': availableStock,
      };
}
