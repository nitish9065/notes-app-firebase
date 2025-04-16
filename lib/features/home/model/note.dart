// models/note.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime lastModified;
  final String userId;
  final List<String> sharedWith;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastModified,
    required this.userId,
    this.sharedWith = const [],
  });

  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastModified: (data['lastModified'] as Timestamp).toDate(),
      userId: data['userId'],
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastModified': Timestamp.fromDate(lastModified),
        'userId': userId,
        'sharedWith': sharedWith,
      };
}
