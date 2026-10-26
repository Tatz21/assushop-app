import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/outbox_item_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class SyncOutboxService {
  static final SyncOutboxService _instance = SyncOutboxService._internal();
  factory SyncOutboxService() => _instance;
  SyncOutboxService._internal();

  static const _uuid = Uuid();
  List<OutboxItemModel> _outbox = [];
  bool _isSimulatedOffline = false;
  bool _isRealNetworkConnected = true;
  bool _isProcessingQueue = false;

  final StreamController<List<OutboxItemModel>> _outboxStreamController =
      StreamController<List<OutboxItemModel>>.broadcast();

  Stream<List<OutboxItemModel>> get outboxStream =>
      _outboxStreamController.stream;

  List<OutboxItemModel> get queue => List.unmodifiable(_outbox);

  int get pendingCount =>
      _outbox.where((i) => i.status == OutboxStatus.pending).length;

  bool get isEffectiveOnline => _isRealNetworkConnected && !_isSimulatedOffline;
  bool get isSimulatedOffline => _isSimulatedOffline;

  Future<void> initialize() async {
    final savedOutbox = await StorageService.loadOutbox();
    if (savedOutbox != null) {
      _outbox = savedOutbox;
      _outboxStreamController.add(_outbox);
    }

    // Monitor real network status
    Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      _isRealNetworkConnected = isConnected;
      if (isEffectiveOnline) {
        processQueue();
      }
    });
  }

  void setOfflineSimulation(bool offline) {
    _isSimulatedOffline = offline;
    if (isEffectiveOnline) {
      processQueue();
    }
  }

  /// Enqueue an action with UUID v4 idempotency token
  Future<OutboxItemModel> enqueueAction({
    required String actionType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final item = OutboxItemModel(
      id: _uuid.v4(),
      actionType: actionType,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
      status: isEffectiveOnline ? OutboxStatus.syncing : OutboxStatus.pending,
    );

    _outbox.add(item);
    await StorageService.saveOutbox(_outbox);
    _outboxStreamController.add(_outbox);

    if (isEffectiveOnline) {
      // Trigger background sync pulse
      unawaited(processQueue());
    }

    return item;
  }

  /// Drains FIFO outbox items
  Future<int> processQueue({
    Future<bool> Function(OutboxItemModel item)? executor,
  }) async {
    if (_isProcessingQueue || !isEffectiveOnline) return 0;
    _isProcessingQueue = true;

    int syncedCount = 0;
    try {
      for (final item in _outbox) {
        if (item.status == OutboxStatus.pending ||
            item.status == OutboxStatus.syncing) {
          item.status = OutboxStatus.syncing;
          _outboxStreamController.add(_outbox);

          // Simulated remote sync commit delay
          await Future.delayed(const Duration(milliseconds: 300));

          bool success = true;
          final exec = executor ?? FirebaseService().syncOutboxItemToCloud;
          try {
            success = await exec(item);
          } catch (e) {
            success = false;
            item.errorMessage = e.toString();
          }

          if (success) {
            item.status = OutboxStatus.synced;
            item.syncedAt = DateTime.now();
            syncedCount++;
          } else {
            item.status = OutboxStatus.failed;
            item.retryCount++;
          }
        }
      }

      await StorageService.saveOutbox(_outbox);
      _outboxStreamController.add(_outbox);
    } finally {
      _isProcessingQueue = false;
    }

    return syncedCount;
  }

  Future<void> clearSynced() async {
    _outbox.removeWhere((item) => item.status == OutboxStatus.synced);
    await StorageService.saveOutbox(_outbox);
    _outboxStreamController.add(_outbox);
  }
}
