import 'package:flutter/material.dart';
import 'package:notease/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final canvasColor = isDark ? GitHubColors.darkCanvasDefault : GitHubColors.lightCanvasDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;
    final fgSubtle = isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GitHub Blankslate Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 24,
                color: fgMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No note selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an existing note from the tabs on the left/right or click the "New note" button to start writing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: fgMuted,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                'Tip: Notes are saved locally and ready to sync',
                style: TextStyle(
                  fontSize: 11,
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
