import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_header.dart';
import '../../data/models/outlet_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/sale_invoice_model.dart';
import '../../state/app_state.dart';

class AddSaleScreen extends StatefulWidget {
  final String? initialOutletId;
  final bool showBackButton;

  const AddSaleScreen({
    super.key,
    this.initialOutletId,
    this.showBackButton = true,
  });

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  String? _selectedOutletId;
  final Map<String, int> _cartQuantities = {};
  double _discountPercentage = 0.0;
  String _paymentMode = 'Credit';

  @override
  void initState() {
    super.initState();
    _selectedOutletId = widget.initialOutletId;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final outlets = appState.allOutlets;

    if (_selectedOutletId == null && outlets.isNotEmpty) {
      _selectedOutletId = outlets.first.id;
    }

    final selectedOutlet = appState.getOutletById(_selectedOutletId ?? '');
    final products = appState.products;

    // Financial calculations
    double subtotal = 0.0;
    double totalGst = 0.0;
    int totalItems = 0;

    _cartQuantities.forEach((skuId, qty) {
      if (qty > 0) {
        final product = products.firstWhere((p) => p.id == skuId);
        final lineSubtotal = qty * product.baseRate;
        final lineDiscount = lineSubtotal * (_discountPercentage / 100);
        final taxable = lineSubtotal - lineDiscount;
        final gst = taxable * (product.gstPercentage / 100);

        subtotal += lineSubtotal;
        totalGst += gst;
        totalItems += qty;
      }
    });

    final totalDiscount = subtotal * (_discountPercentage / 100);
    final grandTotal = (subtotal - totalDiscount) + totalGst;
    final availableCredit = selectedOutlet != null
        ? (selectedOutlet.creditLimit - selectedOutlet.balance)
        : 0.0;
    final isExceedingCredit =
        selectedOutlet != null && grandTotal > availableCredit && availableCredit > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'New Sales Order',
        showBackButton: widget.showBackButton,
      ),
      body: Column(
        children: [
          // Outlet Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Retail Outlet',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedOutletId,
                    items: outlets.map((o) {
                      return DropdownMenuItem(
                        value: o.id,
                        child: Text(
                          '${o.name} (${o.market}) - Due: ₹${Formatters.formatCurrency(o.balance)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedOutletId = val;
                      });
                    },
                  ),
                ),
                if (selectedOutlet != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit Limit: ₹${Formatters.formatCurrency(selectedOutlet.creditLimit)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Available: ₹${Formatters.formatCurrency(availableCredit)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: availableCredit > 5000
                              ? AppColors.green
                              : AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  if (isExceedingCredit) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        '⚠️ Warning: Order exceeds remaining credit limit!',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.grayBorder),

          // SKU Catalog List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = products[index];
                final qty = _cartQuantities[p.id] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: qty > 0 ? AppColors.green : AppColors.grayBorder,
                      width: qty > 0 ? 1.5 : 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: qty > 0
                              ? AppColors.green.withAlpha(20)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: qty > 0 ? AppColors.green : AppColors.textDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${p.skuCode} • ${p.packSize}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rate: ₹${p.baseRate.toStringAsFixed(0)} + ${p.gstPercentage.toStringAsFixed(0)}% GST (MRP: ₹${p.mrp.toStringAsFixed(0)})',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stepper: [-] Qty [+]
                      Row(
                        children: [
                          InkWell(
                            onTap: qty > 0
                                ? () {
                                    setState(() {
                                      _cartQuantities[p.id] = qty - 1;
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: qty > 0
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: AppColors.grayBorder),
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Container(
                            width: 38,
                            alignment: Alignment.center,
                            child: Text(
                              '$qty',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: qty > 0
                                    ? AppColors.primaryRed
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _cartQuantities[p.id] = qty + 1;
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Tray: Discount, Grand Total & Submit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Discount & Payment Mode Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Discount: ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            DropdownButton<double>(
                              value: _discountPercentage,
                              isDense: true,
                              items: const [
                                DropdownMenuItem(value: 0.0, child: Text('0%')),
                                DropdownMenuItem(value: 2.5, child: Text('2.5%')),
                                DropdownMenuItem(value: 5.0, child: Text('5%')),
                                DropdownMenuItem(value: 10.0, child: Text('10%')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _discountPercentage = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Terms: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _paymentMode,
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Credit', child: Text('Credit')),
                              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _paymentMode = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Financial Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: $totalItems SKUs • Tax: ₹${totalGst.toStringAsFixed(1)}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${grandTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Confirm Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: totalItems > 0 && selectedOutlet != null
                          ? () => _submitOrder(
                              context,
                              appState,
                              selectedOutlet,
                              products,
                              grandTotal,
                            )
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        'Confirm & Book Order',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitOrder(
    BuildContext context,
    AppState appState,
    OutletModel outlet,
    List<ProductModel> products,
    double grandTotal,
  ) {
    final List<SaleItemModel> items = [];

    _cartQuantities.forEach((skuId, qty) {
      if (qty > 0) {
        final p = products.firstWhere((prod) => prod.id == skuId);
        items.add(
          SaleItemModel(
            skuId: p.id,
            skuCode: p.skuCode,
            productName: p.name,
            quantity: qty,
            baseRate: p.baseRate,
            discountPercent: _discountPercentage,
            gstPercentage: p.gstPercentage,
          ),
        );
      }
    });

    final invoiceNo =
        'AUPL-INV-2026-${(appState.invoices.length + 101).toString().padLeft(3, '0')}';

    final invoice = SaleInvoiceModel(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: invoiceNo,
      outletId: outlet.id,
      outletName: outlet.name,
      salesmanId: appState.currentUser.id,
      date: DateTime.now(),
      items: items,
      paymentMode: _paymentMode,
      remarks: 'Field sales order booking',
    );

    appState.recordSaleInvoice(invoice);

    // Show Confirmation Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Order Booked!',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice Number: $invoiceNo'),
              const SizedBox(height: 4),
              Text('Outlet: ${outlet.name}'),
              const SizedBox(height: 4),
              Text('Grand Total: ₹${grandTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '✅ Automatically debited to Party Ledger and updated outstanding balance.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF166534),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.showBackButton) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _cartQuantities.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
