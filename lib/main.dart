import 'package:flutter/material.dart';
import 'Screens/login_screen.dart'; 

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
        brightness: Brightness.dark, 
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212), 
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F), 
          titleTextStyle: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}