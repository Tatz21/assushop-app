import 'dart:convert';

enum OutboxStatus {
  pending,
  syncing,
  synced,
  failed;

  String get label {
    switch (this) {
      case OutboxStatus.pending:
        return 'Pending';
      case OutboxStatus.syncing:
        return 'Syncing';
      case OutboxStatus.synced:
        return 'Synced';
      case OutboxStatus.failed:
        return 'Failed';
    }
  }
}

class OutboxItemModel {
  final String id; // UUID v4 idempotency token
  final String actionType; // SALE_INVOICE, COLLECTION, CHECK_IN, CHECK_OUT, ASSIGN_OUTLET, CREATE_OUTLET
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  OutboxStatus status;
  int retryCount;
  String? errorMessage;
  DateTime? syncedAt;

  OutboxItemModel({
    required this.id,
    required this.actionType,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.status = OutboxStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
    this.syncedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actionType': actionType,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'retryCount': retryCount,
        'errorMessage': errorMessage,
        'syncedAt': syncedAt?.toIso8601String(),
      };

  factory OutboxItemModel.fromJson(Map<String, dynamic> json) => OutboxItemModel(
        id: json['id'] as String,
        actionType: json['actionType'] as String,
        entityId: json['entityId'] as String,
        payload: json['payload'] is String
            ? jsonDecode(json['payload'] as String) as Map<String, dynamic>
            : (json['payload'] as Map<String, dynamic>? ?? {}),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: OutboxStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => OutboxStatus.pending,
        ),
        retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
        errorMessage: json['errorMessage'] as String?,
        syncedAt: json['syncedAt'] != null
            ? DateTime.parse(json['syncedAt'] as String)
            : null,
      );
}
