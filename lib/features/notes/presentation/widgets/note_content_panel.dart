import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/data/repositories/note_repository.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';
import 'dart:async';

class NoteContentPanel extends ConsumerStatefulWidget {
  const NoteContentPanel({super.key, required this.noteId});
  final String noteId;

  @override
  ConsumerState<NoteContentPanel> createState() => _NoteContentPanelState();
}

class _NoteContentPanelState extends ConsumerState<NoteContentPanel> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Timer? _debounce;
  Note? _currentNote;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadNote();
  }

  @override
  void didUpdateWidget(covariant NoteContentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteId != widget.noteId) {
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    final repo = ref.read(noteRepositoryProvider);
    final note = await repo.getNoteById(widget.noteId);
    if (note != null && mounted) {
      setState(() => _currentNote = note);
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (_currentNote != null) {
        ref.read(notesNotifierProvider.notifier).updateNote(
          _currentNote!.copyWith(
            title: _titleController.text,
            content: _contentController.text,
          ),
        );
      }
    });
  }

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
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasDefault;
    final headerBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasSubtle;
    final noteColor = _currentNote != null
        ? _getNoteColor(_currentNote!.color)
        : (isDark ? AppColors.accent : AppColors.accentLight);

    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Tag / Color Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: noteColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: noteColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: noteColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _currentNote?.color.name.toUpperCase() ?? 'NOTE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: noteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Note Title Input
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    onChanged: (_) => _onChanged(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Title your note...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _ColorPicker(
                  selected: _currentNote?.color ?? NoteColor.sage,
                  isDark: isDark,
                  onColorSelected: (color) {
                    if (_currentNote != null) {
                      setState(() => _currentNote = _currentNote!.copyWith(color: color));
                      ref.read(notesNotifierProvider.notifier).updateNote(
                            _currentNote!.copyWith(color: color),
                          );
                    }
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  tooltip: _currentNote?.isPinned == true ? 'Unpin note' : 'Pin note',
                  icon: _currentNote?.isPinned == true
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  active: _currentNote?.isPinned == true,
                  isDark: isDark,
                  onTap: () {
                    if (_currentNote != null) {
                      ref.read(notesNotifierProvider.notifier).togglePin(_currentNote!);
                      setState(() => _currentNote = _currentNote!.copyWith(
                            isPinned: !_currentNote!.isPinned,
                          ));
                    }
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  tooltip: 'Delete note',
                  icon: Icons.delete_outline_rounded,
                  isDanger: true,
                  isDark: isDark,
                  onTap: () {
                    if (_currentNote != null) {
                      ref.read(notesNotifierProvider.notifier).deleteNote(_currentNote!.id);
                    }
                  },
                ),
              ],
            ),
          ),

          // Note Meta & Timestamp strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: noteColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Auto-saved locally',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                  ),
                ),
                const Spacer(),
                if (_currentNote != null)
                  Text(
                    'Edited ${_formatDate(_currentNote!.updatedAt)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                    ),
                  ),
              ],
            ),
          ),

          // Main Note Editor Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: TextField(
                controller: _contentController,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                expands: true,
                style: TextStyle(
                  height: 1.65,
                  fontSize: 14.5,
                  color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Start writing your thoughts, markdown, or lists...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.tooltip,
    this.active = false,
    this.isDanger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String? tooltip;
  final bool active;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final fgColor = isDanger
        ? const Color(0xFFF85149)
        : (active
            ? (isDark ? AppColors.accent : AppColors.accentLight)
            : (isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted));

    final button = Material(
      color: active
          ? (isDark ? AppColors.accent.withValues(alpha: 0.15) : AppColors.accentLight.withValues(alpha: 0.12))
          : (isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasDefault),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? (isDark ? AppColors.accent : AppColors.accentLight) : borderColor,
              width: 1,
            ),
          ),
          child: Icon(icon, size: 16, color: fgColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selected,
    required this.onColorSelected,
    required this.isDark,
  });

  final NoteColor selected;
  final void Function(NoteColor) onColorSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const colors = [
      (NoteColor.sage, 'Sage', AppColors.noteSage),
      (NoteColor.sky, 'Sky', AppColors.noteSky),
      (NoteColor.lavender, 'Lavender', AppColors.noteLavender),
      (NoteColor.peach, 'Peach', AppColors.notePeach),
      (NoteColor.butter, 'Butter', AppColors.noteButter),
      (NoteColor.mint, 'Mint', AppColors.noteMint),
      (NoteColor.rose, 'Rose', AppColors.noteRose),
    ];

    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final bgColor = isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasDefault;

    return PopupMenuButton<NoteColor>(
      tooltip: 'Change note color',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      color: isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.firstWhere((c) => c.$1 == selected).$3,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted,
            ),
          ],
        ),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOTE COLOR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  final isSelected = selected == c.$1;
                  return InkWell(
                    onTap: () {
                      onColorSelected(c.$1);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.$3.withValues(alpha: isSelected ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? c.$3 : c.$3.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        c.$2,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: c.$3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
