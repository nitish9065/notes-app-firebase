import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_app/features/auth/data/auth_repository.dart';
import 'package:notes_app/features/home/data/encryption_service.dart';
import 'package:notes_app/features/home/data/notes_repo.dart';
import 'package:notes_app/features/user/data/user_repository.dart';
import 'package:notes_app/features/user/model/app_user.dart';

final authProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepository(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn.standard(),
      userRepo: ref.read(userRepoProvider),
    );
  },
);

final userProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final userStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authProvider).currentUserState(),
);

final userRepoProvider = Provider<UserRepository>(
  (ref) {
    return UserRepository(FirebaseFirestore.instance);
  },
);

final appUserStream = StreamProvider<AppUser>(
  (ref) async* {
    yield* ref
        .read(userRepoProvider)
        .streamProfile(FirebaseAuth.instance.currentUser!.uid);
  },
);

// repositories/notes_repository.dart
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(
    FirebaseFirestore.instance,
    ref.watch(encryptionServiceProvider),
  );
});

// encryption_service.dart
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService(const FlutterSecureStorage());
});


