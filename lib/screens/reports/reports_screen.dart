import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/mock_data.dart';
import '../../data/models/leaderboard_model.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../state/app_state.dart';
import 'debtor_aging_screen.dart';

class ReportsScreen extends StatefulWidget {
  final bool showBackButton;

  const ReportsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTabIndex = 1; // 0: My Performance, 1: Team, 2: Overall
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Reports',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 22),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Export Corporate Reports',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a report format to spool to printer or share via PDF.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEFF6FF),
                          child: Icon(Icons.print_outlined, color: Color(0xFF2563EB)),
                        ),
                        title: Text('Debtor Aging Report (Print A4 PDF)',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: Text('Full network 0-90+ days overdue breakdown',
                            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                        onTap: () async {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Spooling Debtor Aging Landscape A4 Report...'),
                              backgroundColor: AppColors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await ThermalPrinterService.printDebtorAgingReport(
                            outlets: appState.debtorOutlets,
                            transactions: appState.allLedgerTransactions,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDCFCE7),
                          child: Icon(Icons.share_outlined, color: Color(0xFF16A34A)),
                        ),
                        title: Text('Share Debtor Aging PDF',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: Text('Export and share PDF to accounts or WhatsApp',
                            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                        onTap: () async {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generating Debtor Aging PDF for sharing...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await ThermalPrinterService.shareDebtorAgingReport(
                            outlets: appState.debtorOutlets,
                            transactions: appState.allLedgerTransactions,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
            tooltip: 'Download / Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Segmented Control: My Performance | Team | Overall | Debtor Aging (A4)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SegmentedTabs(
              tabs: const ['My Performance', 'Team', 'Overall', 'Debtor Aging (A4)'],
              selectedIndex: _selectedTabIndex,
              onTabSelected: (idx) {
                setState(() => _selectedTabIndex = idx);
              },
            ),
          ),

          // Period Filter Dropdown (e.g., "This Month ∨") - show on performance/team tabs
          if (_selectedTabIndex != 3)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: InkWell(
                  onTap: () => _showPeriodPicker(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.grayBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPeriod,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 6),

          // Main Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildMyPerformanceView(appState)
                : _selectedTabIndex == 1
                    ? _buildLeaderboardView(MockData.teamLeaderboard)
                    : _selectedTabIndex == 2
                        ? _buildLeaderboardView(MockData.overallLeaderboard)
                        : const DebtorAgingScreen(showBackButton: false),
          ),

          // Bottom Sticky / Fixed Summary Card
          if (_selectedTabIndex != 3)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.greenCardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.greenBorder, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Rank',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedTabIndex == 2 ? '4' : '2',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blueCardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.blueBorder, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Collection',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ 4,50,000',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardView(List<LeaderboardItemModel> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildLeaderboardItem(item);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardItemModel item) {
    Widget rankBadge;

    if (item.rank == 1) {
      rankBadge = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        ),
        child: Center(
          child: Text(
            '1',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
      );
    } else if (item.rank == 2) {
      rankBadge = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
        ),
        child: Center(
          child: Text(
            '2',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      );
    } else if (item.rank == 3) {
      rankBadge = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF97316), width: 1.2),
        ),
        child: Center(
          child: Text(
            '3',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFC2410C),
            ),
          ),
        ),
      );
    } else {
      rankBadge = SizedBox(
        width: 26,
        child: Center(
          child: Text(
            '${item.rank}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: item.isCurrentUser ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isCurrentUser ? AppColors.greenBorder : AppColors.grayBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          rankBadge,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.name,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: item.isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            Formatters.formatCurrency(item.collectionAmount),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPerformanceView(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Achievement Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grayBorder, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Target Progress',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (appState.todayCollection / appState.monthlyTarget).clamp(0.0, 1.0),
                  backgroundColor: AppColors.grayLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achieved: ${Formatters.formatCurrency(appState.todayCollection)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                    Text(
                      'Target: ${Formatters.formatCurrency(appState.monthlyTarget)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Performance Metrics
          _buildMetricRow(
            icon: Icons.storefront_outlined,
            title: 'Outlets Visited Today',
            value: '${appState.outletsVisitedCount} / 15',
            color: AppColors.blue,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.receipt_long_outlined,
            title: 'Average Ticket Size',
            value: '₹ 4,041',
            color: AppColors.purple,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.verified_outlined,
            title: 'Productivity Ratio',
            value: '80.0%',
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grayBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final periods = ['Today', 'This Week', 'This Month', 'Last Month', 'This Quarter'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Period',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              ...periods.map(
                (p) => ListTile(
                  title: Text(p, style: GoogleFonts.inter(fontSize: 14)),
                  trailing: p == _selectedPeriod
                      ? const Icon(Icons.check, color: AppColors.primaryRed)
                      : null,
                  onTap: () {
                    setState(() => _selectedPeriod = p);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
