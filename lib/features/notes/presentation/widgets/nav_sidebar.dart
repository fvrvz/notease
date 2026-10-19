import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/core/theme/app_theme.dart';

class NavSidebar extends ConsumerWidget {
  const NavSidebar({super.key, required this.isExpanded, required this.onToggle});
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final surfaceColor = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasSubtle;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 12),
          // GitHub header / branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  Row(
                    children: [
                      // GitHub-style Octocat / App Icon
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasDefault,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 15,
                          color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NoteEase',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
                        ),
                      ),
                    ],
                  ),
                _GitHubSidebarToggle(
                  isExpanded: isExpanded,
                  onToggle: onToggle,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 8),

          // GitHub Nav Item Section
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'NOTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                ),
              ),
            ),
          _NavItem(
            icon: Icons.notes_rounded,
            label: 'All Notes',
            isExpanded: isExpanded,
            badge: 'active',
            isSelected: true,
            isDark: isDark,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.push_pin_outlined,
            label: 'Pinned',
            isExpanded: isExpanded,
            isDark: isDark,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            isExpanded: isExpanded,
            isDark: isDark,
            onTap: () {},
          ),

          const Spacer(),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isExpanded: isExpanded,
            isDark: isDark,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _GitHubSidebarToggle extends StatelessWidget {
  const _GitHubSidebarToggle({
    required this.isExpanded,
    required this.onToggle,
    required this.isDark,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Icon(
            isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
            size: 16,
            color: fgMuted,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    required this.isDark,
    this.badge,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isDark;
  final String? badge;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset;
    final fgColor = isSelected
        ? (isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault)
        : (isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                      color: isDark ? GitHubColors.darkBorderMuted : GitHubColors.lightBorderMuted,
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: fgColor),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: fgColor,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? GitHubColors.darkBorderMuted : GitHubColors.lightBorderMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
