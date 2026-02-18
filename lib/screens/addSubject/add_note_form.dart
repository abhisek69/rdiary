import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rdiary/screens/addSubject/scribble_canvas_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../widgets/mood_selector.dart';

class AddNoteForm extends StatefulWidget {
  final DateTime? selectedDate;

  const AddNoteForm({super.key, this.selectedDate});

  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  Map<String, dynamic>? _drawingData;


  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty &&
        _drawingData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Note can't be empty!"),
          backgroundColor:
          Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = const Uuid().v4();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(id)
          .set({
        'title': _titleController.text.isEmpty
            ? null
            : _titleController.text,
        'content': _contentController.text,
        'date': Timestamp.fromDate(
          DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          ),
        ),
        'mood': _selectedMood ?? "neutral",
        'drawingData': _drawingData,
        'createdAt': Timestamp.now(),
      });

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving note: $e"),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 📅 Date Display
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 😊 Mood Selector
          const Text(
            "How are you feeling today?",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          MoodSelector(
            selectedMoodId: _selectedMood,
            onSelected: (moodId) {
              setState(() {
                _selectedMood = moodId;
              });
            },
          ),

          const SizedBox(height: 20),
          // ScribbleCanvasWidget(
          //   initialDrawing: null,
          //   onChanged: (data) {
          //     _drawingData = data;
          //   },
          // ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title (Optional)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // ✍️ Content
          const Text(
            "Your Thoughts",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _contentController,
            maxLines: null,
            minLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your thoughts... ✍️',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          // 💾 Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding:
                EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Save Note",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
