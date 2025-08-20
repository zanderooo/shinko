import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF8B5CF6); // Deep purple
  static const _secondaryColor = Color(0xFFEC4899); // Pink
  static const _backgroundColor = Color(0xFF0F0F0F); // Almost black
  static const _surfaceColor = Color(0xFF1A1A1A); // Dark surface
  static const _cardColor = Color(0xFF262626); // Card background
  static const _errorColor = Color(0xFFF87171); // Light red
  static const _warningColor = Color(0xFFFBBF24); // Amber

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: _cardColor.withValues(alpha: 0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
        displayMedium: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        labelMedium: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardColor.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _cardColor.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get neonCardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withValues(alpha: 0.3),
            _secondaryColor.withValues(alpha: 0.2),
            _primaryColor.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _secondaryColor.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get streakCardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _warningColor.withValues(alpha: 0.4),
            Colors.orange.withValues(alpha: 0.3),
            _primaryColor.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _warningColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static const titleLarge = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5);
  static const titleMedium = TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: 0.25);
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: 0.5);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70, letterSpacing: 0.25);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54, letterSpacing: 0.4);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientAccent = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}