import 'package:flutter/material.dart';

// Thème sombre de l'application mobile

class DarkThemeData {
  static ThemeData get darkThemeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF88D795)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF88D795),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 65, 65, 65),
      useMaterial3: true,
    );
  }
}