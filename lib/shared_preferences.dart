import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeSessionKey(String sessionKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('session_key', sessionKey);
}

Future<String?> getSessionKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('session_key');
}
