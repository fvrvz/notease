import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';

class MockNoteRepository {
  final List<Note> notes;
  MockNoteRepository(this.notes);

  Stream<List<Note>> watchActiveNotes() => Stream.value(notes);
}

void main() {
  group('Search filtering multi-attribute test', () {
    final note1 = Note(
      id: '1',
      title: 'Sprint Planning Meeting',
      content: 'Review Q4 roadmap and architecture design goals',
      color: NoteColor.sage,
      createdAt: DateTime(2026, 10, 15, 10, 0),
      updatedAt: DateTime(2026, 10, 19, 14, 30),
      tags: ['planning', 'scrum'],
    );

    final note2 = Note(
      id: '2',
      title: 'Grocery Checklist',
      content: 'Almond milk, avocados, apples, sourdough bread',
      color: NoteColor.peach,
      createdAt: DateTime(2026, 9, 20),
      updatedAt: DateTime(2026, 9, 21),
      tags: ['personal', 'shopping'],
    );

    final note3 = Note(
      id: '3',
      title: 'Flutter Desktop Tips',
      content: 'Use Impeller Metal backend on macOS for smooth rendering',
      color: NoteColor.sky,
      createdAt: DateTime(2025, 12, 1),
      updatedAt: DateTime(2025, 12, 5),
      tags: ['dev', 'flutter'],
    );

    test('Searches by title', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      container.read(searchQueryProvider.notifier).state = 'sprint';
      final filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '1');
    });

    test('Searches by note content', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      container.read(searchQueryProvider.notifier).state = 'sourdough';
      final filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '2');
    });

    test('Searches by color name', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      container.read(searchQueryProvider.notifier).state = 'peach';
      final filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '2');
    });

    test('Searches by tag', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      container.read(searchQueryProvider.notifier).state = 'flutter';
      final filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '3');
    });

    test('Searches by month name and year (date search)', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      // October 2026 matches note1
      container.read(searchQueryProvider.notifier).state = 'october';
      var filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '1');

      // 2025 matches note3
      container.read(searchQueryProvider.notifier).state = '2025';
      filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '3');

      // Formatted date "19/10/2026" or "Oct 19"
      container.read(searchQueryProvider.notifier).state = 'oct 19';
      filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '1');
    });

    test('Multi-word cross-attribute search (title + date)', () async {
      final container = ProviderContainer(
        overrides: [
          activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2, note3])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeNotesProvider.future);

      // "planning oct" matches note1 (planning is in title/tag, oct is in date)
      container.read(searchQueryProvider.notifier).state = 'planning oct';
      final filtered = container.read(filteredNotesProvider).value!;
      expect(filtered.length, 1);
      expect(filtered.first.id, '1');
    });
  });
}
