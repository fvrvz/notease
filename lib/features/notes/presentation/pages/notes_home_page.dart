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

class _NotesHomePageState extends ConsumerState<NotesHomePage>
    with SingleTickerProviderStateMixin {
  bool _navExpanded = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;
  String? _activeNoteId;

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleNoteSelection(String id) {
    final current = ref.read(selectedNoteIdProvider);
    if (current == id) {
      // Toggle off if already selected
      ref.read(selectedNoteIdProvider.notifier).state = null;
    } else {
      // Open new note
      ref.read(selectedNoteIdProvider.notifier).state = id;
    }
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

    // Listen to selection changes to drive smooth accordion toggle animation
    ref.listen<String?>(selectedNoteIdProvider, (previous, next) {
      if (next != null) {
        setState(() => _activeNoteId = next);
        if (previous == null || _toggleController.value == 0.0) {
          _toggleController.forward(from: 0.0);
        }
      } else {
        _toggleController.reverse().then((_) {
          if (mounted) setState(() => _activeNoteId = null);
        });
      }
    });

    if (selectedId != null && _activeNoteId == null) {
      _activeNoteId = selectedId;
      _toggleController.value = 1.0;
    }

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
                  hintText: 'Search notes by title, content, date, tags...',
                  hintStyle: TextStyle(
                    color: fgMuted,
                    fontSize: 12.5,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: fgMuted,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, size: 14, color: fgMuted),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // New Note Button
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
    // Keep focus note during collapse animation so strips rebalance smoothly
    final currentFocusId = selectedId ?? (_toggleController.value > 0 ? _activeNoteId : null);
    final selectedIndex = notes.indexWhere((n) => n.id == currentFocusId);

    // Left notes: notes before current focus (or all notes if none selected)
    final leftNotes = selectedIndex > 0
        ? notes.sublist(0, selectedIndex)
        : (selectedIndex < 0 ? notes : <Note>[]);
    final rightNotes = selectedIndex >= 0 && selectedIndex < notes.length - 1
        ? notes.sublist(selectedIndex + 1)
        : <Note>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar (fixed width)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
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
            selectedId: selectedId,
            onNoteSelected: _toggleNoteSelection,
          ),

        // Active Note Panel with smooth ease-in-out expand/collapse animation OR Empty State
        Expanded(
          child: AnimatedBuilder(
            animation: _toggleAnimation,
            builder: (context, _) {
              final activeId = selectedId ?? _activeNoteId;
              final showActiveNote = activeId != null &&
                  notes.any((n) => n.id == activeId) &&
                  (_toggleAnimation.value > 0.0 || selectedId != null);

              if (!showActiveNote) {
                // When completely collapsed, show Empty State
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    title: searchQuery.isNotEmpty ? 'No matching notes' : null,
                    message: searchQuery.isNotEmpty
                        ? 'No notes matched "$searchQuery". Try searching by title, content, date, color, or tags.'
                        : 'Click any note strip to expand it, or click + to create a new note.',
                    icon: searchQuery.isNotEmpty ? Icons.search_off_rounded : null,
                  ),
                );
              }

              // Smooth horizontal expansion & collapse using widthFactor
              return Align(
                alignment: Alignment.centerLeft,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _toggleAnimation.value,
                    child: FadeTransition(
                      opacity: _toggleAnimation,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 320,
                          maxWidth: 860,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: NoteContentPanel(
                          key: ValueKey(activeId),
                          noteId: activeId,
                          onCollapse: () => _toggleNoteSelection(activeId),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Right accordion strips (horizontally scrollable if many notes)
        if (rightNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: rightNotes,
            isLeft: false,
            selectedId: selectedId,
            onNoteSelected: _toggleNoteSelection,
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: (selectedId != null && notes.any((n) => n.id == selectedId))
          ? Padding(
              key: ValueKey(selectedId),
              padding: const EdgeInsets.all(8),
              child: NoteContentPanel(
                noteId: selectedId,
                onCollapse: () => ref.read(selectedNoteIdProvider.notifier).state = null,
              ),
            )
          : (notes.isEmpty
              ? Padding(
                  key: const ValueKey('empty_mobile'),
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    title: searchQuery.isNotEmpty ? 'No matching notes' : null,
                    message: searchQuery.isNotEmpty
                        ? 'No notes matched "$searchQuery".'
                        : null,
                    icon: searchQuery.isNotEmpty ? Icons.search_off_rounded : null,
                  ),
                )
              : ListView.builder(
                  key: const ValueKey('list_mobile'),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: notes.length,
                  itemBuilder: (ctx, i) {
                    final note = notes[i];
                    return _MobileNoteCard(
                      note: note,
                      isDark: isDark,
                      borderColor: borderColor,
                      onTap: () => _toggleNoteSelection(note.id),
                    );
                  },
                )),
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
    final color = _noteColor(note.color);
    final cardBg = isDark ? AppColors.darkCanvasSubtle : AppColors.lightCanvasDefault;
    final fgDefault = isDark ? AppColors.darkFgDefault : AppColors.lightFgDefault;
    final fgMuted = isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
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
                  if (note.isPinned) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.push_pin_rounded, size: 13, color: color),
                  ],
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: fgMuted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    DateFormat.yMMMd().format(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkFgSubtle : AppColors.lightFgSubtle,
                    ),
                  ),
                  if (note.tags.isNotEmpty) ...[
                    const Spacer(),
                    ...note.tags.take(3).map(
                          (tag) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.darkFgMuted : AppColors.lightFgMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
