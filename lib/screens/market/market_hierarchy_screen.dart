import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/search_bar_field.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import 'district_wise_screen.dart';

class MarketHierarchyScreen extends StatefulWidget {
  final bool showBackButton;

  const MarketHierarchyScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<MarketHierarchyScreen> createState() => _MarketHierarchyScreenState();
}

class _MarketHierarchyScreenState extends State<MarketHierarchyScreen> {
  int _selectedTabIndex = 0; // 0: State, 1: District, 2: Market
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Market / District / State Wise',
        showBackButton: widget.showBackButton,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
            onSelected: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: $val')),
              );
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Export', child: Text('Export Data')),
              const PopupMenuItem(value: 'Refresh', child: Text('Refresh Hierarchy')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tabs: State | District | Market
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SegmentedTabs(
              tabs: const ['State', 'District', 'Market'],
              selectedIndex: _selectedTabIndex,
              onTabSelected: (idx) {
                setState(() {
                  _selectedTabIndex = idx;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
          ),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SearchBarField(
              hintText: _selectedTabIndex == 0
                  ? 'Search state...'
                  : _selectedTabIndex == 1
                      ? 'Search district...'
                      : 'Search market...',
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          // List Items
          Expanded(
            child: _buildTabContent(appState),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppState appState) {
    if (_selectedTabIndex == 0) {
      // States
      final states = MockData.states.where((s) {
        if (_searchQuery.isEmpty) return true;
        return s.name.toLowerCase().contains(_searchQuery);
      }).toList();

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: states.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final state = states[index];
          return _buildRegionCard(
            title: state.name,
            countText: '${_formatCount(state.outletCount)} Outlets',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DistrictWiseScreen(stateName: state.name),
                ),
              );
            },
          );
        },
      );
    } else if (_selectedTabIndex == 1) {
      // Districts
      final districts = MockData.uttarPradeshDistricts.where((d) {
        if (_searchQuery.isEmpty) return true;
        return d.name.toLowerCase().contains(_searchQuery);
      }).toList();

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: districts.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final district = districts[index];
          return _buildRegionCard(
            title: district.name,
            countText: '${district.outletCount} Outlets',
            onTap: () {
              setState(() {
                _selectedTabIndex = 2;
              });
            },
          );
        },
      );
    } else {
      // Markets
      final markets = MockData.kanpurMarkets.where((m) {
        if (_searchQuery.isEmpty) return true;
        return m.name.toLowerCase().contains(_searchQuery);
      }).toList();

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: markets.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final market = markets[index];
          return _buildRegionCard(
            title: market.name,
            countText: '${market.outletCount} Outlets',
            onTap: () {
              appState.setFilters(market: market.name);
              appState.setNavIndex(1); // Jump to Outlet List
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        },
      );
    }
  }

  Widget _buildRegionCard({
    required String title,
    required String countText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.grayBorder, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    countText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final s = count.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return count.toString();
  }
}
