import 'package:flutter/material.dart';
import 'package:notease/features/notes/presentation/widgets/note_content_panel.dart';

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key, required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteContentPanel(noteId: noteId),
    );
  }
}
