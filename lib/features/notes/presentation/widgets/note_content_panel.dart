import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/data/repositories/note_repository.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';
import 'dart:async';

enum EditorMode { edit, split, preview }

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
  EditorMode _editorMode = EditorMode.edit;

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
    setState(() {}); // Immediate update for real-time markdown preview
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
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasDefault;
    final headerBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasSubtle;
    final noteColor = _currentNote != null
        ? _getNoteColor(_currentNote!.color)
        : (isDark ? AppColors.accent : AppColors.accentLight);

    return Container(
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radius),
              ),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Color Label Dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: noteColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                // Note Title Field
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    onChanged: (_) => _onChanged(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: 'Note title...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Mode Toggle: Write / Split / Preview
                _buildModeToggle(isDark, borderColor),
                const SizedBox(width: 8),
                _ColorPicker(
                  selected: _currentNote?.color ?? NoteColor.sage,
                  isDark: isDark,
                  borderColor: borderColor,
                  onColorSelected: (color) {
                    if (_currentNote != null) {
                      setState(() => _currentNote = _currentNote!.copyWith(color: color));
                      ref.read(notesNotifierProvider.notifier).updateNote(
                            _currentNote!.copyWith(color: color),
                          );
                    }
                  },
                ),
                const SizedBox(width: 6),
                _HeaderIconButton(
                  tooltip: _currentNote?.isPinned == true ? 'Unpin' : 'Pin',
                  icon: _currentNote?.isPinned == true
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  active: _currentNote?.isPinned == true,
                  isDark: isDark,
                  borderColor: borderColor,
                  onTap: () {
                    if (_currentNote != null) {
                      ref.read(notesNotifierProvider.notifier).togglePin(_currentNote!);
                      setState(() => _currentNote = _currentNote!.copyWith(
                            isPinned: !_currentNote!.isPinned,
                          ));
                    }
                  },
                ),
                const SizedBox(width: 6),
                _HeaderIconButton(
                  tooltip: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  isDanger: true,
                  isDark: isDark,
                  borderColor: borderColor,
                  onTap: () {
                    if (_currentNote != null) {
                      ref.read(notesNotifierProvider.notifier).deleteNote(_currentNote!.id);
                    }
                  },
                ),
              ],
            ),
          ),

          // Real-time Editor and/or Markdown Preview Body
          Expanded(
            child: _buildBodyContent(isDark, borderColor),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(bool isDark, Color borderColor) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeButton('Edit', EditorMode.edit, isDark),
          _modeButton('Split', EditorMode.split, isDark),
          _modeButton('Preview', EditorMode.preview, isDark),
        ],
      ),
    );
  }

  Widget _modeButton(String text, EditorMode mode, bool isDark) {
    final isSelected = _editorMode == mode;
    final fg = isSelected
        ? (isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault)
        : (isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted);
    final bg = isSelected
        ? (isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault)
        : Colors.transparent;

    return GestureDetector(
      onTap: () => setState(() => _editorMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radius - 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(bool isDark, Color borderColor) {
    final isCompact = MediaQuery.of(context).size.width < 900;

    if (_editorMode == EditorMode.preview) {
      return _buildMarkdownPreview(isDark);
    }

    if (_editorMode == EditorMode.split && !isCompact) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildRawEditor(isDark)),
          VerticalDivider(width: 1, thickness: 1, color: borderColor),
          Expanded(child: _buildMarkdownPreview(isDark)),
        ],
      );
    }

    // Default: Full raw editor
    return _buildRawEditor(isDark);
  }

  Widget _buildRawEditor(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        onChanged: (_) => _onChanged(),
        maxLines: null,
        expands: true,
        style: TextStyle(
          height: 1.6,
          fontSize: 13.5,
          fontFamily: 'monospace',
          color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
        ),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: '# Title\n\nWrite markdown here...\n- [ ] Task 1\n- [x] Task 2',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
            fontFamily: 'monospace',
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildMarkdownPreview(bool isDark) {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      return Center(
        child: Text(
          'Nothing to preview yet.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
          ),
        ),
      );
    }

    final mdStyleSheet = MarkdownStyleSheet(
      p: TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
      ),
      h1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
      ),
      h2: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
      ),
      h3: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
      ),
      code: TextStyle(
        fontSize: 12.5,
        fontFamily: 'monospace',
        backgroundColor: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
        color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault,
        ),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault,
            width: 3,
          ),
        ),
      ),
    );

    return Markdown(
      data: _contentController.text,
      styleSheet: mdStyleSheet,
      padding: const EdgeInsets.all(16),
      selectable: true,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.borderColor,
    this.tooltip,
    this.active = false,
    this.isDanger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color borderColor;
  final String? tooltip;
  final bool active;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final fgColor = isDanger
        ? const Color(0xFFE5534B)
        : (active
            ? (isDark ? AppColors.accent : AppColors.accentLight)
            : (isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted));

    final button = Material(
      color: active
          ? (isDark ? AppColors.accent.withValues(alpha: 0.15) : AppColors.accentLight.withValues(alpha: 0.12))
          : (isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasDefault),
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: active ? (isDark ? AppColors.accent : AppColors.accentLight) : borderColor,
              width: 1,
            ),
          ),
          child: Icon(icon, size: 14, color: fgColor),
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
    required this.borderColor,
  });

  final NoteColor selected;
  final void Function(NoteColor) onColorSelected;
  final bool isDark;
  final Color borderColor;

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

    final bgColor = isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasDefault;

    return PopupMenuButton<NoteColor>(
      tooltip: 'Change note color',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: BorderSide(color: borderColor),
      ),
      color: isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.firstWhere((c) => c.$1 == selected).$3,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
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
                'COLOR TINT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: colors.map((c) {
                  final isSelected = selected == c.$1;
                  return InkWell(
                    onTap: () {
                      onColorSelected(c.$1);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.$3.withValues(alpha: isSelected ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(
                          color: isSelected ? c.$3 : c.$3.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        c.$2,
                        style: TextStyle(
                          fontSize: 11,
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
