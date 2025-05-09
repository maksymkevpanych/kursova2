import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'session_key';
  static const String _isAdminKey = 'is_admin'; // Додано ключ для перевірки адміністратора

  /// Зберігає сесію користувача
  static Future<void> saveSessionKey(String sessionKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, sessionKey);
  }

  /// Отримує сесію користувача
  static Future<String?> getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  /// Очищує сесію користувача
  static Future<void> clearSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_isAdminKey); // Видаляємо також статус адміністратора
  }

  /// Зберігає статус адміністратора
  static Future<void> saveIsAdmin(bool isAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminKey, isAdmin);
  }

  /// Отримує статус адміністратора
  static Future<bool> getIsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false; // За замовчуванням false
  }
}
