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
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final canvasColor = isDark ? GitHubColors.darkCanvasDefault : GitHubColors.lightCanvasSubtle;
    final surfaceColor = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault;
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fgDefault,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // GitHub Repository Settings Section Box
          _GitHubSection(
            title: 'Appearance',
            description: 'Choose your default theme interface mode.',
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
                          'Theme preference',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: fgDefault,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDark ? 'GitHub Dark mode active' : 'GitHub Light mode active',
                          style: TextStyle(fontSize: 12, color: fgMuted),
                        ),
                      ],
                    ),
                    _GitHubThemeToggle(
                      isDark: isDark,
                      onToggle: () => ref.read(themeModeProvider.notifier).toggle(),
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _GitHubSection(
            title: 'Storage & Sync',
            description: 'Local guest storage is currently active. Connect a cloud provider to sync.',
            borderColor: borderColor,
            surfaceColor: surfaceColor,
            children: [
              _SyncProviderRow(
                name: 'Google Drive',
                desc: 'Sync notes JSON to your personal Google Drive app data.',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderRow(
                name: 'iCloud (Apple)',
                desc: 'Seamless sync across macOS and iOS devices.',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderRow(
                name: 'Microsoft OneDrive',
                desc: 'Store notes inside your personal or work OneDrive.',
                isDark: isDark,
                borderColor: borderColor,
              ),
              Divider(height: 1, color: borderColor),
              _SyncProviderRow(
                name: 'Dropbox',
                desc: 'Direct file synchronization to Dropbox/Apps/NoteEase.',
                isDark: isDark,
                borderColor: borderColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _GitHubSection(
            title: 'About NoteEase',
            description: 'Cross-platform notes client inspired by GitHub Primer UI.',
            borderColor: borderColor,
            surfaceColor: surfaceColor,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: TextStyle(fontSize: 13, color: fgDefault)),
                    Text('v1.0.0 (Primer)', style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: fgMuted)),
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

class _GitHubSection extends StatelessWidget {
  const _GitHubSection({
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
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: fgDefault,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: fgMuted,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _GitHubThemeToggle extends StatelessWidget {
  const _GitHubThemeToggle({
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
      color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 14,
                color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
              ),
              const SizedBox(width: 6),
              Text(
                isDark ? 'Dark' : 'Light',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
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
    required this.name,
    required this.desc,
    required this.isDark,
    required this.borderColor,
  });

  final String name;
  final String desc;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // GitHub style outline secondary button
          Material(
            color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg,
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
