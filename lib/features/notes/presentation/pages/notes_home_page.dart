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
    final borderColor = isDark ? GitHubColors.darkBorderDefault : GitHubColors.lightBorderDefault;
    final headerBg = isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault;

    return Scaffold(
      backgroundColor: isDark ? GitHubColors.darkCanvasDefault : GitHubColors.lightCanvasSubtle,
      body: Column(
        children: [
          // GitHub Global Navigation Bar
          _buildGitHubTopNav(context, isDark, borderColor, headerBg),
          // Main Body
          Expanded(
            child: notesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg,
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

  Widget _buildGitHubTopNav(
    BuildContext context,
    bool isDark,
    Color borderColor,
    Color headerBg,
  ) {
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;

    return Container(
      height: 48 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // GitHub Octocat-like Icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.terminal_rounded,
              size: 16,
              color: fgDefault,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'notease',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fgDefault,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasInset,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              'Public',
              style: TextStyle(
                fontSize: 11,
                color: fgMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // GitHub Quick Search Box
          Expanded(
            child: Container(
              height: 28,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: isDark ? GitHubColors.darkCanvasInset : GitHubColors.lightCanvasDefault,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
                style: TextStyle(fontSize: 12, color: fgDefault),
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Type "/" to search notes...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? GitHubColors.darkFgSubtle : GitHubColors.lightFgSubtle,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 14,
                    color: fgMuted,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 28),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          const Spacer(),

          // New Note GitHub Green Primary Button
          Material(
            color: GitHubColors.darkSuccessEmphasis,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => ref.read(notesNotifierProvider.notifier).createNote(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'New note',
                      style: TextStyle(
                        fontSize: 12,
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
        // Navigation sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _navExpanded ? 220 : 54,
          child: NavSidebar(
            isExpanded: _navExpanded,
            onToggle: () => setState(() => _navExpanded = !_navExpanded),
          ),
        ),

        // Left collapsed note strips
        if (leftNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: leftNotes,
            isLeft: true,
            onNoteSelected: (id) {
              ref.read(selectedNoteIdProvider.notifier).state = id;
            },
          ),

        // Center: active note OR empty state
        Expanded(
          child: selectedId != null && notes.any((n) => n.id == selectedId)
              ? NoteContentPanel(
                  noteId: selectedId,
                  key: ValueKey(selectedId),
                )
              : const EmptyState(),
        ),

        // Right collapsed note strips
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
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      itemBuilder: (ctx, i) {
        final note = notes[i];
        return _MobileGitHubNoteCard(
          note: note,
          isDark: isDark,
          borderColor: borderColor,
          onTap: () => ref.read(selectedNoteIdProvider.notifier).state = note.id,
        );
      },
    );
  }
}

class _MobileGitHubNoteCard extends StatelessWidget {
  const _MobileGitHubNoteCard({
    required this.note,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
  });

  final Note note;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onTap;

  Color _badgeColor(NoteColor color) {
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
    final fgDefault = isDark ? GitHubColors.darkFgDefault : GitHubColors.lightFgDefault;
    final fgMuted = isDark ? GitHubColors.darkFgMuted : GitHubColors.lightFgMuted;
    final color = _badgeColor(note.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? GitHubColors.darkCanvasSubtle : GitHubColors.lightCanvasDefault,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              Icon(Icons.push_pin_rounded, size: 14, color: isDark ? GitHubColors.darkAccentFg : GitHubColors.lightAccentFg),
          ],
        ),
        subtitle: note.content.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12,
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
