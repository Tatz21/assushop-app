import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/models/outlet_model.dart';
import '../../data/models/collection_model.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../state/app_state.dart';
import '../ledger/party_ledger_screen.dart';

class CollectionEntryScreen extends StatefulWidget {
  final String? outletId;
  final bool showBackButton;

  const CollectionEntryScreen({
    super.key,
    this.outletId,
    this.showBackButton = true,
  });

  @override
  State<CollectionEntryScreen> createState() => _CollectionEntryScreenState();
}

class _CollectionEntryScreenState extends State<CollectionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  late TextEditingController _utrController;
  late TextEditingController _chequeNoController;
  late TextEditingController _bankNameController;
  int _paymentModeIndex = 0; // 0: Cash, 1: UPI, 2: Cheque
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _invoiceController = TextEditingController(text: 'INV-20260905-001');
    _amountController = TextEditingController(text: '18500');
    _remarksController = TextEditingController();
    _utrController = TextEditingController(text: '428910482910');
    _chequeNoController = TextEditingController(text: '883921');
    _bankNameController = TextEditingController(text: 'State Bank of India');
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _utrController.dispose();
    _chequeNoController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _saveCollection(OutletModel outlet) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid collection amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final paymentModes = ['Cash', 'UPI', 'Cheque'];
    final selectedMode = paymentModes[_paymentModeIndex];

    String modeDetails = selectedMode;
    if (selectedMode == 'UPI') {
      modeDetails = 'UPI (UTR: ${_utrController.text.trim()})';
    } else if (selectedMode == 'Cheque') {
      modeDetails =
          'Cheque #${_chequeNoController.text.trim()} (${_bankNameController.text.trim()})';
    }

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addCollection(
      outletId: outlet.id,
      invoiceNo: _invoiceController.text.trim(),
      amount: amount,
      paymentMode: modeDetails,
      remarks: _remarksController.text.trim(),
    );

    setState(() => _isSaving = false);

    // Show formal AUPL Collection Receipt Modal
    final receiptNo = 'RCT-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final remainingBalance = (outlet.balance - amount).clamp(0, double.infinity);

    final collectionRecord = CollectionModel(
      id: receiptNo,
      invoiceNo: _invoiceController.text.trim(),
      outletId: outlet.id,
      outletName: outlet.name,
      outletCode: outlet.code,
      outletAddress: outlet.address,
      amount: amount,
      paymentMode: modeDetails,
      remarks: _remarksController.text.trim(),
      date: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Header with Logo Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.green, size: 40),
                  const SizedBox(height: 6),
                  Text(
                    'PAYMENT RECEIPT',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'ANSU UDYOG PRIVATE LIMITED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      receiptNo,
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Receipt Particulars
            _receiptRow('Received From:', outlet.name),
            _receiptRow('Party Code:', outlet.code),
            _receiptRow('Market / District:', '${outlet.market}, ${outlet.district}'),
            _receiptRow('Mode & Reference:', modeDetails),
            _receiptRow('Invoice Ref:', _invoiceController.text.trim()),
            const Divider(height: 18),
            _receiptRow('Amount Paid:', Formatters.formatCurrency(amount),
                isHighlight: true),
            _receiptRow('Updated Balance:',
                Formatters.formatCurrency(remainingBalance.toDouble()),
                isGreen: remainingBalance == 0),
            const SizedBox(height: 16),

            // Print / Share Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Spooling 80mm/58mm Thermal Receipt...'),
                          backgroundColor: Color(0xFF1E293B),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await ThermalPrinterService.printThermalReceipt(
                        context: context,
                        outlet: outlet,
                        collection: collectionRecord,
                        salesmanName: appState.currentUser.name,
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Print Receipt', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.grayBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sharing Receipt $receiptNo via WhatsApp / PDF...'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      await ThermalPrinterService.shareReceiptPdf(
                        outlet: outlet,
                        collection: collectionRecord,
                        salesmanName: appState.currentUser.name,
                      );
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share PDF', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PartyLedgerScreen(outletId: outlet.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Ledger', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value,
      {bool isHighlight = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: isHighlight ? 14 : 12,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight
                    ? AppColors.primaryRed
                    : (isGreen ? AppColors.green : AppColors.textDark),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlet = appState.getOutletById(widget.outletId ?? '1') ??
        appState.allOutlets.first;

    final paymentModes = ['Cash', 'UPI', 'Cheque'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Collection Entry',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PartyLedgerScreen(outletId: outlet.id),
                ),
              );
            },
            tooltip: 'Ledger History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Outlet Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grayBorder, width: 0.8),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        size: 22,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outlet.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${outlet.code} • ${outlet.market}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                          'Outstanding',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(outlet.balance),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Invoice Reference Field
              Text(
                'Against Invoice / Reference No.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _invoiceController,
                style: AppTypography.bodyText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryRed, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Collection Amount Field
              Text(
                'Collection Amount (₹)',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryRed, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter collection amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Payment Mode Segmented selector
              Text(
                'Payment Mode',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedTabs(
                tabs: paymentModes,
                selectedIndex: _paymentModeIndex,
                onTabSelected: (idx) {
                  setState(() => _paymentModeIndex = idx);
                },
              ),

              const SizedBox(height: 14),

              // DYNAMIC PAYMENT MODE FIELDS
              if (_paymentModeIndex == 1) ...[
                // UPI Dynamic Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.qr_code_2_rounded,
                              color: Color(0xFF16A34A), size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AUPL Merchant UPI VPA',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                                Text(
                                  'aupl.sales@icici',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('VERIFIED',
                                style: TextStyle(
                                    color: Color(0xFF15803D),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '12-Digit UPI Transaction / UTR Ref No.*',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _utrController,
                        style: GoogleFonts.robotoMono(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 428910482910',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: Color(0xFF86EFAC)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (_paymentModeIndex == 2) ...[
                // Cheque Details Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_outlined,
                              color: Color(0xFF2563EB), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Bank Cheque Particulars',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cheque No.*',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _chequeNoController,
                                  style: GoogleFonts.robotoMono(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: '6-digit Cheque #',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Drawn On Bank*',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _bankNameController,
                                  style: GoogleFonts.inter(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. SBI, HDFC',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Remarks (Optional)
              Text(
                'Remarks (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                style: AppTypography.bodyText,
                decoration: InputDecoration(
                  hintText: 'Add remarks...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 12.5, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grayBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryRed, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Save Collection Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveCollection(outlet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save & Generate Receipt',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
