import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark theme
  static const darkBackground = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF141418);
  static const darkSurface2 = Color(0xFF1E1E25);
  static const darkBorder = Color(0xFF2A2A35);
  static const darkText = Color(0xFFE8E7E4);
  static const darkTextMuted = Color(0xFF888898);

  // Light theme
  static const lightBackground = Color(0xFFF8F7F4);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF0EEE9);
  static const lightBorder = Color(0xFFE5E3DC);
  static const lightText = Color(0xFF1A1A1A);
  static const lightTextMuted = Color(0xFF7A7A7A);

  // Accent
  static const accent = Color(0xFF7B6EF6);
  static const accentLight = Color(0xFF9F95F8);

  // Note colors
  static const noteSage = Color(0xFFB5C9B7);
  static const noteLavender = Color(0xFFC4B5D6);
  static const notePeach = Color(0xFFF0C5B3);
  static const noteSky = Color(0xFFB3CDE8);
  static const noteButter = Color(0xFFEDE4A6);
  static const noteMint = Color(0xFFB5D6C9);
  static const noteRose = Color(0xFFE8B5C4);

  static const List<Color> noteColors = [
    noteSage,
    noteLavender,
    notePeach,
    noteSky,
    noteButter,
    noteMint,
    noteRose,
  ];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        onBackground: AppColors.darkText,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextMuted),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextMuted, size: 20),
      dividerColor: AppColors.darkBorder,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        onBackground: AppColors.lightText,
        onSurface: AppColors.lightText,
        outline: AppColors.lightBorder,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextMuted),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextMuted, size: 20),
      dividerColor: AppColors.lightBorder,
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primary, fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(color: primary, fontWeight: FontWeight.w700),
      headlineLarge: base.headlineLarge?.copyWith(color: primary, fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: muted),
      labelLarge: base.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w500),
      labelMedium: base.labelMedium?.copyWith(color: muted),
      labelSmall: base.labelSmall?.copyWith(color: muted),
    );
  }
}
