import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteViewModel extends ChangeNotifier {
  final _service = NoteService();

  List<Note> _notes = [];
  bool isLoading = false;
  String? error;

  String? _currentUserId;
  StreamSubscription? _notesSub;

  List<Note> get notes => _notes;

  void listen(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    
    _notesSub?.cancel();
    
    Future.microtask(() {
      isLoading = true;
      notifyListeners();
    });

    _notesSub = _service.notesStream(userId).listen((notes) {
      _notes    = notes;
      isLoading = false;
      error     = null;
      notifyListeners();
    }, onError: (e) {
      isLoading = false;
      error     = e.toString();
      notifyListeners();
    });
  }

  void clear() {
    _currentUserId = null;
    _notesSub?.cancel();
    _notes.clear();
  }

  Future<void> createNote(String userId, String title, String body) {
    final now  = DateTime.now();
    final note = Note(
      id:        '',               // Firestore assigns the ID
      userId:    userId,
      title:     title.trim(),
      body:      body.trim(),
      createdAt: now,
      updatedAt: now,
    );
    return _service.createNote(note);
  }

  Future<void> saveNote(Note note) => _service.saveNote(note);

  Future<void> deleteNote(String noteId) => _service.deleteNote(noteId);
}
