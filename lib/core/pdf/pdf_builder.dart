import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/customers/data/customer_model.dart';
import '../../features/customers/data/customer_statement_model.dart';
import '../../features/sales/data/sale_model.dart';
import '../utils/formatters.dart';

/// Builds client-side invoice/statement PDFs from already-fetched API data
/// (never fabricated) for the Share/Print actions (spec sections 11, 13).
class PdfBuilder {
  PdfBuilder._();

  static Future<pw.Document> invoice(SaleModel sale) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Sales Invoice', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(sale.invoiceNumber, style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Customer: ${sale.customerName ?? '-'}'),
                pw.Text('Date: ${sale.invoiceDate}'),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Product', bold: true),
                    _cell('Qty', bold: true),
                    _cell('Price', bold: true),
                    _cell('Total', bold: true),
                  ],
                ),
                for (final item in sale.items)
                  pw.TableRow(children: [
                    _cell(item.productName),
                    _cell('${Formatters.number(item.quantity)} ${item.unitSymbol}'),
                    _cell(Formatters.money(item.unitPrice)),
                    _cell(Formatters.money(item.lineTotal)),
                  ]),
              ],
            ),
            pw.SizedBox(height: 20),
            _summaryRow('Subtotal', sale.subtotal),
            _summaryRow('Discount', sale.discountAmount),
            _summaryRow('Total', sale.total, bold: true),
            _summaryRow('Paid', sale.paidAmount),
            _summaryRow('Remaining', sale.remainingAmount, bold: true),
          ],
        ),
      ),
    );

    return doc;
  }

  static Future<pw.Document> statement(CustomerModel customer, CustomerStatement statement) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Customer Statement', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(customer.name),
          pw.SizedBox(height: 20),
          _summaryRow('Opening Balance', statement.openingBalance),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Date', bold: true),
                  _cell('Description', bold: true),
                  _cell('Amount', bold: true),
                  _cell('Balance', bold: true),
                ],
              ),
              for (final t in statement.transactions)
                pw.TableRow(children: [
                  _cell(t.date),
                  _cell(t.description ?? t.type),
                  _cell(Formatters.money(t.amount)),
                  _cell(Formatters.money(t.balanceAfter)),
                ]),
            ],
          ),
          pw.SizedBox(height: 12),
          _summaryRow('Current Balance', statement.closingBalance, bold: true),
        ],
      ),
    );

    return doc;
  }

  /// Generic tabular report export (spec section 22 "export/share to PDF")
  /// — reused by every Reports-on-Mobile screen (Sales/Collections/Profit/
  /// Receivables/Stock Movement) instead of one bespoke builder per report,
  /// since they're all just a title + optional summary lines + a table.
  static Future<pw.Document> genericReport({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<String>> rows,
    List<MapEntry<String, String>> summary = const [],
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(subtitle),
          if (summary.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            for (final entry in summary) _textRow(entry.key, entry.value, bold: entry.key == summary.last.key),
          ],
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: headers.map((h) => _cell(h, bold: true)).toList(),
              ),
              for (final row in rows) pw.TableRow(children: row.map(_cell).toList()),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  static pw.Widget _summaryRow(String label, num value, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.Text(Formatters.money(value), style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );

  static pw.Widget _textRow(String label, String value, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.Text(value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );
}
