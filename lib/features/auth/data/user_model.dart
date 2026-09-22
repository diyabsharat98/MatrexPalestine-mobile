class WarehouseSummary {
  const WarehouseSummary({required this.id, required this.code, required this.name, required this.nameAr});

  final int id;
  final String code;
  final String name;
  final String nameAr;

  factory WarehouseSummary.fromJson(Map<String, dynamic> json) => WarehouseSummary(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
      );
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.preferredLanguage,
    required this.roles,
    required this.permissions,
    required this.warehouse,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String preferredLanguage;
  final List<String> roles;
  final List<String> permissions;
  final WarehouseSummary? warehouse;

  bool can(String permission) => permissions.contains(permission);

  bool hasRole(String role) => roles.contains(role);

  /// Whether this user sees company-wide data (dashboard, sales list,
  /// payments list) rather than only their own — mirrors the backend's
  /// `sales.view_all` / `payments.view_all` scoping.
  bool get seesAllSales => can('sales.view_all');

  bool get seesAllPayments => can('payments.view_all');

  bool get isWarehouseUser => hasRole('Warehouse Manager') || hasRole('Administrator');

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        preferredLanguage: json['preferred_language'] as String? ?? 'ar',
        roles: List<String>.from(json['roles'] as List? ?? []),
        permissions: List<String>.from(json['permissions'] as List? ?? []),
        warehouse: json['warehouse'] != null
            ? WarehouseSummary.fromJson(json['warehouse'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'preferred_language': preferredLanguage,
        'roles': roles,
        'permissions': permissions,
        'warehouse': warehouse == null
            ? null
            : {'id': warehouse!.id, 'code': warehouse!.code, 'name': warehouse!.name, 'name_ar': warehouse!.nameAr},
      };
}
