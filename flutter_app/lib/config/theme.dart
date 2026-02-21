import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF0D4A2D);
  static const Color lightGreen = Color(0xFF1A7A4A);
  static const Color accentGold = Color(0xFFC9A84C);
  static const Color lightGold = Color(0xFFE8C97A);
  static const Color cream = Color(0xFFF8F3E9);
  static const Color darkCream = Color(0xFFEDE7D8);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF4A4A6A);
  static const Color textLight = Color(0xFF8A8AAA);
  static const Color userBubble = Color(0xFF0D4A2D);
  static const Color assistantBubble = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF2E7D32);
  // Alias used in screens
  static const Color backgroundCream = cream;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: accentGold,
          surface: cream,
          background: cream,
        ),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: primaryGreen.withOpacity(0.1),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryGreen.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryGreen.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: textDark, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textMedium, fontSize: 16),
          bodyMedium: TextStyle(color: textMedium, fontSize: 14),
          labelLarge: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        ),
      );

  // Gradient decorations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, lightGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = LinearGradient(
    colors: [cream, darkCream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
