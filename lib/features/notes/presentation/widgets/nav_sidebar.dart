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
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final surfaceColor = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasSubtle;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;

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
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          // App Logo & Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  Row(
                    children: [
                      // Sleek custom gradient app icon badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2F81F7), const Color(0xFF8957E5)]
                                : [const Color(0xFF0969DA), const Color(0xFF8250DF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? const Color(0xFF2F81F7) : const Color(0xFF0969DA))
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NoteEase',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: fgDefault,
                        ),
                      ),
                    ],
                  ),
                _SidebarToggleButton(
                  isExpanded: isExpanded,
                  onToggle: onToggle,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),

          // Workspace Section
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: fgMuted,
                ),
              ),
            ),
          _NavItem(
            icon: Icons.notes_rounded,
            label: 'All Notes',
            isExpanded: isExpanded,
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
          const SizedBox(height: 10),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isExpanded: isExpanded,
            isDark: isDark,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  const _SidebarToggleButton({
    required this.isExpanded,
    required this.onToggle,
    required this.isDark,
    required this.borderColor,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasDefault,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Icon(
            isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
            size: 16,
            color: isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted,
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
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isDark;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark
        ? AppColors.darkCanvasInset
        : AppColors.lightCanvasDefault;
    final fgColor = isSelected
        ? (isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault)
        : (isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted);
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: isSelected
                  ? Border.all(
                      color: isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault,
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? accent : fgColor,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: fgColor,
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
