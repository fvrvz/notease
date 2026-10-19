import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GitHub Primer Design System tokens & palette
class GitHubColors {
  // Dark mode (GitHub Dark default)
  static const darkCanvasDefault = Color(0xFF0D1117);
  static const darkCanvasSubtle = Color(0xFF161B22);
  static const darkCanvasInset = Color(0xFF010409);
  static const darkBorderDefault = Color(0xFF30363D);
  static const darkBorderMuted = Color(0xFF21262D);
  static const darkFgDefault = Color(0xFFE6EDF3);
  static const darkFgMuted = Color(0xFF8D96A0);
  static const darkFgSubtle = Color(0xFF6E7681);
  static const darkAccentFg = Color(0xFF2F81F7);
  static const darkAccentEmphasis = Color(0xFF1F6FEB);
  static const darkSuccessFg = Color(0xFF3FB950);
  static const darkSuccessEmphasis = Color(0xFF238636);
  static const darkAttentionFg = Color(0xFFD29922);
  static const darkDangerFg = Color(0xFFF85149);

  // Light mode (GitHub Light default)
  static const lightCanvasDefault = Color(0xFFFFFFFF);
  static const lightCanvasSubtle = Color(0xFFF6F8FA);
  static const lightCanvasInset = Color(0xFFEFF2F5);
  static const lightBorderDefault = Color(0xFFD0D7DE);
  static const lightBorderMuted = Color(0xFFD8DEE4);
  static const lightFgDefault = Color(0xFF1F2328);
  static const lightFgMuted = Color(0xFF656D76);
  static const lightFgSubtle = Color(0xFF8C959F);
  static const lightAccentFg = Color(0xFF0969DA);
  static const lightAccentEmphasis = Color(0xFF0969DA);
  static const lightSuccessFg = Color(0xFF1A7F37);
  static const lightSuccessEmphasis = Color(0xFF1F883D);
  static const lightAttentionFg = Color(0xFF9A6700);
  static const lightDangerFg = Color(0xFFCF222E);

  // GitHub badge / label pastel hues for notes
  // Dark variants
  static const darkNoteGreen = Color(0xFF238636);
  static const darkNoteBlue = Color(0xFF1F6FEB);
  static const darkNotePurple = Color(0xFF8957E5);
  static const darkNoteOrange = Color(0xFFBD561D);
  static const darkNoteYellow = Color(0xFF9E6A03);
  static const darkNoteTeal = Color(0xFF1B7C83);
  static const darkNotePink = Color(0xFFBF4B8A);

  // Light variants
  static const lightNoteGreen = Color(0xFFDAFBE1);
  static const lightNoteBlue = Color(0xFFDDF4FF);
  static const lightNotePurple = Color(0xFFFBEFFF);
  static const lightNoteOrange = Color(0xFFFFEBD9);
  static const lightNoteYellow = Color(0xFFFFF8C5);
  static const lightNoteTeal = Color(0xFFDCF6F9);
  static const lightNotePink = Color(0xFFFFEFF7);
}

class AppColors {
  // Legacy accessors mapped to GitHub design tokens
  static const darkBackground = GitHubColors.darkCanvasDefault;
  static const darkSurface = GitHubColors.darkCanvasSubtle;
  static const darkSurface2 = GitHubColors.darkCanvasInset;
  static const darkBorder = GitHubColors.darkBorderDefault;
  static const darkText = GitHubColors.darkFgDefault;
  static const darkTextMuted = GitHubColors.darkFgMuted;

  static const lightBackground = GitHubColors.lightCanvasSubtle;
  static const lightSurface = GitHubColors.lightCanvasDefault;
  static const lightSurface2 = GitHubColors.lightCanvasInset;
  static const lightBorder = GitHubColors.lightBorderDefault;
  static const lightText = GitHubColors.lightFgDefault;
  static const lightTextMuted = GitHubColors.lightFgMuted;

  // GitHub Primer Primary Blue & Green
  static const accent = GitHubColors.darkAccentFg;
  static const accentLight = GitHubColors.lightAccentFg;
  static const gitHubGreen = GitHubColors.darkSuccessEmphasis;

  // Note colors with subtle GitHub-style badges
  static const noteSage = Color(0xFF2EA043);
  static const noteLavender = Color(0xFF8957E5);
  static const notePeach = Color(0xFFBD561D);
  static const noteSky = Color(0xFF2F81F7);
  static const noteButter = Color(0xFFD29922);
  static const noteMint = Color(0xFF1B7C83);
  static const noteRose = Color(0xFFDB61A2);

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
    final textTheme = _buildTextTheme(
      GitHubColors.darkFgDefault,
      GitHubColors.darkFgMuted,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GitHubColors.darkCanvasDefault,
      colorScheme: const ColorScheme.dark(
        surface: GitHubColors.darkCanvasSubtle,
        surfaceContainerHighest: GitHubColors.darkCanvasInset,
        primary: GitHubColors.darkAccentFg,
        onPrimary: Colors.white,
        onSurface: GitHubColors.darkFgDefault,
        outline: GitHubColors.darkBorderDefault,
        outlineVariant: GitHubColors.darkBorderMuted,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: GitHubColors.darkCanvasSubtle,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: GitHubColors.darkBorderDefault, width: 1),
        ),
      ),
      dividerColor: GitHubColors.darkBorderDefault,
      dividerTheme: const DividerThemeData(
        color: GitHubColors.darkBorderDefault,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GitHubColors.darkCanvasInset,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.darkBorderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.darkBorderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.darkAccentFg, width: 2),
        ),
        hintStyle: const TextStyle(
          color: GitHubColors.darkFgSubtle,
          fontSize: 13,
        ),
      ),
      iconTheme: const IconThemeData(
        color: GitHubColors.darkFgMuted,
        size: 16,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      GitHubColors.lightFgDefault,
      GitHubColors.lightFgMuted,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: GitHubColors.lightCanvasSubtle,
      colorScheme: const ColorScheme.light(
        surface: GitHubColors.lightCanvasDefault,
        surfaceContainerHighest: GitHubColors.lightCanvasInset,
        primary: GitHubColors.lightAccentFg,
        onPrimary: Colors.white,
        onSurface: GitHubColors.lightFgDefault,
        outline: GitHubColors.lightBorderDefault,
        outlineVariant: GitHubColors.lightBorderMuted,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: GitHubColors.lightCanvasDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: GitHubColors.lightBorderDefault, width: 1),
        ),
      ),
      dividerColor: GitHubColors.lightBorderDefault,
      dividerTheme: const DividerThemeData(
        color: GitHubColors.lightBorderDefault,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GitHubColors.lightCanvasDefault,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.lightBorderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.lightBorderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: GitHubColors.lightAccentFg, width: 2),
        ),
        hintStyle: const TextStyle(
          color: GitHubColors.lightFgSubtle,
          fontSize: 13,
        ),
      ),
      iconTheme: const IconThemeData(
        color: GitHubColors.lightFgMuted,
        size: 16,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    // GitHub uses -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif
    // GoogleFonts.inter / noto sans matches this with high fidelity
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: primary,
        fontSize: 14,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: primary,
        fontSize: 13,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: muted,
        fontSize: 12,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
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
