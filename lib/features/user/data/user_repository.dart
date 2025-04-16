import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/core/constants/app_contants.dart';
import 'package:notes_app/features/user/model/app_user.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository(this.firestore);

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      firestore.collection(AppContants.userCollection);

  Future<AppUser> getProfile(String uid) async {
    final doc = await _userCollection.doc(uid).get();
    return AppUser.fromFirestore(doc);
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _userCollection.get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList()
      ..removeWhere(
        (element) => element.uid == FirebaseAuth.instance.currentUser!.uid,
      );
  }

  Future<List<AppUser>> searchUsers(String query) async {
    final searchQuery = query.toLowerCase();
    final snapshot = await _userCollection
        .where('displayName', isGreaterThanOrEqualTo: searchQuery)
        .where('displayName', isLessThan: '${searchQuery}z')
        .get();

    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }

  Stream<AppUser> streamProfile(String uid) async* {
    final userStream = _userCollection
        .doc(uid)
        .snapshots()
        .map((snapshot) => AppUser.fromFirestore(snapshot));
    yield* userStream;
  }

  Future<AppUser?> getProfileByEmail(String email) async {
    final doc = await _userCollection.where('email', isEqualTo: email).get();
    if (doc.size == 0) return null;
    return AppUser.fromFirestore(doc.docs.first);
  }

  Future<void> updateProfile(AppUser profile) async {
    await _userCollection.doc(profile.uid).update(profile.toMap());
  }

  Future<void> createProfile(
      {required String uid,
      required String email,
      required String displayName,
      required String photoUrl}) async {
    await _userCollection.doc(uid).set({
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.now(),
    });
  }
}
