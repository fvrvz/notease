import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _NotesHomePageState extends ConsumerState<NotesHomePage>
    with TickerProviderStateMixin {
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
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderMuted : AppColors.lightBorderMuted;
    final headerBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvasDefault : AppColors.lightCanvasSubtle,
      body: Column(
        children: [
          // Elegant minimal top bar
          _buildAppTopBar(context, isDark, borderColor, headerBg),
          // Main Body with Sidebar + Accordion Strips + Active Note Editor
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
                  return _buildMobileLayout(notes, selectedId, isDark, borderColor);
                }
                return _buildDesktopLayout(notes, selectedId, isDark, borderColor);
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
  ) {
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;
    final accent = isDark ? AppColors.accent : AppColors.accentLight;

    return Container(
      height: 52 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // Search Box with smooth rounded corners
          Expanded(
            child: Container(
              height: 34,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCanvasInset : AppColors.lightCanvasInset,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
                style: TextStyle(fontSize: 13, color: fgDefault),
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Search notes by title or content...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: fgMuted,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 32),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // New Note Button with clean modern styling
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => ref.read(notesNotifierProvider.notifier).createNote(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'New Note',
                      style: TextStyle(
                        fontSize: 13,
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
  ) {
    final selectedIndex = notes.indexWhere((n) => n.id == selectedId);
    final leftNotes = selectedIndex > 0 ? notes.sublist(0, selectedIndex) : <Note>[];
    final rightNotes = selectedIndex >= 0 && selectedIndex < notes.length - 1
        ? notes.sublist(selectedIndex + 1)
        : (selectedIndex < 0 ? notes : <Note>[]);

    return Row(
      children: [
        // Collapsible sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: _navExpanded ? 220 : 60,
          child: NavSidebar(
            isExpanded: _navExpanded,
            onToggle: () => setState(() => _navExpanded = !_navExpanded),
          ),
        ),

        // Left accordion strips (collapsed notes)
        if (leftNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: leftNotes,
            isLeft: true,
            onNoteSelected: (id) {
              ref.read(selectedNoteIdProvider.notifier).state = id;
            },
          ),

        // Center: active note panel or empty state
        Expanded(
          child: selectedId != null && notes.any((n) => n.id == selectedId)
              ? NoteContentPanel(
                  noteId: selectedId,
                  key: ValueKey(selectedId),
                )
              : const EmptyState(),
        ),

        // Right accordion strips (collapsed notes)
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

  Widget _buildMobileLayout(
    List<Note> notes,
    String? selectedId,
    bool isDark,
    Color borderColor,
  ) {
    if (selectedId != null && notes.any((n) => n.id == selectedId)) {
      return NoteContentPanel(noteId: selectedId, key: ValueKey(selectedId));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note.title.isEmpty ? 'Untitled note' : note.title,
                style: TextStyle(
                  fontSize: 14.5,
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
                size: 15,
                color: isDark ? AppColors.accent : AppColors.accentLight,
              ),
          ],
        ),
        subtitle: note.content.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
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
              )
            : null,
      ),
    );
  }
}
