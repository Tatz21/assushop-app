enum OutletStatus {
  visited,
  pending,
  notVisited;

  String get label {
    switch (this) {
      case OutletStatus.visited:
        return 'Visited';
      case OutletStatus.pending:
        return 'Pending';
      case OutletStatus.notVisited:
        return 'Not Visited';
    }
  }
}

class OutletModel {
  final String id;
  final String code;
  final String name;
  final String ownerName;
  final String mobile;
  final String state;
  final String district;
  final String market;
  final String address;
  final double distance;
  OutletStatus status;
  double totalSale;
  double totalCollection;
  double balance;
  final DateTime? lastVisitDate;
  DateTime? lastCollectionDate;
  double? lastCollectionAmount;

  // AUPL Operational Extensions
  final String? assignedSalesmanId;
  final double creditLimit;
  final double openingBalance;
  final double latitude;
  final double longitude;
  final double geofenceRadius;
  final bool isCheckedIn;
  final DateTime? checkInTime;

  OutletModel({
    required this.id,
    required this.code,
    required this.name,
    required this.ownerName,
    required this.mobile,
    required this.state,
    required this.district,
    required this.market,
    required this.address,
    required this.distance,
    required this.status,
    required this.totalSale,
    required this.totalCollection,
    required this.balance,
    this.lastVisitDate,
    this.lastCollectionDate,
    this.lastCollectionAmount,
    this.assignedSalesmanId,
    this.creditLimit = 50000.0,
    this.openingBalance = 10000.0,
    this.latitude = 26.46743,
    this.longitude = 80.35032,
    this.geofenceRadius = 100.0,
    this.isCheckedIn = false,
    this.checkInTime,
  });

  int get agingDays {
    if (lastCollectionDate != null) {
      final days = DateTime.now().difference(lastCollectionDate!).inDays;
      return days > 0 ? days : 12;
    }
    final hash = code.codeUnits.fold(0, (prev, elem) => prev + elem);
    return 10 + (hash % 95);
  }

  OutletModel copyWith({
    String? id,
    String? code,
    String? name,
    String? ownerName,
    String? mobile,
    String? state,
    String? district,
    String? market,
    String? address,
    double? distance,
    OutletStatus? status,
    double? totalSale,
    double? totalCollection,
    double? balance,
    DateTime? lastVisitDate,
    DateTime? lastCollectionDate,
    double? lastCollectionAmount,
    String? assignedSalesmanId,
    double? creditLimit,
    double? openingBalance,
    double? latitude,
    double? longitude,
    double? geofenceRadius,
    bool? isCheckedIn,
    DateTime? checkInTime,
  }) {
    return OutletModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      mobile: mobile ?? this.mobile,
      state: state ?? this.state,
      district: district ?? this.district,
      market: market ?? this.market,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      totalSale: totalSale ?? this.totalSale,
      totalCollection: totalCollection ?? this.totalCollection,
      balance: balance ?? this.balance,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      lastCollectionDate: lastCollectionDate ?? this.lastCollectionDate,
      lastCollectionAmount: lastCollectionAmount ?? this.lastCollectionAmount,
      assignedSalesmanId: assignedSalesmanId ?? this.assignedSalesmanId,
      creditLimit: creditLimit ?? this.creditLimit,
      openingBalance: openingBalance ?? this.openingBalance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'ownerName': ownerName,
        'mobile': mobile,
        'state': state,
        'district': district,
        'market': market,
        'address': address,
        'distance': distance,
        'status': status.name,
        'totalSale': totalSale,
        'totalCollection': totalCollection,
        'balance': balance,
        'lastVisitDate': lastVisitDate?.toIso8601String(),
        'lastCollectionDate': lastCollectionDate?.toIso8601String(),
        'lastCollectionAmount': lastCollectionAmount,
        'assignedSalesmanId': assignedSalesmanId,
        'creditLimit': creditLimit,
        'openingBalance': openingBalance,
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadius': geofenceRadius,
        'isCheckedIn': isCheckedIn,
        'checkInTime': checkInTime?.toIso8601String(),
      };

  factory OutletModel.fromJson(Map<String, dynamic> json) => OutletModel(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        ownerName: json['ownerName'] as String,
        mobile: json['mobile'] as String,
        state: json['state'] as String,
        district: json['district'] as String,
        market: json['market'] as String,
        address: json['address'] as String,
        distance: (json['distance'] as num).toDouble(),
        status: OutletStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => OutletStatus.pending,
        ),
        totalSale: (json['totalSale'] as num).toDouble(),
        totalCollection: (json['totalCollection'] as num).toDouble(),
        balance: (json['balance'] as num).toDouble(),
        lastVisitDate: json['lastVisitDate'] != null
            ? DateTime.parse(json['lastVisitDate'] as String)
            : null,
        lastCollectionDate: json['lastCollectionDate'] != null
            ? DateTime.parse(json['lastCollectionDate'] as String)
            : null,
        lastCollectionAmount:
            (json['lastCollectionAmount'] as num?)?.toDouble(),
        assignedSalesmanId: json['assignedSalesmanId'] as String?,
        creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 50000.0,
        openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 10000.0,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 26.46743,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 80.35032,
        geofenceRadius: (json['geofenceRadius'] as num?)?.toDouble() ?? 100.0,
        isCheckedIn: json['isCheckedIn'] as bool? ?? false,
        checkInTime: json['checkInTime'] != null
            ? DateTime.parse(json['checkInTime'] as String)
            : null,
      );
}
