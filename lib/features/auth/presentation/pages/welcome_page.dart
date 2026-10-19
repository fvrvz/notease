import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/core/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final surfaceColor = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasSubtle;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Scaffold(
      backgroundColor: canvasColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to NoteEase',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: fgDefault,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Minimal notes with cloud sync options.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: fgMuted,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Auth Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProviderSignInButton(
                          label: 'Continue with Google',
                          icon: Icons.g_mobiledata_rounded,
                          color: const Color(0xFF4285F4),
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 10),
                        _ProviderSignInButton(
                          label: 'Continue with Apple',
                          icon: Icons.apple_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 10),
                        _ProviderSignInButton(
                          label: 'Continue with Microsoft',
                          icon: Icons.window_rounded,
                          color: const Color(0xFF00A4EF),
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor, height: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or',
                                style: TextStyle(fontSize: 11.5, color: fgMuted),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor, height: 1)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Primary Action: Guest Mode
                        Material(
                          color: accent,
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          child: InkWell(
                            onTap: () => context.go('/'),
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radius),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'No account needed. Local storage by default.',
                    style: TextStyle(fontSize: 11.5, color: fgMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderSignInButton extends StatelessWidget {
  const _ProviderSignInButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: fgDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
