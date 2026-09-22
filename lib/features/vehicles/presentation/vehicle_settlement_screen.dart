import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../data/vehicle_load_model.dart';
import '../data/vehicles_repository.dart';

final _previewProvider = FutureProvider.autoDispose.family<List<VehicleStockRow>, int>((ref, loadId) {
  return ref.watch(vehiclesRepositoryProvider).previewSettlement(loadId);
});

class VehicleSettlementScreen extends ConsumerStatefulWidget {
  const VehicleSettlementScreen({super.key, required this.vehicleLoadId});

  final int vehicleLoadId;

  @override
  ConsumerState<VehicleSettlementScreen> createState() => _VehicleSettlementScreenState();
}

class _VehicleSettlementScreenState extends ConsumerState<VehicleSettlementScreen> {
  final Map<int, TextEditingController> _actualControllers = {};
  final Map<int, TextEditingController> _reasonControllers = {};
  bool _submitting = false;
  String? _error;

  TextEditingController _actualController(VehicleStockRow row) {
    return _actualControllers.putIfAbsent(
      row.productId,
      () => TextEditingController(text: Formatters.number(row.expectedRemainingQty)),
    );
  }

  TextEditingController _reasonController(int productId) {
    return _reasonControllers.putIfAbsent(productId, TextEditingController.new);
  }

  @override
  void dispose() {
    for (final c in _actualControllers.values) {
      c.dispose();
    }
    for (final c in _reasonControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(List<VehicleStockRow> rows) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final items = rows
          .map((row) => (
                productId: row.productId,
                actualRemainingQty: double.tryParse(_actualController(row).text) ?? 0,
                reason: _reasonController(row.productId).text.isEmpty ? null : _reasonController(row.productId).text,
              ))
          .toList();

      final settlement = await ref.read(vehiclesRepositoryProvider).submitSettlement(
            vehicleLoadId: widget.vehicleLoadId,
            items: items,
          );

      if (!mounted) return;
      final message = settlement.status == 'pending_approval' ? l10n.settlementStatusPending : l10n.settlementStatusNoDiscrepancy;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.settlementSubmittedTitle),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonClose))],
        ),
      );
      if (mounted) context.pop();
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
    final previewAsync = ref.watch(_previewProvider(widget.vehicleLoadId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlementTitle)),
      body: previewAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(_previewProvider(widget.vehicleLoadId))),
        data: (rows) => Column(
          children: [
            Expanded(
              child: ListView(
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
                  ...rows.map((row) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isArabic ? row.productNameAr : row.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${l10n.settlementExpected}: ${Formatters.number(row.expectedRemainingQty)} ${row.baseUnitSymbol}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _actualController(row),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(labelText: l10n.settlementActual, isDense: true),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _reasonController(row.productId),
                                decoration: InputDecoration(labelText: l10n.settlementReasonHint, isDense: true),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _submitting ? null : () => _submit(rows),
                  child: _submitting
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.settlementSubmit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
