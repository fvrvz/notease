import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notease/domain/models/note.dart';

class LocalStorageService {
  static const String _notesKey = 'notease_notes_v2';
  final StreamController<List<Note>> _notesController =
      StreamController<List<Note>>.broadcast();

  List<Note> _memoryNotes = [];
  bool _initialized = false;

  LocalStorageService() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_notesKey);
        if (raw != null) {
          final List decoded = jsonDecode(raw);
          _memoryNotes = decoded.map((e) => Note.fromJson(e)).toList();
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'notes.json'));
        if (await file.exists()) {
          final raw = await file.readAsString();
          final List decoded = jsonDecode(raw);
          _memoryNotes = decoded.map((e) => Note.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error initializing local storage: $e');
    }

    // Default sample notes seeded with 10 rich notes
    if (_memoryNotes.isEmpty || _memoryNotes.length < 10) {
      _memoryNotes = [
        Note(
          id: '1',
          title: 'Welcome to NoteEase',
          content: '# Welcome to NoteEase\n\nA minimal, focused notes workspace.\n- [x] Accordion animated note strips\n- [x] Real-time inline Markdown formatting\n- [ ] Multi-provider cloud synchronization',
          color: NoteColor.sage,
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isPinned: true,
        ),
        Note(
          id: '2',
          title: 'Architecture & Stack',
          content: '## Technology Stack\n\n- **Framework**: Flutter (AOT native compiled)\n- **State Management**: Riverpod 2.6+\n- **Storage**: Local persistence with offline-first design\n- **Target Platforms**: macOS, Windows, Android, iOS, Web',
          color: NoteColor.sky,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isPinned: true,
        ),
        Note(
          id: '3',
          title: 'Design Guidelines',
          content: '### Design Rules\n\n1. Flat surfaces with crisp 1px borders\n2. Decreased **6px** border radius\n3. Consistent text alignments across elements\n4. Strict adherence to zero drop shadows and zero gradients',
          color: NoteColor.lavender,
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        Note(
          id: '4',
          title: 'Markdown Cheatsheet',
          content: '## Markdown Cheatsheet\n\nUse `# Header 1`, `## Header 2`, `### Header 3`.\nFormat text with **bold** or *italic*.\nInclude inline code like `var note = Note();`.\n> Important quote or callout block.\n- [ ] Unchecked checklist item\n- [x] Completed item',
          color: NoteColor.peach,
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        Note(
          id: '5',
          title: 'Meeting Notes: Sync Strategy',
          content: '### Cloud Sync Options\n\nDiscussing integration adapters:\n- **Google Drive**: Storing notes JSON in appDataFolder\n- **iCloud Drive**: Seamless Apple ecosystem synchronization\n- **OneDrive / Dropbox**: File level bi-directional sync',
          color: NoteColor.butter,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
        Note(
          id: '6',
          title: 'Book Recommendations',
          content: '### Reading List\n\n- **Designing Data-Intensive Applications** - Martin Kleppmann\n- **Clean Architecture** - Robert C. Martin\n- **The Design of Everyday Things** - Don Norman\n- **Refactoring** - Martin Fowler',
          color: NoteColor.mint,
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        Note(
          id: '7',
          title: 'Weekly Sprint Goals',
          content: '### Sprint Tasks\n\n- [x] Animate note expansion and collapse\n- [x] Left-align active note container\n- [x] Real-time inline markdown parsing\n- [ ] Implement cloud sync credentials sheet\n- [ ] Export notes as .md bundle',
          color: NoteColor.rose,
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 21)),
        ),
        Note(
          id: '8',
          title: 'Product Roadmap',
          content: '## NoteEase Roadmap\n\n- **v1.0**: Core notes editor, accordion strip layout, guest local mode\n- **v1.1**: Google Drive & iCloud sync integration\n- **v1.2**: Tagging system and note linking',
          color: NoteColor.sky,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 22)),
        ),
        Note(
          id: '9',
          title: 'Code Snippets: Dart extensions',
          content: '### Useful Extensions\n\n```dart\nextension StringUtils on String {\n  bool get isBlank => trim().isEmpty;\n}\n```\nKeep utility functions small and testable.',
          color: NoteColor.lavender,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 23)),
        ),
        Note(
          id: '10',
          title: 'Quick Ideas & Brainstorming',
          content: '### Feature Ideas\n\n- Keyboard shortcuts: `Cmd+N` for new note, `Cmd+F` for search\n- Drag and drop reordering of note strips\n- Quick color switcher via keyboard numbers `1-7`',
          color: NoteColor.sage,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 24)),
        ),
      ];
      _save();
    }

    _initialized = true;
    _emit();
  }

  void _emit() {
    final active = _memoryNotes.where((n) => !n.isArchived).toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    _notesController.add(active);
  }

  Future<void> _save() async {
    try {
      final jsonString = jsonEncode(_memoryNotes.map((e) => e.toJson()).toList());
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notesKey, jsonString);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'notes.json'));
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      debugPrint('Error saving notes to storage: $e');
    }
  }

  Stream<List<Note>> watchActiveNotes() async* {
    if (_initialized) {
      yield _memoryNotes.where((n) => !n.isArchived).toList()
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }
    yield* _notesController.stream;
  }

  Future<List<Note>> searchNotes(String query) async {
    final q = query.toLowerCase();
    return _memoryNotes.where((n) =>
        !n.isArchived &&
        (n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q))
    ).toList();
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return _memoryNotes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(Note note) async {
    final index = _memoryNotes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _memoryNotes[index] = note;
    } else {
      _memoryNotes.insert(0, note);
    }
    await _save();
    _emit();
  }

  Future<void> deleteNote(String id) async {
    _memoryNotes.removeWhere((n) => n.id == id);
    await _save();
    _emit();
  }

  void dispose() {
    _notesController.close();
  }
}
