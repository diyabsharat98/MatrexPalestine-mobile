import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../data/products_repository.dart';

class ProductScannerScreen extends ConsumerStatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  ConsumerState<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends ConsumerState<ProductScannerScreen> {
  final _controller = MobileScannerController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _busy = true);
    await _controller.stop();

    try {
      final product = await ref.read(productsRepositoryProvider).findByBarcode(code);
      if (mounted) context.pop(product);
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message(isArabic))));
      setState(() => _busy = false);
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.productScanBarcode),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Container(
            width: 260,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 48,
            child: Text(
              l10n.productScanInstruction,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          if (_busy) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
