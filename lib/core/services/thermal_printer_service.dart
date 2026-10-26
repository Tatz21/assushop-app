import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../data/models/outlet_model.dart';
import '../../data/models/ledger_model.dart';
import '../../data/models/collection_model.dart';
import 'pdf_generator_service.dart';

class ThermalPrinterService {
  /// Spools 80mm/58mm thermal receipt directly to print driver or Bluetooth ESC/POS
  static Future<void> printThermalReceipt({
    required BuildContext context,
    required OutletModel outlet,
    required CollectionModel collection,
    String salesmanName = 'Rohit Sharma (AUPL)',
  }) async {
    final pdfBytes = await PdfGeneratorService.generateThermalSlipReceipt(
      outlet: outlet,
      collection: collection,
      salesmanName: salesmanName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'AUPL_Receipt_${collection.id}',
      format: const PdfPageFormat(
        72 * PdfPageFormat.mm,
        double.infinity,
        marginAll: 4 * PdfPageFormat.mm,
      ),
    );
  }

  /// Spools corporate A4 Statement of Account to system printer or PDF exporter
  static Future<void> printA4Statement({
    required BuildContext context,
    required OutletModel outlet,
    required List<LedgerTransactionModel> transactions,
    String salesmanName = 'Rohit Sharma (AUPL)',
  }) async {
    final pdfBytes = await PdfGeneratorService.generatePartyStatementA4(
      outlet: outlet,
      transactions: transactions,
      salesmanName: salesmanName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'AUPL_Statement_${outlet.code}',
      format: PdfPageFormat.a4,
    );
  }

  /// Shares A4 Statement PDF via WhatsApp or System Share Intent
  static Future<void> shareStatementPdf({
    required OutletModel outlet,
    required List<LedgerTransactionModel> transactions,
    String salesmanName = 'Rohit Sharma (AUPL)',
  }) async {
    final pdfBytes = await PdfGeneratorService.generatePartyStatementA4(
      outlet: outlet,
      transactions: transactions,
      salesmanName: salesmanName,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'AUPL_Statement_${outlet.code}.pdf',
    );
  }

  /// Shares Thermal Slip PDF via WhatsApp or System Share Intent
  static Future<void> shareReceiptPdf({
    required OutletModel outlet,
    required CollectionModel collection,
    String salesmanName = 'Rohit Sharma (AUPL)',
  }) async {
    final pdfBytes = await PdfGeneratorService.generateThermalSlipReceipt(
      outlet: outlet,
      collection: collection,
      salesmanName: salesmanName,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'AUPL_Receipt_${collection.id}.pdf',
    );
  }

  /// Spools Debtor Aging Report to system printer or PDF
  static Future<void> printDebtorAgingReport({
    required List<OutletModel> outlets,
    required List<LedgerTransactionModel> transactions,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateDebtorAgingReport(
      outlets: outlets,
      allTransactions: transactions,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'AUPL_Debtor_Aging_Report',
      format: PdfPageFormat.a4.landscape,
    );
  }

  /// Shares Debtor Aging Report PDF
  static Future<void> shareDebtorAgingReport({
    required List<OutletModel> outlets,
    required List<LedgerTransactionModel> transactions,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateDebtorAgingReport(
      outlets: outlets,
      allTransactions: transactions,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'AUPL_Debtor_Aging_Report.pdf',
    );
  }
}
