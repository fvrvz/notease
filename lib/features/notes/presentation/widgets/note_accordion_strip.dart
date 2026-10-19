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


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final surfaceColor = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;
    final textColor = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          width: _isHovered ? 48 : 34,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? color.withValues(alpha: isDark ? 0.2 : 0.12)
                : surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: _isHovered ? color : borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Colored dot badge indicator at top
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        widget.note.title.isEmpty ? 'Untitled' : widget.note.title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
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
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 11,
                    color: color,
                  ),
                )
              else
                const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
