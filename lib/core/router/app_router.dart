import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notease/features/notes/presentation/pages/notes_home_page.dart';
import 'package:notease/features/auth/presentation/pages/welcome_page.dart';
import 'package:notease/features/settings/presentation/pages/settings_page.dart';
import 'package:notease/features/notes/presentation/pages/note_editor_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const NotesHomePage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/note/:id',
        name: 'note-editor',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoteEditorPage(noteId: id);
        },
      ),
    ],
  );
});
