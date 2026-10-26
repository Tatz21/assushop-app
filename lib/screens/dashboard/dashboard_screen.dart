import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/quick_action_card.dart';
import '../../data/models/outlet_model.dart';
import '../../state/app_state.dart';

import '../collection/collection_entry_screen.dart';
import '../ledger/party_ledger_screen.dart';
import '../market/market_hierarchy_screen.dart';
import '../sales/add_sale_screen.dart';
import '../more/offline_sync_screen.dart';
import '../reports/debtor_aging_screen.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueChanged<int> onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.scaffoldKey,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        isDashboard: true,
        user: user,
        onMenuPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        onNotificationPressed: () {
          _showNotificationsDialog(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Card
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.grayBorder, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Formatters.formatHeaderDate(appState.currentDate),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Active Geofenced Visit Banner (When Checked In)
            if (appState.activeVisitSession != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF047857).withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACTIVE VISIT IN PROGRESS',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF6EE7B7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                appState.activeVisitSession!.outletName,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: Colors.white, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                appState.activeVisitSession!.formattedDuration,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Checked in: ${appState.activeVisitSession!.checkInDistanceMeters.toStringAsFixed(1)}m from store • GPS Geofenced',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddSaleScreen(
                                    initialOutletId:
                                        appState.activeVisitSession!.outletId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart, size: 15),
                            label: const Text('Add Sale',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF047857),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CollectionEntryScreen(
                                    outletId:
                                        appState.activeVisitSession!.outletId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.currency_rupee, size: 15),
                            label: const Text('Collection',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withAlpha(40),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showCheckOutDialog(
                                  context,
                                  appState,
                                  appState.activeVisitSession!.outletId);
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 15),
                            label: const Text('End Visit',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // 4 Main KPI Cards (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: "Today's Collection",
                    value: Formatters.formatCurrency(appState.todayCollection),
                    icon: Icons.currency_rupee_rounded,
                    type: MetricCardType.green,
                    onTap: () => onNavigateTab(2), // Collection Tab
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Outlets Visited',
                    value: '${appState.outletsVisitedCount}',
                    icon: Icons.storefront_outlined,
                    type: MetricCardType.blue,
                    onTap: () {
                      appState.setFilters(status: OutletStatus.visited);
                      onNavigateTab(1); // Outlets Tab
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Pending Outlets',
                    value: '${appState.pendingOutletsCount}',
                    icon: Icons.people_outline_rounded,
                    type: MetricCardType.purple,
                    onTap: () {
                      appState.setFilters(status: OutletStatus.pending);
                      onNavigateTab(1); // Outlets Tab
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Monthly Target',
                    value: Formatters.formatCurrency(appState.monthlyTarget),
                    icon: Icons.track_changes_outlined,
                    type: MetricCardType.red,
                    onTap: () => onNavigateTab(3), // Reports Tab
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Salesman Route Beat Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2537), Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F2537).withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.route_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Territory Route Beat',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Civil Lines & Nayaganj Market • ${appState.filteredOutlets.length} Outlets Scheduled',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE BEAT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Field & Ops',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Quick Actions (4x2 Grid)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
              children: [
                QuickActionCard(
                  label: 'Add Sale (SKU)',
                  icon: Icons.add_shopping_cart_rounded,
                  iconColor: const Color(0xFF1B5E20),
                  iconBgColor: const Color(0xFFE8F5E9),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddSaleScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Outlet List',
                  icon: Icons.store_rounded,
                  iconColor: AppColors.primaryRed,
                  iconBgColor: const Color(0xFFFFECEE),
                  onTap: () {
                    appState.clearFilters();
                    onNavigateTab(1);
                  },
                ),
                QuickActionCard(
                  label: 'Collection',
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppColors.primaryRed,
                  iconBgColor: const Color(0xFFFFECEE),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CollectionEntryScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Territory Map',
                  icon: Icons.hub_rounded,
                  iconColor: const Color(0xFF0F2537),
                  iconBgColor: const Color(0xFFE2E8F0),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MarketHierarchyScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Party Ledger',
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.purple,
                  iconBgColor: AppColors.purpleLight,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PartyLedgerScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Market List',
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.primaryRed,
                  iconBgColor: const Color(0xFFFFECEE),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MarketHierarchyScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Debtors (A4)',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFC2410C),
                  iconBgColor: const Color(0xFFFFEDD5),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DebtorAgingScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'Offline Outbox',
                  icon: Icons.cloud_sync_rounded,
                  iconColor: const Color(0xFF0284C7),
                  iconBgColor: const Color(0xFFE0F2FE),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OfflineSyncScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  label: 'PDF Reports',
                  icon: Icons.print_rounded,
                  iconColor: AppColors.primaryRed,
                  iconBgColor: const Color(0xFFFFECEE),
                  onTap: () {
                    onNavigateTab(3);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Healthier Smiles Banner
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Leaf Illustration Background
                    Positioned(
                      right: -10,
                      bottom: -15,
                      child: Opacity(
                        opacity: 0.9,
                        child: Icon(
                          Icons.spa_rounded,
                          size: 110,
                          color: const Color(0xFF4ADE80).withAlpha(120),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"Together for\nHealthier Smiles"',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF166534),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ANSU Ayurvedic Dental Care',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRedLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '2 New',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _notificationItem(
                  icon: Icons.monetization_on_outlined,
                  color: AppColors.green,
                  title: 'Collection Target Alert',
                  subtitle: 'You are ₹ 76,500 away from your monthly target.',
                  time: '10 mins ago',
                ),
                const SizedBox(height: 12),
                _notificationItem(
                  icon: Icons.storefront_outlined,
                  color: AppColors.blue,
                  title: 'New Outlets Assigned',
                  subtitle: '3 new outlets added in Civil Lines, Kanpur.',
                  time: '1 hr ago',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _notificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCheckOutDialog(
      BuildContext context, AppState appState, String outletId) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.primaryRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'End Store Visit',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm check-out and end your GPS visit session. You can enter any visit remarks below:',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textDark),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: remarksController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Discussed new SKU stock, owner requested next visit on Friday',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.checkOutOutlet(
                outletId,
                remarksController.text.trim().isNotEmpty
                    ? remarksController.text.trim()
                    : 'Completed field visit.',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visit completed and checked out successfully!'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete & Check Out'),
          ),
        ],
      ),
    );
  }
}
