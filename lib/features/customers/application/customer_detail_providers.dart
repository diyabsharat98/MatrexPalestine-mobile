import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../payments/data/payment_model.dart';
import '../../payments/data/payments_repository.dart';
import '../../returns/data/sales_return_model.dart';
import '../../returns/data/sales_returns_repository.dart';
import '../../sales/data/sale_model.dart';
import '../../sales/data/sales_repository.dart';
import '../data/customer_model.dart';
import '../data/customer_statement_model.dart';
import '../data/customers_repository.dart';

final customerDetailProvider = FutureProvider.autoDispose.family<CustomerModel, int>((ref, id) {
  return ref.watch(customersRepositoryProvider).find(id);
});

final customerSalesProvider = FutureProvider.autoDispose.family<List<SaleModel>, int>((ref, customerId) async {
  final result = await ref.watch(salesRepositoryProvider).list(customerId: customerId);
  return result.items;
});

final customerPaymentsProvider = FutureProvider.autoDispose.family<List<PaymentModel>, int>((ref, customerId) async {
  final result = await ref.watch(paymentsRepositoryProvider).list(customerId: customerId);
  return result.items;
});

final customerStatementProvider = FutureProvider.autoDispose.family<CustomerStatement, int>((ref, customerId) {
  return ref.watch(customersRepositoryProvider).statement(customerId);
});

final customerReturnsProvider = FutureProvider.autoDispose.family<List<SalesReturnModel>, int>((ref, customerId) async {
  final result = await ref.watch(salesReturnsRepositoryProvider).list(customerId: customerId);
  return result.items;
});
