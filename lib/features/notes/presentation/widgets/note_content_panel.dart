import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/data/repositories/note_repository.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';
import 'package:notease/features/notes/presentation/widgets/markdown_controller.dart';
import 'dart:async';

class NoteContentPanel extends ConsumerStatefulWidget {
  const NoteContentPanel({
    super.key,
    required this.noteId,
    this.onCollapse,
  });

  final String noteId;
  final VoidCallback? onCollapse;

  @override
  ConsumerState<NoteContentPanel> createState() => _NoteContentPanelState();
}

class _NoteContentPanelState extends ConsumerState<NoteContentPanel> {
  late TextEditingController _titleController;
  late MarkdownSyntaxTextEditingController _contentController;
  Timer? _debounce;
  Note? _currentNote;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = MarkdownSyntaxTextEditingController(isDark: true);
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
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
    _contentController.updateTheme(isDark);
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final canvasColor = isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasDefault;
    final headerBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasSubtle;
    final noteColor = _currentNote != null
        ? _getNoteColor(_currentNote!.color)
        : (isDark ? AppColors.accent : AppColors.accentLight);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (widget.onCollapse != null) {
            widget.onCollapse!();
          } else {
            ref.read(selectedNoteIdProvider.notifier).state = null;
          }
        },
      },
      child: Container(
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radius),
                ),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showFormatting = constraints.maxWidth >= 540;
                  return Row(
                    children: [
                      // Collapse / Toggle Note Button
                      Tooltip(
                        message: 'Collapse note (Esc)',
                        child: InkWell(
                          onTap: () {
                            if (widget.onCollapse != null) {
                              widget.onCollapse!();
                            } else {
                              ref.read(selectedNoteIdProvider.notifier).state = null;
                            }
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          child: Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                              color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Note Color Dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: noteColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 10),
                    // Title Field
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        onChanged: (_) => _onChanged(),
                        style: TextStyle(
                          fontSize: 15,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick Markdown Formatting Buttons (shown when width permits)
                    if (showFormatting) ...[
                      _QuickFormatBar(
                        controller: _contentController,
                        isDark: isDark,
                        borderColor: borderColor,
                      ),
                      const SizedBox(width: 8),
                    ],
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
                    const SizedBox(width: 4),
                    _HeaderIconButton(
                      tooltip: _isPreviewMode ? 'Switch to Edit' : 'Preview Note',
                      icon: _isPreviewMode
                          ? Icons.edit_outlined
                          : Icons.visibility_outlined,
                      active: _isPreviewMode,
                      isDark: isDark,
                      borderColor: borderColor,
                      onTap: () {
                        setState(() => _isPreviewMode = !_isPreviewMode);
                      },
                    ),
                    const SizedBox(width: 4),
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
                    const SizedBox(width: 4),
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
                );
              },
            ),
          ),

          // Real-time WYSIWYG / Markdown Editor or Pure Preview Area
          Expanded(
            child: _isPreviewMode
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Markdown(
                      data: _contentController.text.trim().isEmpty
                          ? '*No content in note yet. Switch to Edit mode to start writing.*'
                          : _contentController.text,
                      selectable: true,
                      padding: EdgeInsets.zero,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                        ),
                        h1: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                        ),
                        h2: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                        ),
                        h3: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault,
                        ),
                        code: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                          backgroundColor: isDark ? const Color(0xFF161B22) : const Color(0xFFF0F2F5),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border(
                            left: BorderSide(
                              color: isDark ? AppColors.accent : AppColors.accentLight,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: TextField(
                      controller: _contentController,
                      onChanged: (_) => _onChanged(),
                      inputFormatters: [SmartMarkdownTextInputFormatter()],
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
                        hintText: 'Start writing markdown (# Heading, - Bullet, 1. List, - [ ] Task)...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                          fontSize: 14.5,
                          height: 1.65,
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
          ),
          if (_currentNote != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 1)),
                color: headerBg,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radius),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 460;
                  return Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Updated ${DateFormat.yMMMd().format(_currentNote!.updatedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                        ),
                      ),
                      if (!isCompact && _currentNote!.tags.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ..._currentNote!.tags.take(2).map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                      ],
                      const Spacer(),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _contentController,
                        builder: (context, value, _) {
                          final words = value.text.trim().isEmpty
                              ? 0
                              : value.text.trim().split(RegExp(r'\s+')).length;
                          return Text(
                            '$words words',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFormatBar extends StatelessWidget {
  const _QuickFormatBar({
    required this.controller,
    required this.isDark,
    required this.borderColor,
  });

  final TextEditingController controller;
  final bool isDark;
  final Color borderColor;

  void _insertInline(String prefix, String suffix) {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid) {
      controller.text = '$text$prefix$suffix';
      return;
    }
    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      ),
    );
  }

  void _toggleLinePrefix(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final offset = selection.isValid ? selection.baseOffset : text.length;

    int lineStart = offset - 1;
    while (lineStart >= 0 && lineStart < text.length && text[lineStart] != '\n') {
      lineStart--;
    }
    lineStart++; // Start of the line

    int lineEnd = offset;
    while (lineEnd < text.length && text[lineEnd] != '\n') {
      lineEnd++;
    }

    final currentLine = (lineStart <= lineEnd && lineEnd <= text.length)
        ? text.substring(lineStart, lineEnd)
        : '';

    // Strip any existing heading or list prefix
    final cleanLine = currentLine.replaceFirst(
      RegExp(r'^(#{1,6}\s+|[-*•+]\s+|\d+\.\s+|-\s*\[[ xX]?\]\s+|>\s*)'),
      '',
    );

    final newLine = currentLine.startsWith(prefix) ? cleanLine : '$prefix$cleanLine';
    final newText = text.replaceRange(lineStart, lineEnd, newLine);

    final diff = newLine.length - currentLine.length;
    final newOffset = (offset + diff).clamp(0, newText.length);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _formatBtn('H1', 'Heading 1', () => _toggleLinePrefix('# ')),
          _formatBtn('H2', 'Heading 2', () => _toggleLinePrefix('## ')),
          _formatBtn('H3', 'Heading 3', () => _toggleLinePrefix('### ')),
          _formatBtn('B', 'Bold', () => _insertInline('**', '**'), isBold: true),
          _formatBtn('I', 'Italic', () => _insertInline('*', '*'), isItalic: true),
          _formatBtn('•', 'Bullet List', () => _toggleLinePrefix('- ')),
          _formatBtn('1.', 'Numbered List', () => _toggleLinePrefix('1. ')),
          _formatBtn('☐', 'Task Checkbox', () => _toggleLinePrefix('- [ ] ')),
          _formatBtn('`', 'Code', () => _insertInline('`', '`'), isCode: true),
        ],
      ),
    );
  }

  Widget _formatBtn(
    String label,
    String tooltip,
    VoidCallback onTap, {
    bool isBold = false,
    bool isItalic = false,
    bool isCode = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius - 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 26,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontFamily: isCode ? 'monospace' : null,
              color: isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted,
            ),
          ),
        ),
      ),
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
