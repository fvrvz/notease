import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/core/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
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
            padding: const EdgeInsets.all(28),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient Note App Icon
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2F81F7), const Color(0xFF8957E5)]
                            : [const Color(0xFF0969DA), const Color(0xFF8250DF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? const Color(0xFF2F81F7) : const Color(0xFF0969DA))
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to NoteEase',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: fgDefault,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimal notes with multi-provider cloud sync.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: fgMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Authentication card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                        const SizedBox(height: 12),
                        _ProviderSignInButton(
                          label: 'Continue with Apple',
                          icon: Icons.apple_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 12),
                        _ProviderSignInButton(
                          label: 'Continue with Microsoft',
                          icon: Icons.window_rounded,
                          color: const Color(0xFF00A4EF),
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor, height: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(fontSize: 12, color: fgMuted),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor, height: 1)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Primary Accent Action: Continue as Guest
                        Material(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => context.go('/'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      fontSize: 14,
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

                  const SizedBox(height: 20),
                  Text(
                    'No login required. Local offline storage by default.',
                    style: TextStyle(fontSize: 12, color: fgMuted),
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
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
