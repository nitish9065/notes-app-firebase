// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_app/features/user/data/user_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required UserRepository userRepo,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _userRepository = userRepo;

  Stream<User?> currentUserState() => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    final userCred = await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      ),
    );
    await _createAccount(userCred);
    return userCred;
  }

  Future<void> _createAccount(UserCredential userCred) async {
    if (userCred.user != null && userCred.user!.email != null) {
      final userExist =
          await _userRepository.getProfileByEmail(userCred.user!.email!);
      if (userExist == null) {
        await _userRepository.createProfile(
            uid: userCred.user!.uid,
            email: userCred.user!.email!,
            displayName: userCred.user!.displayName ?? 'Unknown',
            photoUrl: userCred.user!.photoURL ?? '');
      }
    }
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final userCred = await _firebaseAuth.signInWithCredential(
      OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      ),
    );
    await _createAccount(userCred);
    return userCred;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
