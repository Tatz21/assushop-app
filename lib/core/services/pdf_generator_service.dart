import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/outlet_model.dart';
import '../../data/models/ledger_model.dart';
import '../../data/models/collection_model.dart';

class PdfGeneratorService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd-MMM-yyyy');
  static final _dateTimeFormat = DateFormat('dd-MMM-yyyy hh:mm a');

  /// Generates Corporate A4 Statement of Account PDF
  static Future<Uint8List> generatePartyStatementA4({
    required OutletModel outlet,
    required List<LedgerTransactionModel> transactions,
    DateTime? startDate,
    DateTime? endDate,
    String salesmanName = 'Rohit Sharma (AUPL Sales)',
  }) async {
    final pdf = pw.Document();

    final start = startDate ?? (transactions.isNotEmpty ? transactions.first.date : DateTime.now().subtract(const Duration(days: 30)));
    final end = endDate ?? DateTime.now();

    // Calculate totals
    double totalDebits = 0.0;
    double totalCredits = 0.0;

    for (var txn in transactions) {
      if (txn.type == LedgerType.sale) {
        totalDebits += txn.amount;
      } else {
        totalCredits += txn.amount;
      }
    }

    final openingBalance = outlet.openingBalance;
    final closingBalance = outlet.balance;

    // Aging breakdown
    double aging0to30 = 0.0;
    double aging31to60 = 0.0;
    double aging61to90 = 0.0;
    double aging90Plus = 0.0;

    final now = DateTime.now();
    for (var txn in transactions.where((t) => t.type == LedgerType.sale)) {
      final days = now.difference(txn.date).inDays;
      if (days <= 30) {
        aging0to30 += txn.amount;
      } else if (days <= 60) {
        aging31to60 += txn.amount;
      } else if (days <= 90) {
        aging61to90 += txn.amount;
      } else {
        aging90Plus += txn.amount;
      }
    }

    // Running balance tracker for table
    double runningBalance = openingBalance;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildA4Header(context),
        footer: (context) => _buildA4Footer(context, salesmanName),
        build: (context) => [
          pw.SizedBox(height: 12),
          // Title & Period Banner
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'STATEMENT OF ACCOUNT / PARTY LEDGER',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  'Period: ${_dateFormat.format(start)} to ${_dateFormat.format(end)}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Two-column Info Cards
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Party Details
              pw.Expanded(
                flex: 6,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CUSTOMER DETAILS',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      pw.Text(
                        outlet.name,
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Proprietor: ${outlet.ownerName}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Code: ${outlet.code} | Mobile: ${outlet.mobile}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Market: ${outlet.market}, ${outlet.district}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Address: ${outlet.address}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Right: Account Metrics
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ACCOUNT FINANCIAL SUMMARY',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _buildMetricRow('Credit Limit:', _currencyFormat.format(outlet.creditLimit)),
                      _buildMetricRow('Opening Balance:', _currencyFormat.format(openingBalance)),
                      _buildMetricRow('Total Billed (Debits):', _currencyFormat.format(totalDebits)),
                      _buildMetricRow('Total Paid (Credits):', _currencyFormat.format(totalCredits)),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                      _buildMetricRow(
                        'Closing Balance:',
                        _currencyFormat.format(closingBalance),
                        isBold: true,
                        valueColor: closingBalance > 0 ? PdfColors.red800 : PdfColors.green800,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Ledger Transactions Table
          pw.Text(
            'TRANSACTION CHRONOLOGY',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Ref / Doc #', 'Particulars', 'Debit (Rs.)', 'Credit (Rs.)', 'Balance (Rs.)'],
            data: transactions.map((txn) {
              if (txn.type == LedgerType.sale) {
                runningBalance += txn.amount;
              } else {
                runningBalance -= txn.amount;
              }
              return [
                _dateFormat.format(txn.date),
                txn.reference,
                '${txn.type.label} - ${txn.remarks.isEmpty ? txn.reference : txn.remarks}',
                txn.type == LedgerType.sale ? txn.amount.toStringAsFixed(2) : '-',
                txn.type == LedgerType.collection ? txn.amount.toStringAsFixed(2) : '-',
                runningBalance.toStringAsFixed(2),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blue800,
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 14),

          // Aging Analysis Table
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DEBTOR AGING BREAKDOWN (DAYS OVERDUE)',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildAgingBox('0 - 30 Days', aging0to30, PdfColors.green800),
                    _buildAgingBox('31 - 60 Days', aging31to60, PdfColors.amber800),
                    _buildAgingBox('61 - 90 Days', aging61to90, PdfColors.orange800),
                    _buildAgingBox('90+ Days', aging90Plus, PdfColors.red800),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Terms and Signatures
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                flex: 6,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Terms & Conditions:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('1. Discrepancies if any must be intimated in writing within 7 days of statement issue.', style: const pw.TextStyle(fontSize: 7)),
                    pw.Text('2. Overdue balances beyond credit terms attract 18% p.a. interest.', style: const pw.TextStyle(fontSize: 7)),
                    pw.Text('3. All disputes subject to Kanpur (Uttar Pradesh) jurisdiction only.', style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('For ANSU UDYOG PRIVATE LIMITED', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 28),
                    pw.Container(width: 140, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 2),
                    pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildA4Header(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ANSU UDYOG PRIVATE LIMITED',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Manufacturer & Distributor of FMCG & Consumer Goods',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  '14/128, Civil Lines, Kanpur, Uttar Pradesh - 208001',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  'CIN: U15400UP2020PTC134567 | GSTIN: 09AAACA1234F1Z5',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Ph: +91 512 2309876 | Email: accounts@ansushop.in',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('AUPL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('AUTHENTIC', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1.5, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildA4Footer(pw.Context context, String salesmanName) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated via AUPL Field Sales App by $salesmanName on ${_dateTimeFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMetricRow(String label, String value, {bool isBold = false, PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? (isBold ? PdfColors.blue900 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAgingBox(String label, double amount, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        pw.SizedBox(height: 1),
        pw.Text(
          _currencyFormat.format(amount),
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }

  /// Generates 58mm / 80mm Bluetooth Thermal Slip Receipt
  static Future<Uint8List> generateThermalSlipReceipt({
    required OutletModel outlet,
    required CollectionModel collection,
    String salesmanName = 'Rohit Sharma (AUPL Sales)',
  }) async {
    final pdf = pw.Document();

    // 80mm width standard thermal roll format
    const pageFormat = PdfPageFormat(
      72 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 4 * PdfPageFormat.mm,
    );

    final verificationPayload = 'AUPL-COL|${collection.id}|${collection.amount}|${collection.paymentMode}|${collection.date.toIso8601String()}';

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'ANSU UDYOG PVT. LTD.',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Civil Lines, Kanpur (U.P.)',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'GSTIN: 09AAACA1234F1Z5',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              _buildDashedLine(),
              pw.SizedBox(height: 4),
              pw.Text(
                '*** PAYMENT RECEIPT ***',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              _buildDashedLine(),
              pw.SizedBox(height: 6),

              // Metadata table
              _buildThermalRow('Receipt No:', collection.id),
              _buildThermalRow('Date & Time:', _dateTimeFormat.format(collection.date)),
              _buildThermalRow('Party:', outlet.name),
              _buildThermalRow('Party Code:', outlet.code),
              _buildThermalRow('Owner:', outlet.ownerName),
              _buildThermalRow('Payment Mode:', collection.paymentMode.toUpperCase()),
              if (collection.remarks.isNotEmpty)
                _buildThermalRow('Ref / Details:', collection.remarks),

              pw.SizedBox(height: 6),
              _buildDashedLine(),
              pw.SizedBox(height: 6),

              // Highlighted Amount
              pw.Text('AMOUNT RECEIVED', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 2),
              pw.Text(
                _currencyFormat.format(collection.amount),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              _buildDashedLine(),
              pw.SizedBox(height: 6),

              // Outstanding balance summary
              _buildThermalRow('Previous Due:', _currencyFormat.format(outlet.balance + collection.amount)),
              _buildThermalRow('This Payment:', _currencyFormat.format(collection.amount)),
              _buildThermalRow(
                'Updated Balance:',
                _currencyFormat.format(outlet.balance),
                isBold: true,
              ),

              pw.SizedBox(height: 6),
              _buildDashedLine(),
              pw.SizedBox(height: 6),

              // Digital Verification QR
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: verificationPayload,
                width: 55,
                height: 55,
              ),
              pw.SizedBox(height: 4),
              pw.Text('Scan to verify digital authenticity', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700)),

              pw.SizedBox(height: 8),
              pw.Text('Collected by: $salesmanName', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 4),
              pw.Text('*** System Generated Slip ***', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates A4 Landscape Debtor Aging Summary Report
  static Future<Uint8List> generateDebtorAgingReport({
    required List<OutletModel> outlets,
    required List<LedgerTransactionModel> allTransactions,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    double grandTotalOutstanding = 0.0;
    double grand0to30 = 0.0;
    double grand31to60 = 0.0;
    double grand61to90 = 0.0;
    double grand90Plus = 0.0;

    final tableRows = <List<String>>[];

    for (var outlet in outlets) {
      final txns = allTransactions.where((t) => t.outletId == outlet.id && t.type == LedgerType.sale);
      double b0to30 = 0.0;
      double b31to60 = 0.0;
      double b61to90 = 0.0;
      double b90Plus = 0.0;

      for (var t in txns) {
        final days = now.difference(t.date).inDays;
        if (days <= 30) {
          b0to30 += t.amount;
        } else if (days <= 60) {
          b31to60 += t.amount;
        } else if (days <= 90) {
          b61to90 += t.amount;
        } else {
          b90Plus += t.amount;
        }
      }

      grandTotalOutstanding += outlet.balance;
      grand0to30 += b0to30;
      grand31to60 += b31to60;
      grand61to90 += b61to90;
      grand90Plus += b90Plus;

      final riskLevel = outlet.balance > outlet.creditLimit
          ? 'CRITICAL OVERDUE'
          : (b90Plus > 0 ? 'HIGH RISK' : 'NORMAL');

      tableRows.add([
        outlet.name,
        outlet.code,
        outlet.market,
        outlet.district,
        outlet.creditLimit.toStringAsFixed(0),
        outlet.balance.toStringAsFixed(2),
        b0to30.toStringAsFixed(0),
        b31to60.toStringAsFixed(0),
        b61to90.toStringAsFixed(0),
        b90Plus.toStringAsFixed(0),
        riskLevel,
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ANSU UDYOG PRIVATE LIMITED — CONSOLIDATED DEBTOR AGING REPORT',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Territory: Uttar Pradesh Distribution Network | As of ${_dateFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text('CONFIDENTIAL / ACCOUNTS AUDIT', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 1, color: PdfColors.blue900),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Store Name',
              'Code',
              'Market',
              'District',
              'Limit (Rs.)',
              'Total Due',
              '0-30d',
              '31-60d',
              '61-90d',
              '90d+',
              'Risk Status'
            ],
            data: tableRows,
            headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
              7: pw.Alignment.centerRight,
              8: pw.Alignment.centerRight,
              9: pw.Alignment.centerRight,
              10: pw.Alignment.center,
            },
          ),
          pw.SizedBox(height: 10),
          // Grand Totals Summary Row
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('NETWORK TOTALS (${outlets.length} Parties):', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Outstanding: ${_currencyFormat.format(grandTotalOutstanding)}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text('0-30d: ${_currencyFormat.format(grand0to30)}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('31-60d: ${_currencyFormat.format(grand31to60)}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('61-90d: ${_currencyFormat.format(grand61to90)}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('90d+: ${_currencyFormat.format(grand90Plus)}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildThermalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDashedLine() {
    return pw.Container(
      height: 1,
      child: pw.LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints!.maxWidth;
          const dashWidth = 3.0;
          const dashSpace = 2.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return pw.Flex(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            direction: pw.Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return pw.SizedBox(
                width: dashWidth,
                height: 0.5,
                child: pw.DecoratedBox(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey700),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
