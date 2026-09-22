import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/customers_list_controller.dart';
import '../data/customers_repository.dart';

class NewCustomerScreen extends ConsumerStatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  ConsumerState<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends ConsumerState<NewCustomerScreen> {
  final _name = TextEditingController();
  final _nameAr = TextEditingController();
  final _phone = TextEditingController();
  final _secondaryPhone = TextEditingController();
  final _area = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _creditLimit = TextEditingController();
  final _paymentTermsDays = TextEditingController();
  final _notes = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _nameAr.dispose();
    _phone.dispose();
    _secondaryPhone.dispose();
    _area.dispose();
    _city.dispose();
    _address.dispose();
    _creditLimit.dispose();
    _paymentTermsDays.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_name.text.trim().isEmpty || _nameAr.text.trim().isEmpty) {
      setState(() => _error = l10n.customerNameRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final customer = await ref.read(customersRepositoryProvider).create(
            name: _name.text.trim(),
            nameAr: _nameAr.text.trim(),
            phone: _phone.text.trim(),
            secondaryPhone: _secondaryPhone.text.trim(),
            area: _area.text.trim(),
            city: _city.text.trim(),
            address: _address.text.trim(),
            creditLimit: double.tryParse(_creditLimit.text.trim()),
            paymentTermsDays: int.tryParse(_paymentTermsDays.text.trim()),
            notes: _notes.text.trim(),
          );
      ref.invalidate(customersListControllerProvider);
      if (mounted) context.pop(customer);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerNewCustomer)),
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
          TextField(controller: _nameAr, decoration: InputDecoration(labelText: l10n.customerFieldNameAr)),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: InputDecoration(labelText: l10n.customerFieldName)),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.customerFieldPhone),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secondaryPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.customerFieldSecondaryPhone),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _area, decoration: InputDecoration(labelText: l10n.customerFieldArea))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _city, decoration: InputDecoration(labelText: l10n.customerFieldCity))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: InputDecoration(labelText: l10n.customerFieldAddress)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _creditLimit,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.customerFieldCreditLimit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _paymentTermsDays,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.customerFieldPaymentTerms),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, maxLines: 3, decoration: InputDecoration(labelText: l10n.commonNotes)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.customerSave),
          ),
        ],
      ),
    );
  }
}
