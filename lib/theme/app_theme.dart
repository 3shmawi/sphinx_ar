import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colours — deep lapis lazuli + gold
  static const Color primaryGold = Color(0xFFD4A017);
  static const Color lightGold = Color(0xFFF5C842);
  static const Color darkGold = Color(0xFF8B6914);
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF161622);
  static const Color surfaceVariant = Color(0xFF1E1E2E);
  static const Color onSurface = Color(0xFFE8E0D0);
  static const Color onSurfaceDim = Color(0xFF9E9787);
  static const Color accentTeal = Color(0xFF3DDBD9);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: Color(0xFF1A1200),
        secondary: accentTeal,
        surface: surface,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: primaryGold, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: primaryGold, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: onSurface),
          bodyMedium: TextStyle(color: onSurfaceDim),
          labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cinzel(
          color: primaryGold,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: primaryGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: const Color(0xFF1A1200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
