import 'package:flutter/material.dart';
import 'package:notease/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
  });

  final String? title;
  final String? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final fgSubtle = isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                icon ?? Icons.edit_note_rounded,
                size: 22,
                color: accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'No note selected',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Click on any note strip on the side to expand it, or create a new note.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: fgMuted,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Text(
                'Stored locally • Offline ready',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: fgSubtle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
