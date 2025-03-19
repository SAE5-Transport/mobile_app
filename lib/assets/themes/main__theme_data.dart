import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Thème clair de l'application mobile

class MainThemeData {
  static ThemeData get mainThemeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF88D795)
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 51, 153, 68),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 51, 153, 68),
        unselectedItemColor: Colors.black,
      ),
      textTheme: TextTheme(
        displaySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        displayLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}