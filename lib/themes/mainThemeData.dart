import 'package:flutter/material.dart';

class MainThemeData {
  static ThemeData get mainThemeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }
}