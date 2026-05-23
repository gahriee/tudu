import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;

  // Real-time stream — all notes for a user, newest first
  Stream<List<Note>> notesStream(String userId) {
    return _db
      .collection('notes')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final notes = snapshot.docs
          .map((doc) => Note.fromMap(doc.id, doc.data()))
          .toList();
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return notes;
      });
  }

  Future<void> createNote(Note note) {
    return _db.collection('notes').add(note.toMap());
  }

  Future<void> saveNote(Note note) {
    return _db.collection('notes').doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) {
    return _db.collection('notes').doc(noteId).delete();
  }
}
