import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/domain/models/note.dart';

class NoteAccordionStrip extends StatelessWidget {
  const NoteAccordionStrip({
    super.key,
    required this.notes,
    required this.isLeft,
    required this.onNoteSelected,
    this.selectedId,
  });

  final List<Note> notes;
  final bool isLeft;
  final void Function(String id) onNoteSelected;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    // Show up to 4 note strips (160px) before scrolling horizontally
    final stripWidth = math.min(notes.length * 40.0, 160.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: stripWidth,
      ),
      child: SizedBox(
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
                      isSelected: entry.value.id == selectedId,
                      onTap: () => onNoteSelected(entry.value.id),
                    ))
                .toList(),
          ),
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
    this.isSelected = false,
  });

  final Note note;
  final int index;
  final bool isLeft;
  final VoidCallback onTap;
  final bool isSelected;

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

    return Tooltip(
      message: widget.isSelected
          ? 'Active Note: Click to collapse'
          : (widget.note.title.isEmpty ? 'Untitled note' : widget.note.title),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: 36,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: (widget.isSelected || _isHovered)
                  ? color.withValues(alpha: isDark ? 0.26 : 0.18)
                  : surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(
                color: widget.isSelected ? color : (_isHovered ? color : borderColor),
                width: widget.isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                // Colored dot badge or collapse icon
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 6),
                  child: widget.isSelected
                      ? Icon(
                          Icons.unfold_less_rounded,
                          size: 13,
                          color: color,
                        )
                      : Container(
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
                            fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: (_isHovered || widget.isSelected)
                                ? (isDark ? Colors.white : const Color(0xFF1F2328))
                                : textColor,
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
      ),
    );
  }
}
