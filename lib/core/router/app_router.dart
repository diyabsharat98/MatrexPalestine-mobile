import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/biometric_service.dart';
import '../../features/auth/presentation/biometric_lock_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/customers/presentation/customer_detail_screen.dart';
import '../../features/customers/presentation/customer_picker_screen.dart';
import '../../features/customers/presentation/customer_statement_screen.dart';
import '../../features/customers/presentation/customers_list_screen.dart';
import '../../features/customers/presentation/new_customer_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/payments/presentation/new_payment_screen.dart';
import '../../features/payments/presentation/payments_list_screen.dart';
import '../../features/products/presentation/new_product_screen.dart';
import '../../features/products/presentation/product_scanner_screen.dart';
import '../../features/products/presentation/products_list_screen.dart';
import '../../features/reports/presentation/collections_report_screen.dart';
import '../../features/reports/presentation/profit_report_screen.dart';
import '../../features/reports/presentation/receivables_report_screen.dart';
import '../../features/reports/presentation/reports_hub_screen.dart';
import '../../features/reports/presentation/sales_report_screen.dart';
import '../../features/reports/presentation/stock_movements_screen.dart';
import '../../features/returns/presentation/new_return_screen.dart';
import '../../features/returns/presentation/returns_list_screen.dart';
import '../../features/sales/presentation/new_sale_screen.dart';
import '../../features/sales/presentation/sale_detail_screen.dart';
import '../../features/sales/presentation/sales_list_screen.dart';
import '../../features/vehicles/presentation/my_vehicle_stock_screen.dart';
import '../../features/vehicles/presentation/new_vehicle_load_screen.dart';
import '../../features/vehicles/presentation/pending_settlements_screen.dart';
import '../../features/vehicles/presentation/vehicle_loads_list_screen.dart';
import '../../features/vehicles/presentation/vehicle_settlement_screen.dart';
import '../../features/warehouse_ops/presentation/new_purchase_screen.dart';
import '../../features/warehouse_ops/presentation/new_stock_adjustment_screen.dart';
import '../../features/warehouse_ops/presentation/new_stock_transfer_screen.dart';
import '../../features/common/presentation/more_screen.dart';
import '../../features/common/presentation/stock_screen.dart';
import '../sync/sync_status_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final isRep = authState.user?.hasRole('Sales Representative') ?? true;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final loggingIn = state.matchedLocation == '/login';
      final atLock = state.matchedLocation == '/lock';

      if (!authState.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) return '/';

      if (!atLock) {
        final biometricAvailable = await ref.read(biometricAvailableProvider.future);
        final unlocked = ref.read(biometricLockControllerProvider);
        if (biometricAvailable && !unlocked) return '/lock';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/lock', builder: (context, state) => const BiometricLockScreen()),
      GoRoute(
        path: '/products',
        builder: (context, state) => ProductsListScreen(forSelection: state.extra == true),
      ),
      GoRoute(path: '/products/scan', builder: (context, state) => const ProductScannerScreen()),
      GoRoute(path: '/products/new', builder: (context, state) => const NewProductScreen()),
      GoRoute(path: '/customer-picker', builder: (context, state) => const CustomerPickerScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const NewCustomerScreen()),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerDetailScreen(customerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/customers/:id/statement',
        builder: (context, state) => CustomerStatementScreen(customerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/sales/new',
        builder: (context, state) => NewSaleScreen(initialCustomerId: state.extra as int?),
      ),
      GoRoute(
        path: '/sales/:id',
        builder: (context, state) => SaleDetailScreen(
          invoiceId: int.parse(state.pathParameters['id']!),
          justCreated: state.extra == true,
        ),
      ),
      GoRoute(
        path: '/payments/new',
        builder: (context, state) => NewPaymentScreen(initialCustomerId: state.extra as int?),
      ),
      GoRoute(path: '/returns', builder: (context, state) => const ReturnsListScreen()),
      GoRoute(path: '/returns/new', builder: (context, state) => const NewReturnScreen()),
      GoRoute(path: '/vehicle-loads/new', builder: (context, state) => const NewVehicleLoadScreen()),
      GoRoute(
        path: '/vehicle-loads/:id/settlement',
        builder: (context, state) => VehicleSettlementScreen(vehicleLoadId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/my-vehicle-stock', builder: (context, state) => const MyVehicleStockScreen()),
      GoRoute(path: '/settlements/pending', builder: (context, state) => const PendingSettlementsScreen()),
      GoRoute(path: '/purchases/new', builder: (context, state) => const NewPurchaseScreen()),
      GoRoute(path: '/stock-transfers/new', builder: (context, state) => const NewStockTransferScreen()),
      GoRoute(path: '/stock-adjustments/new', builder: (context, state) => const NewStockAdjustmentScreen()),
      GoRoute(path: '/sync-status', builder: (context, state) => const SyncStatusScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsHubScreen()),
      GoRoute(path: '/reports/sales', builder: (context, state) => const SalesReportScreen()),
      GoRoute(path: '/reports/collections', builder: (context, state) => const CollectionsReportScreen()),
      GoRoute(path: '/reports/profit', builder: (context, state) => const ProfitReportScreen()),
      GoRoute(path: '/reports/receivables', builder: (context, state) => const ReceivablesReportScreen()),
      GoRoute(path: '/reports/stock-movements', builder: (context, state) => const StockMovementsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: isRep
            ? [
                StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const DashboardScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/customers', builder: (c, s) => const CustomersListScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/sales', builder: (c, s) => const SalesListScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/payments', builder: (c, s) => const PaymentsListScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (c, s) => const MoreScreen())]),
              ]
            : [
                StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const DashboardScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/stock', builder: (c, s) => const StockScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/customers', builder: (c, s) => const CustomersListScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/documents', builder: (c, s) => const VehicleLoadsListScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (c, s) => const MoreScreen())]),
              ],
      ),
    ],
  );
});

/// Bridges Riverpod state changes into something [GoRouter]'s
/// `refreshListenable` can listen to, so a login/logout triggers `redirect`
/// to re-run immediately instead of waiting for the next navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(biometricLockControllerProvider, (_, _) => notifyListeners());
  }
}
