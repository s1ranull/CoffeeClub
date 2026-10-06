import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CoffeeClubApp());
}

class CoffeeClubApp extends StatelessWidget {
  const CoffeeClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoffeeClub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
} 