import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightBg = Color(0xFFECEEF2);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E6EE);
  static const Color lightDarkCard = Color(0xFF141519);
  static const Color lightPillActive = Color(0xFF141519);
  static const Color lightPillInactive = Color(0xFFE2E6EF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0D0E12);
  static const Color darkCard = Color(0xFF17181F);
  static const Color darkCardBorder = Color(0xFF242630);
  static const Color darkAccentPill = Color(0xFFD9C3A3); // Warm Bronze / Gold accent
  static const Color darkPillActive = Color(0xFF262833);
  static const Color darkPillInactive = Color(0xFF1D1E26);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8F94A0);

  // Shared Accent Colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGold = Color(0xFFF59E0B);

  // Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: lightPillActive,
        secondary: accentGold,
        surface: lightCard,
        onSurface: lightTextPrimary,
        error: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: lightCardBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPillActive,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: darkAccentPill,
        secondary: darkAccentPill,
        surface: darkCard,
        onSurface: darkTextPrimary,
        error: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: darkCardBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccentPill,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // Soft Capsule Card Decoration helper
  static BoxDecoration capsuleCardDecoration(BuildContext context, {bool isDarkCard = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDarkCard) {
      return BoxDecoration(
        color: lightDarkCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      );
    }

    return BoxDecoration(
      color: isDark ? darkCard : lightCard,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isDark ? darkCardBorder : lightCardBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? const Color(0x40000000) : const Color(0x0A000000),
          blurRadius: 18,
          offset: const Offset(0, 6),
        )
      ],
    );
  }
}
