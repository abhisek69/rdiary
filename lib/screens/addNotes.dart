// AddNoteScreen.dart (fixed version)
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/note_provider.dart';
import '../models/firebaseHelper.dart';
import '../utils/loading_helper.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote;
  final DateTime? selectedDate;

  const AddNoteScreen({super.key, this.existingNote, this.selectedDate});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  File? _selectedImage;
  List<String> _drawingPaths = [];

  final List<Map<String, String>> moods = [
    {'label': '😊', 'value': 'Happy'},
    {'label': '😭', 'value': 'Sad'},
    {'label': '😡', 'value': 'Angry'},
    {'label': '🥱', 'value': 'Tired'},
    {'label': '🤩', 'value': 'Excited'},
    {'label': '😐', 'value': 'Neutral'},
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    if (note != null) {
      _titleController.text = note.title ?? '';
      _contentController.text = note.content;
      _selectedDate = note.date;
      _selectedMood = note.mood;
      if (note.imagePath != null) _selectedImage = File(note.imagePath!);
      _drawingPaths = List.from(note.drawingPaths ?? []);
    } else {
      _selectedDate = widget.selectedDate ?? DateTime.now();
    }
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty && _drawingPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Note can't be empty!"),
          backgroundColor: Colors.red.shade900,
        ),
      );
      return;
    }

    showLoadingScreen(context, message: "Saving your note...");

    try {
      final noteId = widget.existingNote?.id ?? const Uuid().v4();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? imageUrl;
      List<String> drawingUrls = [];

      if (_selectedImage != null) {
        imageUrl = await uploadFileToFirebase(
          _selectedImage!,
          'notes/${user.uid}/$noteId/image.jpg',
        );
      }

      for (int i = 0; i < _drawingPaths.length; i++) {
        final file = File(_drawingPaths[i]);
        final url = await uploadFileToFirebase(
          file,
          'notes/${user.uid}/$noteId/drawing_$i.png',
        );
        if (url != null) drawingUrls.add(url);
      }

      final newNote = Note(
        id: noteId,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        content: _contentController.text,
        date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
        imagePath: imageUrl,
        drawingPaths: drawingUrls,
        mood: _selectedMood,
      );

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      if (widget.existingNote == null) {
        noteProvider.addNote(newNote);
      } else {
        noteProvider.updateNote(newNote);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .set({
        'id': newNote.id,
        'title': newNote.title,
        'content': newNote.content,
        'date': Timestamp.fromDate(newNote.date),
        'imagePath': imageUrl,
        'drawingPaths': drawingUrls,
        'mood': newNote.mood,
        'uid': user.uid,
      });

      hideLoadingScreen(context);
      Get.offAllNamed('/home', arguments: _selectedDate);
    } catch (e) {
      hideLoadingScreen(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving note: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote != null ? 'Edit Note' : 'New Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: "Save Note",
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDate(),
            const SizedBox(height: 10),
            _buildMoodSelector(),
            const SizedBox(height: 20),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDate() => Align(
    alignment: Alignment.centerRight,
    child: Text(
      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
      style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildMoodSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("How are you feeling today?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: moods.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final mood = moods[i];
            final isSelected = _selectedMood == mood['value'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood['value']),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Text(mood['label']!, style: const TextStyle(fontSize: 24)),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 60),
                        child: Text(
                          mood['value']!,
                          style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildTitleField() => TextField(
    controller: _titleController,
    decoration: const InputDecoration(labelText: 'Title (Optional)', border: OutlineInputBorder()),
  );

  Widget _buildContentField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Your Thoughts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: _contentController,
        decoration: const InputDecoration(hintText: 'Write your thoughts... ✍️', border: OutlineInputBorder()),
        maxLines: null,
        minLines: 8,
        keyboardType: TextInputType.multiline,
      ),
    ],
  );

  Widget _buildSubmitButton() => ElevatedButton.icon(
    onPressed: _saveNote,
    icon: const Icon(Icons.save),
    label: const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Text("Submit Note", style: TextStyle(fontSize: 16, color: Colors.white)),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
