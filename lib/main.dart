import 'package:flutter/material.dart';
import 'login_screen.dart'; // Імпортуємо екран входу

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPC Login Demo',
      theme: ThemeData(
        brightness: Brightness.dark, // Темний режим
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212), // Темний фон
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F), // Темний фон AppBar
          titleTextStyle: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginScreen(), // Використовуємо екран входу
    );
  }
}