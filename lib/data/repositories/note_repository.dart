import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notease/data/local/storage_service.dart';
import 'package:notease/domain/models/note.dart';

final storageServiceProvider = Provider<LocalStorageService>((ref) {
  final service = LocalStorageService();
  ref.onDispose(service.dispose);
  return service;
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(storageServiceProvider));
});

class NoteRepository {
  final LocalStorageService _storage;
  const NoteRepository(this._storage);

  Stream<List<Note>> watchActiveNotes() => _storage.watchActiveNotes();

  Future<List<Note>> searchNotes(String query) => _storage.searchNotes(query);

  Future<Note?> getNoteById(String id) => _storage.getNoteById(id);

  Future<void> createNote(Note note) => _storage.saveNote(note);

  Future<void> updateNote(Note note) => _storage.saveNote(note);

  Future<void> deleteNote(String id) => _storage.deleteNote(id);
}
