import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/domain/models/note.dart';

class NoteAccordionStrip extends StatelessWidget {
  const NoteAccordionStrip({
    super.key,
    required this.notes,
    required this.isLeft,
    required this.onNoteSelected,
  });

  final List<Note> notes;
  final bool isLeft;
  final void Function(String id) onNoteSelected;

  static const double _stripWidth = 36.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: notes.length * _stripWidth,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: notes
            .asMap()
            .entries
            .map((entry) => _NoteStrip(
                  note: entry.value,
                  index: entry.key,
                  isLeft: isLeft,
                  onTap: () => onNoteSelected(entry.value.id),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: entry.key * 35),
                      duration: 180.ms,
                    ))
            .toList(),
      ),
    );
  }
}

class _NoteStrip extends StatefulWidget {
  const _NoteStrip({
    required this.note,
    required this.index,
    required this.isLeft,
    required this.onTap,
  });

  final Note note;
  final int index;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  State<_NoteStrip> createState() => _NoteStripState();
}

class _NoteStripState extends State<_NoteStrip> {
  bool _isHovered = false;

  Color _getBadgeColor(NoteColor color, bool isDark) {
    if (isDark) {
      switch (color) {
        case NoteColor.sage:
          return GitHubColors.darkNoteGreen;
        case NoteColor.sky:
          return GitHubColors.darkNoteBlue;
        case NoteColor.lavender:
          return GitHubColors.darkNotePurple;
        case NoteColor.peach:
          return GitHubColors.darkNoteOrange;
        case NoteColor.butter:
          return GitHubColors.darkNoteYellow;
        case NoteColor.mint:
          return GitHubColors.darkNoteTeal;
        case NoteColor.rose:
          return GitHubColors.darkNotePink;
      }
    } else {
      switch (color) {
        case NoteColor.sage:
          return const Color(0xFF1A7F37);
        case NoteColor.sky:
          return const Color(0xFF0969DA);
        case NoteColor.lavender:
          return const Color(0xFF8250DF);
        case NoteColor.peach:
          return const Color(0xFFBC4C00);
        case NoteColor.butter:
          return const Color(0xFF9A6700);
        case NoteColor.mint:
          return const Color(0xFF1B7C83);
        case NoteColor.rose:
          return const Color(0xFFBF3989);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = _getBadgeColor(widget.note.color, isDark);
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final surfaceColor = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault;
    final textColor = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          width: _isHovered ? 46 : 34,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 1),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset)
                : surfaceColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered ? badgeColor : borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Colored dot badge at top (like git commit/tag status)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.note.title.isEmpty ? 'Untitled' : widget.note.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                          color: _isHovered ? badgeColor : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
