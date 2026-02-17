import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'addSubject/addSubject.dart';
import 'package:scribble/scribble.dart';

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

    final doc =
        await FirebaseFirestore.instance
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Diary Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
              );
              await _refreshNoteFromFirestore();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      if (currentNote.title != null &&
                          currentNote.title!.isNotEmpty)
                        Text(
                          currentNote.title!,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      const SizedBox(height: 10),

                      /// Date + Mood
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(currentNote.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          if (currentNote.mood != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentNote.mood!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const Divider(height: 30, thickness: 1),

                      /// Content
                      Text(
                        currentNote.content,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      /// 🔥 Drawings Section
                      if (currentNote.drawingPaths != null &&
                          currentNote.drawingPaths!.isNotEmpty) ...[
                        const SizedBox(height: 20),

                        Text("Drawings", style: theme.textTheme.titleMedium),

                        const SizedBox(height: 12),

                        ...currentNote.drawingPaths!.map((path) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(path),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ],

                      /// Optional Image
                      if (currentNote.imagePath != null) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(currentNote.imagePath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
