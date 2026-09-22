import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../products/data/product_model.dart';
import '../application/new_vehicle_load_controller.dart';
import '../data/vehicle_model.dart';
import '../data/vehicles_repository.dart';

final _vehiclesProvider = FutureProvider.autoDispose((ref) => ref.watch(vehiclesRepositoryProvider).listVehicles());
final _salesRepsProvider = FutureProvider.autoDispose((ref) => ref.watch(vehiclesRepositoryProvider).listSalesReps());

class NewVehicleLoadScreen extends ConsumerStatefulWidget {
  const NewVehicleLoadScreen({super.key});

  @override
  ConsumerState<NewVehicleLoadScreen> createState() => _NewVehicleLoadScreenState();
}

class _NewVehicleLoadScreenState extends ConsumerState<NewVehicleLoadScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _addProduct() async {
    final product = await context.push<ProductModel>('/products', extra: true);
    if (product != null) {
      ref.read(newVehicleLoadControllerProvider.notifier).addProduct(product);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final warehouseId = ref.read(authControllerProvider).user?.warehouse?.id;
    if (warehouseId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(newVehicleLoadControllerProvider.notifier).submit(warehouseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.vehicleLoadCompletedTitle)));
        context.pop();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() => _error = e.message(isArabic));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(newVehicleLoadControllerProvider);
    final vehiclesAsync = ref.watch(_vehiclesProvider);
    final repsAsync = ref.watch(_salesRepsProvider);

    final canSubmit = state.vehicle != null && state.salesRep != null && state.lines.isNotEmpty && !_submitting;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicleLoadNewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
            const SizedBox(height: 16),
          ],
          vehiclesAsync.when(
            loading: () => const SkeletonBlock(height: 56),
            error: (error, _) => ErrorStateView(error: error),
            data: (vehicles) => DropdownButtonFormField<VehicleModel>(
              initialValue: state.vehicle,
              decoration: InputDecoration(labelText: l10n.vehicleLoadSelectVehicle),
              items: vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
              onChanged: (v) {
                if (v != null) ref.read(newVehicleLoadControllerProvider.notifier).setVehicle(v);
              },
            ),
          ),
          const SizedBox(height: 12),
          repsAsync.when(
            loading: () => const SkeletonBlock(height: 56),
            error: (error, _) => ErrorStateView(error: error),
            data: (reps) => DropdownButtonFormField<SalesRepModel>(
              initialValue: state.salesRep,
              decoration: InputDecoration(labelText: l10n.vehicleLoadSelectRep),
              items: reps.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
              onChanged: (r) {
                if (r != null) ref.read(newVehicleLoadControllerProvider.notifier).setSalesRep(r);
              },
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: _addProduct, icon: const Icon(Icons.add), label: Text(l10n.vehicleLoadAddProduct)),
          const SizedBox(height: 12),
          ...state.lines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(isArabic ? line.product.nameAr : line.product.name),
                subtitle: Text(line.unit.unitSymbol),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref.read(newVehicleLoadControllerProvider.notifier).updateQuantity(index, line.quantity - 1),
                    ),
                    Text(Formatters.number(line.quantity)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref.read(newVehicleLoadControllerProvider.notifier).updateQuantity(index, line.quantity + 1),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canSubmit ? _submit : null,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.vehicleLoadConfirm),
          ),
        ],
      ),
    );
  }
}
