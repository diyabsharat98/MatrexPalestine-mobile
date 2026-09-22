class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.uuid,
    required this.paymentNumber,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.reference,
    required this.paymentDate,
    required this.status,
  });

  final int id;
  final String uuid;
  final String paymentNumber;
  final int? customerId;
  final String? customerName;
  final double amount;
  final String method;
  final String? reference;
  final String paymentDate;
  final String status;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return PaymentModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      paymentNumber: json['payment_number'] as String,
      customerId: customer?['id'] as int?,
      customerName: customer?['name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      reference: json['reference'] as String?,
      paymentDate: json['payment_date'] as String,
      status: json['status'] as String,
    );
  }
}
