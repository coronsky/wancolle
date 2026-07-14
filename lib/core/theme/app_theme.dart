import 'package:flutter/material.dart';

class AppTheme {
  static const ivory = Color(0xFFFFFCF5);
  static const beige = Color(0xFFE9D8C3);
  static const mint = Color(0xFFBFE5D6);
  static const dustyBlue = Color(0xFFAABDD6);
  static const pastelYellow = Color(0xFFF9E7A7);
  static const cocoa = Color(0xFF6F5F54);
  static const night = Color(0xFF28313D);

  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: mint,
      brightness: Brightness.light,
      primary: mint,
      secondary: dustyBlue,
      tertiary: pastelYellow,
      surface: ivory,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ivory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cocoa,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: cocoa,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cocoa,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: cocoa,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: cocoa,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: cocoa,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.62),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: dustyBlue.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: mint, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: cocoa, fontWeight: FontWeight.w600),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.82),
        indicatorColor: mint.withValues(alpha: 0.42),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: dustyBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: dustyBlue,
      brightness: Brightness.dark,
      primary: mint,
      secondary: dustyBlue,
      tertiary: pastelYellow,
      surface: night,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF1F252D),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF24303A),
        indicatorColor: mint.withValues(alpha: 0.2),
      ),
    );
  }
}
