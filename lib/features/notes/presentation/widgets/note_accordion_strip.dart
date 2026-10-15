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

  static const double _stripWidth = 40.0;

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
                      delay: Duration(milliseconds: entry.key * 50),
                      duration: 200.ms,
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

  Color get _noteColor {
    const map = {
      NoteColor.sage: AppColors.noteSage,
      NoteColor.lavender: AppColors.noteLavender,
      NoteColor.peach: AppColors.notePeach,
      NoteColor.sky: AppColors.noteSky,
      NoteColor.butter: AppColors.noteButter,
      NoteColor.mint: AppColors.noteMint,
      NoteColor.rose: AppColors.noteRose,
    };
    return map[widget.note.color] ?? AppColors.noteSage;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _isHovered ? 52 : 40,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
          decoration: BoxDecoration(
            color: _noteColor.withOpacity(_isHovered ? 0.95 : 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _noteColor.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _noteColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.note.title.isEmpty ? 'Untitled' : widget.note.title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
