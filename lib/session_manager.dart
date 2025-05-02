import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'session_key';

  // Зберегти session key
  static Future<void> saveSessionKey(String sessionKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, sessionKey);
  }

  // Отримати session key
  static Future<String?> getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  // Видалити session key (при logout)
  static Future<void> clearSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
