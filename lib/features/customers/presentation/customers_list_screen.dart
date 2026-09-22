import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../application/customers_list_controller.dart';
import 'widgets/customer_card.dart';

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(customersListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(customersListControllerProvider);
    final canCreate = ref.watch(authControllerProvider).user?.can('customers.create') == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCustomers),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ConnectivityBanner())],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push('/customers/new'),
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  ref.read(customersListControllerProvider.notifier).search(value);
                });
              },
              decoration: InputDecoration(
                hintText: l10n.customerSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(customersListControllerProvider.notifier).search(_searchController.text),
              child: state.when(
                loading: () => const SkeletonList(itemHeight: 180),
                error: (error, _) => ListView(children: [
                  ErrorStateView(error: error, onRetry: () => ref.invalidate(customersListControllerProvider)),
                ]),
                data: (data) {
                  if (data.items.isEmpty) {
                    return ListView(children: [EmptyStateView(title: l10n.customersEmpty, icon: Icons.people_outline)]);
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: data.items.length + (data.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= data.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return CustomerCard(customer: data.items[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
