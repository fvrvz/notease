import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notease/core/theme/app_theme.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';
import 'package:notease/features/notes/presentation/widgets/note_accordion_strip.dart';
import 'package:notease/features/notes/presentation/widgets/note_content_panel.dart';
import 'package:notease/features/notes/presentation/widgets/nav_sidebar.dart';
import 'package:notease/features/notes/presentation/widgets/empty_state.dart';

class NotesHomePage extends ConsumerStatefulWidget {
  const NotesHomePage({super.key});

  @override
  ConsumerState<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends ConsumerState<NotesHomePage> {
  bool _navExpanded = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);
    final selectedId = ref.watch(selectedNoteIdProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
    final headerBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasSubtle,
      body: Column(
        children: [
          _buildAppTopBar(context, isDark, borderColor, headerBg, isMobile, selectedId, searchQuery),
          Expanded(
            child: notesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? AppColors.accent : AppColors.accentLight,
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notes) {
                if (isMobile) {
                  return _buildMobileResponsiveLayout(notes, selectedId, isDark, borderColor, searchQuery);
                }
                return _buildDesktopLayout(notes, selectedId, isDark, borderColor, searchQuery);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTopBar(
    BuildContext context,
    bool isDark,
    Color borderColor,
    Color headerBg,
    bool isMobile,
    String? selectedId,
    String searchQuery,
  ) {
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Container(
      height: 48 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 14,
        right: 14,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          if (isMobile && selectedId != null) ...[
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, size: 20, color: fgDefault),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => ref.read(selectedNoteIdProvider.notifier).state = null,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              height: 32,
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  color: fgDefault,
                ),
                decoration: InputDecoration(
                  filled: false,
                  isDense: true,
                  hintText: 'Search title, content, date, tags...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 15,
                    color: fgMuted,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                    maxWidth: 32,
                    maxHeight: 32,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 14),
                          color: fgMuted,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 32,
                            maxWidth: 28,
                            maxHeight: 32,
                          ),
                          splashRadius: 14,
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 32,
                    maxWidth: 28,
                    maxHeight: 32,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: InkWell(
              onTap: () => ref.read(notesNotifierProvider.notifier).createNote(),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'New Note',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<Note> notes,
    String? selectedId,
    bool isDark,
    Color borderColor,
    String searchQuery,
  ) {
    final selectedIndex = notes.indexWhere((n) => n.id == selectedId);
    final leftNotes = selectedIndex > 0 ? notes.sublist(0, selectedIndex) : <Note>[];
    final rightNotes = selectedIndex >= 0 && selectedIndex < notes.length - 1
        ? notes.sublist(selectedIndex + 1)
        : (selectedIndex < 0 ? notes : <Note>[]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar (fixed width)
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: _navExpanded ? 200 : 52,
          child: NavSidebar(
            isExpanded: _navExpanded,
            onToggle: () => setState(() => _navExpanded = !_navExpanded),
          ),
        ),

        // Left accordion strips (horizontally scrollable if many notes)
        if (leftNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: leftNotes,
            isLeft: true,
            onNoteSelected: (id) {
              ref.read(selectedNoteIdProvider.notifier).state = id;
            },
          ),

        // Left-aligned Active Note Panel with smooth AnimatedSize & AnimatedSwitcher
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              reverseDuration: const Duration(milliseconds: 160),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                );
              },
              child: selectedId != null && notes.any((n) => n.id == selectedId)
                  ? Padding(
                      key: ValueKey(selectedId),
                      padding: const EdgeInsets.all(8),
                      child: NoteContentPanel(
                        noteId: selectedId,
                      ),
                    )
                  : Padding(
                      key: ValueKey('empty_state_${searchQuery.isNotEmpty}'),
                      padding: const EdgeInsets.all(16),
                      child: EmptyState(
                        title: searchQuery.isNotEmpty ? 'No matching notes' : null,
                        message: searchQuery.isNotEmpty
                            ? 'No notes matched "$searchQuery". Try searching by title, content, date, color, or tags.'
                            : null,
                        icon: searchQuery.isNotEmpty ? Icons.search_off_rounded : null,
                      ),
                    ),
            ),
          ),
        ),

        // Right accordion strips (horizontally scrollable if many notes)
        if (rightNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: rightNotes,
            isLeft: false,
            onNoteSelected: (id) {
              ref.read(selectedNoteIdProvider.notifier).state = id;
            },
          ),
      ],
    );
  }

  Widget _buildMobileResponsiveLayout(
    List<Note> notes,
    String? selectedId,
    bool isDark,
    Color borderColor,
    String searchQuery,
  ) {
    if (selectedId != null && notes.any((n) => n.id == selectedId)) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: NoteContentPanel(noteId: selectedId, key: ValueKey(selectedId)),
      );
    }

    if (notes.isEmpty) {
      return EmptyState(
        title: searchQuery.isNotEmpty ? 'No matching notes' : null,
        message: searchQuery.isNotEmpty
            ? 'No notes matched "$searchQuery". Try searching by title, content, date, color, or tags.'
            : null,
        icon: searchQuery.isNotEmpty ? Icons.search_off_rounded : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: notes.length,
      itemBuilder: (ctx, i) {
        final note = notes[i];
        return _MobileNoteCard(
          note: note,
          isDark: isDark,
          borderColor: borderColor,
          onTap: () => ref.read(selectedNoteIdProvider.notifier).state = note.id,
        );
      },
    );
  }
}

class _MobileNoteCard extends StatelessWidget {
  const _MobileNoteCard({
    required this.note,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
  });

  final Note note;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onTap;

  Color _noteColor(NoteColor color) {
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
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final color = _noteColor(note.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note.title.isEmpty ? 'Untitled note' : note.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fgDefault,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note.isPinned)
              Icon(
                Icons.push_pin_rounded,
                size: 14,
                color: isDark ? AppColors.accent : AppColors.accentLight,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: fgMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: fgMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().format(note.updatedAt),
                  style: TextStyle(fontSize: 11, color: fgMuted),
                ),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ...note.tags.take(3).map(
                        (tag) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 0.8),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(fontSize: 10, color: fgMuted),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
