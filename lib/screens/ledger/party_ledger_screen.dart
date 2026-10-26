import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/models/ledger_model.dart';
import '../../data/models/outlet_model.dart';
import '../../data/models/collection_model.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../state/app_state.dart';
import 'a4_statement_preview_screen.dart';

class PartyLedgerScreen extends StatefulWidget {
  final String? outletId;
  final bool showBackButton;

  const PartyLedgerScreen({
    super.key,
    this.outletId,
    this.showBackButton = true,
  });

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  int _selectedTabIndex = 0; // 0: Transactions, 1: Statements

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlet = appState.getOutletById(widget.outletId ?? '1') ??
        appState.allOutlets.first;
    final transactions = appState.getLedgerForOutlet(outlet.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Party Ledger',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => A4StatementPreviewScreen(outletId: outlet.id),
                ),
              );
            },
            tooltip: 'Print A4 Statement',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () {
              // Search in transactions
            },
            tooltip: 'Search Ledger',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected Outlet Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
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
                    width: 40,
                    height: 40,
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
                          'Code: ${outlet.code}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                outlet.address,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3 Financial Summary Cards (Total Sale, Total Collection, Balance)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Sale',
                    amount: Formatters.formatCurrency(outlet.totalSale),
                    textColor: AppColors.green,
                    bgColor: AppColors.greenCardBg,
                    borderColor: AppColors.greenBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Collection',
                    amount: Formatters.formatCurrency(outlet.totalCollection),
                    textColor: AppColors.blue,
                    bgColor: AppColors.blueCardBg,
                    borderColor: AppColors.blueBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Balance',
                    amount: Formatters.formatCurrency(outlet.balance),
                    textColor: AppColors.primaryRed,
                    bgColor: const Color(0xFFFFF1F2),
                    borderColor: const Color(0xFFFECDD3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Segmented Tabs: Transactions (underlined) | Statements
          Container(
            color: Colors.white,
            child: SegmentedTabs(
              tabs: const ['Transactions', 'Statements'],
              selectedIndex: _selectedTabIndex,
              isUnderlineStyle: true,
              onTabSelected: (idx) {
                setState(() => _selectedTabIndex = idx);
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildTransactionsList(outlet, transactions)
                : _buildStatementsList(outlet),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(OutletModel outlet, List<LedgerTransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions recorded yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: transactions.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final txn = transactions[index];
        final isCollection = txn.type == LedgerType.collection;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grayBorder, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Date & Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatDate(txn.date),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      txn.type.label,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Amount, Reference & Print Action
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(txn.amount),
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isCollection ? AppColors.green : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        txn.reference,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (isCollection) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.print_outlined, size: 18, color: Color(0xFF15803D)),
                      tooltip: 'Print 80mm Slip Receipt',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final col = CollectionModel(
                          id: txn.reference,
                          invoiceNo: txn.reference,
                          outletId: outlet.id,
                          outletName: outlet.name,
                          outletCode: outlet.code,
                          outletAddress: outlet.address,
                          amount: txn.amount,
                          paymentMode: txn.remarks.isNotEmpty ? txn.remarks : 'Collection',
                          remarks: txn.remarks,
                          date: txn.date,
                        );
                        await ThermalPrinterService.printThermalReceipt(
                          context: context,
                          outlet: outlet,
                          collection: col,
                          salesmanName: Provider.of<AppState>(context, listen: false).currentUser.name,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatementsList(OutletModel outlet) {
    final statements = [
      {'month': 'August 2026', 'opening': '₹ 15,000', 'closing': '₹ 23,000', 'status': 'Generated'},
      {'month': 'July 2026', 'opening': '₹ 18,000', 'closing': '₹ 15,000', 'status': 'Settled'},
      {'month': 'June 2026', 'opening': '₹ 10,000', 'closing': '₹ 18,000', 'status': 'Settled'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: statements.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final st = statements[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grayBorder, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    st['month']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Closing: ${st['closing']}',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading statement for ${st['month']}...')),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primaryRed),
                label: const Text('PDF', style: TextStyle(color: AppColors.primaryRed, fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryRedBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
