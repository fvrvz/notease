import 'package:flutter/material.dart';
import 'package:notease/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final fgSubtle = isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Floating Icon with subtle glow
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                size: 26,
                color: accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No note selected',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click on any note strip along the sides to expand it, or create a brand new note to begin writing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: fgMuted,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.offline_pin_outlined,
                    size: 14,
                    color: fgSubtle,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stored locally • Offline ready',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: fgSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
