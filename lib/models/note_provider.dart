import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note.dart';
import 'supabase_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => [..._notes];

  void addNote(Note note) {
    _notes.insert(0, note); // add to top
    notifyListeners(); // tells UI to update
  }

  updateNote(Note updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      debugPrint('[RDIARY][MEDIA] Starting note deletion. noteId: $noteId');
      
      // 1. Fetch note to get media URLs
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists) {
        final noteData = doc.data()!;
        final drawingPaths = List<String>.from(noteData['drawingPaths'] ?? []);
        final previewUrl = noteData['drawingPreviewUrl'] as String?;

        // 2. Delete files from Supabase
        if (drawingPaths.isNotEmpty || previewUrl != null) {
          debugPrint('[RDIARY][SUPABASE][DELETE] Starting media cleanup for note');
          for (final url in drawingPaths) {
            await SupabaseHelper.deleteFile(url);
          }
          if (previewUrl != null) {
            await SupabaseHelper.deleteFile(previewUrl);
          }
        }
      }

      // 3. Delete from Firestore
      debugPrint('[RDIARY][FIRESTORE] Removing note document...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      debugPrint('[RDIARY][FIRESTORE] Note document removed SUCCESS');
      debugPrint('[RDIARY][MEDIA] Note deletion COMPLETE');

      // Remove from the local list
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners(); 
    } catch (e) {
      debugPrint('[RDIARY][MEDIA] Note deletion FAILED');
      debugPrint('error: $e');
    }
  }
}
