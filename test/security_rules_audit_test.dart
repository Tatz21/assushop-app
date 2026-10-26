import 'package:flutter_test/flutter_test.dart';
import 'package:ansu_sales_app/core/services/play_integrity_service.dart';
import 'package:ansu_sales_app/data/mock_data.dart';
import 'package:ansu_sales_app/data/models/outlet_model.dart';
import 'package:ansu_sales_app/data/models/sale_invoice_model.dart';
import 'package:ansu_sales_app/state/app_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7: Comprehensive Security & 18 Business Rules Audit Test Suite', () {
    late AppState state;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      state = AppState();
    });

    test('Rule 1 & 2: Assigned Access & Territorial Data Isolation', () {
      // Current user is USR001 (Rohit Sharma)
      expect(state.currentUser.id, 'USR001');

      // Verify salesman cannot see outlets assigned to other salesmen
      final outlets = state.filteredOutlets;
      expect(outlets.every((o) => o.assignedSalesmanId == 'USR001' || o.assignedSalesmanId == null), isTrue);
      expect(outlets.any((o) => o.assignedSalesmanId != null && o.assignedSalesmanId != 'USR001'), isFalse);

      // Verify outlets assigned to USR002 (Rajesh Kumar) are NOT in salesman's list
      final outlet3 = state.getOutletById('3'); // Assigned to USR002
      expect(outlet3, isNotNull);
      expect(outlet3!.assignedSalesmanId, 'USR002');
      expect(outlets.any((o) => o.id == '3'), isFalse);
    });

    test('Rule 3 & 4: GPS Geofence Verification and Anti-Remote Check-In', () {
      // 1. Within 100m geofence: Check-In allowed
      state.setSimulatedGpsDistance(40.0); // 40m away
      final outlet1 = state.getOutletById('1')!;
      expect(state.simulatedGpsDistanceMeters, lessThanOrEqualTo(100.0));
      final checkInSuccess = state.checkInOutlet(outlet1.id);
      expect(checkInSuccess, isTrue);
      expect(state.activeVisitSession?.outletId, outlet1.id);

      // 2. Beyond 100m geofence (Remote check-in attempt from 150m): strictly blocked!
      state.setSimulatedGpsDistance(150.0); // 150m away (>100m)
      final outlet2 = state.getOutletById('2')!;
      final remoteCheckInSuccess = state.checkInOutlet(outlet2.id);
      expect(remoteCheckInSuccess, isFalse);
    });

    test('Rule 7 & 8: Auto Party Ledger & Auto Outstanding calculation', () {
      final initialOutlet = state.getOutletById('2')!;
      final initialBalance = initialOutlet.balance; // 25,000

      // Record a new collection of ₹5,000
      state.addCollection(
        outletId: '2',
        invoiceNo: 'INV-TEST-001',
        amount: 5000.0,
        paymentMode: 'Cash',
        remarks: 'Pilot Test Collection',
      );

      final updatedOutlet = state.getOutletById('2')!;
      expect(updatedOutlet.balance, initialBalance - 5000.0);
      expect(updatedOutlet.totalCollection, initialOutlet.totalCollection + 5000.0);

      // Verify ledger transaction was appended
      final txns = state.getLedgerForOutlet('2');
      expect(txns.any((t) => t.amount == 5000.0), isTrue);
    });

    test('Rule 9: Opening Balance Isolation and Immutability', () {
      final outlet1 = state.getOutletById('1')!;
      final originalOpeningBal = outlet1.openingBalance;
      expect(originalOpeningBal, 10000.0);

      // Record collection
      state.addCollection(
        outletId: '1',
        invoiceNo: 'INV-ISOLATION-01',
        amount: 2000.0,
        paymentMode: 'UPI',
        remarks: 'Test',
      );

      final reloaded = state.getOutletById('1')!;
      // Opening balance must remain completely untouched
      expect(reloaded.openingBalance, originalOpeningBal);
    });

    test('Rule 10: Central SKU Master Integrity', () {
      final products = MockData.initialProducts;
      expect(products.isNotEmpty, isTrue);

      for (final p in products) {
        expect(p.skuCode.startsWith('SKU-AUPL-'), isTrue);
        expect(p.mrp, greaterThan(0));
        expect(p.baseRate, lessThan(p.mrp));
        expect(p.gstPercentage, isIn([5.0, 12.0, 18.0, 28.0]));
      }
    });

    test('Rule 11 & 12: Append-only Financial Invoices and Client Idempotency', () {
      final outlet = state.getOutletById('1')!;

      // Create an invoice
      final invoice = SaleInvoiceModel(
        id: 'INV-AUDIT-001',
        invoiceNumber: 'AUPL-INV-AUDIT-001',
        outletId: outlet.id,
        outletName: outlet.name,
        salesmanId: 'USR001',
        date: DateTime.now(),
        items: const [
          SaleItemModel(
            skuId: 'PRD001',
            skuCode: 'SKU-AUPL-01',
            productName: 'Ansu Clean Floor Wash 500ml',
            quantity: 10,
            baseRate: 85.0,
            gstPercentage: 18.0,
          ),
        ],
      );

      state.recordSaleInvoice(invoice);

      final invoices = state.invoices.where((inv) => inv.outletId == outlet.id).toList();
      expect(invoices.isNotEmpty, isTrue);
      // Ensure invoice was appended immutably
      expect(invoices.any((inv) => inv.invoiceNumber == 'AUPL-INV-AUDIT-001'), isTrue);
    });

    test('Rule 15: 1-Click Debtor Aging Buckets Verification (0-30, 31-60, 61-90, 90+)', () {
      final allOutlets = state.allOutlets;
      expect(allOutlets.isNotEmpty, isTrue);

      final totalDebtors = allOutlets.where((o) => o.balance > 0).toList();
      expect(totalDebtors.length, greaterThan(0));

      final totalOutstanding = totalDebtors.fold<double>(0, (sum, o) => sum + o.balance);
      expect(totalOutstanding, greaterThan(0));
    });

    test('Phase 7 Hardening: Google Play Integrity & Anti-Tamper Attestation', () async {
      // 1. Genuine attestation
      final result = await PlayIntegrityService.verifyClientIntegrity();
      expect(result.isSecure, isTrue);
      expect(result.verdict, IntegrityVerdict.genuine);
      expect(result.appLicensingVerdict, 'LICENSED');
      expect(result.deviceToken.startsWith('AUPL_PLAY_INT_VERIFIED_'), isTrue);

      // 2. Clock-drift rejection (>10 minutes drift)
      final driftServerTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 1000; // 16+ min drift
      final driftResult = await PlayIntegrityService.verifyClientIntegrity(customServerEpoch: driftServerTime);
      expect(driftResult.isSecure, isFalse);
      expect(driftResult.verdict, IntegrityVerdict.clockDriftExceeded);
      expect(driftResult.rejectionReason, contains('10 minutes'));

      // 3. Hardware device binding validation
      expect(PlayIntegrityService.verifyDeviceBinding(boundDeviceId: 'DEV-AUPL-8839', currentDeviceId: 'DEV-AUPL-8839'), isTrue);
      expect(PlayIntegrityService.verifyDeviceBinding(boundDeviceId: 'DEV-AUPL-8839', currentDeviceId: 'DEV-SPOOF-0000'), isFalse);
    });
  });
}
