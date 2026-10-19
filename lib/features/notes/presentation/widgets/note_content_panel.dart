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
    _debounce = Timer(const Duration(milliseconds: 400), () {
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
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final canvasColor = isDark ? GitHubColors.darkCanvasDefault : GitHubColors.lightCanvasDefault;
    final headerBg = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasSubtle;
    final noteColor = _currentNote != null
        ? _getBadgeColor(_currentNote!.color, isDark)
        : (isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GitHub Header Bar (like an issue / PR header or file header)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Color Pill / Status indicator (like GitHub Open/Closed pill)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: noteColor.withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: noteColor.withValues(alpha: 0.4), width: 1),
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
                        _currentNote?.color.name ?? 'note',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: noteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    onChanged: (_) => _onChanged(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Note title...',
                      hintStyle: TextStyle(
                        color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                        fontSize: 16,
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
                const SizedBox(width: 6),
                // GitHub-style Button for Pin
                _GitHubIconButton(
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
                const SizedBox(width: 6),
                // GitHub-style Button for Delete
                _GitHubIconButton(
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

          // GitHub Markdown Meta / Sub-bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? GitHubColors.darkBorderMuted : GitHubColors.lightBorderMuted),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 14,
                  color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                ),
                const SizedBox(width: 6),
                Text(
                  'Markdown Editor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                  ),
                ),
                const Spacer(),
                if (_currentNote != null)
                  Text(
                    'Updated ${_formatDate(_currentNote!.updatedAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                    ),
                  ),
              ],
            ),
          ),

          // Editor Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                expands: true,
                style: TextStyle(
                  height: 1.6,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Type markdown or text here...',
                  hintStyle: TextStyle(
                    color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                    fontFamily: 'monospace',
                    fontSize: 13,
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

class _GitHubIconButton extends StatelessWidget {
  const _GitHubIconButton({
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
    final bgColor = isDanger
        ? Colors.transparent
        : (active
            ? (isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset)
            : (isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault));
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final fgColor = isDanger
        ? (isDark ? GitHubColors.darkDangerFg : GitHubColors.lightDangerFg)
        : (active
            ? (isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg)
            : (isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted));

    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Icon(icon, size: 15, color: fgColor),
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
      (NoteColor.sage, 'Green', Color(0xFF2EA043)),
      (NoteColor.sky, 'Blue', Color(0xFF2F81F7)),
      (NoteColor.lavender, 'Purple', Color(0xFF8957E5)),
      (NoteColor.peach, 'Orange', Color(0xFFBD561D)),
      (NoteColor.butter, 'Yellow', Color(0xFFD29922)),
      (NoteColor.mint, 'Teal', Color(0xFF1B7C83)),
      (NoteColor.rose, 'Pink', Color(0xFFDB61A2)),
    ];

    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final bgColor = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault;

    return PopupMenuButton<NoteColor>(
      tooltip: 'Label color',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: borderColor),
      ),
      color: isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
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
              Icons.arrow_drop_down,
              size: 14,
              color: isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted,
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
                'LABELS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                ),
              ),
              const SizedBox(height: 8),
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
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.$3.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? c.$3 : c.$3.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
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
