import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/core/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final surfaceColor = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault;
    final canvasColor = isDark ? GitHubColors.darkCanvasDefault : GitHubColors.lightCanvasSubtle;
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

    return Scaffold(
      backgroundColor: canvasColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GitHub Octocat-style Box Logo
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Icon(
                      Icons.terminal_rounded,
                      size: 28,
                      color: fgDefault,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sign in to NoteEase',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      color: fgDefault,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GitHub-style Authentication Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Google Button
                        _GitHubAuthButton(
                          label: 'Sign in with Google',
                          icon: Icons.g_mobiledata_rounded,
                          isPrimary: false,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 12),

                        // Microsoft Button
                        _GitHubAuthButton(
                          label: 'Sign in with Microsoft',
                          icon: Icons.window_rounded,
                          isPrimary: false,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 12),

                        // Apple Button
                        _GitHubAuthButton(
                          label: 'Sign in with Apple',
                          icon: Icons.apple_rounded,
                          isPrimary: false,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor, height: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or',
                                style: TextStyle(fontSize: 12, color: fgMuted),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor, height: 1)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // GitHub Green Primary Action: Guest Mode
                        _GitHubAuthButton(
                          label: 'Continue as Guest',
                          icon: Icons.person_outline_rounded,
                          isPrimary: true,
                          isDark: isDark,
                          borderColor: borderColor,
                          onTap: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No account required. ',
                          style: TextStyle(fontSize: 13, color: fgMuted),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Text(
                            'Start writing →',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _GitHubAuthButton extends StatelessWidget {
  const _GitHubAuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isDark,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      // GitHub green button
      return Material(
        color: GitHubColors.darkSuccessEmphasis,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Secondary Outline Button
    final bgColor = isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset;
    final fgColor = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
