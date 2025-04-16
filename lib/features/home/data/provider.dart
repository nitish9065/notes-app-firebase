import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/features/home/model/note.dart';
import 'package:notes_app/features/home/model/selected_user_state.dart';
import 'package:notes_app/features/user/model/app_user.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final notesProvider = StreamProvider<List<Note>>((ref) async* {
  yield* ref
      .read(notesRepositoryProvider)
      .getUserNotes(FirebaseAuth.instance.currentUser!.uid);
});

final userListProvider = FutureProvider<List<AppUser>>((ref) async {
  return ref.read(userRepoProvider).getAllUsers();
});

final selectedUserIdProvider =
    StateNotifierProvider<SelectedUserIdNotifier, List<String>>(
  (ref) => SelectedUserIdNotifier(),
);

final inNoteSearchProvider = StateProvider<bool>((ref) {
  return false;
});

// notes count stats streamProvider
final noteCountStatsProvider = StreamProvider.autoDispose<Map<String, int>>(
  (ref) {
    return ref.watch(notesRepositoryProvider).getNoteCountsStream(
          FirebaseAuth.instance.currentUser!.uid,
        );
  },
);
