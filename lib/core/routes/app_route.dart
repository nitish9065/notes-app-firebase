import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/features/auth/presentation/screen/login_screen.dart';
import 'package:notes_app/features/home/presentation/home.dart';
import 'package:notes_app/features/home/presentation/note_editor.dart';
import 'package:notes_app/features/user/presentation/profile_screen.dart';
import 'package:notes_app/features/user/presentation/user_shared_note_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_route.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRoute(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) =>
            ref.watch(userStateProvider).value == null ? '/login' : '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const NotesListScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              final map = state.extra as Map<String, bool>?;
              return NoteEditorScreen(
                noteId: id == 'null' ? null : id,
                lockActions: map?['lockAction'] ?? false,
              );
            },
          )
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: '/note',
            builder: (context, state) {
              final map = state.extra as Map<String, bool>?;
              return UserSharedNoteScreen(map?['showShared'] ?? false);
            },
          )
        ],
      )
    ],
  );
}
