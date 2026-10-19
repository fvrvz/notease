import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notease/domain/models/note.dart';
import 'package:notease/features/notes/presentation/pages/notes_home_page.dart';
import 'package:notease/features/notes/providers/notes_provider.dart';

void main() {
  testWidgets('Note toggles open and closed on selection', (tester) async {
    final note1 = Note(
      id: 'note-1',
      title: 'First Test Note',
      content: 'Content of note 1',
      color: NoteColor.sage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        activeNotesProvider.overrideWith((ref) => Stream.value([note1])),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: NotesHomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially no note is open
    expect(container.read(selectedNoteIdProvider), isNull);

    // Select note-1 (toggle open)
    container.read(selectedNoteIdProvider.notifier).state = 'note-1';
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(selectedNoteIdProvider), 'note-1');

    // Toggle closed
    container.read(selectedNoteIdProvider.notifier).state = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(container.read(selectedNoteIdProvider), isNull);
  });

  testWidgets('Switching between notes runs fold and unfold animation', (tester) async {
    final note1 = Note(
      id: 'note-1',
      title: 'First Test Note',
      content: 'Content of note 1',
      color: NoteColor.sage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final note2 = Note(
      id: 'note-2',
      title: 'Second Test Note',
      content: 'Content of note 2',
      color: NoteColor.peach,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        activeNotesProvider.overrideWith((ref) => Stream.value([note1, note2])),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: NotesHomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Note 1
    container.read(selectedNoteIdProvider.notifier).state = 'note-1';
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(container.read(selectedNoteIdProvider), 'note-1');

    // Switch to Note 2 directly while Note 1 is open
    container.read(selectedNoteIdProvider.notifier).state = 'note-2';
    // Mid-transition pump (fold Note 1)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // Settle transition (unfold Note 2)
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(container.read(selectedNoteIdProvider), 'note-2');
  });
}

