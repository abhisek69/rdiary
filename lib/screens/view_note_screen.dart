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
        currentNote = Note.fromFirestore(doc.data()!, doc.id);
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Diary Note'),
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
              await _refreshNoteFromFirestore();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentNote.title != null && currentNote.title!.isNotEmpty)
                Text(
                  currentNote.title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(currentNote.date),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (currentNote.mood != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentNote.mood!,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                ],
              ),

              const Divider(height: 30, thickness: 1),
              Text(
                currentNote.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),


              const SizedBox(height: 20),

              if (currentNote.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(currentNote.imagePath!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              if (currentNote.drawingPaths!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text("Drawings:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 10),
                ...currentNote.drawingPaths!.map((path) {
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
                }),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
