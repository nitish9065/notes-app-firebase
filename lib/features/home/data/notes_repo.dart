import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/core/constants/app_contants.dart';
import 'package:notes_app/features/home/data/encryption_service.dart';
import 'package:notes_app/features/home/model/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;
  final EncryptionService _encryption;

  NotesRepository(this._firestore, this._encryption);

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection(AppContants.notesCollection);

  Stream<List<Note>> getUserNotes(String userId) {
    return _notes
        .where('userId', isEqualTo: userId)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      return _getNotesFromStream(snapshot);
    });
  }

  Stream<List<Note>> getNotesSharedBy(String userId) {
    return _notes
        .where('userId', isEqualTo: userId)
        .where('sharedWith', isNotEqualTo: [])
        .snapshots()
        .asyncMap((snapshot) async {
          return _getNotesFromStream(snapshot);
        });
  }

  Stream<List<Note>> getNotesSharedWith(String userId) {
    return _notes
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      return _getNotesFromStream(snapshot);
    });
  }

  Future<List<Note>> _getNotesFromStream(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    return Future.wait(
      snapshot.docs.map((doc) async {
        final content = await _encryption.decrypt(doc['content']);
        final data = doc.data()..['content'] = content;
        return Note.fromMap(doc.id, data);
      }),
    );
  }

  Future<void> saveNote(
      {String? noteId,
      required String userId,
      required String title,
      required String content,
      List<String> sharedUsers = const []}) async {
    final encryptedContent = await _encryption.encrypt(content);
    if (noteId != null) {
      await _notes.doc(noteId).set({
        'title': title,
        'content': encryptedContent,
        'lastModified': Timestamp.now(),
        'sharedWith': sharedUsers,
      }, SetOptions(merge: true));
    } else {
      await _notes.add({
        'title': title,
        'content': encryptedContent,
        'createdAt': Timestamp.now(),
        'lastModified': Timestamp.now(),
        'userId': userId,
        'sharedWith': sharedUsers,
      });
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _notes.doc(noteId).delete();
  }

  Future<Note?> getNote(String noteId) async {
    final doc = await _notes.doc(noteId).get();
    if (doc.data() == null) return null;
    final content = await _encryption.decrypt(doc.data()!['content']);
    final data = doc.data()!..['content'] = content;
    return Note.fromMap(
      doc.id,
      data,
    );
  }

  Stream<Map<String, int>> getNoteCountsStream(String userId) {
    final controller = StreamController<Map<String, int>>();

    // Initialize counts
    Map<String, int> counts = {
      'totalNotes': 0,
      'sharedByUser': 0,
      'sharedWithUser': 0,
    };

    // 1. Total Notes Query
    final totalNotesSub = _notes
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      counts['totalNotes'] = snapshot.size;
      controller.add(Map.from(counts));
    });

    // 2. Notes Shared By User Query
    final sharedByUserSub = _notes
        .where('userId', isEqualTo: userId)
        .where('sharedWith', isNotEqualTo: [])
        .snapshots()
        .listen((snapshot) {
          counts['sharedByUser'] = snapshot.size;
          controller.add(Map.from(counts));
        });

    // 3. Notes Shared With User Query
    final sharedWithUserSub = _notes
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      counts['sharedWithUser'] = snapshot.size;
      controller.add(Map.from(counts));
    });

    // Cleanup
    controller.onCancel = () {
      totalNotesSub.cancel();
      sharedByUserSub.cancel();
      sharedWithUserSub.cancel();
    };

    return controller.stream;
  }
}
