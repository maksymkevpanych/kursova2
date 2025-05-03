import 'package:flutter/material.dart';
import 'package:kursova2/Services/rpc_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kursova2/constants.dart';

final rpc = RpcService(url: apiUrl); 

Future<void> login(
  BuildContext context,
  String username,
  String password,
  Function onSuccess,
) async {
  final response = await rpc.sendRequest(
    method: 'User->login',
    params: {
      'username': username,
      'password': password,
    },
    sessionKey: 'login',
    id: 1,
  );

  if (response != null && response['result'] != null) {
    final sessionKey = response['result']['response'];
    print('Login success: $sessionKey');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_key', sessionKey);

    onSuccess();
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