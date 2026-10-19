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
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
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
          icon: Icon(Icons.arrow_back_rounded, size: 20, color: fgMuted),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: fgDefault,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // Appearance Section
          _SettingsSection(
            title: 'Appearance',
            description: 'Customize the application theme style.',
            borderColor: borderColor,
            surfaceColor: surfaceColor,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interface Theme',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: fgDefault,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDark ? 'Dark theme enabled' : 'Light theme enabled',
                          style: TextStyle(fontSize: 12.5, color: fgMuted),
                        ),
                      ],
                    ),
                    _ThemeTogglePill(
                      isDark: isDark,
                      onToggle: () => ref.read(themeModeProvider.notifier).toggle(),
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cloud Sync Section
          _SettingsSection(
            title: 'Storage & Cloud Sync',
            description: 'Notes are saved locally on this device. Connect a provider to sync across platforms.',
            borderColor: borderColor,
            surfaceColor: surfaceColor,
            children: [
              _SyncProviderItem(
                icon: Icons.add_to_drive_rounded,
                name: 'Google Drive',
                desc: 'Sync notes to your personal Google Drive app folder',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderItem(
                icon: Icons.cloud_done_rounded,
                name: 'Apple iCloud',
                desc: 'Native iCloud Drive synchronization for Apple devices',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderItem(
                icon: Icons.window_rounded,
                name: 'Microsoft OneDrive',
                desc: 'Keep notes synchronized with OneDrive cloud',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderItem(
                icon: Icons.cloud_queue_rounded,
                name: 'Dropbox',
                desc: 'Save and synchronize markdown files in Dropbox',
                isDark: isDark,
                borderColor: borderColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _SettingsSection(
            title: 'About NoteEase',
            description: 'Minimal, cross-platform notes application.',
            borderColor: borderColor,
            surfaceColor: surfaceColor,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: TextStyle(fontSize: 13.5, color: fgDefault)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 12,
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
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: fgDefault,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: fgMuted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeTogglePill extends StatelessWidget {
  const _ThemeTogglePill({
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 15,
                color: isDark ? AppColors.accent : AppColors.accentLight,
              ),
              const SizedBox(width: 8),
              Text(
                isDark ? 'Dark Mode' : 'Light Mode',
                style: TextStyle(
                  fontSize: 12.5,
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

class _SyncProviderItem extends StatelessWidget {
  const _SyncProviderItem({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: fgDefault,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 12,
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
