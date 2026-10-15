import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notease/domain/models/note.dart';

class LocalStorageService {
  static const String _notesKey = 'notease_notes_v1';
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

    // Default sample notes if empty
    if (_memoryNotes.isEmpty) {
      _memoryNotes = [
        Note(
          id: '1',
          title: 'Welcome to NoteEase',
          content: 'A minimal, fast notes app with accordion layout.\n\n- Click any note strip on the side to expand.\n- Change colors, pin notes, and connect your cloud storage in settings.',
          color: NoteColor.sage,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isPinned: true,
        ),
        Note(
          id: '2',
          title: 'Design ideas',
          content: 'Keep UI minimal with pastel color coding, glass borders, and smooth transitions.',
          color: NoteColor.lavender,
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        Note(
          id: '3',
          title: 'Meeting Notes',
          content: 'Cross-platform sync implementation:\n1. Local storage as guest\n2. OAuth connect for Google Drive / iCloud / OneDrive / Dropbox\n3. Bi-directional sync with conflict resolution',
          color: NoteColor.peach,
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
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
