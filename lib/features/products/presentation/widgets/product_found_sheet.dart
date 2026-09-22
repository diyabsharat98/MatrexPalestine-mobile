import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/product_model.dart';

/// Shows the "Product Found" bottom sheet (spec section 6) and, if the
/// caller is in selection mode, pops the picker with the chosen product.
Future<ProductModel?> showProductFoundSheet(
  BuildContext context,
  ProductModel product, {
  required bool forSelection,
}) {
  final l10n = AppLocalizations.of(context)!;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final unit = product.defaultSaleUnit;

  return showModalBottomSheet<ProductModel>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(l10n.productFoundTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? product.nameAr : product.name,
              style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.availableStock != null
                          ? '${Formatters.number(product.availableStock! / unit.conversionFactor)} ${isArabic ? unit.unitNameAr : unit.unitName}'
                          : '—',
                      style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(l10n.productAvailable, style: Theme.of(sheetContext).textTheme.bodySmall),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.money(unit.sellingPrice),
                      style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(l10n.productSellingPrice, style: Theme.of(sheetContext).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (forSelection)
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(product),
                child: Text(l10n.productAddToInvoice),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(l10n.commonClose),
              ),
          ],
        ),
      ),
    ),
  );
}
