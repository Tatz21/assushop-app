import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/location_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/sync_outbox_service.dart';
import '../core/services/firebase_service.dart';
import '../data/mock_data.dart';
import '../data/models/user_model.dart';
import '../data/models/outlet_model.dart';
import '../data/models/collection_model.dart';
import '../data/models/ledger_model.dart';
import '../data/models/product_model.dart';
import '../data/models/salesman_model.dart';
import '../data/models/sale_invoice_model.dart';
import '../data/models/audit_log_model.dart';
import '../data/models/outbox_item_model.dart';
import '../data/models/visit_session_model.dart';

enum AppRole {
  salesman,
  admin;

  String get label => this == AppRole.admin ? 'Administrator' : 'Field Salesman';
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = true;
  UserModel _currentUser = MockData.currentUser;
  AppRole _currentRole = AppRole.salesman;

  double _todayCollection = 48500.0;
  double _todaySales = 63500.0;
  final double _monthlyTarget = 150000.0;
  final DateTime _currentDate = DateTime(2026, 9, 5);

  late List<OutletModel> _outlets;
  late List<LedgerTransactionModel> _ledgerTransactions;
  late List<ProductModel> _products;
  late List<SalesmanModel> _salesmen;
  late List<SaleInvoiceModel> _invoices;
  late List<AuditLogModel> _auditLogs;
  late List<CollectionModel> _collections;
  late List<VisitSessionModel> _visitSessions;
  VisitSessionModel? _activeVisitSession;

  // Admin selection state
  String _selectedSalesmanIdForAdmin = 'USR001';

  // Outlets filter state
  String _outletSearchQuery = '';
  String? _selectedState = 'Uttar Pradesh';
  String? _selectedDistrict = 'Kanpur';
  String? _selectedMarket;
  OutletStatus? _selectedStatus;

  // Sync state
  bool _isSyncing = false;
  DateTime _lastSyncedTime = DateTime.now();

  // Navigation state
  int _selectedNavIndex = 0;

  // Geofence testing toggle (Simulated GPS distance in meters)
  double _simulatedGpsDistanceMeters = 40.0; // Defaults to 40m (Within 100m geofence)
  bool _simulatedIsMockLocation = false;

  final SyncOutboxService _outboxService = SyncOutboxService();
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseConnectionStatus get firebaseStatus => _firebaseService.status;
  String get firebaseProjectId => _firebaseService.projectId;
  DateTime get lastCloudSync => _firebaseService.lastCloudSync;
  int get syncedTransactionsCount => _firebaseService.syncedTransactionsCount;

  AppState() {
    _outlets = List.from(MockData.initialOutlets);
    _ledgerTransactions = List.from(MockData.initialLedgerTransactions);
    _products = List.from(MockData.initialProducts);
    _salesmen = List.from(MockData.initialSalesmen);
    _invoices = List.from(MockData.initialInvoices);
    _auditLogs = List.from(MockData.initialAuditLogs);
    _collections = [];
    _visitSessions = [];

    _initAsyncServices();
  }

  Future<void> _initAsyncServices() async {
    await _outboxService.initialize();

    _firebaseService.statusStream.listen((_) {
      notifyListeners();
    });

    // Load persistent storage if available
    final loadedOutlets = await StorageService.loadOutlets();
    if (loadedOutlets != null && loadedOutlets.isNotEmpty) {
      _outlets = loadedOutlets;
    } else {
      await StorageService.saveOutlets(_outlets);
    }

    final loadedProducts = await StorageService.loadProducts();
    if (loadedProducts != null && loadedProducts.isNotEmpty) {
      _products = loadedProducts;
    } else {
      await StorageService.saveProducts(_products);
    }

    final loadedSalesmen = await StorageService.loadSalesmen();
    if (loadedSalesmen != null && loadedSalesmen.isNotEmpty) {
      _salesmen = loadedSalesmen;
    } else {
      await StorageService.saveSalesmen(_salesmen);
    }

    final loadedInvoices = await StorageService.loadInvoices();
    if (loadedInvoices != null && loadedInvoices.isNotEmpty) {
      _invoices = loadedInvoices;
    }

    final loadedCollections = await StorageService.loadCollections();
    if (loadedCollections != null) {
      _collections = loadedCollections;
    }

    final loadedLedger = await StorageService.loadLedger();
    if (loadedLedger != null && loadedLedger.isNotEmpty) {
      _ledgerTransactions = loadedLedger;
    }

    final loadedAuditLogs = await StorageService.loadAuditLogs();
    if (loadedAuditLogs != null && loadedAuditLogs.isNotEmpty) {
      _auditLogs = loadedAuditLogs;
    }

    final loadedSessions = await StorageService.loadVisitSessions();
    if (loadedSessions != null) {
      _visitSessions = loadedSessions;
      _activeVisitSession = _visitSessions.where((s) => s.isActive).firstOrNull;
    }

    final savedUser = await AuthService.loadSavedUser();
    if (savedUser != null) {
      _currentUser = savedUser;
    }

    final savedRole = await AuthService.loadSavedRole();
    _currentRole = savedRole;

    _calculateTodayTotals();
    notifyListeners();
  }

  void _calculateTodayTotals() {
    double saleSum = 0;
    for (final inv in _invoices) {
      if (inv.date.year == _currentDate.year &&
          inv.date.month == _currentDate.month &&
          inv.date.day == _currentDate.day) {
        saleSum += inv.grandTotal;
      }
    }
    if (saleSum > 0) _todaySales = saleSum;

    double colSum = 0;
    for (final c in _collections) {
      if (c.date.year == _currentDate.year &&
          c.date.month == _currentDate.month &&
          c.date.day == _currentDate.day) {
        colSum += c.amount;
      }
    }
    if (colSum > 0) _todayCollection = colSum;
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  UserModel get currentUser => _currentUser;
  AppRole get currentRole => _currentRole;
  bool get isAdmin => _currentRole == AppRole.admin;

  double get todayCollection => _todayCollection;
  double get todaySales => _todaySales;
  double get monthlyTarget => _monthlyTarget;
  DateTime get currentDate => _currentDate;
  int get selectedNavIndex => _selectedNavIndex;
  bool get isSyncing => _isSyncing;
  DateTime get lastSyncedTime => _lastSyncedTime;
  double get simulatedGpsDistanceMeters => _simulatedGpsDistanceMeters;
  bool get simulatedIsMockLocation => _simulatedIsMockLocation;

  List<OutletModel> get allOutlets => _outlets;
  List<ProductModel> get products => _products;
  List<SalesmanModel> get salesmen => _salesmen;
  List<SaleInvoiceModel> get invoices => _invoices;
  List<CollectionModel> get collections => _collections;
  List<AuditLogModel> get auditLogs => _auditLogs;
  List<VisitSessionModel> get visitSessions => _visitSessions;
  VisitSessionModel? get activeVisitSession => _activeVisitSession;
  String get selectedSalesmanIdForAdmin => _selectedSalesmanIdForAdmin;

  // Outbox / Offline getters
  bool get isSimulatedOffline => _outboxService.isSimulatedOffline;
  bool get isEffectiveOnline => _outboxService.isEffectiveOnline;
  int get pendingOutboxCount => _outboxService.pendingCount;
  List<OutboxItemModel> get outboxQueue => _outboxService.queue;

  SalesmanModel? get selectedSalesmanForAdmin =>
      _salesmen.firstWhere((s) => s.id == _selectedSalesmanIdForAdmin,
          orElse: () => _salesmen.first);

  int get outletsVisitedCount =>
      _outlets.where((o) => o.status == OutletStatus.visited).length;

  int get pendingOutletsCount =>
      _outlets.where((o) => o.status == OutletStatus.pending).length;

  int get totalOutletsCount => _outlets.length;

  // Filtered outlets according to role (Salesman sees assigned only unless in Admin mode)
  List<OutletModel> get filteredOutlets {
    return _outlets.where((outlet) {
      if (_currentRole == AppRole.salesman) {
        if (outlet.assignedSalesmanId != null &&
            outlet.assignedSalesmanId != _currentUser.id) {
          return false;
        }
      }

      if (_outletSearchQuery.isNotEmpty) {
        final query = _outletSearchQuery.toLowerCase();
        final matchesName = outlet.name.toLowerCase().contains(query);
        final matchesCode = outlet.code.toLowerCase().contains(query);
        final matchesAddress = outlet.address.toLowerCase().contains(query);
        if (!matchesName && !matchesCode && !matchesAddress) return false;
      }

      if (_selectedStatus != null && outlet.status != _selectedStatus) {
        return false;
      }

      if (_selectedMarket != null && _selectedMarket!.isNotEmpty) {
        if (outlet.market != _selectedMarket) return false;
      }

      return true;
    }).toList();
  }

  String get outletSearchQuery => _outletSearchQuery;
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedMarket => _selectedMarket;
  OutletStatus? get selectedStatus => _selectedStatus;

  // Debtors List with Ageing
  List<OutletModel> get debtorOutlets {
    return _outlets.where((o) => o.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
  }

  double get totalOutstandingDebt =>
      _outlets.fold(0.0, (sum, o) => sum + o.balance);

  List<LedgerTransactionModel> getLedgerForOutlet(String outletId) {
    return _ledgerTransactions
        .where((txn) => txn.outletId == outletId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<LedgerTransactionModel> get allLedgerTransactions =>
      List.unmodifiable(_ledgerTransactions);

  OutletModel? getOutletById(String id) {
    try {
      return _outlets.firstWhere((o) => o.id == id || o.code == id);
    } catch (_) {
      return _outlets.isNotEmpty ? _outlets.first : null;
    }
  }

  // --- ACTIONS ---

  void toggleRole() {
    _currentRole =
        _currentRole == AppRole.salesman ? AppRole.admin : AppRole.salesman;
    AuthService.saveSession(_currentUser, _currentRole);
    notifyListeners();
  }

  void setRole(AppRole role) {
    _currentRole = role;
    AuthService.saveSession(_currentUser, _currentRole);
    notifyListeners();
  }

  void switchUser(UserModel user, {AppRole? role}) {
    _currentUser = user;
    if (role != null) {
      _currentRole = role;
    } else {
      _currentRole = user.role.toLowerCase().contains('admin') ||
              user.role.toLowerCase().contains('director')
          ? AppRole.admin
          : AppRole.salesman;
    }
    AuthService.saveSession(_currentUser, _currentRole);
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setSelectedSalesmanForAdmin(String salesmanId) {
    _selectedSalesmanIdForAdmin = salesmanId;
    notifyListeners();
  }

  void setSimulatedGpsDistance(double distanceMeters) {
    _simulatedGpsDistanceMeters = distanceMeters;
    notifyListeners();
  }

  void toggleSimulatedMockLocation(bool isMock) {
    _simulatedIsMockLocation = isMock;
    notifyListeners();
  }

  void toggleOfflineSimulation() {
    final newOffline = !_outboxService.isSimulatedOffline;
    _outboxService.setOfflineSimulation(newOffline);
    _recordAuditLog(
      action: 'NETWORK_MODE_CHANGE',
      entityType: 'DEVICE',
      entityId: _currentUser.id,
      details: newOffline
          ? 'Switched to Simulated Offline Mode'
          : 'Restored Online Connectivity. Auto-sync triggered.',
    );
    notifyListeners();
  }

  // GPS Check-In Verification
  bool checkInOutlet(String outletId) {
    final index = _outlets.indexWhere((o) => o.id == outletId);
    if (index == -1) return false;

    // Haversine threshold check
    final isWithinRange = LocationService.isWithinGeofence(
      distanceMeters: _simulatedGpsDistanceMeters,
      thresholdMeters: _outlets[index].geofenceRadius,
    );

    if (!isWithinRange) {
      return false; // Strictly blocked if outside 100m geofence!
    }

    final isAntiMockPassed = LocationService.verifyAntiMock(
      isMockProvider: _simulatedIsMockLocation,
      accuracyMeters: 14.5,
    );

    final outlet = _outlets[index];
    _outlets[index] = outlet.copyWith(
      isCheckedIn: true,
      checkInTime: DateTime.now(),
      status: OutletStatus.visited,
      lastVisitDate: DateTime.now(),
    );

    // Create active visit session
    final session = VisitSessionModel(
      id: 'VIS-${DateTime.now().millisecondsSinceEpoch}',
      outletId: outlet.id,
      outletName: outlet.name,
      outletCode: outlet.code,
      salesmanId: _currentUser.id,
      salesmanName: _currentUser.name,
      checkInTime: DateTime.now(),
      checkInLat: outlet.latitude,
      checkInLng: outlet.longitude,
      checkInDistanceMeters: _simulatedGpsDistanceMeters,
      isMockLocation: !isAntiMockPassed,
      remarks: 'GPS geofenced visit started (${_simulatedGpsDistanceMeters.toStringAsFixed(1)}m away)',
    );

    _activeVisitSession = session;
    _visitSessions.insert(0, session);

    // Enqueue Outbox mutation with idempotency token
    _outboxService.enqueueAction(
      actionType: 'CHECK_IN',
      entityId: outletId,
      payload: session.toJson(),
    );

    _recordAuditLog(
      action: 'GPS_CHECK_IN',
      entityType: 'VISIT',
      entityId: outletId,
      details:
          'Verified GPS Check-In for ${outlet.name} (${_simulatedGpsDistanceMeters.toStringAsFixed(1)}m away). Anti-Mock: ${isAntiMockPassed ? 'CLEAN' : 'FLAGGED'}',
    );

    StorageService.saveOutlets(_outlets);
    StorageService.saveVisitSessions(_visitSessions);
    notifyListeners();
    return true;
  }

  void checkOutOutlet(String outletId, String remarks) {
    final index = _outlets.indexWhere((o) => o.id == outletId);
    if (index != -1) {
      final outlet = _outlets[index];
      _outlets[index] = outlet.copyWith(
        isCheckedIn: false,
      );

      if (_activeVisitSession != null &&
          _activeVisitSession!.outletId == outletId) {
        _activeVisitSession!.checkOutTime = DateTime.now();
        _activeVisitSession!.remarks = remarks;

        _outboxService.enqueueAction(
          actionType: 'CHECK_OUT',
          entityId: outletId,
          payload: _activeVisitSession!.toJson(),
        );

        _activeVisitSession = null;
      }

      _recordAuditLog(
        action: 'VISIT_CHECK_OUT',
        entityType: 'VISIT',
        entityId: outletId,
        details: 'Checked out from ${outlet.name}. Remarks: $remarks',
      );

      StorageService.saveOutlets(_outlets);
      StorageService.saveVisitSessions(_visitSessions);
      notifyListeners();
    }
  }

  // Store-Salesman Assignment Actions
  void assignOutletToSalesman(String outletId, String salesmanId) {
    final outletIndex = _outlets.indexWhere((o) => o.id == outletId);
    final salesman = _salesmen.firstWhere((s) => s.id == salesmanId);

    if (outletIndex != -1) {
      _outlets[outletIndex] = _outlets[outletIndex].copyWith(
        assignedSalesmanId: salesmanId,
      );

      _outboxService.enqueueAction(
        actionType: 'ASSIGN_OUTLET',
        entityId: outletId,
        payload: {
          'outletId': outletId,
          'salesmanId': salesmanId,
          'salesmanName': salesman.name,
        },
      );

      _recordAuditLog(
        action: 'ASSIGN_OUTLET',
        entityType: 'OUTLET',
        entityId: outletId,
        details:
            'Assigned ${_outlets[outletIndex].name} to ${salesman.name} (${salesman.employeeId})',
      );

      StorageService.saveOutlets(_outlets);
      notifyListeners();
    }
  }

  void unassignOutlet(String outletId) {
    final outletIndex = _outlets.indexWhere((o) => o.id == outletId);
    if (outletIndex != -1) {
      final oldSalesmanId = _outlets[outletIndex].assignedSalesmanId;
      _outlets[outletIndex] = _outlets[outletIndex].copyWith(
        assignedSalesmanId: null,
      );

      _outboxService.enqueueAction(
        actionType: 'UNASSIGN_OUTLET',
        entityId: outletId,
        payload: {
          'outletId': outletId,
        },
      );

      _recordAuditLog(
        action: 'UNASSIGN_OUTLET',
        entityType: 'OUTLET',
        entityId: outletId,
        details:
            'Unassigned ${_outlets[outletIndex].name} from salesman $oldSalesmanId',
      );

      StorageService.saveOutlets(_outlets);
      notifyListeners();
    }
  }

  void bulkAssignMarketToSalesman(String market, String salesmanId) {
    final salesman = _salesmen.firstWhere((s) => s.id == salesmanId);
    int count = 0;

    for (int i = 0; i < _outlets.length; i++) {
      if (_outlets[i].market == market) {
        _outlets[i] = _outlets[i].copyWith(assignedSalesmanId: salesmanId);
        count++;
      }
    }

    _outboxService.enqueueAction(
      actionType: 'BULK_ASSIGN_MARKET',
      entityId: market,
      payload: {
        'market': market,
        'salesmanId': salesmanId,
        'count': count,
      },
    );

    _recordAuditLog(
      action: 'BULK_ASSIGN_MARKET',
      entityType: 'MARKET',
      entityId: market,
      details: 'Allocated all $count outlets in $market to ${salesman.name}',
    );

    StorageService.saveOutlets(_outlets);
    notifyListeners();
  }

  void reassignAllOutlets({
    required String fromSalesmanId,
    required String toSalesmanId,
  }) {
    final fromSalesman = _salesmen.firstWhere((s) => s.id == fromSalesmanId);
    final toSalesman = _salesmen.firstWhere((s) => s.id == toSalesmanId);
    int count = 0;

    for (int i = 0; i < _outlets.length; i++) {
      if (_outlets[i].assignedSalesmanId == fromSalesmanId) {
        _outlets[i] = _outlets[i].copyWith(assignedSalesmanId: toSalesmanId);
        count++;
      }
    }

    _outboxService.enqueueAction(
      actionType: 'REASSIGN_ROUTE',
      entityId: toSalesmanId,
      payload: {
        'fromSalesmanId': fromSalesmanId,
        'toSalesmanId': toSalesmanId,
        'count': count,
      },
    );

    _recordAuditLog(
      action: 'REASSIGN_ROUTE',
      entityType: 'SALESMAN',
      entityId: toSalesmanId,
      details:
          'Transferred entire route of $count outlets from ${fromSalesman.name} to ${toSalesman.name}',
    );

    StorageService.saveOutlets(_outlets);
    notifyListeners();
  }

  void addOutlet(OutletModel newOutlet) {
    _outlets.insert(0, newOutlet);

    _outboxService.enqueueAction(
      actionType: 'CREATE_OUTLET',
      entityId: newOutlet.id,
      payload: newOutlet.toJson(),
    );

    _recordAuditLog(
      action: 'CREATE_OUTLET',
      entityType: 'OUTLET',
      entityId: newOutlet.id,
      details:
          'Onboarded new store: ${newOutlet.name} (${newOutlet.code}) in ${newOutlet.market}',
    );

    StorageService.saveOutlets(_outlets);
    notifyListeners();
  }

  // SKU Order Booking
  void recordSaleInvoice(SaleInvoiceModel invoice) {
    final outletIndex = _outlets.indexWhere(
        (o) => o.id == invoice.outletId || o.code == invoice.outletId);

    _invoices.insert(0, invoice);
    _todaySales += invoice.grandTotal;

    // Automatic debit to Party Ledger
    final newLedgerEntry = LedgerTransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      outletId: invoice.outletId,
      date: invoice.date,
      type: LedgerType.sale,
      amount: invoice.grandTotal,
      reference: invoice.invoiceNumber,
      remarks: 'Sales order: ${invoice.totalQuantity} items booked',
    );
    _ledgerTransactions.insert(0, newLedgerEntry);

    // Update Outlet financials & status
    if (outletIndex != -1) {
      final outlet = _outlets[outletIndex];
      _outlets[outletIndex] = outlet.copyWith(
        totalSale: outlet.totalSale + invoice.grandTotal,
        balance: outlet.balance + invoice.grandTotal,
        status: OutletStatus.visited,
        lastVisitDate: invoice.date,
      );
    }

    // Update active visit session if present
    if (_activeVisitSession != null &&
        _activeVisitSession!.outletId == invoice.outletId) {
      _activeVisitSession!.isOrderBooked = true;
      _activeVisitSession!.orderAmount += invoice.grandTotal;
    }

    // Enqueue Outbox mutation with UUID v4 token
    _outboxService.enqueueAction(
      actionType: 'SALE_INVOICE',
      entityId: invoice.invoiceNumber,
      payload: invoice.toJson(),
    );

    _recordAuditLog(
      action: 'SALE_INVOICE',
      entityType: 'INVOICE',
      entityId: invoice.invoiceNumber,
      details:
          'Invoice ${invoice.invoiceNumber} booked for ${invoice.outletName} (₹${invoice.grandTotal.toStringAsFixed(2)})',
    );

    StorageService.saveInvoices(_invoices);
    StorageService.saveLedger(_ledgerTransactions);
    StorageService.saveOutlets(_outlets);
    notifyListeners();
  }

  // Payment Collection
  void addCollection({
    required String outletId,
    required String invoiceNo,
    required double amount,
    required String paymentMode,
    required String remarks,
  }) {
    final outletIndex =
        _outlets.indexWhere((o) => o.id == outletId || o.code == outletId);
    OutletModel? outlet;
    if (outletIndex != -1) {
      outlet = _outlets[outletIndex];
    } else {
      outlet = _outlets.first;
    }

    final newCollection = CollectionModel(
      id: 'COL-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNo: invoiceNo,
      outletId: outlet.id,
      outletName: outlet.name,
      outletCode: outlet.code,
      outletAddress: outlet.address,
      amount: amount,
      paymentMode: paymentMode,
      remarks: remarks,
      date: DateTime.now(),
    );

    _collections.insert(0, newCollection);
    _todayCollection += amount;

    // Add credit to Party Ledger
    final newLedgerEntry = LedgerTransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      outletId: outlet.id,
      date: DateTime.now(),
      type: LedgerType.collection,
      amount: amount,
      reference: paymentMode,
      remarks: remarks.isNotEmpty ? remarks : 'Collection recorded via app',
    );
    _ledgerTransactions.insert(0, newLedgerEntry);

    // Update outlet financials
    if (outletIndex != -1) {
      _outlets[outletIndex] = outlet.copyWith(
        totalCollection: outlet.totalCollection + amount,
        balance: (outlet.balance - amount).clamp(0, double.infinity),
        lastCollectionDate: DateTime.now(),
        lastCollectionAmount: amount,
        status: OutletStatus.visited,
      );
    }

    // Update active visit session if present
    if (_activeVisitSession != null &&
        _activeVisitSession!.outletId == outlet.id) {
      _activeVisitSession!.isPaymentCollected = true;
      _activeVisitSession!.collectionAmount += amount;
    }

    // Enqueue Outbox mutation with UUID v4 token
    _outboxService.enqueueAction(
      actionType: 'COLLECTION',
      entityId: newCollection.id,
      payload: newCollection.toJson(),
    );

    _recordAuditLog(
      action: 'COLLECTION_RECEIPT',
      entityType: 'COLLECTION',
      entityId: invoiceNo,
      details:
          'Received ₹${amount.toStringAsFixed(2)} via $paymentMode from ${outlet.name}',
    );

    StorageService.saveCollections(_collections);
    StorageService.saveLedger(_ledgerTransactions);
    StorageService.saveOutlets(_outlets);
    notifyListeners();
  }

  // Master Catalog CRUD
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    _recordAuditLog(
      action: 'CREATE_PRODUCT',
      entityType: 'PRODUCT',
      entityId: product.skuCode,
      details: 'Added SKU ${product.skuCode}: ${product.name} (₹${product.baseRate})',
    );
    StorageService.saveProducts(_products);
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
      _recordAuditLog(
        action: 'UPDATE_PRODUCT',
        entityType: 'PRODUCT',
        entityId: updated.skuCode,
        details: 'Updated SKU ${updated.skuCode} pricing & tax details',
      );
      StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  void _recordAuditLog({
    required String action,
    required String entityType,
    required String entityId,
    required String details,
  }) {
    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        entityType: entityType,
        entityId: entityId,
        details: details,
        performedBy: _currentRole == AppRole.admin
            ? 'Administrator'
            : _currentUser.name,
        timestamp: DateTime.now(),
      ),
    );
    StorageService.saveAuditLogs(_auditLogs);
  }

  bool login(String mobile, String password) {
    if (mobile.trim().isNotEmpty && password.trim().isNotEmpty) {
      _isLoggedIn = true;
      AuthService.saveSession(_currentUser, _currentRole);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _selectedNavIndex = 0;
    AuthService.clearSession();
    notifyListeners();
  }

  void setOutletSearchQuery(String query) {
    _outletSearchQuery = query;
    notifyListeners();
  }

  void setFilters({
    String? state,
    String? district,
    String? market,
    OutletStatus? status,
  }) {
    if (state != null) _selectedState = state;
    if (district != null) _selectedDistrict = district;
    _selectedMarket = market;
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _outletSearchQuery = '';
    _selectedMarket = null;
    _selectedStatus = null;
    notifyListeners();
  }

  void markOutletVisited(String outletId) {
    final index = _outlets.indexWhere((o) => o.id == outletId);
    if (index != -1) {
      _outlets[index] = _outlets[index].copyWith(
        status: OutletStatus.visited,
        lastVisitDate: DateTime.now(),
      );
      StorageService.saveOutlets(_outlets);
      notifyListeners();
    }
  }

  Future<void> syncData() async {
    _isSyncing = true;
    notifyListeners();

    await _outboxService.processQueue();
    await Future.delayed(const Duration(milliseconds: 600));

    _isSyncing = false;
    _lastSyncedTime = DateTime.now();
    notifyListeners();
  }
}
