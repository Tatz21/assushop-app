import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_bottom_nav.dart';
import '../core/widgets/responsive_wrapper.dart';
import '../state/app_state.dart';
import 'collection/collection_entry_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'ledger/party_ledger_screen.dart';
import 'login/login_screen.dart';
import 'market/market_hierarchy_screen.dart';
import 'more/more_screen.dart';
import 'more/profile_screen.dart';
import 'more/offline_sync_screen.dart';
import 'outlets/outlet_list_screen.dart';
import 'reports/reports_screen.dart';
import 'reports/debtor_aging_screen.dart';
import 'sales/add_sale_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    final List<Widget> screens = [
      DashboardScreen(
        scaffoldKey: _scaffoldKey,
        onNavigateTab: (index) => appState.setNavIndex(index),
      ),
      const OutletListScreen(showBackButton: false),
      const CollectionEntryScreen(showBackButton: false),
      const ReportsScreen(showBackButton: false),
      const MoreScreen(showBackButton: false),
    ];

    return ResponsiveWrapper(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildAppDrawer(context, appState, user),
        body: Column(
          children: [
            // Simulated Offline Banner
            if (appState.isSimulatedOffline)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: const Color(0xFFFEF3C7),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 16, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OfflineSyncScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Simulated Offline Mode • ${appState.pendingOutboxCount} items queued in Outbox (Tap to view)',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB45309),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        appState.toggleOfflineSimulation();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Go Online',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Tab View
            Expanded(
              child: IndexedStack(
                index: appState.selectedNavIndex,
                children: screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: appState.selectedNavIndex,
          onTap: (index) {
            appState.setNavIndex(index);
          },
        ),
      ),
    );
  }

  void _showUserSwitcherSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select User Profile',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Switch persona to test representative vs administrator privileges:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ...AuthService.systemUsers.map((u) {
                  final isSelected = appState.currentUser.id == u.id;
                  final isAdmin = u.id == 'ADM001';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryRed.withAlpha(20)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryRed
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(u.avatarUrl),
                        radius: 18,
                      ),
                      title: Text(
                        u.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${u.role} • ${u.employeeId}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AppColors.primaryRed
                              : AppColors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAdmin ? 'Admin' : 'Sales Rep',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        appState.switchUser(
                          u,
                          role: isAdmin ? AppRole.admin : AppRole.salesman,
                        );
                        Navigator.pop(ctx);
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppDrawer(BuildContext context, AppState appState, dynamic user) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Red Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: AppColors.primaryRed,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.role,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.employeeId,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home / Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    appState.setNavIndex(0);
                  },
                ),
                _drawerItem(
                  icon: Icons.storefront_rounded,
                  title: 'Outlet List',
                  onTap: () {
                    Navigator.pop(context);
                    appState.setNavIndex(1);
                  },
                ),
                _drawerItem(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Collection Entry',
                  onTap: () {
                    Navigator.pop(context);
                    appState.setNavIndex(2);
                  },
                ),
                _drawerItem(
                  icon: Icons.location_on_rounded,
                  title: 'Market / District Wise',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MarketHierarchyScreen()),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.menu_book_rounded,
                  title: 'Party Ledger',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PartyLedgerScreen()),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.add_shopping_cart_rounded,
                  title: 'New Sales Order (SKU)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddSaleScreen()),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Reports & Leaderboard',
                  onTap: () {
                    Navigator.pop(context);
                    appState.setNavIndex(3);
                  },
                ),
                _drawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Debtor Aging & Outstandings',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${appState.debtorOutlets.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DebtorAgingScreen()),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.sync_alt_rounded,
                  title: 'Offline Sync & Outbox Center',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: appState.isSimulatedOffline
                          ? const Color(0xFFD97706)
                          : (appState.pendingOutboxCount > 0
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF16A34A)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      appState.isSimulatedOffline
                          ? 'OFFLINE'
                          : (appState.pendingOutboxCount > 0
                              ? '${appState.pendingOutboxCount} PENDING'
                              : 'ONLINE'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const OfflineSyncScreen()),
                    );
                  },
                ),
                const Divider(),
                _drawerItem(
                  icon: Icons.laptop_chromebook_rounded,
                  title: 'Standalone Web Admin Console',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PORTAL :54080',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.open_in_browser, color: Color(0xFF16A34A)),
                            SizedBox(width: 8),
                            Text('Standalone Web Console'),
                          ],
                        ),
                        content: const Text(
                          'The AUPL Central Admin Console runs as a dedicated standalone desktop web console outside the mobile app at:\n\nhttp://localhost:54080\n\nFeatures:\n• Store-Salesman Allocation Matrix\n• Master SKU Catalog & Tiered GST\n• Live GPS Field Radar & Anti-Mock Tracking\n• Debtor Aging 0-90+ Days & CSV Export\n• Firebase Cloud Pipeline & Immutable Audit Trail',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.switch_account_rounded,
                  title: 'Switch User Persona',
                  onTap: () {
                    _showUserSwitcherSheet(context, appState);
                  },
                ),
                _drawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      appState.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.logout,
                        size: 18, color: AppColors.primaryRed),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: trailing,
      dense: true,
      onTap: onTap,
    );
  }
}
