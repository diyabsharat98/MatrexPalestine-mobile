import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../application/customers_list_controller.dart';
import '../data/customer_model.dart';

class CustomerPickerScreen extends ConsumerStatefulWidget {
  const CustomerPickerScreen({super.key});

  @override
  ConsumerState<CustomerPickerScreen> createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends ConsumerState<CustomerPickerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _addCustomer() async {
    final customer = await context.push<CustomerModel>('/customers/new');
    if (customer != null && mounted) context.pop(customer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(customersListControllerProvider);
    final canCreate = ref.watch(authControllerProvider).user?.can('customers.create') == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.saleSelectCustomer),
        actions: [
          if (canCreate) IconButton(icon: const Icon(Icons.person_add_alt_1), onPressed: _addCustomer),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref.read(customersListControllerProvider.notifier).search(value);
                });
              },
              decoration: InputDecoration(hintText: l10n.saleSearchCustomer, prefixIcon: const Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const SkeletonList(),
              error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(customersListControllerProvider)),
              data: (data) {
                if (data.items.isEmpty) return EmptyStateView(title: l10n.customersEmpty);
                return ListView.builder(
                  itemCount: data.items.length,
                  itemBuilder: (context, index) {
                    final CustomerModel customer = data.items[index];
                    return ListTile(
                      title: Text(isArabic ? customer.nameAr : customer.name),
                      subtitle: Text(customer.phone ?? customer.area ?? ''),
                      trailing: Text(Formatters.money(customer.balance)),
                      onTap: () => context.pop(customer),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
