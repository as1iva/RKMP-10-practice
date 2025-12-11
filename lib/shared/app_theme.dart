import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFEE7F30),
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.comfortaa(
            fontSize: 57, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.comfortaa(
            fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.comfortaa(
            fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.comfortaa(
            fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.comfortaa(
            fontSize: 28, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.comfortaa(
            fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.comfortaa(
            fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.comfortaa(
            fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.comfortaa(
            fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.comfortaa(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFEE7F30),
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.comfortaa(
            fontSize: 57, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.comfortaa(
            fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.comfortaa(
            fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.comfortaa(
            fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.comfortaa(
            fontSize: 28, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.comfortaa(
            fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.comfortaa(
            fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.comfortaa(
            fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.comfortaa(
            fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.comfortaa(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
