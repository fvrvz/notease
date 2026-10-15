import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:notease/core/theme/app_theme.dart';
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
  bool _navExpanded = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);
    final selectedId = ref.watch(selectedNoteIdProvider);
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: notesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (isMobile) {
            return _buildMobileLayout(notes, selectedId);
          }
          return _buildDesktopLayout(notes, selectedId);
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildDesktopLayout(List<dynamic> notes, String? selectedId) {
    // Find index of selected note
    final selectedIndex = notes.indexWhere((n) => n.id == selectedId);
    final leftNotes = selectedIndex > 0 ? notes.sublist(0, selectedIndex) : [];
    final rightNotes = selectedIndex >= 0 && selectedIndex < notes.length - 1
        ? notes.sublist(selectedIndex + 1)
        : (selectedIndex < 0 ? notes : []);

    return Row(
      children: [
        // Navigation sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _navExpanded ? 240 : 64,
          child: NavSidebar(
            isExpanded: _navExpanded,
            onToggle: () => setState(() => _navExpanded = !_navExpanded),
          ),
        ),

        // Left collapsed note strips
        if (leftNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: leftNotes.cast(),
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
                ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.02)
              : const EmptyState(),
        ),

        // Right collapsed note strips
        if (rightNotes.isNotEmpty)
          NoteAccordionStrip(
            notes: rightNotes.cast(),
            isLeft: false,
            onNoteSelected: (id) {
              ref.read(selectedNoteIdProvider.notifier).state = id;
            },
          ),
      ],
    );
  }

  Widget _buildMobileLayout(List<dynamic> notes, String? selectedId) {
    if (selectedId != null && notes.any((n) => n.id == selectedId)) {
      return Column(
        children: [
          // Mobile top bar
          _buildMobileTopBar(),
          Expanded(
            child: NoteContentPanel(noteId: selectedId, key: ValueKey(selectedId)),
          ),
        ],
      );
    }
    // Show notes list
    return Column(
      children: [
        _buildMobileTopBar(),
        Expanded(
          child: notes.isEmpty
              ? const EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (ctx, i) {
                    final note = notes[i];
                    return _MobileNoteCard(
                      note: note,
                      onTap: () => ref.read(selectedNoteIdProvider.notifier).state = note.id,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 56 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'NoteEase',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => ref.read(notesNotifierProvider.notifier).createNote(),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, size: 24),
    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut);
  }
}

class _MobileNoteCard extends StatelessWidget {
  const _MobileNoteCard({required this.note, required this.onTap});
  final dynamic note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _noteColor(note.color.name),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _noteColor(String name) {
    const map = {
      'sage': AppColors.noteSage,
      'lavender': AppColors.noteLavender,
      'peach': AppColors.notePeach,
      'sky': AppColors.noteSky,
      'butter': AppColors.noteButter,
      'mint': AppColors.noteMint,
      'rose': AppColors.noteRose,
    };
    return map[name] ?? AppColors.noteSage;
  }
}
