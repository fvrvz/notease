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
    _debounce = Timer(const Duration(milliseconds: 600), () {
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

  Color get _noteColor {
    if (_currentNote == null) return AppColors.noteSage;
    const map = {
      NoteColor.sage: AppColors.noteSage,
      NoteColor.lavender: AppColors.noteLavender,
      NoteColor.peach: AppColors.notePeach,
      NoteColor.sky: AppColors.noteSky,
      NoteColor.butter: AppColors.noteButter,
      NoteColor.mint: AppColors.noteMint,
      NoteColor.rose: AppColors.noteRose,
    };
    return map[_currentNote!.color] ?? AppColors.noteSage;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? _noteColor.withOpacity(0.08)
            : _noteColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _noteColor.withOpacity(isDark ? 0.2 : 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TextField(
                controller: _contentController,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                expands: true,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start writing...',
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              onChanged: (_) => _onChanged(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Note title',
              ),
            ),
          ),
          _ColorPicker(
            selected: _currentNote?.color ?? NoteColor.sage,
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
          IconButton(
            icon: Icon(
              _currentNote?.isPinned == true
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              color: _currentNote?.isPinned == true
                  ? AppColors.accent
                  : null,
            ),
            onPressed: () {
              if (_currentNote != null) {
                ref.read(notesNotifierProvider.notifier).togglePin(_currentNote!);
                setState(() => _currentNote = _currentNote!.copyWith(
                  isPinned: !_currentNote!.isPinned,
                ));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              if (_currentNote != null) {
                ref.read(notesNotifierProvider.notifier).deleteNote(_currentNote!.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onColorSelected});
  final NoteColor selected;
  final void Function(NoteColor) onColorSelected;

  @override
  Widget build(BuildContext context) {
    const colors = [
      (NoteColor.sage, AppColors.noteSage),
      (NoteColor.lavender, AppColors.noteLavender),
      (NoteColor.peach, AppColors.notePeach),
      (NoteColor.sky, AppColors.noteSky),
      (NoteColor.butter, AppColors.noteButter),
      (NoteColor.mint, AppColors.noteMint),
      (NoteColor.rose, AppColors.noteRose),
    ];

    return PopupMenuButton<NoteColor>(
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _colorFor(selected),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors
                .map((pair) => GestureDetector(
                      onTap: () {
                        onColorSelected(pair.$1);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: pair.$2,
                          shape: BoxShape.circle,
                          border: selected == pair.$1
                              ? Border.all(color: AppColors.accent, width: 2)
                              : null,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Color _colorFor(NoteColor c) {
    const map = {
      NoteColor.sage: AppColors.noteSage,
      NoteColor.lavender: AppColors.noteLavender,
      NoteColor.peach: AppColors.notePeach,
      NoteColor.sky: AppColors.noteSky,
      NoteColor.butter: AppColors.noteButter,
      NoteColor.mint: AppColors.noteMint,
      NoteColor.rose: AppColors.noteRose,
    };
    return map[c] ?? AppColors.noteSage;
  }
}
