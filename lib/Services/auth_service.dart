import 'package:flutter/material.dart';
import 'package:kursova2/Services/rpc_service.dart';
import 'package:kursova2/constants.dart';
import 'package:kursova2/session_manager.dart'; // Імпортуємо SessionManager

final rpc = RpcService(url: apiUrl);

Future<void> login(
  BuildContext context,
  String username,
  String password,
  Function(bool isAdmin) onSuccess, // Колбек тепер приймає статус адміністратора
) async {
  final response = await rpc.sendRequest(
    method: 'User->login',
    params: {
      'username': username,
      'password': password,
    },
    sessionKey: 'login',
    id: 3,
  );

  // Логування відповіді сервера
  print('Server response: $response');

  if (response != null && response['result'] != null) {
    final sessionKey = response['result']['response'];

    // Зміна ключа на 'isAdmin'
    final isAdmin = response['result']['isAdmin'] ?? false; // Отримуємо статус адміністратора
    print('Login success: $sessionKey, isAdmin: $isAdmin');

    // Зберігаємо сесію та статус адміністратора
    await SessionManager.saveSessionKey(sessionKey);
    await SessionManager.saveIsAdmin(isAdmin);

    // Викликаємо колбек із передачею статусу адміністратора
    onSuccess(isAdmin);
  } else {
    print('Login failed: ${response?['error'] ?? 'Unknown error'}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text('${response?['error'] ?? 'Unknown error'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>> register(String username, String password, bool isAdmin) async {
  final response = await rpc.sendRequest(
    method: 'User->register',
    params: {
      'username': username,
      'password': password,
      'is_admin': isAdmin,
    },
    sessionKey: 'login',
    id: 4,
  );

  return response ?? {'status': 'error during request'};
}