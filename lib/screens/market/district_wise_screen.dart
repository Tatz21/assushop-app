import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/search_bar_field.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class DistrictWiseScreen extends StatefulWidget {
  final String stateName;

  const DistrictWiseScreen({
    super.key,
    this.stateName = 'Uttar Pradesh',
  });

  @override
  State<DistrictWiseScreen> createState() => _DistrictWiseScreenState();
}

class _DistrictWiseScreenState extends State<DistrictWiseScreen> {
  int _selectedTabIndex = 0; // 0: District, 1: Market
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
        title: widget.stateName,
      ),
      body: Column(
        children: [
          // Segmented Tabs: District | Market
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SegmentedTabs(
              tabs: const ['District', 'Market'],
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

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SearchBarField(
              hintText: _selectedTabIndex == 0
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

          // District or Market List
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildDistrictList(appState)
                : _buildMarketList(appState),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictList(AppState appState) {
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
        return _buildItemCard(
          title: district.name,
          countText: '${district.outletCount} Outlets',
          onTap: () {
            setState(() {
              _selectedTabIndex = 1;
            });
          },
        );
      },
    );
  }

  Widget _buildMarketList(AppState appState) {
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
        return _buildItemCard(
          title: market.name,
          countText: '${market.outletCount} Outlets',
          onTap: () {
            appState.setFilters(
              state: widget.stateName,
              district: 'Kanpur',
              market: market.name,
            );
            appState.setNavIndex(1); // Navigate to Outlets
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      },
    );
  }

  Widget _buildItemCard({
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
}
