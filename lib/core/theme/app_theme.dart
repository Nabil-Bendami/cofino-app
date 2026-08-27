import 'package:flutter/material.dart';

class AppTheme {
  // Coffee ordering UI: charcoal header, clean cards and warm orange actions.
  static const Color cream = Color(0xFFF7F7F7);
  static const Color dustyRose = Color(0xFFAAA39B);
  static const Color lightBeige = Color(0xFFF1F1F1);
  static const Color coffee = Color(0xFF4A3328);
  static const Color darkBrown = Color(0xFF242529);
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color caramel = Color(0xFFF58A14);
  static const Color errorRed = Color(0xFFD32F2F);

  static const Color goldenAmber = Color(0xFFF58A14);
  static const Color darkRoast = Color(0xFF2C2E33);
  static const Color cocoaBanner = Color(0xFF35373C);
  static const Color warmBeige = Color(0xFFF9F9F9);
  static const Color chipUnselected = Color(0xFFF1F1F1);
  static const Color cardBorder = Color(0xFFE9E9E9);
  static const Color mutedText = Color(0xFF8A8886);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldenAmber,
        primary: goldenAmber,
        onPrimary: softWhite,
        secondary: darkRoast,
        onSecondary: softWhite,
        tertiary: lightBeige,
        onTertiary: darkBrown,
        surface: softWhite,
        onSurface: darkBrown,
        error: errorRed,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: softWhite,
        foregroundColor: darkBrown,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkBrown,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkBrown),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldenAmber,
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
          foregroundColor: darkBrown,
          side: const BorderSide(color: darkBrown, width: 1.5),
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
          foregroundColor: goldenAmber,
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
          borderSide: const BorderSide(color: goldenAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
      ),
      cardTheme: CardThemeData(
        color: softWhite,
        elevation: 0,
        shadowColor: darkBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: softWhite,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? goldenAmber
                  : mutedText,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontSize: 12,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? goldenAmber
                  : mutedText,
            )),
      ),
    );
  }
}
