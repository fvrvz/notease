import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined modern palette using GitHub Primer's sophisticated canvas, surface, and text colors.
class AppColors {
  // Dark Canvas & Surfaces (Subtle contrast, elegant depth)
  static const darkCanvasDefault = Color(0xFF0D1117);
  static const darkCanvasSubtle = Color(0xFF161B22);
  static const darkCanvasInset = Color(0xFF090D12);
  static const darkBorderDefault = Color(0xFF30363D);
  static const darkBorderMuted = Color(0xFF21262D);
  static const darkFgDefault = Color(0xFFE6EDF3);
  static const darkFgMuted = Color(0xFF8D96A0);
  static const darkFgSubtle = Color(0xFF6E7681);

  // Light Canvas & Surfaces
  static const lightCanvasDefault = Color(0xFFFFFFFF);
  static const lightCanvasSubtle = Color(0xFFF6F8FA);
  static const lightCanvasInset = Color(0xFFEEF1F5);
  static const lightBorderDefault = Color(0xFFD0D7DE);
  static const lightBorderMuted = Color(0xFFE1E4E8);
  static const lightFgDefault = Color(0xFF1F2328);
  static const lightFgMuted = Color(0xFF656D76);
  static const lightFgSubtle = Color(0xFF8C959F);

  // Primary brand accent (Clean electric blue with smooth tint)
  static const accent = Color(0xFF2F81F7);
  static const accentLight = Color(0xFF0969DA);

  // Clean note label tint colors
  static const noteSage = Color(0xFF2EA043);
  static const noteSky = Color(0xFF2F81F7);
  static const noteLavender = Color(0xFF8957E5);
  static const notePeach = Color(0xFFE5534B);
  static const noteButter = Color(0xFFD29922);
  static const noteMint = Color(0xFF1B7C83);
  static const noteRose = Color(0xFFDB61A2);

  static const List<Color> noteColors = [
    noteSage,
    noteSky,
    noteLavender,
    notePeach,
    noteButter,
    noteMint,
    noteRose,
  ];
}

class AppTheme {
  static const double cardRadius = 14.0;
  static const double buttonRadius = 10.0;
  static const double pillRadius = 20.0;

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      AppColors.darkFgDefault,
      AppColors.darkFgMuted,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvasDefault,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkCanvasSubtle,
        surfaceContainerHighest: AppColors.darkCanvasInset,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        onSurface: AppColors.darkFgDefault,
        outline: AppColors.darkBorderDefault,
        outlineVariant: AppColors.darkBorderMuted,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkCanvasSubtle,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.darkBorderMuted, width: 1),
        ),
      ),
      dividerColor: AppColors.darkBorderMuted,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderMuted,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkFgMuted,
        size: 18,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      AppColors.lightFgDefault,
      AppColors.lightFgMuted,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightCanvasSubtle,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightCanvasDefault,
        surfaceContainerHighest: AppColors.lightCanvasInset,
        primary: AppColors.accentLight,
        onPrimary: Colors.white,
        onSurface: AppColors.lightFgDefault,
        outline: AppColors.lightBorderDefault,
        outlineVariant: AppColors.lightBorderMuted,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightCanvasDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.lightBorderDefault, width: 1),
        ),
      ),
      dividerColor: AppColors.lightBorderMuted,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderMuted,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightFgMuted,
        size: 18,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: primary,
        fontSize: 15,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: primary,
        fontSize: 13.5,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: muted,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: muted,
        fontSize: 12,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: muted,
        fontSize: 11,
      ),
    );
  }
}
