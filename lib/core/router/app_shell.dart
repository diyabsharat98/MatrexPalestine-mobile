import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../features/auth/application/auth_controller.dart';

/// Bottom-nav shell. Tab labels/icons switch based on role (spec section 5):
/// Sales Representative gets Home/Customers/Sales/Collections/More,
/// everyone else (warehouse/admin/accountant/viewer) gets
/// Home/Stock/Customers/Documents/More. The underlying branch order stays
/// fixed so `StatefulShellRoute` can preserve each tab's navigation state.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).user;
    final isRep = user?.hasRole('Sales Representative') ?? true;

    final destinations = isRep
        ? [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
            NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l10n.navCustomers),
            NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: l10n.navSales),
            NavigationDestination(icon: const Icon(Icons.payments_outlined), selectedIcon: const Icon(Icons.payments), label: l10n.navCollections),
            NavigationDestination(icon: const Icon(Icons.menu_outlined), selectedIcon: const Icon(Icons.menu), label: l10n.navMore),
          ]
        : [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
            NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: l10n.navStock),
            NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l10n.navCustomers),
            NavigationDestination(icon: const Icon(Icons.description_outlined), selectedIcon: const Icon(Icons.description), label: l10n.navDocuments),
            NavigationDestination(icon: const Icon(Icons.menu_outlined), selectedIcon: const Icon(Icons.menu), label: l10n.navMore),
          ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: destinations,
      ),
    );
  }
}
