class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    required this.phone,
    required this.area,
    required this.city,
    required this.address,
    required this.creditLimit,
    required this.paymentTermsDays,
    required this.balance,
    required this.availableCredit,
    required this.isActive,
  });

  final int id;
  final String code;
  final String name;
  final String nameAr;
  final String? phone;
  final String? area;
  final String? city;
  final String? address;
  final double creditLimit;
  final int paymentTermsDays;
  final double balance;
  final double availableCredit;
  final bool isActive;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        nameAr: json['name_ar'] as String,
        phone: json['phone'] as String?,
        area: json['area'] as String?,
        city: json['city'] as String?,
        address: json['address'] as String?,
        creditLimit: (json['credit_limit'] as num).toDouble(),
        paymentTermsDays: json['payment_terms_days'] as int? ?? 0,
        balance: (json['balance'] as num).toDouble(),
        availableCredit: (json['available_credit'] as num).toDouble(),
        isActive: json['is_active'] as bool? ?? true,
      );

  /// Round-trips through the same shape [fromJson] expects — used to
  /// persist this customer in the offline cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'name_ar': nameAr,
        'phone': phone,
        'area': area,
        'city': city,
        'address': address,
        'credit_limit': creditLimit,
        'payment_terms_days': paymentTermsDays,
        'balance': balance,
        'available_credit': availableCredit,
        'is_active': isActive,
      };
}
