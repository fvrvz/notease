import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/core/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasSubtle;
    final surfaceColor = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 18, color: fgMuted),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: fgDefault,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              _SettingsSection(
                title: 'Appearance',
                description: 'Customize the application theme interface.',
                borderColor: borderColor,
                surfaceColor: surfaceColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interface Theme',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: fgDefault,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDark ? 'Dark mode enabled' : 'Light mode enabled',
                              style: TextStyle(fontSize: 12, color: fgMuted),
                            ),
                          ],
                        ),
                        _ThemeToggle(
                          isDark: isDark,
                          onToggle: () => ref.read(themeModeProvider.notifier).toggle(),
                          borderColor: borderColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _SettingsSection(
                title: 'Storage & Cloud Sync',
                description: 'Notes are saved locally on this machine. Connect a provider to sync.',
                borderColor: borderColor,
                surfaceColor: surfaceColor,
                children: [
                  _SyncProviderRow(
                    icon: Icons.add_to_drive_rounded,
                    name: 'Google Drive',
                    desc: 'Sync notes to personal Google Drive app folder',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                  Divider(height: 1, color: borderColor),
                  _SyncProviderRow(
                    icon: Icons.cloud_done_rounded,
                    name: 'Apple iCloud',
                    desc: 'iCloud Drive file sync for Apple devices',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                  Divider(height: 1, color: borderColor),
                  _SyncProviderRow(
                    icon: Icons.window_rounded,
                    name: 'Microsoft OneDrive',
                    desc: 'Synchronize notes with OneDrive personal/work',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                  Divider(height: 1, color: borderColor),
                  _SyncProviderRow(
                    icon: Icons.cloud_queue_rounded,
                    name: 'Dropbox',
                    desc: 'Save and synchronize markdown files in Dropbox',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _SettingsSection(
                title: 'About NoteEase',
                description: 'Minimal, cross-platform notes application.',
                borderColor: borderColor,
                surfaceColor: surfaceColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Version', style: TextStyle(fontSize: 13, color: fgDefault)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: fgMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.description,
    required this.borderColor,
    required this.surfaceColor,
    required this.children,
  });

  final String title;
  final String description;
  final Color borderColor;
  final Color surfaceColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fgDefault,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: fgMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.borderColor,
  });

  final bool isDark;
  final VoidCallback onToggle;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 14,
                color: isDark ? AppColors.accent : AppColors.accentLight,
              ),
              const SizedBox(width: 6),
              Text(
                isDark ? 'Dark' : 'Light',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncProviderRow extends StatelessWidget {
  const _SyncProviderRow({
    required this.icon,
    required this.name,
    required this.desc,
    required this.isDark,
    required this.borderColor,
  });

  final IconData icon;
  final String name;
  final String desc;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fgDefault,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11.5, color: fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
