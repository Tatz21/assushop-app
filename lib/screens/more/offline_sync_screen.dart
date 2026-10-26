import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../data/models/outbox_item_model.dart';
import '../../data/models/sale_invoice_model.dart';
import '../../state/app_state.dart';

class OfflineSyncScreen extends StatefulWidget {
  final bool showBackButton;

  const OfflineSyncScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm:ss a');
  bool _isProcessing = false;

  void _triggerManualSync(AppState appState) async {
    setState(() => _isProcessing = true);
    await appState.syncData();
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outbox synchronization completed successfully!'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _simulateOfflineBatch(AppState appState) {
    if (appState.allOutlets.isEmpty) return;
    final outlet = appState.allOutlets.first;

    // 1. Offline Check-in
    appState.checkInOutlet(outlet.id);

    // 2. Offline Sale Order
    final products = appState.products;
    final p1 = products.isNotEmpty ? products[0] : null;
    final p2 = products.length > 1 ? products[1] : null;

    if (p1 != null) {
      final items = [
        SaleItemModel(
          skuId: p1.id,
          skuCode: p1.skuCode,
          productName: p1.name,
          quantity: 10,
          baseRate: p1.baseRate,
          discountPercent: 5.0,
          gstPercentage: p1.gstPercentage,
        ),
        if (p2 != null)
          SaleItemModel(
            skuId: p2.id,
            skuCode: p2.skuCode,
            productName: p2.name,
            quantity: 5,
            baseRate: p2.baseRate,
            discountPercent: 0.0,
            gstPercentage: p2.gstPercentage,
          ),
      ];

      final invoice = SaleInvoiceModel(
        id: 'INV-OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
        invoiceNumber: 'OFF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        outletId: outlet.id,
        outletName: outlet.name,
        salesmanId: appState.currentUser.id,
        date: DateTime.now(),
        items: items,
        paymentMode: 'Credit',
        remarks: 'Offline spot sale booking via Field Tablet',
      );
      appState.recordSaleInvoice(invoice);
    }

    // 3. Offline Collection
    appState.addCollection(
      outletId: outlet.id,
      invoiceNo: 'INV-OFFLINE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      amount: 5000.0,
      paymentMode: 'Cash (Offline Spot Payment)',
      remarks: 'Collected offline during beat visit',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.isSimulatedOffline
                ? 'Queued 3 offline transactions in Outbox with UUID v4 idempotency tokens!'
                : 'Created & automatically synced 3 transactions with zero duplicates!',
          ),
          backgroundColor: appState.isSimulatedOffline ? const Color(0xFFD97706) : AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isOffline = appState.isSimulatedOffline;
    final queue = appState.outboxQueue;
    final pendingCount = appState.pendingOutboxCount;
    final syncedCount = queue.where((i) => i.status == OutboxStatus.synced).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Offline Sync & Outbox',
        showBackButton: widget.showBackButton,
        actions: [
          IconButton(
            icon: Icon(
              _isProcessing ? Icons.sync : Icons.refresh_rounded,
              color: Colors.white,
            ),
            tooltip: 'Refresh Outbox',
            onPressed: _isProcessing ? null : () => _triggerManualSync(appState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connectivity Status & Airplane Mode Toggle Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOffline ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOffline ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                  width: 1.2,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isOffline ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isOffline ? Icons.wifi_off_rounded : Icons.cloud_done_rounded,
                          color: isOffline ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOffline ? 'Simulated Offline Mode' : 'Cloud Connected (Online)',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isOffline ? const Color(0xFF92400E) : const Color(0xFF166534),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOffline
                                  ? 'Transactions safely stored in local Outbox'
                                  : 'Real-time telemetry • Project: ansu-sales-aupl-cloud',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isOffline ? const Color(0xFFB45309) : const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isOffline,
                        activeTrackColor: const Color(0xFFD97706),
                        onChanged: (val) {
                          appState.toggleOfflineSimulation();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOffline ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toggle Airplane / Signal Loss Simulation',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        Text(
                          isOffline ? 'OFFLINE ❌' : 'ONLINE 📶',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isOffline ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Outbox Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Pending Sync',
                    count: pendingCount,
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Synced',
                    count: syncedCount,
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Queue',
                    count: queue.length,
                    icon: Icons.layers_outlined,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Actions Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grayBorder, width: 0.8),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Queue Resilience & Idempotency Controls',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing || isOffline
                              ? null
                              : () => _triggerManualSync(appState),
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.cloud_upload_rounded, size: 16),
                          label: Text(
                            isOffline ? 'Offline (Disabled)' : 'Sync Outbox Now',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _simulateOfflineBatch(appState),
                          icon: const Icon(Icons.playlist_add_rounded, size: 16),
                          label: const Text(
                            '+3 Test Txns',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Outbox Items List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outbox Event Queue (${queue.length})',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'FIFO Execution Order',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Queue List or Empty State
            if (queue.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grayBorder, width: 0.8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.task_alt_rounded, color: AppColors.green, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      'Outbox Queue is Clean & Fully Synced',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All local sales orders, collections, and field visits have been committed to Cloud Firestore with zero duplicate records.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _simulateOfflineBatch(appState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: AppColors.textDark,
                        elevation: 0,
                      ),
                      child: const Text('Simulate 3 Offline Actions'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queue.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = queue[queue.length - 1 - index]; // Newest first for inspection
                  return _buildOutboxItemCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildOutboxItemCard(OutboxItemModel item) {
    Color typeColor = const Color(0xFF2563EB);
    String typeLabel = item.actionType;

    if (item.actionType.contains('SALE')) {
      typeColor = const Color(0xFF16A34A);
      typeLabel = 'SALE ORDER';
    } else if (item.actionType.contains('COLLECTION')) {
      typeColor = const Color(0xFFD97706);
      typeLabel = 'COLLECTION';
    } else if (item.actionType.contains('CHECK_IN')) {
      typeColor = const Color(0xFF0284C7);
      typeLabel = 'CHECK IN';
    } else if (item.actionType.contains('CHECK_OUT')) {
      typeColor = const Color(0xFF7C3AED);
      typeLabel = 'CHECK OUT';
    }

    Color statusColor = const Color(0xFFD97706);
    String statusLabel = 'PENDING SYNC';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (item.status == OutboxStatus.synced) {
      statusColor = const Color(0xFF16A34A);
      statusLabel = 'SYNCED';
      statusIcon = Icons.check_circle_rounded;
    } else if (item.status == OutboxStatus.syncing) {
      statusColor = const Color(0xFF2563EB);
      statusLabel = 'SYNCING';
      statusIcon = Icons.sync_rounded;
    } else if (item.status == OutboxStatus.failed) {
      statusColor = Colors.red;
      statusLabel = 'FAILED';
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayBorder, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: typeColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.send_to_mobile_rounded, color: typeColor, size: 20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: typeColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ID: ${item.entityId}',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.robotoMono(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                ),
                const Spacer(),
                Text(
                  _dateFormat.format(item.createdAt),
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Idempotency Key (UUID v4):',
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                ),
                SelectableText(
                  item.id,
                  style: GoogleFonts.robotoMono(fontSize: 10.5, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w700),
                ),
                const Divider(color: Color(0xFF334155), height: 12),
                Text(
                  'Payload Preview:',
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                ),
                SelectableText(
                  const JsonEncoder.withIndent('  ').convert(item.payload),
                  style: GoogleFonts.robotoMono(fontSize: 9.5, color: const Color(0xFFE2E8F0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
