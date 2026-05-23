import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id:        id,
      userId:    map['userId']    as String,
      title:     map['title']     as String,
      body:      map['body']      as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':    userId,
    'title':     title,
    'body':      body,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Note copyWith({String? title, String? body}) {
    return Note(
      id:        id,
      userId:    userId,
      title:     title     ?? this.title,
      body:      body      ?? this.body,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
