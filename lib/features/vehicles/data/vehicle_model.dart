class VehicleModel {
  const VehicleModel({required this.id, required this.code, required this.name, required this.plateNumber});

  final int id;
  final String code;
  final String name;
  final String? plateNumber;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        plateNumber: json['plate_number'] as String?,
      );
}

class SalesRepModel {
  const SalesRepModel({required this.id, required this.name, required this.username, required this.warehouseId});

  final int id;
  final String name;
  final String username;
  final int? warehouseId;

  factory SalesRepModel.fromJson(Map<String, dynamic> json) => SalesRepModel(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        warehouseId: json['warehouse_id'] as int?,
      );
}

class WarehouseModel {
  const WarehouseModel({required this.id, required this.code, required this.name, required this.nameAr});

  final int id;
  final String code;
  final String name;
  final String nameAr;

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
      );
}

class SupplierModel {
  const SupplierModel({required this.id, required this.code, required this.name, required this.nameAr});

  final int id;
  final String code;
  final String name;
  final String nameAr;

  factory SupplierModel.fromJson(Map<String, dynamic> json) => SupplierModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
      );
}
