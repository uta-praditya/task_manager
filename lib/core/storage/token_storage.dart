import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'auth_box';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_userKey, userData);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(_userKey);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> clearAuth() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_tokenKey);
    await box.delete(_userKey);
  }
}