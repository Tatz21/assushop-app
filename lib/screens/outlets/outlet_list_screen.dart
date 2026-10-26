import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/search_bar_field.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/outlet_model.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import 'outlet_detail_screen.dart';

class OutletListScreen extends StatefulWidget {
  final bool showBackButton;

  const OutletListScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<OutletListScreen> createState() => _OutletListScreenState();
}

class _OutletListScreenState extends State<OutletListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _searchController.text = appState.outletSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          'Filter by Status',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            appState.setFilters(status: null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset', style: TextStyle(color: AppColors.primaryRed)),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildFilterOption(
                      title: 'All Outlets',
                      isSelected: appState.selectedStatus == null,
                      onTap: () {
                        appState.setFilters(status: null);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildFilterOption(
                      title: 'Visited Outlets',
                      status: OutletStatus.visited,
                      isSelected: appState.selectedStatus == OutletStatus.visited,
                      onTap: () {
                        appState.setFilters(status: OutletStatus.visited);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildFilterOption(
                      title: 'Pending Outlets',
                      status: OutletStatus.pending,
                      isSelected: appState.selectedStatus == OutletStatus.pending,
                      onTap: () {
                        appState.setFilters(status: OutletStatus.pending);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildFilterOption(
                      title: 'Not Visited Outlets',
                      status: OutletStatus.notVisited,
                      isSelected: appState.selectedStatus == OutletStatus.notVisited,
                      onTap: () {
                        appState.setFilters(status: OutletStatus.notVisited);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption({
    required String title,
    OutletStatus? status,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          if (status != null) ...[
            StatusBadge(status: status),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primaryRed : AppColors.textDark,
            ),
          ),
        ],
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primaryRed, size: 20)
          : null,
    );
  }

  void _showDropdownPicker({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required ValueChanged<String?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Select $title',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedItem;
                    return ListTile(
                      title: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.primaryRed : AppColors.textDark,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primaryRed)
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlets = appState.filteredOutlets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Outlet List',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () {
              // Focus on search bar
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Row (State, District, Market)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    label: appState.selectedState ?? 'State',
                    onTap: () {
                      _showDropdownPicker(
                        title: 'State',
                        items: MockData.states.map((s) => s.name).toList(),
                        selectedItem: appState.selectedState,
                        onSelected: (val) => appState.setFilters(state: val),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    label: appState.selectedDistrict ?? 'District',
                    onTap: () {
                      _showDropdownPicker(
                        title: 'District',
                        items: MockData.uttarPradeshDistricts.map((d) => d.name).toList(),
                        selectedItem: appState.selectedDistrict,
                        onSelected: (val) => appState.setFilters(district: val),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    label: appState.selectedMarket ?? 'Market',
                    onTap: () {
                      _showDropdownPicker(
                        title: 'Market',
                        items: ['All', ...MockData.kanpurMarkets.map((m) => m.name)],
                        selectedItem: appState.selectedMarket ?? 'All',
                        onSelected: (val) => appState.setFilters(
                          market: val == 'All' ? null : val,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Search Bar and Red Filter Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SearchBarField(
              hintText: 'Search outlet name / code',
              controller: _searchController,
              showFilterButton: true,
              onChanged: (val) => appState.setOutletSearchQuery(val),
              onFilterTap: () => _openFilterDialog(context),
            ),
          ),

          // Total Outlets counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Outlets: ${appState.totalOutletsCount}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (appState.selectedStatus != null)
                  InkWell(
                    onTap: () => appState.setFilters(status: null),
                    child: Row(
                      children: [
                        StatusBadge(status: appState.selectedStatus!),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, size: 14, color: AppColors.gray),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Outlets List
          Expanded(
            child: outlets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No outlets found',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            appState.clearFilters();
                          },
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: outlets.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final outlet = outlets[index];
                      return _buildOutletCard(context, outlet);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.grayBorder, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletCard(BuildContext context, OutletModel outlet) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.grayBorder, width: 0.8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OutletDetailScreen(outletId: outlet.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Red Store Icon Box
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  size: 20,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            outlet.name,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: outlet.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${outlet.code}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                        Text(
                          Formatters.formatDistance(outlet.distance),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
