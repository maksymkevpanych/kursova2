import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpc_service.dart';
import 'warehouses_screen.dart'; // новий екран

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPC Login Demo',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final rpc = RpcService(url: 'http://localhost/kursach/index.php');

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

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

      // Перехід на новий екран
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WarehousesScreen()),
        );
      }
    } else {
      print('Login failed: ${response?['error'] ?? 'Unknown error'}');

      // Показати помилку
      if (context.mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
