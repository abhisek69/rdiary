import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rdiary/screens/addNotes.dart';
import '../models/note.dart';

class ViewNoteScreen extends StatefulWidget {
  final Note note;
  const ViewNoteScreen({super.key, required this.note});

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late Note currentNote;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentNote = widget.note;
  }

  Future<void> _refreshNoteFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(currentNote.id)
        .get();

    if (doc.exists) {
      setState(() {
        currentNote = Note.fromFirestore(doc.data()!,doc.id);
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Note',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNoteScreen(existingNote: currentNote),
                ),
              );
              // After editing, refresh the note data
              await _refreshNoteFromFirestore();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentNote.mood != null)
              Row(
                children: [
                  const Text("Mood: ",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(currentNote.mood!,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              DateFormat.yMMMMd().format(currentNote.date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (currentNote.title != null)
              Text(currentNote.title!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              currentNote.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (currentNote.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(currentNote.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            if (currentNote.drawingPaths!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentNote.drawingPaths!.map((path) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
