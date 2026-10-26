import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../data/models/outlet_model.dart';
import '../../state/app_state.dart';
import '../collection/collection_entry_screen.dart';
import '../ledger/a4_statement_preview_screen.dart';

class DebtorAgingScreen extends StatefulWidget {
  final bool showBackButton;

  const DebtorAgingScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<DebtorAgingScreen> createState() => _DebtorAgingScreenState();
}

class _DebtorAgingScreenState extends State<DebtorAgingScreen> {
  String _selectedBucket = 'ALL'; // ALL, 0-30, 31-60, 61-90, 90+
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allDebtors = appState.debtorOutlets;

    // Compute Aging totals
    double totalDue = 0.0;
    double a0 = 0.0;
    double a30 = 0.0;
    double a60 = 0.0;
    double a90 = 0.0;

    int c0 = 0;
    int c30 = 0;
    int c60 = 0;
    int c90 = 0;

    for (var d in allDebtors) {
      totalDue += d.balance;
      if (d.agingDays <= 30) {
        a0 += d.balance;
        c0++;
      } else if (d.agingDays <= 60) {
        a30 += d.balance;
        c30++;
      } else if (d.agingDays <= 90) {
        a60 += d.balance;
        c60++;
      } else {
        a90 += d.balance;
        c90++;
      }
    }

    final filteredDebtors = allDebtors.where((d) {
      // Bucket filter
      if (_selectedBucket == '0-30' && d.agingDays > 30) return false;
      if (_selectedBucket == '31-60' && (d.agingDays <= 30 || d.agingDays > 60)) return false;
      if (_selectedBucket == '61-90' && (d.agingDays <= 60 || d.agingDays > 90)) return false;
      if (_selectedBucket == '90+' && d.agingDays <= 90) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return d.name.toLowerCase().contains(q) ||
            d.code.toLowerCase().contains(q) ||
            d.market.toLowerCase().contains(q) ||
            d.ownerName.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Debtor Aging & Outstandings',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white, size: 22),
            tooltip: 'Print Debtor Aging Report (A4)',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spooling Debtor Aging Landscape A4 Report...'),
                  backgroundColor: AppColors.green,
                  duration: Duration(seconds: 1),
                ),
              );
              await ThermalPrinterService.printDebtorAgingReport(
                outlets: allDebtors,
                transactions: appState.allLedgerTransactions,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
            tooltip: 'Share Debtor Aging PDF',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating Debtor Aging PDF for sharing...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await ThermalPrinterService.shareDebtorAgingReport(
                outlets: allDebtors,
                transactions: appState.allLedgerTransactions,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Summary Banner with 4 Aging Buckets
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL ACCOUNTS RECEIVABLE',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(totalDue),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        '${allDebtors.length} Debtors Active',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAgingPill(
                        bucket: '0-30',
                        label: '0-30 Days',
                        amount: a0,
                        count: c0,
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFF0FDF4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildAgingPill(
                        bucket: '31-60',
                        label: '31-60 Days',
                        amount: a30,
                        count: c30,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildAgingPill(
                        bucket: '61-90',
                        label: '61-90 Days',
                        amount: a60,
                        count: c60,
                        color: const Color(0xFFEA580C),
                        bgColor: const Color(0xFFFFF7ED),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildAgingPill(
                        bucket: '90+',
                        label: '90+ Days',
                        amount: a90,
                        count: c90,
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEF2F2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search & Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grayBorder, width: 0.8),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search debtor name, code, market...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 9),
                      ),
                      style: GoogleFonts.inter(fontSize: 12.5),
                    ),
                  ),
                ),
                if (_selectedBucket != 'ALL') ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _selectedBucket = 'ALL'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Clear Filter',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.grayBorder),

          // Debtors List
          Expanded(
            child: filteredDebtors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.green),
                        const SizedBox(height: 8),
                        Text(
                          'No Debtors Found',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        Text(
                          'All accounts in this bracket are cleared.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredDebtors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final debtor = filteredDebtors[index];
                      return _buildDebtorCard(debtor, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingPill({
    required String bucket,
    required String label,
    required double amount,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    final isSelected = _selectedBucket == bucket;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBucket = isSelected ? 'ALL' : bucket;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(80),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatCurrency(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : color,
              ),
            ),
            Text(
              '$count stores',
              style: GoogleFonts.inter(
                fontSize: 8.5,
                color: isSelected ? Colors.white.withAlpha(200) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtorCard(OutletModel debtor, AppState appState) {
    Color riskColor = const Color(0xFF16A34A);
    String riskLabel = 'Normal (0-30d)';

    if (debtor.agingDays > 90 || debtor.balance > debtor.creditLimit) {
      riskColor = const Color(0xFFDC2626);
      riskLabel = 'CRITICAL OVERDUE';
    } else if (debtor.agingDays > 60) {
      riskColor = const Color(0xFFEA580C);
      riskLabel = 'HIGH RISK';
    } else if (debtor.agingDays > 30) {
      riskColor = const Color(0xFFD97706);
      riskLabel = 'Moderate Alert';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayBorder, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: riskColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.store_rounded, color: riskColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debtor.name,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${debtor.code} • ${debtor.market} • Prop: ${debtor.ownerName}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: riskColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  riskLabel,
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: riskColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit Limit',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      Formatters.formatCurrency(debtor.creditLimit),
                      style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Aging Days',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${debtor.agingDays} Days',
                      style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: riskColor),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Due',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      Formatters.formatCurrency(debtor.balance),
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryRed),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => A4StatementPreviewScreen(outletId: debtor.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print_outlined, size: 14),
                  label: const Text('Statement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionEntryScreen(outletId: debtor.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment_rounded, size: 14),
                  label: const Text('Collect Cash/UPI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T element) test) => where(test);
}
