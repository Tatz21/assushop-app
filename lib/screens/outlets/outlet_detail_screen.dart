import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../state/app_state.dart';
import '../collection/collection_entry_screen.dart';
import '../ledger/a4_statement_preview_screen.dart';
import '../ledger/party_ledger_screen.dart';
import '../sales/add_sale_screen.dart';
import 'geofence_checkin_dialog.dart';

class OutletDetailScreen extends StatelessWidget {
  final String outletId;

  const OutletDetailScreen({
    super.key,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlet = appState.getOutletById(outletId);

    if (outlet == null) {
      return const Scaffold(
        appBar: AppHeader(title: 'Outlet Details'),
        body: Center(child: Text('Outlet not found')),
      );
    }

    final availableCredit = (outlet.creditLimit - outlet.balance).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Outlet Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
            tooltip: 'A4 Statement',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => A4StatementPreviewScreen(outletId: outlet.id),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing details for ${outlet.name}'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Card with basic info
            Container(
              padding: const EdgeInsets.all(16),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          size: 24,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outlet.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
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
                            const SizedBox(height: 4),
                            StatusBadge(status: outlet.status),
                          ],
                        ),
                      ),
                      // Check-in status pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: outlet.isCheckedIn
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: outlet.isCheckedIn
                                ? const Color(0xFF86EFAC)
                                : AppColors.grayBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              outlet.isCheckedIn
                                  ? Icons.gps_fixed_rounded
                                  : Icons.location_on_outlined,
                              size: 13,
                              color: outlet.isCheckedIn
                                  ? const Color(0xFF15803D)
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              outlet.isCheckedIn ? 'Checked-In' : 'Not In Store',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: outlet.isCheckedIn
                                    ? const Color(0xFF15803D)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.grayBorder),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Owner:',
                    value: outlet.ownerName,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile:',
                    value: outlet.mobile,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address:',
                    value: outlet.address,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.map_outlined,
                    label: 'Market:',
                    value: '${outlet.market}, ${outlet.district}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Credit Health Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit Limit: ₹${Formatters.formatCurrency(outlet.creditLimit)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                        Text(
                          'Opening Bal: ₹${Formatters.formatCurrency(outlet.openingBalance)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Available Credit',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        '₹${Formatters.formatCurrency(availableCredit)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Financial Summary Row
            Text(
              'Financial Overview',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    title: 'Total Sale',
                    amount: Formatters.formatCurrency(outlet.totalSale),
                    textColor: AppColors.green,
                    bgColor: AppColors.greenCardBg,
                    borderColor: AppColors.greenBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFinancialCard(
                    title: 'Total Collection',
                    amount: Formatters.formatCurrency(outlet.totalCollection),
                    textColor: AppColors.blue,
                    bgColor: AppColors.blueCardBg,
                    borderColor: AppColors.blueBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFinancialCard(
                    title: 'Balance Due',
                    amount: Formatters.formatCurrency(outlet.balance),
                    textColor: AppColors.primaryRed,
                    bgColor: const Color(0xFFFFF1F2),
                    borderColor: const Color(0xFFFECDD3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Action Buttons
            Text(
              'Field Actions',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // Primary Row: GPS Check-in & Record Sale
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => GeofenceCheckInDialog(outlet: outlet),
                      );
                    },
                    icon: Icon(
                      outlet.isCheckedIn
                          ? Icons.check_circle_rounded
                          : Icons.location_on_rounded,
                      size: 18,
                    ),
                    label: Text(
                      outlet.isCheckedIn ? 'Checked-In' : 'GPS Check-In',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: outlet.isCheckedIn
                          ? AppColors.green
                          : AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddSaleScreen(initialOutletId: outlet.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                    label: Text(
                      'Record Sale',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2537), // AUPL Navy
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Secondary Row: Record Collection & Party Ledger
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CollectionEntryScreen(outletId: outlet.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.currency_rupee_rounded, size: 18),
                    label: Text(
                      'Collection',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PartyLedgerScreen(outletId: outlet.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.purple),
                    label: Text(
                      'Party Ledger',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.purpleBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tertiary Row: Print A4 Statement
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => A4StatementPreviewScreen(outletId: outlet.id),
                    ),
                  );
                },
                icon: const Icon(Icons.print_outlined, size: 18, color: Color(0xFF1B5E20)),
                label: Text(
                  'Print Official A4 Statement',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1B5E20)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Communication Actions (Call, WhatsApp, Maps)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleActionButton(
                  icon: Icons.call,
                  color: AppColors.green,
                  label: 'Call',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${outlet.mobile}...')),
                    );
                  },
                ),
                _buildCircleActionButton(
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF25D366),
                  label: 'WhatsApp',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening WhatsApp for ${outlet.mobile}...')),
                    );
                  },
                ),
                _buildCircleActionButton(
                  icon: Icons.directions_outlined,
                  color: AppColors.blue,
                  label: 'Maps',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to ${outlet.address}...')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard({
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

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(60), width: 1),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
