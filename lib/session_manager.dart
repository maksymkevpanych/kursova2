import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'session_key';
  static const String _isAdminKey = 'is_admin';

  
  static Future<void> saveSessionKey(String sessionKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, sessionKey);
  }


  static Future<String?> getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }


  static Future<void> clearSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_isAdminKey); 
  }

  
  static Future<void> saveIsAdmin(bool isAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminKey, isAdmin);
  }

  
  static Future<bool> getIsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false; 
  }
}
