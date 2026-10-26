import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/outlet_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/salesman_model.dart';
import '../../data/models/sale_invoice_model.dart';
import '../../data/models/collection_model.dart';
import '../../data/models/ledger_model.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/outbox_item_model.dart';
import '../../data/models/visit_session_model.dart';

class StorageService {
  StorageService._();

  static const String _kOutletsKey = 'aupl_storage_outlets';
  static const String _kProductsKey = 'aupl_storage_products';
  static const String _kSalesmenKey = 'aupl_storage_salesmen';
  static const String _kInvoicesKey = 'aupl_storage_invoices';
  static const String _kCollectionsKey = 'aupl_storage_collections';
  static const String _kLedgerKey = 'aupl_storage_ledger';
  static const String _kAuditLogsKey = 'aupl_storage_audit_logs';
  static const String _kOutboxKey = 'aupl_storage_outbox';
  static const String _kVisitSessionsKey = 'aupl_storage_visit_sessions';

  // Save methods
  static Future<void> saveOutlets(List<OutletModel> outlets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = outlets.map((o) => o.toJson()).toList();
    await prefs.setString(_kOutletsKey, jsonEncode(jsonList));
  }

  static Future<void> saveProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_kProductsKey, jsonEncode(jsonList));
  }

  static Future<void> saveSalesmen(List<SalesmanModel> salesmen) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = salesmen.map((s) => s.toJson()).toList();
    await prefs.setString(_kSalesmenKey, jsonEncode(jsonList));
  }

  static Future<void> saveInvoices(List<SaleInvoiceModel> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = invoices.map((i) => i.toJson()).toList();
    await prefs.setString(_kInvoicesKey, jsonEncode(jsonList));
  }

  static Future<void> saveCollections(List<CollectionModel> collections) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = collections.map((c) => c.toJson()).toList();
    await prefs.setString(_kCollectionsKey, jsonEncode(jsonList));
  }

  static Future<void> saveLedger(List<LedgerTransactionModel> ledger) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ledger.map((l) => l.toJson()).toList();
    await prefs.setString(_kLedgerKey, jsonEncode(jsonList));
  }

  static Future<void> saveAuditLogs(List<AuditLogModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_kAuditLogsKey, jsonEncode(jsonList));
  }

  static Future<void> saveOutbox(List<OutboxItemModel> outbox) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = outbox.map((o) => o.toJson()).toList();
    await prefs.setString(_kOutboxKey, jsonEncode(jsonList));
  }

  static Future<void> saveVisitSessions(List<VisitSessionModel> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_kVisitSessionsKey, jsonEncode(jsonList));
  }

  // Load methods
  static Future<List<OutletModel>?> loadOutlets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOutletsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => OutletModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<ProductModel>?> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProductsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<SalesmanModel>?> loadSalesmen() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSalesmenKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => SalesmanModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<SaleInvoiceModel>?> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kInvoicesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => SaleInvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<CollectionModel>?> loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCollectionsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => CollectionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<LedgerTransactionModel>?> loadLedger() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLedgerKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => LedgerTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<AuditLogModel>?> loadAuditLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAuditLogsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<OutboxItemModel>?> loadOutbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOutboxKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => OutboxItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<VisitSessionModel>?> loadVisitSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kVisitSessionsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => VisitSessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}
