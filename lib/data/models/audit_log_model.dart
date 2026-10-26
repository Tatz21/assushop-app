class AuditLogModel {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String details;
  final String performedBy;
  final DateTime timestamp;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    required this.performedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'details': details,
        'performedBy': performedBy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
        id: json['id'] as String,
        action: json['action'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        details: json['details'] as String,
        performedBy: json['performedBy'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
