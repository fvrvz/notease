import 'package:flutter/material.dart';
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

  static const double _stripWidth = 42.0;

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

  Color _getNoteColor(NoteColor color) {
    switch (color) {
      case NoteColor.sage:
        return AppColors.noteSage;
      case NoteColor.sky:
        return AppColors.noteSky;
      case NoteColor.lavender:
        return AppColors.noteLavender;
      case NoteColor.peach:
        return AppColors.notePeach;
      case NoteColor.butter:
        return AppColors.noteButter;
      case NoteColor.mint:
        return AppColors.noteMint;
      case NoteColor.rose:
        return AppColors.noteRose;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getNoteColor(widget.note.color);
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final surfaceColor = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;
    final textColor = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: _isHovered ? 52 : 38,
          margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? color.withValues(alpha: isDark ? 0.22 : 0.16)
                : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? color.withValues(alpha: 0.6) : borderColor,
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              // Colored dot badge indicator at top
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
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
                          fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: -0.2,
                          color: _isHovered ? color : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.note.isPinned)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 11,
                    color: color,
                  ),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
