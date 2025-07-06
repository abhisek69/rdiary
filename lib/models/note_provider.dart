import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => [..._notes];

  void addNote(Note note) {
    _notes.insert(0, note); // add to top
    notifyListeners(); // tells UI to update
  }


  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }
  Future<void> deleteNote(String noteId) async {
    // Remove from Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      // Remove from the local list
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      print('Error deleting note: $e');
    }
  }
}
