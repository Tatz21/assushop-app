class SalesmanModel {
  final String id;
  final String employeeId;
  final String name;
  final String mobile;
  final String email;
  final String role;
  final List<String> assignedMarkets;
  final List<String> assignedOutletIds;
  final double monthlyTarget;
  final double dailyTarget;
  final String avatarUrl;

  const SalesmanModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.mobile,
    required this.email,
    this.role = 'Sales Executive',
    required this.assignedMarkets,
    required this.assignedOutletIds,
    this.monthlyTarget = 150000.0,
    this.dailyTarget = 15000.0,
    this.avatarUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
  });

  SalesmanModel copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? mobile,
    String? email,
    String? role,
    List<String>? assignedMarkets,
    List<String>? assignedOutletIds,
    double? monthlyTarget,
    double? dailyTarget,
    String? avatarUrl,
  }) {
    return SalesmanModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      role: role ?? this.role,
      assignedMarkets: assignedMarkets ?? this.assignedMarkets,
      assignedOutletIds: assignedOutletIds ?? this.assignedOutletIds,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'name': name,
        'mobile': mobile,
        'email': email,
        'role': role,
        'assignedMarkets': assignedMarkets,
        'assignedOutletIds': assignedOutletIds,
        'monthlyTarget': monthlyTarget,
        'dailyTarget': dailyTarget,
        'avatarUrl': avatarUrl,
      };

  factory SalesmanModel.fromJson(Map<String, dynamic> json) => SalesmanModel(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? 'Sales Executive',
        assignedMarkets:
            (json['assignedMarkets'] as List<dynamic>?)?.cast<String>() ?? [],
        assignedOutletIds:
            (json['assignedOutletIds'] as List<dynamic>?)?.cast<String>() ?? [],
        monthlyTarget: (json['monthlyTarget'] as num?)?.toDouble() ?? 150000.0,
        dailyTarget: (json['dailyTarget'] as num?)?.toDouble() ?? 15000.0,
        avatarUrl: json['avatarUrl'] as String? ??
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      );
}
