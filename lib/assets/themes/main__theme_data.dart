import 'package:flutter/material.dart';

// Thème clair de l'application mobile

class MainThemeData {
  static ThemeData get mainThemeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF88D795)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF88D795),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    );
  }
}