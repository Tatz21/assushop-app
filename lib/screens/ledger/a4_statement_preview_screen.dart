import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../data/models/ledger_model.dart';
import '../../state/app_state.dart';

class A4StatementPreviewScreen extends StatefulWidget {
  final String outletId;

  const A4StatementPreviewScreen({
    super.key,
    required this.outletId,
  });

  @override
  State<A4StatementPreviewScreen> createState() => _A4StatementPreviewScreenState();
}

class _A4StatementPreviewScreenState extends State<A4StatementPreviewScreen> {
  bool _showInteractivePdfViewer = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlet = appState.getOutletById(widget.outletId);
    final transactions = appState.getLedgerForOutlet(widget.outletId);

    if (outlet == null) {
      return const Scaffold(
        appBar: AppHeader(title: 'A4 Statement'),
        body: Center(child: Text('Outlet not found')),
      );
    }

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

    return Scaffold(
      backgroundColor: const Color(0xFF525659), // PDF reader style neutral background
      appBar: AppHeader(
        title: 'A4 Statement: ${outlet.name}',
        actions: [
          IconButton(
            icon: Icon(
              _showInteractivePdfViewer ? Icons.view_agenda_outlined : Icons.picture_as_pdf_outlined,
              color: Colors.white,
            ),
            tooltip: _showInteractivePdfViewer ? 'Switch to Document View' : 'Live PDF Engine View',
            onPressed: () {
              setState(() {
                _showInteractivePdfViewer = !_showInteractivePdfViewer;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            tooltip: 'Print Statement',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spooling A4 Document to System Printer...'),
                  backgroundColor: AppColors.green,
                  duration: Duration(seconds: 1),
                ),
              );
              await ThermalPrinterService.printA4Statement(
                context: context,
                outlet: outlet,
                transactions: transactions,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Share via WhatsApp / PDF',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Generating A4 PDF for ${outlet.name}...'),
                  duration: const Duration(seconds: 1),
                ),
              );
              await ThermalPrinterService.shareStatementPdf(
                outlet: outlet,
                transactions: transactions,
              );
            },
          ),
        ],
      ),
      body: _showInteractivePdfViewer
          ? PdfPreview(
              build: (format) => PdfGeneratorService.generatePartyStatementA4(
                outlet: outlet,
                transactions: transactions,
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'AUPL_Statement_${outlet.code}.pdf',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680), // Standard A4 aspect container
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AUPL Letterhead Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANSU UDYOG PRIVATE LIMITED',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B5E20), // AUPL Green
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CIN: U24246UP2020PTC134567 | GSTIN: 09AAACA1234F1Z5',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '14/112, Civil Lines, Kanpur, Uttar Pradesh - 208001',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Email: accounts@ansushop.com | Phone: +91 512 2309876',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.grayBorder),
                      ),
                      child: Text(
                        'ISO A4 FORMAT',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(thickness: 1.5, color: Color(0xFF1B5E20)),
                const SizedBox(height: 8),

                // Statement Title & Date
                Center(
                  child: Text(
                    'PARTY STATEMENT OF ACCOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Statement Date: ${Formatters.formatDate(DateTime.now())} • As of Today',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Party Information Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.grayBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billed To: ${outlet.name}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Proprietor: ${outlet.ownerName} • Contact: ${outlet.mobile}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Address: ${outlet.address}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Outlet Code: ${outlet.code}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Credit Limit: ₹${Formatters.formatCurrency(outlet.creditLimit)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Market: ${outlet.market}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Transactions Table
                Table(
                  border: TableBorder.all(
                    color: const Color(0xFFCBD5E1),
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.4), // Date
                    1: FlexColumnWidth(2.5), // Particulars
                    2: FlexColumnWidth(1.8), // Ref / Voucher
                    3: FlexColumnWidth(1.6), // Debit
                    4: FlexColumnWidth(1.6), // Credit
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                      ),
                      children: [
                        _buildTableHeader('Date'),
                        _buildTableHeader('Particulars'),
                        _buildTableHeader('Voucher / Ref'),
                        _buildTableHeader('Debit (₹)'),
                        _buildTableHeader('Credit (₹)'),
                      ],
                    ),

                    // Opening Balance Row
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                      ),
                      children: [
                        _buildTableCell('01-Aug-2026', isBold: true),
                        _buildTableCell('Opening Balance B/F', isBold: true),
                        _buildTableCell('OPENING', isCenter: true),
                        _buildTableCell(
                            Formatters.formatCurrency(outlet.openingBalance),
                            isRight: true,
                            isBold: true),
                        _buildTableCell('-', isCenter: true),
                      ],
                    ),

                    // Transaction Rows
                    ...transactions.map((txn) {
                      final isSale = txn.type == LedgerType.sale;
                      return TableRow(
                        children: [
                          _buildTableCell(Formatters.formatDate(txn.date)),
                          _buildTableCell(
                              isSale ? 'Sales Invoice Booking' : 'Collection Receipt'),
                          _buildTableCell(txn.reference),
                          _buildTableCell(
                            isSale ? Formatters.formatCurrency(txn.amount) : '-',
                            isRight: true,
                            textColor: isSale ? AppColors.primaryRed : null,
                          ),
                          _buildTableCell(
                            !isSale ? Formatters.formatCurrency(txn.amount) : '-',
                            isRight: true,
                            textColor: !isSale ? AppColors.green : null,
                          ),
                        ],
                      );
                    }),

                    // Total Summary Row
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                      ),
                      children: [
                        _buildTableCell('TOTALS', isBold: true),
                        _buildTableCell('', isBold: true),
                        _buildTableCell('', isBold: true),
                        _buildTableCell(
                          Formatters.formatCurrency(totalDebits + outlet.openingBalance),
                          isRight: true,
                          isBold: true,
                          textColor: AppColors.primaryRed,
                        ),
                        _buildTableCell(
                          Formatters.formatCurrency(totalCredits),
                          isRight: true,
                          isBold: true,
                          textColor: AppColors.green,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Closing Outstanding Callout Box
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NET OUTSTANDING:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '₹${Formatters.formatCurrency(outlet.balance)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Signature & Seal Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 1,
                          color: AppColors.grayBorder,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Party Receiver Signature & Seal',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'For ANSU UDYOG PRIVATE LIMITED',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: 160,
                          height: 1,
                          color: AppColors.grayBorder,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Authorized Signatory',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'This is a computer-generated statement issued via AUPL Sales Enterprise System.',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isBold = false,
    bool isRight = false,
    bool isCenter = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      child: Text(
        text,
        textAlign: isRight
            ? TextAlign.right
            : (isCenter ? TextAlign.center : TextAlign.left),
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? AppColors.textDark,
        ),
      ),
    );
  }
}
