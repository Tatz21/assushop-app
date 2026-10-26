class VisitSessionModel {
  final String id;
  final String outletId;
  final String outletName;
  final String outletCode;
  final String salesmanId;
  final String salesmanName;
  final DateTime checkInTime;
  DateTime? checkOutTime;
  final double checkInLat;
  final double checkInLng;
  final double checkInDistanceMeters;
  final bool isMockLocation;
  String remarks;
  bool isOrderBooked;
  bool isPaymentCollected;
  double orderAmount;
  double collectionAmount;

  VisitSessionModel({
    required this.id,
    required this.outletId,
    required this.outletName,
    required this.outletCode,
    required this.salesmanId,
    required this.salesmanName,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInDistanceMeters,
    this.isMockLocation = false,
    this.remarks = '',
    this.isOrderBooked = false,
    this.isPaymentCollected = false,
    this.orderAmount = 0.0,
    this.collectionAmount = 0.0,
  });

  bool get isActive => checkOutTime == null;

  Duration get duration {
    final end = checkOutTime ?? DateTime.now();
    return end.difference(checkInTime);
  }

  String get formattedDuration {
    final d = duration;
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'outletId': outletId,
        'outletName': outletName,
        'outletCode': outletCode,
        'salesmanId': salesmanId,
        'salesmanName': salesmanName,
        'checkInTime': checkInTime.toIso8601String(),
        'checkOutTime': checkOutTime?.toIso8601String(),
        'checkInLat': checkInLat,
        'checkInLng': checkInLng,
        'checkInDistanceMeters': checkInDistanceMeters,
        'isMockLocation': isMockLocation,
        'remarks': remarks,
        'isOrderBooked': isOrderBooked,
        'isPaymentCollected': isPaymentCollected,
        'orderAmount': orderAmount,
        'collectionAmount': collectionAmount,
      };

  factory VisitSessionModel.fromJson(Map<String, dynamic> json) =>
      VisitSessionModel(
        id: json['id'] as String,
        outletId: json['outletId'] as String,
        outletName: json['outletName'] as String,
        outletCode: json['outletCode'] as String,
        salesmanId: json['salesmanId'] as String,
        salesmanName: json['salesmanName'] as String,
        checkInTime: DateTime.parse(json['checkInTime'] as String),
        checkOutTime: json['checkOutTime'] != null
            ? DateTime.parse(json['checkOutTime'] as String)
            : null,
        checkInLat: (json['checkInLat'] as num).toDouble(),
        checkInLng: (json['checkInLng'] as num).toDouble(),
        checkInDistanceMeters:
            (json['checkInDistanceMeters'] as num).toDouble(),
        isMockLocation: json['isMockLocation'] as bool? ?? false,
        remarks: json['remarks'] as String? ?? '',
        isOrderBooked: json['isOrderBooked'] as bool? ?? false,
        isPaymentCollected: json['isPaymentCollected'] as bool? ?? false,
        orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0.0,
        collectionAmount: (json['collectionAmount'] as num?)?.toDouble() ?? 0.0,
      );
}
