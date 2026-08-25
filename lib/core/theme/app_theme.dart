import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color cream = Color(0xFFFAF7F2);
  static const Color dustyRose = Color(0xFFE4C7BD);
  static const Color lightBeige = Color(0xFFF4EBE2);
  static const Color coffee = Color(0xFF704535);
  static const Color darkBrown = Color(0xFF2E1B12);
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color caramel = Color(0xFFD98543);
  static const Color errorRed = Color(0xFFD32F2F);

  // New Coffee UI Design System Tokens
  static const Color goldenAmber = Color(0xFFEE9F39);
  static const Color darkRoast = Color(0xFF28170F);
  static const Color cocoaBanner = Color(0xFF83543B);
  static const Color warmBeige = Color(0xFFF9F5EF);
  static const Color chipUnselected = Color(0xFFF5ECE4);
  static const Color cardBorder = Color(0xFFF2EADF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: coffee,
        primary: coffee,
        onPrimary: softWhite,
        secondary: caramel,
        onSecondary: softWhite,
        tertiary: dustyRose,
        onTertiary: darkBrown,
        surface: softWhite,
        onSurface: darkBrown,
        error: errorRed,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: coffee,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: coffee,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: coffee),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coffee,
          foregroundColor: softWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: coffee,
          side: const BorderSide(color: coffee, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coffee,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dustyRose.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coffee, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
      ),
      cardTheme: CardThemeData(
        color: softWhite,
        elevation: 2,
        shadowColor: darkBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: softWhite,
        selectedItemColor: coffee,
        unselectedItemColor: dustyRose,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
