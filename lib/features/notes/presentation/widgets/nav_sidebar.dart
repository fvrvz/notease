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
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          // Logo / Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  Text(
                    'NoteEase',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    isExpanded
                        ? Icons.menu_open_rounded
                        : Icons.menu_rounded,
                    size: 22,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.note_alt_outlined,
            label: 'All Notes',
            isExpanded: isExpanded,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.push_pin_outlined,
            label: 'Pinned',
            isExpanded: isExpanded,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            isExpanded: isExpanded,
            onTap: () {},
          ),
          const Spacer(),
          const Divider(height: 1),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Search',
            isExpanded: isExpanded,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isExpanded: isExpanded,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 16),
        ],
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
  });
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              if (isExpanded) ...[
                const SizedBox(width: 10),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
