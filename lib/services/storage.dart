import 'package:shared_preferences/shared_preferences.dart';

class AppStorageKeys {
  static const String accessToken = 'access_token';
  static const String isNewUser = 'is_new_user';
}

class StorageService {
  static Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> set(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
