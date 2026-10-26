import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';

class AuthService {
  static const String _kLoggedInUserIdKey = 'aupl_logged_in_user_id';
  static const String _kCurrentRoleKey = 'aupl_current_role';
  static const String _kDeviceIdKey = 'aupl_device_hardware_id';

  // Master profiles configured for AUPL operations
  static const List<UserModel> systemUsers = [
    UserModel(
      id: 'USR001',
      name: 'Rohit Sharma',
      role: 'Sales Executive',
      mobile: '9876543210',
      employeeId: 'ANSU-SE-408',
      email: 'rohit.sharma@ansubajradanta.com',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    UserModel(
      id: 'USR002',
      name: 'Rajesh Kumar',
      role: 'Senior Sales Executive',
      mobile: '9839011223',
      employeeId: 'ANSU-SE-409',
      email: 'rajesh.k@ansushop.com',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
    UserModel(
      id: 'USR003',
      name: 'Amit Singh',
      role: 'Sales Executive',
      mobile: '9839044556',
      employeeId: 'ANSU-SE-410',
      email: 'amit.singh@ansushop.com',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    ),
    UserModel(
      id: 'ADM001',
      name: 'Sunil Agarwal',
      role: 'Director & Regional Head',
      mobile: '9999999999',
      employeeId: 'AUPL-DIR-001',
      email: 'sunil.agarwal@ansubajradanta.com',
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    ),
  ];

  static Future<String> getOrGenerateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_kDeviceIdKey);
    if (deviceId == null) {
      deviceId = 'AUPL-DEVICE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      await prefs.setString(_kDeviceIdKey, deviceId);
    }
    return deviceId;
  }

  static Future<UserModel?> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_kLoggedInUserIdKey);
    if (userId == null) return null;
    return systemUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => systemUsers.first,
    );
  }

  static Future<AppRole> loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_kCurrentRoleKey);
    if (roleName == AppRole.admin.name) {
      return AppRole.admin;
    }
    return AppRole.salesman;
  }

  static Future<void> saveSession(UserModel user, AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInUserIdKey, user.id);
    await prefs.setString(_kCurrentRoleKey, role.name);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInUserIdKey);
    await prefs.remove(_kCurrentRoleKey);
  }
}
