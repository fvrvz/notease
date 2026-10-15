import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notease/data/repositories/note_repository.dart';
import 'package:notease/domain/models/note.dart';

final activeNotesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchActiveNotes();
});

final selectedNoteIdProvider = StateProvider<String?>((ref) => null);

final selectedNoteProvider = Provider<Note?>((ref) {
  final id = ref.watch(selectedNoteIdProvider);
  if (id == null) return null;
  final notes = ref.watch(activeNotesProvider).valueOrNull;
  return notes?.firstWhere((n) => n.id == id, orElse: () => Note.create());
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final notes = ref.watch(activeNotesProvider);
  if (query.isEmpty) return notes;
  return notes.whenData((list) =>
      list.where((n) =>
          n.title.toLowerCase().contains(query.toLowerCase()) ||
          n.content.toLowerCase().contains(query.toLowerCase())).toList());
});

class NotesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createNote({NoteColor? color}) async {
    final repo = ref.read(noteRepositoryProvider);
    final note = Note.create(color: color);
    await repo.createNote(note);
    ref.read(selectedNoteIdProvider.notifier).state = note.id;
  }

  Future<void> updateNote(Note note) async {
    final repo = ref.read(noteRepositoryProvider);
    final updated = note.copyWith(updatedAt: DateTime.now());
    await repo.updateNote(updated);
  }

  Future<void> deleteNote(String id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    final selectedId = ref.read(selectedNoteIdProvider);
    if (selectedId == id) {
      ref.read(selectedNoteIdProvider.notifier).state = null;
    }
  }

  Future<void> togglePin(Note note) async {
    await updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  Future<void> archiveNote(Note note) async {
    await updateNote(note.copyWith(isArchived: true));
  }
}

final notesNotifierProvider = AsyncNotifierProvider<NotesNotifier, void>(NotesNotifier.new);
