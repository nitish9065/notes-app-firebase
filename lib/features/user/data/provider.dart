import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/features/home/model/note.dart';

final userSharedNoteListProvider = StreamProvider.autoDispose
    .family<List<Note>, bool>((ref, showSharedBy) async* {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  yield* showSharedBy
      ? ref.read(notesRepositoryProvider).getNotesSharedBy(userId)
      : ref.read(notesRepositoryProvider).getNotesSharedWith(userId);
});
