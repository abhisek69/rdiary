import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'addSubject/addSubject.dart';
import '../widgets/full_screen_viewer.dart';

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
    _loadMedia();
  }

  void _loadMedia() {
    debugPrint('[RDIARY][MEDIA][FETCH] Loading media for note');
    debugPrint('noteId: ${currentNote.id}');
    debugPrint('[RDIARY][MEDIA][FETCH] Photos found: ${currentNote.drawingPaths?.length ?? 0}');
    debugPrint('[RDIARY][MEDIA][FETCH] Drawings found: ${currentNote.drawingPreviewUrl != null ? 1 : 0}');
    debugPrint('[RDIARY][MEDIA][FETCH] Media loading COMPLETE');
  }

  Future<void> _refreshNoteFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    debugPrint('[RDIARY][FIRESTORE] Loading note...');
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(currentNote.id)
            .get();

    if (doc.exists) {
      debugPrint('[RDIARY][FIRESTORE] Note loaded SUCCESS');
      setState(() {
        currentNote = Note.fromFirestore(doc.data()!, doc.id);
      });
      _loadMedia();
    }

    setState(() => isLoading = false);
  }

  Widget _buildImage(String path, {bool isDrawing = false}) {
    final bool isNetwork = path.startsWith('http');
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenViewer(
            pathOrUrl: path,
            title: isDrawing ? 'Drawing' : 'Photo',
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isNetwork
            ? Image.network(
                path,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    debugPrint('[RDIARY][SUPABASE][FETCH] ${isDrawing ? "Drawing" : "Photo"} loaded');
                    return child;
                  }
                  return Container(
                    height: 200,
                    color: Colors.grey.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('[RDIARY][SUPABASE][FETCH] Media load FAILED: $path');
                  return Container(
                    height: 100,
                    color: Colors.grey.withOpacity(0.1),
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  );
                },
              )
            : Image.file(
                File(path),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AddSubjectScreen(
                        selectedDate: currentNote.date,
                        existingNote: currentNote,
                      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                        if (currentNote.title != null && currentNote.title!.isNotEmpty)
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
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            if (currentNote.mood != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentNote.mood!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
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
                      ],
                    ),
                  ),

                  /// 🔥 Media Section (Drawings & Photos)
                  if (currentNote.drawingPreviewUrl != null || 
                      (currentNote.drawingPaths != null && currentNote.drawingPaths!.isNotEmpty)) ...[
                    const SizedBox(height: 24),
                    Text(
                      "Attachments",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Display Drawing as a compact attachment card
                    if (currentNote.drawingPreviewUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Digital Sketch",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: _buildImage(currentNote.drawingPreviewUrl!, isDrawing: true),
                            ),
                          ],
                        ),
                      ),

                    // Display Photos in a clean grid or list
                    if (currentNote.drawingPaths != null && currentNote.drawingPaths!.isNotEmpty)
                      ...currentNote.drawingPaths!.where((path) => path != currentNote.drawingPreviewUrl).map((path) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Memory Photo",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              _buildImage(path),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ],
              ),
            ),
    );
  }
}
