class StatementTransaction {
  const StatementTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.balanceAfter,
  });

  final int id;
  final String date;
  final String type;
  final String? description;
  final double amount;
  final double balanceAfter;

  factory StatementTransaction.fromJson(Map<String, dynamic> json) => StatementTransaction(
        id: json['id'] as int,
        date: json['date'] as String,
        type: json['type'] as String,
        description: json['description'] as String?,
        amount: (json['amount'] as num).toDouble(),
        balanceAfter: (json['balance_after'] as num).toDouble(),
      );
}

class CustomerStatement {
  const CustomerStatement({required this.openingBalance, required this.transactions, required this.closingBalance});

  final double openingBalance;
  final List<StatementTransaction> transactions;
  final double closingBalance;

  factory CustomerStatement.fromJson(Map<String, dynamic> json) => CustomerStatement(
        openingBalance: (json['opening_balance'] as num).toDouble(),
        transactions:
            (json['transactions'] as List).map((t) => StatementTransaction.fromJson(t as Map<String, dynamic>)).toList(),
        closingBalance: (json['closing_balance'] as num).toDouble(),
      );
}
