import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  if (query.trim().isEmpty) return notes;
  return notes.whenData((list) =>
      list.where((note) => _matchesNote(note, query)).toList());
});

bool _matchesNote(Note note, String rawQuery) {
  final cleanQuery = rawQuery.trim().toLowerCase();
  if (cleanQuery.isEmpty) return true;

  // 1. Direct whole-query match check
  if (note.title.toLowerCase().contains(cleanQuery)) return true;
  if (note.content.toLowerCase().contains(cleanQuery)) return true;
  if (note.color.name.toLowerCase().contains(cleanQuery)) return true;
  if (note.tags.any((tag) => tag.toLowerCase().contains(cleanQuery))) return true;

  // Check direct date match
  final dateStrings = _getDateSearchStrings(note.updatedAt)
    ..addAll(_getDateSearchStrings(note.createdAt));
  if (dateStrings.any((ds) => ds.contains(cleanQuery))) return true;

  // 2. Tokenized multi-term search (e.g. "meeting oct 19" or "ideas 2026")
  final normalized = cleanQuery.replaceAll(RegExp(r'[,]+'), ' ');
  final terms = normalized
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();

  if (terms.isEmpty) return true;

  return terms.every((term) {
    if (note.title.toLowerCase().contains(term)) return true;
    if (note.content.toLowerCase().contains(term)) return true;
    if (note.tags.any((t) => t.toLowerCase().contains(term))) return true;
    if (note.color.name.toLowerCase().contains(term)) return true;
    if (dateStrings.any((ds) => ds.contains(term))) return true;
    return false;
  });
}

Set<String> _getDateSearchStrings(DateTime dt) {
  final now = DateTime.now();
  final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
  final diffDays = now.difference(dt).inDays.abs();

  final set = <String>{};

  if (isToday) set.add('today');
  if (isYesterday) set.add('yesterday');
  if (diffDays <= 7) set.add('this week');
  if (dt.year == now.year && dt.month == now.month) set.add('this month');
  if (dt.year == now.year) set.add('this year');

  final formats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('yyyy/MM/dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('d/M/yyyy'),
    DateFormat('d/M/yy'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('M/d/yyyy'),
    DateFormat('d MMM yyyy'),
    DateFormat('d MMMM yyyy'),
    DateFormat('MMM d, yyyy'),
    DateFormat('MMMM d, yyyy'),
    DateFormat('MMM d'),
    DateFormat('MMMM d'),
    DateFormat('d MMM'),
    DateFormat('d MMMM'),
    DateFormat('MMMM yyyy'),
    DateFormat('MMM yyyy'),
    DateFormat('yyyy'),
    DateFormat('MMMM'),
    DateFormat('MMM'),
    DateFormat('EEEE'),
    DateFormat('EEE'),
  ];

  for (final f in formats) {
    try {
      set.add(f.format(dt).toLowerCase());
    } catch (_) {}
  }

  // Raw numerical components
  set.add(dt.day.toString());
  set.add(dt.month.toString());
  set.add(dt.year.toString());

  return set;
}

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
